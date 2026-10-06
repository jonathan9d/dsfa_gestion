import 'dart:io';
import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:excel/excel.dart';
import 'package:xml/xml.dart';

import '../data/database/database.dart';
import '../data/repositories/activite_repository.dart';
import '../data/repositories/controle_pj_repository.dart';
import '../data/repositories/finance_repository.dart';
import '../data/repositories/participant_repository.dart';
import '../data/repositories/presence_repository.dart';
import '../data/repositories/referentiel_repository.dart';
import '../domain/models.dart';
import '../domain/regles_parametres.dart';
import '../domain/services/regles_metier.dart';

/// Stratégie de gestion des doublons à l'import.
enum StrategieDoublon { ignorer, remplacer }

/// Aperçu d'import : comptage par feuille + lignes en erreur.
class ApercuImport {
  ApercuImport({
    required this.aCompter,
    required this.erreurs,
    required this.details,
  });

  /// Nombre de lignes exploitables détectées par feuille.
  final Map<String, int> aCompter;

  /// Nombre d'erreurs de validation par feuille.
  final Map<String, int> erreurs;

  final List<LigneImport> details;

  bool get peutImporter => aCompter.values.any((v) => v > 0);
}

/// Service d'import du classeur Excel de référence.
///
/// Flux : Excel → analyse → mapping → validation → aperçu → confirmation →
/// SQLite. Les données existantes ne sont jamais écrasées silencieusement.
class ExcelImportService {
  ExcelImportService({
    required AppDatabase db,
    required ActivitesRepository activites,
    required LignesBudgetRepository lignesBudget,
    required ParticipantsRepository participants,
    required ActiviteParticipantsRepository activiteParticipants,
    required PresencesRepository presences,
    required ControlesPJRepository controles,
    required DepensesRepository depenses,
    required BanqueRepository banque,
    required ReleveBancaireRepository releve,
    required DistrictsRepository districts,
    required TarifsRepository tarifs,
    required ListesRepository listes,
  }) : _db = db,
       _activites = activites,
       _lignesBudget = lignesBudget,
       _participants = participants,
       _activiteParticipants = activiteParticipants,
       _presences = presences,
       _controles = controles,
       _depenses = depenses,
       _banque = banque,
       _releve = releve,
       _districts = districts,
       _tarifs = tarifs,
       _listes = listes;

  final AppDatabase _db;
  final ActivitesRepository _activites;
  final LignesBudgetRepository _lignesBudget;
  final ParticipantsRepository _participants;
  final ActiviteParticipantsRepository _activiteParticipants;
  final PresencesRepository _presences;
  final ControlesPJRepository _controles;
  final DepensesRepository _depenses;
  final BanqueRepository _banque;
  final ReleveBancaireRepository _releve;
  final DistrictsRepository _districts;
  final TarifsRepository _tarifs;
  final ListesRepository _listes;

  Excel? _classeur;

  /// Charge le classeur depuis un fichier.
  void charger(File fichier) {
    final bytes = fichier.readAsBytesSync();
    _classeur = Excel.decodeBytes(bytes);
  }

  void chargerOctets(List<int> bytes) {
    _classeur = Excel.decodeBytes(_normaliserIdentifiantsFormats(bytes));
  }

  static List<int> _normaliserIdentifiantsFormats(List<int> bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final styles = archive.findFile('xl/styles.xml');
    if (styles == null) return bytes;

    final document = XmlDocument.parse(
      utf8.decode(styles.content as List<int>),
    );
    final formats = document.findAllElements('numFmt').toList();
    final idsExistants = formats
        .map((format) => int.parse(format.getAttribute('numFmtId')!))
        .where((id) => id >= 164)
        .toSet();
    var prochainId = idsExistants.isEmpty
        ? 164
        : idsExistants.reduce((a, b) => a > b ? a : b) + 1;
    final remplacements = <int, int>{};

    for (final format in formats) {
      final id = int.parse(format.getAttribute('numFmtId')!);
      if (id == 0 && format.getAttribute('formatCode') == 'General') {
        format.parent?.children.remove(format);
        continue;
      }
      if (id >= 164) continue;
      final remplacePar = remplacements.putIfAbsent(id, () {
        while (idsExistants.contains(prochainId)) {
          prochainId++;
        }
        idsExistants.add(prochainId);
        return prochainId++;
      });
      format.setAttribute('numFmtId', '$remplacePar');
    }

    if (remplacements.isEmpty) return bytes;
    for (final format in document.findAllElements('xf')) {
      final id = int.tryParse(format.getAttribute('numFmtId') ?? '');
      final remplacePar = id == null ? null : remplacements[id];
      if (remplacePar != null) {
        format.setAttribute('numFmtId', '$remplacePar');
      }
    }

    final index = archive.files.indexOf(styles);
    archive[index] = ArchiveFile.string(styles.name, document.toXmlString());
    return ZipEncoder().encode(archive) ?? bytes;
  }

  Sheet? _feuille(String nom) {
    if (_classeur == null) return null;
    for (final s in _classeur!.tables.keys) {
      if (s.trim().toUpperCase() == nom.trim().toUpperCase()) {
        return _classeur!.tables[s];
      }
    }
    return null;
  }

