import 'dart:io';

import 'package:excel/excel.dart';

import '../data/repositories/activite_repository.dart';
import '../data/repositories/finance_repository.dart';
import '../data/repositories/participant_repository.dart';
import '../data/repositories/presence_repository.dart';
import '../domain/services/controle_pj_service.dart';
import '../domain/services/rapport_financier_service.dart';
import '../domain/services/presence_indemnite_service.dart';
import '../domain/services/rapprochement_service.dart';
import '../domain/statuts.dart';

/// Service d'export des données vers Excel.
class ExcelExportService {
  ExcelExportService({
    required ActivitesRepository activites,
    required LignesBudgetRepository lignesBudget,
    required ParticipantsRepository participants,
    required PresencesRepository presences,
    required DepensesRepository depenses,
    required BanqueRepository banque,
    required PresenceIndemniteService presenceService,
    required ControlePJService controlePJService,
    required RapprochementService rapprochementService,
  }) : _activites = activites,
       _lignesBudget = lignesBudget,
       _participants = participants,
       _presences = presences,
       _depenses = depenses,
       _banque = banque,
       _presenceService = presenceService,
       _controlePJService = controlePJService,
       _rapprochementService = rapprochementService;

  final ActivitesRepository _activites;
  final LignesBudgetRepository _lignesBudget;
  final ParticipantsRepository _participants;
  final PresencesRepository _presences;
  final DepensesRepository _depenses;
  final BanqueRepository _banque;
  final PresenceIndemniteService _presenceService;
  final ControlePJService _controlePJService;
  final RapprochementService _rapprochementService;

  static final _entete = CellStyle(
    bold: true,
    backgroundColorHex: ExcelColor.fromHexString('FF1F4E79'),
    fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
  );

  static final _total = CellStyle(
    bold: true,
    backgroundColorHex: ExcelColor.fromHexString('FFDDEBF7'),
    numberFormat: NumFormat.standard_3,
  );

  static final _totalTexte = CellStyle(
    bold: true,
    backgroundColorHex: ExcelColor.fromHexString('FFDDEBF7'),
  );

  /// Export complet : un classeur, une feuille par domaine.
  Future<List<int>> exporterComplet() async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');

    await _feuilleResume(excel);
    await _feuilleActivites(excel);
    await _feuilleBudgets(excel);
    await _feuilleParticipants(excel);
    await _feuillePresences(excel);
    await _feuilleIndemnites(excel);
    await _feuilleControlePJ(excel);
    await _feuilleDepenses(excel);
    await _feuilleBanque(excel);
    await _feuilleRapprochement(excel);