  /// Analyse le classeur et produit un aperçu sans écrire en base.
  ApercuImport analyser() {
    final aCompter = <String, int>{};
    final erreurs = <String, int>{};
    final details = <LigneImport>[];

    void compter(String feuille, int n) {
      aCompter[feuille] = (aCompter[feuille] ?? 0) + n;
    }

    void erreur(String feuille, int ligne, String message) {
      erreurs[feuille] = (erreurs[feuille] ?? 0) + 1;
      details.add(
        LigneImport(
          feuille: feuille,
          ligne: ligne,
          message: message,
          estErreur: true,
        ),
      );
    }

    // --- DISTANCES_DISTRICTS ---
    final d = _feuille('DISTANCES_DISTRICTS');
    if (d != null) {
      var n = 0;
      for (var i = 1; i < d.maxRows; i++) {
        final row = d.row(i);
        final district = _txt(row, 3);
        final region = _txt(row, 2);
        if (district.isEmpty || region.isEmpty) continue;
        if (district.toUpperCase() == 'DISTRICT') continue;
        compter('DISTANCES_DISTRICTS', 1);
        n++;
        if (_num(row, 5) == null) {
          erreur('DISTANCES_DISTRICTS', i + 1, 'Distance aller manquante');
        }
      }
      if (n > 0) aCompter['DISTANCES_DISTRICTS'] = n;
    }

    // --- REFERENTIEL_TARIFS ---
    final t = _feuille('REFERENTIEL_TARIFS');
    if (t != null) {
      var n = 0;
      for (var i = 1; i < t.maxRows; i++) {
        final row = t.row(i);
        final ligne = _txt(row, 1);
        if (ligne.isEmpty) continue;
        n++;
        if (_num(row, 5) == null) {
          details.add(
            LigneImport(
              feuille: 'REFERENTIEL_TARIFS',
              ligne: i + 1,
              message: 'Tarif vide pour « $ligne » (sera importé à 0)',
              estErreur: false,
            ),
          );
        }
      }
      aCompter['REFERENTIEL_TARIFS'] = n;
    }

    // --- LISTES ---
    final l = _feuille('LISTES');
    if (l != null) {
      var n = 0;
      final colonnes = _colonnesListes(l);
      for (final c in colonnes.keys) {
        for (var i = 1; i < l.maxRows; i++) {
          if (_txt(l.row(i), c).isNotEmpty) n++;
        }
      }
      aCompter['LISTES'] = n;
    }

    // --- LISTES ACTIVITES ---
    final la = _feuille('LISTES ACTIVITES');
    if (la != null) {
      var n = 0;
      for (var i = 1; i < la.maxRows; i++) {
        final row = la.row(i);
        final code = _txt(row, 0);
        if (code.isEmpty) continue;
        n++;
        if (code.toUpperCase() == 'RÉFÉRENCE ACTIVITÉ') continue;
      }
      aCompter['LISTES ACTIVITES'] = n;
    }

    // --- REFERENTIEL_BUDGET ---
    final rb = _feuille('REFERENTIEL_BUDGET');
    if (rb != null) {
      var n = 0;
      for (var i = 1; i < rb.maxRows; i++) {
        final row = rb.row(i);
        final code = _txt(row, 0);
        final ligne = _txt(row, 4);
        if (code.isEmpty || ligne.isEmpty) continue;
        n++;
        final q = _num(row, 6) ?? 0;
        final taux = _num(row, 8) ?? 0;
        if (q <= 0 || taux <= 0) {
          details.add(
            LigneImport(
              feuille: 'REFERENTIEL_BUDGET',
              ligne: i + 1,
              message: 'Quantité ou taux non renseigné pour « $code »',
              estErreur: false,
            ),
          );
        }
      }
      aCompter['REFERENTIEL_BUDGET'] = n;
    }

    // --- CONTROLE_PJ ---
    final cp = _feuille('CONTROLE_PJ');
    if (cp != null) {
      var n = 0;
      for (var i = 1; i < cp.maxRows; i++) {
        final row = cp.row(i);
        final code = _txt(row, 1);
        final benef = _txt(row, 7);
        if (code.isEmpty && benef.isEmpty) continue;
        n++;
        if (_date(row, 5) == null && _num(row, 9) != null) {
          details.add(
            LigneImport(
              feuille: 'CONTROLE_PJ',
              ligne: i + 1,
              message: 'Date PJ invalide ou absente',
              estErreur: false,
            ),
          );
        }
      }
      aCompter['CONTROLE_PJ'] = n;
    }

    // --- PRESENCES_INDEMNITES ---
    final pi = _feuille('PRESENCES_INDEMNITES');
    if (pi != null) {
      var n = 0;
      for (var i = 1; i < pi.maxRows; i++) {
        final row = pi.row(i);
        final code = _txt(row, 1);
        final participant = _txt(row, 2);
        if (code.isEmpty || participant.isEmpty) continue;
        n++;
        if (_date(row, 4) == null) {
          erreur('PRESENCES_INDEMNITES', i + 1, 'Date d\'activité invalide');
        }
      }
      aCompter['PRESENCES_INDEMNITES'] = n;
    }

    // --- J.Depenses ---
    final jd = _feuille('J.Depenses');
    if (jd != null) {
      var n = 0;
      for (var i = 3; i < jd.maxRows; i++) {
        final row = jd.row(i);
        final designation = _txt(row, 9);
        if (designation.isEmpty) continue;
        if (designation.toUpperCase().contains('DÉSIGNATION') ||
            designation.toUpperCase().contains('DESIGNATION')) {
          continue;
        }
        n++;
        final montant =
            (_num(row, 11) ?? 0) *
            (_num(row, 12) ?? 0) *
            (_num(row, 13) ?? 1) *
            (_num(row, 14) ?? 0);
        if (montant <= 0) {
          details.add(
            LigneImport(
              feuille: 'J.Depenses',
              ligne: i + 1,
              message: 'Montant calculé nul pour « $designation »',
              estErreur: false,
            ),
          );
        }
      }
      aCompter['J.Depenses'] = n;
    }

    // --- J.Banque ---
    final jb = _feuille('J.Banque');
    if (jb != null) {
      var n = 0;
      for (var i = 5; i < jb.maxRows; i++) {
        final row = jb.row(i);
        final description = _txt(row, 4);
        final date = _date(row, 0);
        if (description.isEmpty && date == null) continue;
        if (description.toUpperCase() == 'DESCRIPTION') continue;
        n++;
      }
      aCompter['J.Banque'] = n;
    }

    return ApercuImport(aCompter: aCompter, erreurs: erreurs, details: details);
  }

  /// Exécute l'import en base selon la stratégie de doublons.
  Future<RapportImport> importer({
    StrategieDoublon strategie = StrategieDoublon.ignorer,
  }) async {
    final importees = <String, int>{};
    final ignorees = <String, int>{};
    final details = <LigneImport>[];

    await _db.transaction(
      () => _importerDansTransaction(importees, ignorees, details, strategie),
    );

    return RapportImport(
      lignesImportees: importees,
      lignesIgnorees: ignorees,
      details: details,
    );
  }

  /// Réinitialisation complète de l'application : efface toutes les données
  /// locales (y compris les comptes utilisateurs et les paramètres) puis
  /// recharge le classeur de référence embarqué. L'application redémarre
  /// comme au premier lancement (écran de création du compte).
  Future<RapportImport> reinitialiserApplication() async {
    final importees = <String, int>{};
    final ignorees = <String, int>{};
    final details = <LigneImport>[];
    await _db.transaction(() async {
      await _db.delete(_db.presences).go();
      await _db.delete(_db.activiteParticipants).go();
      await _db.delete(_db.lignesBudget).go();
      await _db.delete(_db.controlesPJ).go();
      await _db.delete(_db.depenses).go();
      await _db.delete(_db.banqueOperations).go();
      await _db.delete(_db.releveBancaire).go();
      await _db.delete(_db.activites).go();
      await _db.delete(_db.participants).go();
      await _db.delete(_db.districts).go();
      await _db.delete(_db.referentielTarifs).go();
      await _db.delete(_db.referenceValeurs).go();
      await _db.delete(_db.journalAudit).go();
      await _db.delete(_db.utilisateurs).go();
      await _db.delete(_db.parametres).go();
      await _importerDansTransaction(
        importees,
        ignorees,
        details,
        StrategieDoublon.remplacer,
      );
    });
    return RapportImport(
      lignesImportees: importees,
      lignesIgnorees: ignorees,
      details: details,
    );
  }

  Future<RapportImport> reinitialiserDepuisClasseur() async {
    final importees = <String, int>{};
    final ignorees = <String, int>{};
    final details = <LigneImport>[];
    await _db.transaction(() async {
      await _db.delete(_db.presences).go();
      await _db.delete(_db.activiteParticipants).go();
      await _db.delete(_db.lignesBudget).go();
      await _db.delete(_db.controlesPJ).go();
      await _db.delete(_db.depenses).go();
      await _db.delete(_db.banqueOperations).go();
      await _db.delete(_db.releveBancaire).go();
      await _db.delete(_db.activites).go();
      await _db.delete(_db.participants).go();
      await _db.delete(_db.districts).go();
      await _db.delete(_db.referentielTarifs).go();
      await _db.delete(_db.referenceValeurs).go();
      await _db.delete(_db.parametres).go();
      await _importerDansTransaction(
        importees,
        ignorees,
        details,
        StrategieDoublon.remplacer,
      );
    });
    return RapportImport(
      lignesImportees: importees,
      lignesIgnorees: ignorees,
      details: details,
    );
  }

  Future<void> _importerDansTransaction(
    Map<String, int> importees,
    Map<String, int> ignorees,
    List<LigneImport> details,
    StrategieDoublon strategie,
  ) async {
    final ok = importees;
    final ko = ignorees;
    await _importerDistricts(ok, ko, details, strategie);
    await _importerTarifs(ok, ko, details, strategie);
    await _importerListes(ok, ko, details, strategie);
    await _importerActivites(ok, ko, details, strategie);
    await _importerReferentielBudget(ok, ko, details, strategie);
    await _importerParticipantsPresences(ok, ko, details, strategie);
    await _importerControlePJ(ok, ko, details, strategie);
    await _importerDepenses(ok, ko, details, strategie);
    await _importerBanque(ok, ko, details, strategie);
    await _importerReleveBancaire(ok, ko, details);
    await _importerParametres(ok, ko);
  }

  /// Clé de stockage des règles consolidées de la feuille `PARAMETRES`.
  static const cleParametres = 'regles_parametres';

  /// Parse et enregistre la feuille `PARAMETRES` (règles, taux, seuils et
  /// matrice des PJ) sans toucher au reste des données. Idempotent : peut être
  /// appelé à chaque démarrage pour rafraîchir les règles de référence.
  Future<void> importerParametres() async {
    final ok = <String, int>{};
    final ko = <String, int>{};
    await _importerParametres(ok, ko);
  }

  /// Lit la feuille `PARAMETRES` et l'enregistre en JSON dans la table
  /// clé/valeur. Les sections sont localisées par leurs intitulés afin de
  /// rester valables si le classeur évolue.
  Future<void> _importerParametres(
    Map<String, int> ok,
    Map<String, int> ko,
  ) async {
    const feuille = 'PARAMETRES';
    final sheet = _feuille(feuille);
    if (sheet == null) return;
    final regles = _lireParametres(sheet);
    if (regles.estVide) return;
    await _db
        .into(_db.parametres)
        .insertOnConflictUpdate(
          ParametresCompanion.insert(
            cle: cleParametres,
            valeur: Value(jsonEncode(regles.toJson())),
          ),
        );
    ok[feuille] =
        (ok[feuille] ?? 0) +
        regles.tauxIndemnites.length +
        regles.consommationCarburant.length +
        regles.transferts.length +
        regles.forfaitaires.length +
        regles.matricePJ.length;
  }