    final bytes = excel.encode();
    return bytes ?? <int>[];
  }

  Future<List<int>> exporterActivites() async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    await _feuilleActivites(excel);
    return excel.encode() ?? <int>[];
  }

  Future<List<int>> exporterPresences() async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    await _feuillePresences(excel);
    return excel.encode() ?? <int>[];
  }

  Future<List<int>> exporterIndemnites() async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    await _feuilleIndemnites(excel);
    return excel.encode() ?? <int>[];
  }

  Future<List<int>> exporterControlePJ() async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    await _feuilleControlePJ(excel);
    return excel.encode() ?? <int>[];
  }

  Future<List<int>> exporterDepenses() async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    await _feuilleDepenses(excel);
    return excel.encode() ?? <int>[];
  }

  Future<List<int>> exporterBanque() async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    await _feuilleBanque(excel);
    return excel.encode() ?? <int>[];
  }

  /// Pré-impression du budget (récapitulatif + détail des lignes).
  Future<List<int>> exporterBudget() async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    await _feuilleBudgets(excel);
    await _feuilleRecapBudget(excel);
    return excel.encode() ?? <int>[];
  }

  /// Rapport financier : alloué / réalisé / écart par ligne budgétaire.
  Future<List<int>> exporterRapportFinancier(
    ResumeRapportFinancier rapport,
  ) async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    final sheet = excel['Rapport financier'];
    _entetes(sheet, [
      'Code activité',
      'Code budget',
      'Description activité',
      'Ligne budgétaire',
      'Montant alloué (Ar)',
      'Dépenses réalisées (Ar)',
      'Écart (Ar)',
      'Observation',
    ]);
    for (final l in rapport.lignes) {
      sheet.appendRow([
        TextCellValue(l.codeActivite),
        TextCellValue(l.codeBudget),
        TextCellValue(l.descriptionActivite),
        TextCellValue(l.ligneBudgetaire),
        DoubleCellValue(l.montantAlloue),
        DoubleCellValue(l.depensesRealisees),
        DoubleCellValue(l.ecart),
        TextCellValue(l.observationFinale),
      ]);
    }
    sheet.appendRow([
      TextCellValue('TOTAL'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      DoubleCellValue(rapport.totalAlloue),
      DoubleCellValue(rapport.totalRealise),
      DoubleCellValue(rapport.totalEcart),
      TextCellValue(''),
    ]);
    _styliserDerniereLigne(sheet);
    _ajuster(sheet);
    return excel.encode() ?? <int>[];
  }

  /// Récapitulatif automatique du budget par ligne budgétaire.
  Future<void> _feuilleRecapBudget(Excel excel) async {
    final sheet = excel['Récap budget'];
    _entetes(sheet, [
      'Ligne budgétaire',
      'Nombre de lignes',
      'Montant alloué (Ar)',
    ]);
    final lignes = await _lignesBudget.getAll();
    final parLigne = <String, (int, double)>{};
    for (final l in lignes) {
      final courant = parLigne[l.ligneBudgetaire] ?? (0, 0.0);
      parLigne[l.ligneBudgetaire] =
          (courant.$1 + 1, courant.$2 + l.montantAlloue);
    }
    var total = 0.0;
    final entrees = parLigne.entries.toList()
      ..sort((a, b) => b.value.$2.compareTo(a.value.$2));
    for (final e in entrees) {
      total += e.value.$2;
      sheet.appendRow([
        TextCellValue(e.key),
        IntCellValue(e.value.$1),
        DoubleCellValue(e.value.$2),
      ]);
    }
    _ligneTotal(sheet, 'TOTAL GÉNÉRAL', 2, total);
    _ajuster(sheet);
  }

  Future<void> sauvegarder(List<int> bytes, String chemin) async {
    final file = File(chemin);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);
  }

  // --- Feuilles ---

  Future<void> _feuilleActivites(Excel excel) async {
    final sheet = excel['Activités'];
    _entetes(sheet, [
      'Code',
      'Description',
      'Type',
      'Code budget',
      'Source de financement',
      'Année',
      'Période',
      'Date début',
      'Date fin',
      'Lieu',
      'District',
      'Responsable',
      'Nombre de jours',
      'Nombre participants',
      'Statut',
    ]);
    final activites = await _activites.getAll();
    for (final a in activites) {
      sheet.appendRow([
        TextCellValue(a.code),
        TextCellValue(a.description),
        TextCellValue(a.type),
        TextCellValue(a.codeBudget ?? ''),
        TextCellValue(a.sourceFinancement ?? ''),
        IntCellValue(a.annee ?? 0),
        TextCellValue(a.periode ?? ''),
        _dateCell(a.dateDebut),
        _dateCell(a.dateFin),
        TextCellValue(a.lieu ?? ''),
        TextCellValue(a.district ?? ''),
        TextCellValue(a.responsable ?? ''),
        IntCellValue(a.nombreJours),
        IntCellValue(a.nombreParticipants),
        TextCellValue(a.statut),
      ]);
    }
    _ajuster(sheet);
  }

  Future<void> _feuilleBudgets(Excel excel) async {
    final sheet = excel['Budgets'];
    _entetes(sheet, [
      'Code activité',
      'Ligne budgétaire',
      'Type de budget',
      'Unité',
      'Quantité prévue',
      'Nombre de jour',
      'Taux unitaire (Ar)',
      'Montant alloué (Ar)',
      'Observation',
    ]);
    final lignes = await _lignesBudget.getAll();
    var total = 0.0;
    for (final l in lignes) {
      total += l.montantAlloue;
      sheet.appendRow([
        TextCellValue(l.activiteCode),
        TextCellValue(l.ligneBudgetaire),
        TextCellValue(l.typeBudget),
        TextCellValue(l.unite),
        DoubleCellValue(l.quantitePrevue),
        DoubleCellValue(l.nombreJours),
        DoubleCellValue(l.tauxUnitaire),
        DoubleCellValue(l.montantAlloue),
        TextCellValue(l.observation ?? ''),
      ]);
    }
    _ligneTotal(sheet, 'TOTAL ALLOUÉ', 6, total);
    _ajuster(sheet);
  }

  Future<void> _feuilleParticipants(Excel excel) async {
    final sheet = excel['Participants'];
    _entetes(sheet, [
      'Nom',
      'Prénom',
      'Fonction',
      'Structure',
      'Téléphone',
      'Email',
      'Actif',
    ]);
    final participants = await _participants.getAll();
    for (final p in participants) {
      sheet.appendRow([
        TextCellValue(p.nom),
        TextCellValue(p.prenom),
        TextCellValue(p.fonction ?? ''),
        TextCellValue(p.structure ?? ''),
        TextCellValue(p.telephone ?? ''),
        TextCellValue(p.email ?? ''),
        TextCellValue(p.actif ? 'Oui' : 'Non'),
      ]);
    }
    _ajuster(sheet);
  }

  Future<void> _feuillePresences(Excel excel) async {
    final sheet = excel['Présences'];
    _entetes(sheet, [
      'Code activité',
      'Participant',
      'Date',
      'Statut',
      'Signature / preuve',
      'Taux journalier (Ar)',
      'Indemnité reçue (Ar)',
      'Observation',
    ]);
    final presences = await _presences.getAll();
    final participants = {
      for (final p in await _participants.getAll()) p.id: p,
    };
    for (final p in presences) {
      final part = participants[p.participantId];
      sheet.appendRow([
        TextCellValue(p.activiteCode),
        TextCellValue(
          part == null
              ? '#${p.participantId}'
              : '${part.nom} ${part.prenom}'.trim(),
        ),
        _dateCell(p.date),
        TextCellValue(p.statut),
        TextCellValue(p.signaturePreuve ?? ''),
        DoubleCellValue(p.tauxJournalier),
        DoubleCellValue(p.indemniteRecue),
        TextCellValue(p.observation ?? ''),
      ]);
    }
    _ajuster(sheet);
  }

  Future<void> _feuilleIndemnites(Excel excel) async {
    final sheet = excel['Indemnités'];
    _entetes(sheet, [
      'Code activité',
      'Participant',
      'Jours présents',
      'Taux journalier (Ar)',
      'Indemnité théorique (Ar)',
      'Indemnité reçue (Ar)',
      'Écart (Ar)',
      'Statut',
    ]);
    final activites = await _activites.getAll();
    var theorique = 0.0;
    var recue = 0.0;
    for (final a in activites) {
      final syntheses = await _presenceService.syntheseParParticipant(a.code);
      for (final s in syntheses) {
        theorique += s.indemniteTheorique;
        recue += s.indemniteRecue;
        sheet.appendRow([
          TextCellValue(a.code),
          TextCellValue(s.participantNom),
          IntCellValue(s.nombreJoursPresents),
          DoubleCellValue(s.tauxJournalier),
          DoubleCellValue(s.indemniteTheorique),
          DoubleCellValue(s.indemniteRecue),
          DoubleCellValue(s.ecart),
          TextCellValue(s.statut.libelle),
        ]);
      }
    }
    sheet.appendRow([
      TextCellValue('TOTAL'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      DoubleCellValue(theorique),
      DoubleCellValue(recue),
      DoubleCellValue(recue - theorique),
      TextCellValue(''),
    ]);
    _styliserDerniereLigne(sheet);
    _ajuster(sheet);
  }

  Future<void> _feuilleControlePJ(Excel excel) async {
    final sheet = excel['Contrôle PJ'];
    _entetes(sheet, [
      'Code activité',
      'Date début',
      'Date fin',
      'Date PJ',
      'Ligne budgétaire',
      'Bénéficiaire',
      'Type de PJ',
      'Montant alloué (Ar)',
      'Montant payé (Ar)',
      'Montant PJ (Ar)',
      'Écart budget (Ar)',
      'Écart PJ (Ar)',
      'PJ reçue',
      'PJ conforme',
      'Date PJ cohérente',
      'Statut final',
    ]);
    final resultats = await _controlePJService.evaluerTout();
    for (final (c, r) in resultats) {
      sheet.appendRow([
        TextCellValue(c.activiteCode ?? ''),
        _dateCell(c.dateDebutActivite),
        _dateCell(c.dateFinActivite),
        _dateCell(c.datePJ),
        TextCellValue(c.ligneBudgetaire ?? ''),
        TextCellValue(c.beneficiaire ?? ''),
        TextCellValue(c.typePJ ?? ''),
        DoubleCellValue(c.montantAlloue),
        DoubleCellValue(c.montantPaye),
        DoubleCellValue(c.montantPJ),
        DoubleCellValue(r.ecartBudget),
        DoubleCellValue(r.ecartPJ),
        TextCellValue(c.pjRecue),
        TextCellValue(c.pjConforme),
        TextCellValue(r.datePJCoherente ? OuiNon.oui : OuiNon.non),
        TextCellValue(r.statutFinal),
      ]);
    }
    _ajuster(sheet);
  }

  Future<void> _feuilleDepenses(Excel excel) async {
    final sheet = excel['Dépenses'];
    _entetes(sheet, [
      'Date enregistrement',
      'Date pièce comptable',
      'Période autorisée',
      'Fonds',
      'Réf décaissement',
      'Réf pièce dépense',
      'DCT N°',
      'Code activité',
      'Code budget',
      'Désignation',
      'Unité',
      'Nbr jr/mois',
      'Quantité',
      'Fréquence',
      'P.U. (Ar)',
      'Montant (Ar)',
    ]);
    final depenses = await _depenses.getAll();
    var total = 0.0;
    for (final d in depenses) {
      final montant = d.nbJrMois * d.quantite * d.frequence * d.pu;
      total += montant;
      sheet.appendRow([
        _dateCell(d.dateEnregistrement),
        _dateCell(d.datePieceComptable),
        TextCellValue(d.periodeAutorisee ?? ''),
        TextCellValue(d.fonds),
        TextCellValue(d.refDecaissement ?? ''),
        TextCellValue(d.refPieceDepense ?? ''),
        TextCellValue(d.dctNumero ?? ''),
        TextCellValue(d.codeActivite ?? ''),
        TextCellValue(d.codeBudget ?? ''),
        TextCellValue(d.designation),
        TextCellValue(d.unite ?? ''),
        DoubleCellValue(d.nbJrMois),
        DoubleCellValue(d.quantite),
        DoubleCellValue(d.frequence),
        DoubleCellValue(d.pu),
        DoubleCellValue(montant),
      ]);
    }
    _ligneTotal(sheet, 'TOTAL DÉPENSES', 15, total);
    _ajuster(sheet);
  }

  Future<void> _feuilleBanque(Excel excel) async {
    final sheet = excel['Banque'];
    _entetes(sheet, [
      'Date',
      'Réf pièce',
      'Type',
      'Réf chq/OV',
      'Description',
      'Recettes (Ar)',
      'Dépenses (Ar)',
      'Solde progressif (Ar)',
      'Bailleur',
      'Bénéficiaire',
    ]);
    final ops = await _banque.getAll();
    double solde = 0;
    var recettes = 0.0;
    var depenses = 0.0;
    for (final o in ops) {
      solde += o.recettes - o.depenses;
      recettes += o.recettes;
      depenses += o.depenses;
      sheet.appendRow([
        _dateCell(o.date),
        TextCellValue(o.refPiece ?? ''),
        TextCellValue(o.type),
        TextCellValue(o.refCheque ?? ''),
        TextCellValue(o.description),
        DoubleCellValue(o.recettes),
        DoubleCellValue(o.depenses),
        DoubleCellValue(solde),
        TextCellValue(o.bailleur ?? ''),
        TextCellValue(o.beneficiaire ?? ''),
      ]);
    }
    sheet.appendRow([
      TextCellValue('TOTAL'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      DoubleCellValue(recettes),
      DoubleCellValue(depenses),
      DoubleCellValue(solde),
      TextCellValue(''),
      TextCellValue(''),
    ]);
    _styliserDerniereLigne(sheet);
    _ajuster(sheet);
  }

  Future<void> _feuilleRapprochement(Excel excel) async {
    final sheet = excel['Rapprochement'];
    _entetes(sheet, [
      'Date',
      'Référence',
      'Libellé',
      'Montant journal (Ar)',
      'Montant relevé (Ar)',
      'Écart (Ar)',
      'Statut',
    ]);
    final resultat = await _rapprochementService.calculer();
    for (final l in resultat.lignes) {
      sheet.appendRow([
        _dateCell(l.date),
        TextCellValue(l.reference),
        TextCellValue(l.libelle),
        DoubleCellValue(l.montantJournal),
        DoubleCellValue(l.montantReleve),
        DoubleCellValue(l.ecart),
        TextCellValue(l.statut.libelle),
      ]);
    }
    sheet.appendRow([TextCellValue('')]);
    sheet.appendRow([
      TextCellValue('Solde rapproché journal'),
      DoubleCellValue(resultat.soldeJournal),
    ]);
    sheet.appendRow([
      TextCellValue('Solde rapproché relevé'),
      DoubleCellValue(resultat.soldeReleve),
    ]);
    sheet.appendRow([TextCellValue('Écart'), DoubleCellValue(resultat.ecart)]);
    _ajuster(sheet);
  }

  /// Feuille de synthèse (première feuille de l'export complet).
  Future<void> _feuilleResume(Excel excel) async {
    final sheet = excel['Résumé'];
    final activites = await _activites.getAll();
    final lignes = await _lignesBudget.getAll();
    final presences = await _presences.getAll();
    final participants = await _participants.getAll();
    final depenses = await _depenses.getAll();
    final banque = await _banque.getAll();

    final totalAlloue = lignes.fold<double>(
      0,
      (total, l) => total + l.montantAlloue,
    );
    final totalDepenses = depenses.fold<double>(
      0,
      (total, d) => total + d.nbJrMois * d.quantite * d.frequence * d.pu,
    );
    final soldeBanque = banque.fold<double>(
      0,
      (total, o) => total + o.recettes - o.depenses,
    );

    sheet.appendRow([TextCellValue('DSFA Gestion — Synthèse des données')]);
    sheet.appendRow([
      TextCellValue('Généré le'),
      TextCellValue(DateTime.now().toIso8601String().substring(0, 19)),
    ]);
    sheet.appendRow([TextCellValue('')]);
    sheet.appendRow([
      TextCellValue('Indicateur'),
      TextCellValue('Valeur'),
    ]);
    for (final l in <List<CellValue>>[
      [TextCellValue('Activités'), IntCellValue(activites.length)],
      [TextCellValue('Participants'), IntCellValue(participants.length)],
      [TextCellValue('Présences'), IntCellValue(presences.length)],
      [TextCellValue('Budget alloué (Ar)'), DoubleCellValue(totalAlloue)],
      [TextCellValue('Dépenses (Ar)'), DoubleCellValue(totalDepenses)],
      [TextCellValue('Solde bancaire (Ar)'), DoubleCellValue(soldeBanque)],
    ]) {
      sheet.appendRow(l);
    }
    for (var i = 3; i <= 4; i++) {
      sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i))
              .cellStyle =
          _entete;
      sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i))
              .cellStyle =
          _entete;
    }
    _ajuster(sheet);
  }

  void _entetes(Sheet sheet, List<String> titres) {
    final row = titres.map((t) => TextCellValue(t)).toList();
    sheet.appendRow(row);
    for (var i = 0; i < titres.length; i++) {
      sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
              .cellStyle =
          _entete;
    }
  }

  /// Ajuste la largeur de toutes les colonnes utilisées de la feuille.
  void _ajuster(Sheet sheet) {
    for (var i = 0; i < sheet.maxColumns; i++) {
      sheet.setColumnAutoFit(i);
    }
  }

  /// Ajoute une ligne de total « libellé + montant » et la met en valeur.
  void _ligneTotal(Sheet sheet, String libelle, int colonneMontant, double valeur) {
    final cellule = List<CellValue>.generate(
      colonneMontant + 1,
      (i) => TextCellValue(''),
    );
    cellule[0] = TextCellValue(libelle);
    cellule[colonneMontant] = DoubleCellValue(valeur);
    sheet.appendRow(cellule);
    final ligne = sheet.maxRows - 1;
    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: ligne))
            .cellStyle =
        _totalTexte;
    sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: colonneMontant,
                rowIndex: ligne,
              ),
            )
            .cellStyle =
        _total;
  }

  /// Applique le style de total à la dernière ligne de la feuille.
  void _styliserDerniereLigne(Sheet sheet) {
    final ligne = sheet.maxRows - 1;
    for (var i = 0; i < sheet.maxColumns; i++) {
      sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: ligne))
              .cellStyle =
          _total;
    }
  }

  static CellValue _dateCell(DateTime? d) {
    if (d == null) return TextCellValue('');
    return DateCellValue(year: d.year, month: d.month, day: d.day);
  }
}