  ReglesParametres _lireParametres(Sheet sheet) {
    final tauxIndemnites = <String, double>{};
    final carburant = <String, double>{};
    final transferts = <String, double>{};
    final forfaitaires = <String, double>{};
    final seuils = <String, int>{};
    final sources = <String>[];
    final matrice = <ReglePJRequise>[];

    int? idxIndemnite;
    int? idxCarburant;
    int? idxTransfert;
    int? idxForfaitaire;
    int? idxRapportage;
    int? idxFinancement;
    int? idxMatrice;

    for (var i = 0; i < sheet.maxRows; i++) {
      final row = sheet.row(i);
      final a = _normaliserEntete(_txt(row, 0));
      final d = _normaliserEntete(_txt(row, 3));
      final g = _normaliserEntete(_txt(row, 6));
      if (a.startsWith('1 INDEMNIT')) idxIndemnite = i;
      if (a.startsWith('2 CARBURANT')) idxCarburant = i;
      if (d.startsWith('3 DEPLACEMENT')) idxTransfert = i;
      if (d.startsWith('4 DEPLACEMENT')) idxForfaitaire = i;
      if (g.startsWith('5 REGLES')) idxRapportage = i;
      if (g.startsWith('6 SOURCE')) idxFinancement = i;
      if (a.startsWith('5 MATRICE')) idxMatrice = i;
    }

    // 1. Indemnités : libellé en colonne A, taux en colonne B.
    if (idxIndemnite != null) {
      for (var i = idxIndemnite + 1; i < sheet.maxRows; i++) {
        if (i == idxCarburant) break;
        final row = sheet.row(i);
        final label = _txt(row, 0);
        if (label.isEmpty) break;
        final valeur = _num(row, 1);
        if (valeur != null) tauxIndemnites[label] = valeur;
      }
    }

    // 2. Carburant : véhicule en A, consommation/km en B.
    if (idxCarburant != null) {
      for (var i = idxCarburant + 1; i < sheet.maxRows; i++) {
        if (i == idxMatrice) break;
        final row = sheet.row(i);
        final label = _txt(row, 0);
        if (label.isEmpty) continue;
        final valeur = _num(row, 1);
        if (valeur != null) carburant[label] = valeur;
      }
    }

    // 3. Transfert aéroport : libellé en D, tarif en E.
    if (idxTransfert != null) {
      for (var i = idxTransfert + 1; i < sheet.maxRows; i++) {
        if (i == idxForfaitaire) break;
        final row = sheet.row(i);
        final label = _txt(row, 3);
        if (label.isEmpty) continue;
        final valeur = _num(row, 4);
        if (valeur != null) transferts[label] = valeur;
      }
    }

    // 4. Déplacement forfaitaire.
    if (idxForfaitaire != null) {
      for (var i = idxForfaitaire + 1; i < sheet.maxRows; i++) {
        final row = sheet.row(i);
        final label = _txt(row, 3);
        if (label.isEmpty) break;
        final valeur = _num(row, 4);
        if (valeur != null) forfaitaires[label] = valeur;
      }
    }

    // 5. Seuils de rapportage : libellé en G, jours en H.
    if (idxRapportage != null) {
      for (var i = idxRapportage + 1; i < sheet.maxRows; i++) {
        if (i == idxFinancement) break;
        final row = sheet.row(i);
        final label = _normaliserEntete(_txt(row, 6));
        final valeur = _num(row, 7);
        if (label.isEmpty || valeur == null) continue;
        if (label.contains('UNICEF') && label.contains('ATTENTION')) {
          seuils['UNICEF_ATTENTION'] = valeur.round();
        } else if (label.contains('UNICEF') && label.contains('BLOQU')) {
          seuils['UNICEF_BLOQUE'] = valeur.round();
        } else if (label.contains('AUTRES') && label.contains('ATTENTION')) {
          seuils['AUTRES_ATTENTION'] = valeur.round();
        } else if (label.contains('AUTRES') && label.contains('BLOQU')) {
          seuils['AUTRES_BLOQUE'] = valeur.round();
        }
      }
    }

    // 6. Sources de financement.
    if (idxFinancement != null) {
      for (var i = idxFinancement + 1; i < sheet.maxRows; i++) {
        final label = _txt(sheet.row(i), 6);
        if (label.isEmpty) break;
        sources.add(label);
      }
    }

    // 5. Matrice des PJ requises.
    if (idxMatrice != null) {
      for (var i = idxMatrice + 1; i < sheet.maxRows; i++) {
        final row = sheet.row(i);
        final rubrique = _txt(row, 0);
        final piece = _txt(row, 2);
        if (rubrique.isEmpty && piece.isEmpty) break;
        if (piece.isEmpty) continue;
        // Ignorer la ligne d'en-tête de la matrice.
        if (_normaliserEntete(piece) == 'PJ REQUISE') continue;
        matrice.add(
          ReglePJRequise(
            rubrique: rubrique,
            sousRubrique: _txt(row, 1),
            piece: piece,
            obligatoire: _txt(row, 3).toUpperCase() == 'OUI',
            regleDate: _txt(row, 4),
            typeControle: _txt(row, 5).isEmpty
                ? 'DATE'
                : _txt(row, 5),
            remarque: _txt(row, 6),
            actif: _txt(row, 7).toUpperCase() != 'NON',
          ),
        );
      }
    }

    return ReglesParametres(
      tauxIndemnites: tauxIndemnites,
      consommationCarburant: carburant,
      transferts: transferts,
      forfaitaires: forfaitaires,
      seuilsRapportage: seuils,
      sourcesFinancement: sources,
      matricePJ: matrice,
    );
  }

  Future<void> _importerReleveBancaire(
    Map<String, int> ok,
    Map<String, int> ko,
    List<LigneImport> details,
  ) async {
    const feuille = 'Rappr Banc';
    final sheet = _feuille(feuille);
    if (sheet == null) return;
    for (var i = 12; i < sheet.maxRows; i++) {
      final row = sheet.row(i);
      final date = _date(row, 6);
      final reference = _txt(row, 7);
      final libelle = _txt(row, 8);
      if (date == null && reference.isEmpty && libelle.isEmpty) continue;
      if (date == null) {
        ko[feuille] = (ko[feuille] ?? 0) + 1;
        details.add(
          LigneImport(
            feuille: feuille,
            ligne: i + 1,
            message: 'Mouvement de relevé ignoré : date absente ou invalide.',
            estErreur: true,
          ),
        );
        continue;
      }
      await _releve.insert(
        ReleveBancaireCompanion.insert(
          date: Value(date),
          reference: Value(reference),
          libelle: Value(libelle),
          debit: Value(_num(row, 9) ?? 0),
          credit: Value(_num(row, 10) ?? 0),
        ),
      );
      ok[feuille] = (ok[feuille] ?? 0) + 1;
    }
  }

  /*
   * The source workbook keeps the statement opening balance and outstanding
   * journal movements in reconciliation formulas. The current data model has
   * no fields for those values, so this import deliberately stores only the
   * dated statement movements that map directly to ReleveBancaire.
   */

  Future<void> _importerDistricts(
    Map<String, int> ok,
    Map<String, int> ko,
    List<LigneImport> details,
    StrategieDoublon strategie,
  ) async {
    const feuille = 'DISTANCES_DISTRICTS';
    final d = _feuille(feuille);
    if (d == null) return;
    for (var i = 1; i < d.maxRows; i++) {
      final row = d.row(i);
      final district = _txt(row, 3);
      final region = _txt(row, 2);
      if (district.isEmpty || region.isEmpty) continue;
      final chefLieu = _txt(row, 1);
      final existant = await _districts.parNom(district);
      if (existant != null && strategie == StrategieDoublon.ignorer) {
        ko[feuille] = (ko[feuille] ?? 0) + 1;
        continue;
      }
      final aller = _num(row, 5) ?? 0;
      final delaiAller = _num(row, 7) ?? 0;
      final delaiRetour = _num(row, 8) ?? 0;
      await _districts.upsert(
        DistrictsCompanion.insert(
          numero: Value(_int(row, 0)),
          chefLieuRegion: chefLieu,
          region: region,
          nom: district,
          estChefLieuRegion: Value(
            ReglesMetier.estChefLieuRegion(district, chefLieu),
          ),
          distanceAllerKm: Value(aller),
          distanceCarburantKm: Value(ReglesMetier.distanceCarburant(aller)),
          delaiRouteAller: Value(delaiAller),
          delaiRouteRetour: Value(delaiRetour),
          delaiRouteTotal: Value(
            ReglesMetier.delaiRouteTotal(delaiAller, delaiRetour),
          ),
        ),
      );
      ok[feuille] = (ok[feuille] ?? 0) + 1;
    }
  }

  Future<void> _importerTarifs(
    Map<String, int> ok,
    Map<String, int> ko,
    List<LigneImport> details,
    StrategieDoublon strategie,
  ) async {
    const feuille = 'REFERENTIEL_TARIFS';
    final t = _feuille(feuille);
    if (t == null) return;
    final existants = await _tarifs.getAll();
    for (var i = 1; i < t.maxRows; i++) {
      final row = t.row(i);
      final ligne = _txt(row, 1);
      if (ligne.isEmpty) continue;
      final rubrique = _txt(row, 0);
      final zone = _txt(row, 4).isEmpty ? 'Tous' : _txt(row, 4);
      final typeActivite = _txt(row, 2).isEmpty ? 'Tous' : _txt(row, 2);
      final deja = existants.any(
        (e) => e.ligneBudgetaire == ligne && e.zone == zone,
      );
      if (deja && strategie == StrategieDoublon.ignorer) {
        ko[feuille] = (ko[feuille] ?? 0) + 1;
        continue;
      }
      await _tarifs.insert(
        ReferentielTarifsCompanion.insert(
          rubrique: rubrique,
          ligneBudgetaire: ligne,
          typeActivite: Value(typeActivite),
          unite: Value(_txt(row, 3).isEmpty ? 'personne' : _txt(row, 3)),
          zone: Value(zone),
          tarif: Value(_num(row, 5) ?? 0),
          actif: Value(_txt(row, 6).toUpperCase() != 'NON'),
          observation: Value(_txt(row, 7)),
        ),
      );
      ok[feuille] = (ok[feuille] ?? 0) + 1;
    }
  }

  Future<void> _importerListes(
    Map<String, int> ok,
    Map<String, int> ko,
    List<LigneImport> details,
    StrategieDoublon strategie,
  ) async {
    const feuille = 'LISTES';
    final l = _feuille(feuille);
    if (l == null) return;
    final categories = _colonnesListes(l);
    final existants = await _listes.watchAll().first;
    final set = existants.map((e) => '${e.categorie}|${e.valeur}').toSet();
    for (final entry in categories.entries) {
      var ordre = 0;
      for (var i = 1; i < l.maxRows; i++) {
        final v = _txt(l.row(i), entry.key);
        if (v.isEmpty) continue;
        final cle = '${entry.value}|$v';
        if (set.contains(cle) && strategie == StrategieDoublon.ignorer) {
          ko[feuille] = (ko[feuille] ?? 0) + 1;
          continue;
        }
        if (!set.contains(cle)) {
          await _listes.insert(
            ReferenceValeursCompanion.insert(
              categorie: entry.value,
              valeur: v,
              ordre: Value(ordre++),
            ),
          );
          set.add(cle);
        }
        ok[feuille] = (ok[feuille] ?? 0) + 1;
      }
    }
  }

  /// Catégories de la feuille LISTES, identifiées par le libellé d'en-tête.
  ///
  /// La correspondance se fait par nom de colonne (et non par position) afin
  /// de rester valable lorsque le classeur de référence ajoute, retire ou
  /// réordonne des colonnes — par exemple la colonne `FINANCEMENT` présente
  /// dans `parametres.xlsx`.
  static const _entetesListes = <String, String>{
    'TYPE DE SAISIE': 'TYPE_ACTIVITE',
    'FINANCEMENT': 'FINANCEMENT',
    'RUBRIQUE': 'RUBRIQUE',
    'LIGNE BUDGETAIRE': 'LIGNE_BUDGETAIRE',
    'INDEMNITES': 'INDEMNITE',
    'AVEC DEJEUNER OU SANS DEJEUNER': 'DEJEUNER',
    'PJ RECUE': 'PJ_RECUE',
    'PJ CONFORME': 'PJ_CONFORME',
    'TYPE DE PJ': 'TYPE_PJ',
    'STATUT PRESENCE': 'STATUT_PRESENCE',
  };

  /// Table colonne → catégorie déduite de la ligne d'en-tête de LISTES.
  static Map<int, String> _colonnesListes(Sheet l) {
    final entete = l.row(0);
    final colonnes = <int, String>{};
    for (var c = 0; c < entete.length; c++) {
      final categorie = _entetesListes[_normaliserEntete(_txt(entete, c))];
      if (categorie != null) colonnes[c] = categorie;
    }
    return colonnes;
  }

  /// Normalise un libellé d'en-tête (majuscules, sans accents, espaces
  /// compactés et ponctuation simplifiée) pour une comparaison robuste.
  static String _normaliserEntete(String valeur) {
    const accents = <String, String>{
      'À': 'A', 'Â': 'A', 'Ä': 'A', 'Á': 'A', 'Ã': 'A', 'Å': 'A',
      'Ç': 'C',
      'È': 'E', 'É': 'E', 'Ê': 'E', 'Ë': 'E',
      'Ì': 'I', 'Î': 'I', 'Ï': 'I', 'Í': 'I',
      'Ò': 'O', 'Ô': 'O', 'Ö': 'O', 'Ó': 'O', 'Õ': 'O',
      'Ù': 'U', 'Û': 'U', 'Ü': 'U', 'Ú': 'U',
      'Ÿ': 'Y',
    };
    var texte = valeur.toUpperCase();
    accents.forEach((accent, base) => texte = texte.replaceAll(accent, base));
    return texte
        .replaceAll(RegExp(r'[^A-Z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _importerActivites(
    Map<String, int> ok,
    Map<String, int> ko,
    List<LigneImport> details,
    StrategieDoublon strategie,
  ) async {
    const feuille = 'LISTES ACTIVITES';
    final la = _feuille(feuille);
    if (la == null) return;
    for (var i = 1; i < la.maxRows; i++) {
      final row = la.row(i);
      final code = _txt(row, 0);
      if (code.isEmpty) continue;
      if (code.toUpperCase() == 'RÉFÉRENCE ACTIVITÉ') continue;
      final existante = await _activites.parCode(code);
      if (existante != null && strategie == StrategieDoublon.ignorer) {
        ko[feuille] = (ko[feuille] ?? 0) + 1;
        continue;
      }
      await _activites.insert(
        ActivitesCompanion.insert(
          code: code,
          description: Value(_txt(row, 1)),
          codeBudget: Value(_txt(row, 2)),
          annee: Value(_int(row, 3)),
          periode: Value(_txt(row, 4)),
        ),
      );
      ok[feuille] = (ok[feuille] ?? 0) + 1;
    }
  }

  Future<void> _importerReferentielBudget(
    Map<String, int> ok,
    Map<String, int> ko,
    List<LigneImport> details,
    StrategieDoublon strategie,
  ) async {
    const feuille = 'REFERENTIEL_BUDGET';
    final rb = _feuille(feuille);
    if (rb == null) return;
    final dejaImportees = await _lignesBudget.getAll();
    final cles = dejaImportees
        .map((e) => '${e.activiteCode}|${e.ligneBudgetaire}')
        .toSet();
    for (var i = 1; i < rb.maxRows; i++) {
      final row = rb.row(i);
      final code = _txt(row, 0);
      final ligne = _txt(row, 4);
      if (code.isEmpty || ligne.isEmpty) continue;
      final cle = '$code|$ligne';
      if (cles.contains(cle) && strategie == StrategieDoublon.ignorer) {
        ko[feuille] = (ko[feuille] ?? 0) + 1;
        continue;
      }
      // Crée l'activité si absente (référence utilisée par le budget).
      final activiteExistante = await _activites.parCode(code);
      if (activiteExistante == null) {
        await _activites.insert(
          ActivitesCompanion.insert(
            code: code,
            description: Value(_txt(row, 1)),
            dateDebut: Value(_date(row, 2)),
            dateFin: Value(_date(row, 3)),
          ),
        );
      } else if (activiteExistante.dateDebut == null ||
          activiteExistante.dateFin == null) {
        await _activites.update(
          activiteExistante.id,
          ActivitesCompanion(
            dateDebut: Value(activiteExistante.dateDebut ?? _date(row, 2)),
            dateFin: Value(activiteExistante.dateFin ?? _date(row, 3)),
          ),
        );
      }
      final q = _num(row, 6) ?? 0;
      final jours = _num(row, 7) ?? 0;
      final taux = _num(row, 8) ?? 0;
      final montantSaisi = _num(row, 9);
      await _lignesBudget.insert(
        LignesBudgetCompanion.insert(
          activiteCode: code,
          activiteLibelle: Value(_txt(row, 1)),
          dateDebutPrevue: Value(_date(row, 2)),
          dateFinPrevue: Value(_date(row, 3)),
          ligneBudgetaire: ligne,
          unite: Value(_txt(row, 5).isEmpty ? 'jour-personne' : _txt(row, 5)),
          quantitePrevue: Value(q),
          nombreJours: Value(jours),
          tauxUnitaire: Value(taux),
          montantAlloue: Value(
            montantSaisi ??
                ReglesMetier.montantAlloue(
                  quantite: q,
                  nombreJours: jours,
                  tauxUnitaire: taux,
                ),
          ),
          observation: Value(_txt(row, 10)),
        ),
      );
      cles.add(cle);
      ok[feuille] = (ok[feuille] ?? 0) + 1;
    }
  }

  Future<void> _importerParticipantsPresences(
    Map<String, int> ok,
    Map<String, int> ko,
    List<LigneImport> details,
    StrategieDoublon strategie,
  ) async {
    const feuille = 'PRESENCES_INDEMNITES';
    final pi = _feuille(feuille);
    if (pi == null) return;
    final cache = <String, Participant>{};
    for (final p in await _participants.getAll()) {
      cache[_cleParticipant(p.nom)] = p;
    }
    final activitesExistantes = {
      for (final a in await _activites.getAll()) a.code,
    };
    final affectations = <String, Set<int>>{};

    for (var i = 1; i < pi.maxRows; i++) {
      final row = pi.row(i);
      final code = _txt(row, 1);
      final nom = _txt(row, 2);
      if (code.isEmpty || nom.isEmpty) continue;
      final date = _date(row, 4);
      if (date == null) {
        ko[feuille] = (ko[feuille] ?? 0) + 1;
        details.add(
          LigneImport(
            feuille: feuille,
            ligne: i + 1,
            message: 'Ligne ignorée : date invalide pour « $nom »',
            estErreur: true,
          ),
        );
        continue;
      }
      final statuts = <String>[
        _txt(row, 5),
        _txt(row, 6),
        _txt(row, 7),
        _txt(row, 8),
        _txt(row, 9),
      ];
      final jours = <({DateTime date, String statut})>[
        for (var j = 0; j < statuts.length; j++)
          if (statuts[j].isNotEmpty)
            (
              date: DateTime(
                date.year,
                date.month,
                date.day,
              ).add(Duration(days: j)),
              statut: statuts[j],
            ),
      ];
      if (jours.isEmpty) {
        ko[feuille] = (ko[feuille] ?? 0) + 1;
        continue;
      }
      // Activité absente : la créer pour conserver la donnée.
      if (!activitesExistantes.contains(code)) {
        await _activites.insert(ActivitesCompanion.insert(code: code));
        activitesExistantes.add(code);
      }
      // Participant : réutiliser ou créer.
      final cle = _cleParticipant(nom);
      var participant = cache[cle];
      if (participant == null) {
        final id = await _participants.insert(
          ParticipantsCompanion.insert(nom: nom, fonction: Value(_txt(row, 3))),
        );
        participant = Participant(
          id: id,
          nom: nom,
          prenom: '',
          fonction: _txt(row, 3).isEmpty ? null : _txt(row, 3),
          structure: null,
          telephone: null,
          email: null,
          actif: true,
          observation: null,
        );
        cache[cle] = participant;
      }
      if (strategie == StrategieDoublon.ignorer) {
        var doublon = false;
        for (final jour in jours) {
          if (await _presences.trouver(code, participant.id, jour.date) !=
              null) {
            doublon = true;
            break;
          }
        }
        if (doublon) {
          ko[feuille] = (ko[feuille] ?? 0) + 1;
          continue;
        }
      }
      final preuve = _txt(row, 10);
      final taux = _num(row, 11) ?? 0;
      final indemniteRecue = _num(row, 13) ?? 0;
      final theoriqueTotal = jours.fold<double>(
        0,
        (total, jour) => total + (jour.statut == 'Présent' ? taux : 0),
      );
      var premierJour = true;
      for (final jour in jours) {
        final theorique = ReglesMetier.indemniteTheorique(
          nombreJoursPresents: jour.statut == 'Présent' ? 1 : 0,
          tauxJournalier: taux,
        );
        final recuJour = theoriqueTotal > 0
            ? indemniteRecue * theorique / theoriqueTotal
            : (premierJour ? indemniteRecue : 0.0);
        await _presences.upsert(
          PresencesCompanion.insert(
            activiteCode: code,
            participantId: participant.id,
            date: jour.date,
            statut: Value(jour.statut),
            signaturePreuve: Value(preuve.isEmpty ? null : preuve),
            tauxJournalier: Value(taux),
            indemniteRecue: Value(recuJour),
            observation: Value(_txt(row, 19)),
          ),
        );
        premierJour = false;
      }
      final participantsAffectes = affectations.putIfAbsent(
        code,
        () => <int>{},
      );
      if (participantsAffectes.isEmpty) {
        participantsAffectes.addAll(
          (await _activiteParticipants.parActivite(
            code,
          )).map((affectation) => affectation.participantId),
        );
      }
      if (participantsAffectes.add(participant.id)) {
        await _activiteParticipants.insert(
          ActiviteParticipantsCompanion.insert(
            activiteCode: code,
            participantId: participant.id,
            tauxJournalier: Value(taux),
          ),
        );
      }
      ok[feuille] = (ok[feuille] ?? 0) + 1;
    }
  }

  Future<void> _importerControlePJ(
    Map<String, int> ok,
    Map<String, int> ko,
    List<LigneImport> details,
    StrategieDoublon strategie,
  ) async {
    const feuille = 'CONTROLE_PJ';
    final cp = _feuille(feuille);
    if (cp == null) return;
    for (var i = 1; i < cp.maxRows; i++) {
      final row = cp.row(i);
      final code = _txt(row, 1);
      final benef = _txt(row, 7);
      if (code.isEmpty && benef.isEmpty) continue;
      await _controles.insert(
        ControlesPJCompanion.insert(
          activiteCode: Value(code.isEmpty ? null : code),
          dateDebutActivite: Value(_date(row, 3)),
          dateFinActivite: Value(_date(row, 4)),
          datePJ: Value(_date(row, 5)),
          ligneBudgetaire: Value(_txt(row, 6)),
          beneficiaire: Value(benef),
          typePJ: Value(_txt(row, 8)),
          montantAlloue: Value(_num(row, 9) ?? 0),
          montantPaye: Value(_num(row, 10) ?? 0),
          montantPJ: Value(_num(row, 11) ?? 0),
          pjRecue: Value(_txt(row, 14)),
          pjConforme: Value(_txt(row, 15)),
          observation: Value(_txt(row, 20)),
        ),
      );
      ok[feuille] = (ok[feuille] ?? 0) + 1;
    }
  }

  Future<void> _importerDepenses(
    Map<String, int> ok,
    Map<String, int> ko,
    List<LigneImport> details,
    StrategieDoublon strategie,
  ) async {
    const feuille = 'J.Depenses';
    final jd = _feuille(feuille);
    if (jd == null) return;
    for (var i = 3; i < jd.maxRows; i++) {
      final row = jd.row(i);
      final designation = _txt(row, 9);
      if (designation.isEmpty) continue;
      if (designation.toUpperCase().contains('DÉSIGNATION') ||
          designation.toUpperCase().contains('DESIGNATION')) {
        continue;
      }
      await _depenses.insert(
        DepensesCompanion.insert(
          dateEnregistrement: Value(_date(row, 0)),
          datePieceComptable: Value(_date(row, 1)),
          periodeAutorisee: Value(_txt(row, 2)),
          fonds: Value(_txt(row, 3).isEmpty ? 'Banque' : _txt(row, 3)),
          refDecaissement: Value(_txt(row, 4)),
          refPieceDepense: Value(_txt(row, 5)),
          dctNumero: Value(_txt(row, 6)),
          codeActivite: Value(_txt(row, 7)),
          codeBudget: Value(_txt(row, 8)),
          designation: Value(designation),
          unite: Value(_txt(row, 10)),
          nbJrMois: Value(_num(row, 11) ?? 0),
          quantite: Value(_num(row, 12) ?? 0),
          frequence: Value(_num(row, 13) ?? 1),
          pu: Value(_num(row, 14) ?? 0),
        ),
      );
      ok[feuille] = (ok[feuille] ?? 0) + 1;
    }
  }

  Future<void> _importerBanque(
    Map<String, int> ok,
    Map<String, int> ko,
    List<LigneImport> details,
    StrategieDoublon strategie,
  ) async {
    const feuille = 'J.Banque';
    final jb = _feuille(feuille);
    if (jb == null) return;
    for (var i = 5; i < jb.maxRows; i++) {
      final row = jb.row(i);
      final description = _txt(row, 4);
      final date = _date(row, 0);
      if (description.isEmpty && date == null) continue;
      if (description.toUpperCase() == 'DESCRIPTION') continue;
      if (date == null) {
        ko[feuille] = (ko[feuille] ?? 0) + 1;
        continue;
      }
      await _banque.insert(
        BanqueOperationsCompanion.insert(
          date: date,
          refPiece: Value(_txt(row, 1)),
          type: Value(_txt(row, 2).isEmpty ? 'Opération' : _txt(row, 2)),
          refCheque: Value(_txt(row, 3)),
          description: Value(description),
          recettes: Value(_num(row, 5) ?? 0),
          depenses: Value(_num(row, 6) ?? 0),
          bailleur: Value(_txt(row, 8)),
          beneficiaire: Value(_txt(row, 9)),
        ),
      );
      ok[feuille] = (ok[feuille] ?? 0) + 1;
    }
  }

  // --- Helpers de lecture des cellules ---

  static String _cleParticipant(String nom) =>
      nom.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');

  static Data? _cell(List<Data?> row, int index) =>
      index < row.length ? row[index] : null;

  static String _txt(List<Data?> row, int index) {
    final v = _cell(row, index)?.value;
    if (v == null) return '';
    final String texte = switch (v) {
      TextCellValue() => v.value.text ?? '',
      IntCellValue() => v.value.toString(),
      DoubleCellValue() => v.value.toString(),
      BoolCellValue() => v.value.toString(),
      DateCellValue() => v.asDateTimeLocal().toIso8601String(),
      _ => v.toString(),
    };
    return texte.trim();
  }

  static double? _num(List<Data?> row, int index) {
    final v = _cell(row, index)?.value;
    if (v == null) return null;
    return switch (v) {
      IntCellValue() => v.value.toDouble(),
      DoubleCellValue() => v.value,
      BoolCellValue() => v.value ? 1.0 : 0.0,
      _ => double.tryParse(
        _txt(row, index).replaceAll(' ', '').replaceAll(',', '.'),
      ),
    };
  }

  static int? _int(List<Data?> row, int index) {
    final n = _num(row, index);
    return n?.toInt();
  }

  static DateTime? _date(List<Data?> row, int index) {
    final v = _cell(row, index)?.value;
    if (v == null) return null;
    if (v is DateCellValue) return v.asDateTimeLocal();
    if (v is IntCellValue) {
      // Numéro de série Excel → date (origine 1899-12-30).
      return DateTime(1899, 12, 30).add(Duration(days: v.value));
    }
    if (v is DoubleCellValue) {
      return DateTime(1899, 12, 30).add(Duration(days: v.value.round()));
    }
    return DateTime.tryParse(_txt(row, index));
  }
}
