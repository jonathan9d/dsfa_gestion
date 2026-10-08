import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../domain/rubriques.dart';
import '../../providers/configuration_providers.dart';
import '../../../domain/services/regles_metier.dart';
import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';

/// Types de budget déduits **automatiquement** du libellé de la ligne
/// budgétaire (formules du classeur `BUDGET`).
///
/// Chaque type porte sa propre formule de calcul ; le montant alloué est
/// toujours recalculé, jamais saisi.
class TypeBudget {
  const TypeBudget(this.id, this.libelle, this.formule);

  final String id;
  final String libelle;

  /// Formule lisible, affichée dans le formulaire.
  final String formule;

  static const libres = 'Libre';
  static const indemnitesEquipes = 'Indemnités équipes';
  static const indemnitesChauffeurs = 'Indemnités chauffeurs';
  static const carburant = 'Carburant';
  static const location = 'Location de voitures';
  static const restauration = 'Restauration';
  static const fournitures = 'Fournitures';
  static const deplacementForfaitaire = 'Déplacement forfaitaire';
  static const transfert = 'Frais de transfert aéroport';
  static const taxiBrousse = 'Frais taxi-brousse';
  static const billetAvion = 'Billet d’avion';

  static const tous = <TypeBudget>[
    TypeBudget(
      indemnitesEquipes,
      'Indemnités des équipes centraux et régionaux',
      'Personnes × [ délai de route × taux 100 % '
          '+ jours d’activité × taux 85 % ]',
    ),
    TypeBudget(
      indemnitesChauffeurs,
      'Indemnités des chauffeurs',
      'Personnes × [ délai de route × taux 100 % '
          '+ jours d’activité × taux 100 % ]',
    ),
    TypeBudget(
      carburant,
      'Carburant',
      'Distance aller-retour × consommation × nombre de voitures × PU',
    ),
    TypeBudget(
      location,
      'Location de voitures',
      'Nombre de voitures × jours (délai de route + jours d’activité) × PU',
    ),
    TypeBudget(
      restauration,
      'Restauration',
      'Quantité × jours d’activité × fréquence × PU',
    ),
    TypeBudget(
      fournitures,
      'Fournitures / autres rubriques',
      'Quantité × PU × fréquence',
    ),
    TypeBudget(
      deplacementForfaitaire,
      'Déplacement forfaitaire',
      'Personnes × taux selon provenance et lieu d’activité',
    ),
    TypeBudget(
      transfert,
      'Frais de transfert aéroport',
      'Quantité × fréquence × taux',
    ),
    TypeBudget(
      taxiBrousse,
      'Frais taxi-brousse',
      'Quantité × fréquence × taux',
    ),
    TypeBudget(billetAvion, 'Billet d’avion', 'Quantité × montant saisi'),
    TypeBudget(libres, 'Ligne libre', 'Quantité × jours × taux'),
  ];

  static TypeBudget parId(String? id) =>
      tous.firstWhere((t) => t.id == id, orElse: () => tous.last);

  /// Détection automatique du type à partir du libellé de la ligne
  /// budgétaire (les libellés viennent de `LISTES` / `REFERENTIEL_TARIFS`).
  static TypeBudget depuisLigne(String ligne) {
    final l = _sansAccent(ligne).toUpperCase();
    if (l.contains('CHAUFFEUR') || l.contains('CONDUCTEUR')) {
      return parId(indemnitesChauffeurs);
    }
    if (l.contains('INDEMNIT') ||
        l.contains('PERDIEM') ||
        l.contains('PER DIEM')) {
      return parId(indemnitesEquipes);
    }
    if (l.contains('BILLET') && l.contains('AVION') ||
        l.contains('DEPLACEMENT PAR AVION') ||
        l.contains('DÉPLACEMENT PAR AVION')) {
      return parId(billetAvion);
    }
    if (l.contains('TAXI-BROUSSE') || l.contains('TAXI BROUSSE')) {
      return parId(taxiBrousse);
    }
    if (l.contains('TRANSFERT') && l.contains('AEROPORT')) {
      return parId(transfert);
    }
    if (l.contains('FORFAITAIRE') && l.contains('DEPLACEMENT')) {
      return parId(deplacementForfaitaire);
    }
    if (l.contains('CARBURANT') ||
        l.contains('ESSENCE') ||
        l.contains('GASOIL') ||
        l.contains('DIESEL')) {
      return parId(carburant);
    }
    // « Location de salle équipée » appartient à la restauration / frais
    // d'organisation : le contrôle des salles prime donc sur celui des
    // véhicules (sinon une location de salle était classée « Location de
    // voitures », et donc en déplacement).
    if (l.contains('SALLE') ||
        l.contains('RESTAURATION') ||
        l.contains('ORGANISATION') ||
        l.contains('EAU') ||
        l.contains('PAUSE') ||
        l.contains('DEJEUNER') ||
        l.contains('GOUTER')) {
      return parId(restauration);
    }
    if (l.contains('LOCATION') ||
        l.contains('VOITURE') ||
        l.contains('VEHICULE')) {
      return parId(location);
    }
    if (l.contains('FOURNITURE') ||
        l.contains('PAPIER') ||
        l.contains('STYLO') ||
        l.contains('FLIP') ||
        l.contains('BLOC') ||
        l.contains('CHEMISE') ||
        l.contains('MASKING') ||
        l.contains('POST IT') ||
        l.contains('TONER') ||
        l.contains('IMPRESSION')) {
      return parId(fournitures);
    }
    return parId(libres);
  }

  /// Le libellé permet-il de déduire le type sans ambiguïté ?
  static bool estAutomatique(String ligne) => depuisLigne(ligne).id != libres;

  /// Type retenu pour une ligne : déduit du libellé ; à défaut, le type déjà
  /// enregistré est conservé pour ne pas modifier une ligne existante.
  static String typePourLigne(String ligne, {String? typeStocke}) {
    final auto = depuisLigne(ligne);
    if (auto.id != libres) return auto.id;
    if (typeStocke != null &&
        typeStocke.trim().isNotEmpty &&
        typeStocke != libres) {
      return typeStocke;
    }
    return libres;
  }

  static String _sansAccent(String valeur) {
    const accents = <String, String>{
      'À': 'A',
      'Â': 'A',
      'Ä': 'A',
      'Á': 'A',
      'Ã': 'A',
      'Å': 'A',
      'Ç': 'C',
      'È': 'E',
      'É': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'Ì': 'I',
      'Î': 'I',
      'Ï': 'I',
      'Í': 'I',
      'Ò': 'O',
      'Ô': 'O',
      'Ö': 'O',
      'Ó': 'O',
      'Õ': 'O',
      'Ù': 'U',
      'Û': 'U',
      'Ü': 'U',
      'Ú': 'U',
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'á': 'a',
      'ã': 'a',
      'å': 'a',
      'ç': 'c',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'í': 'i',
      'ò': 'o',
      'ô': 'o',
      'ö': 'o',
      'ó': 'o',
      'õ': 'o',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ú': 'u',
      'ÿ': 'y',
    };
    var texte = valeur;
    accents.forEach((accent, base) => texte = texte.replaceAll(accent, base));
    return texte;
  }
}

/// Dialogue « Nouvelle ligne budgétaire » / « Modifier ».
///
/// * le **type de budget est déduit automatiquement** du libellé de la ligne ;
/// * les champs changent selon le type ;
/// * le montant alloué est **toujours calculé** (règles métier : référentiel
///   tarifaire, distances des districts, consommation carburant) ;
/// * pour le carburant, la **distance aller et retour est calculée et
///   affichée automatiquement** à partir de la destination (le référentiel
///   ne connaît que les distances depuis Antananarivo).
class LigneBudgetDialog extends ConsumerStatefulWidget {
  const LigneBudgetDialog({this.ligne, super.key});

  final LigneBudget? ligne;

  @override
  ConsumerState<LigneBudgetDialog> createState() => _LigneBudgetDialogState();
}

class _LigneBudgetDialogState extends ConsumerState<LigneBudgetDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _activite;
  late final TextEditingController _ligne;
  late final TextEditingController _rubrique;
  late final TextEditingController _montantAlloue;
  late final TextEditingController _unite;
  late final TextEditingController _quantite;
  late final TextEditingController _jours;
  late final TextEditingController _taux;
  late final TextEditingController _observation;

  // --- Paramètres du générateur -------------------------------------------
  late final TextEditingController _personnes;
  late final TextEditingController _delaiRoute;
  late final TextEditingController _voitures;
  late final TextEditingController _pu;
  late final TextEditingController _frequence;
  late final TextEditingController _distance;
  late final TextEditingController _destination;
  late final TextEditingController _provenance;
  late final TextEditingController _vehicule;

  String _type = TypeBudget.libres;
  bool _restauration = false;
  bool _montantConfirme = false;

  @override
  void initState() {
    super.initState();
    final l = widget.ligne;
    final details = _lireDetails(l?.details);
    _activite = TextEditingController(text: l?.activiteCode ?? '');
    _ligne = TextEditingController(text: l?.ligneBudgetaire ?? '');
    _rubrique = TextEditingController(text: '${details['rubrique'] ?? ''}');
    _montantAlloue = TextEditingController(
      text: _chiffre(details['montantAlloueConfirme'] ?? l?.montantAlloue),
    );
    _montantConfirme = l != null && l.montantAlloue > 0;
    _unite = TextEditingController(text: l?.unite ?? 'jour-personne');
    _quantite = TextEditingController(text: _chiffre(l?.quantitePrevue));
    _jours = TextEditingController(text: _chiffre(l?.nombreJours));
    _taux = TextEditingController(text: _chiffre(l?.tauxUnitaire));
    _observation = TextEditingController(text: l?.observation ?? '');
    _personnes = TextEditingController(text: _chiffre(details['personnes']));
    _delaiRoute = TextEditingController(text: _chiffre(details['delaiRoute']));
    _voitures = TextEditingController(text: _chiffre(details['voitures']));
    _pu = TextEditingController(text: _chiffre(details['pu']));
    _frequence = TextEditingController(
      text: _chiffre(details['frequence'], defaut: '1'),
    );
    _distance = TextEditingController(text: _chiffre(details['distanceForce']));
    _destination = TextEditingController(
      text: '${details['destination'] ?? ''}',
    );
    _provenance = TextEditingController(text: '${details['provenance'] ?? ''}');
    _vehicule = TextEditingController(text: '${details['vehicule'] ?? ''}');
    _restauration = details['restauration'] == true;
    // Le type est déduit du libellé de la ligne (jamais choisi à la main).
    _type = l == null
        ? TypeBudget.libres
        : TypeBudget.typePourLigne(l.ligneBudgetaire, typeStocke: l.typeBudget);
    if (l != null) {
      if (_nombre(_personnes) <= 0 && l.quantitePrevue > 0) {
        _personnes.text = _chiffre(l.quantitePrevue);
      }
      if (_pu.text.trim().isEmpty || _nombre(_pu) == 0) {
        _pu.text = _chiffre(l.tauxUnitaire);
      }
      if (_frequence.text.trim().isEmpty) _frequence.text = '1';
    }
    // La rubrique d'une ligne existante est complétée après le premier frame
    // (les tarifs de référence arrivent de la base, en flux).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_rubrique.text.trim().isNotEmpty) return;
      if (_ligne.text.trim().isEmpty) return;
      final trouvee = _rubriqueAutomatique(_ligne.text);
      if (trouvee.isEmpty) return;
      setState(() => _rubrique.text = trouvee);
    });
  }

  static String _chiffre(dynamic v, {String defaut = '0'}) {
    if (v == null) return defaut;
    if (v is num) {
      final d = v.toDouble();
      return d == d.roundToDouble()
          ? d.round().toString()
          : d.toStringAsFixed(2);
    }
    return '$v';
  }

  static Map<String, dynamic> _lireDetails(String? brut) {
    if (brut == null || brut.trim().isEmpty) return <String, dynamic>{};
    try {
      return (jsonDecode(brut) as Map).cast<String, dynamic>();
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static double _nombre(TextEditingController c, {num defaut = 0}) =>
      double.tryParse(c.text.trim().replaceAll(',', '.')) ?? defaut.toDouble();

  /// Valeurs déjà utilisées dans l'écran, proposées dans les listes.
  List<String> _distinctes(
    List<LigneBudget> existantes,
    String Function(LigneBudget) f,
  ) => existantes.map(f).where((v) => v.trim().isNotEmpty).toSet().toList();

  @override
  void dispose() {
    for (final c in [
      _activite,
      _ligne,
      _rubrique,
      _montantAlloue,
      _unite,
      _quantite,
      _jours,
      _taux,
      _observation,
      _personnes,
      _delaiRoute,
      _voitures,
      _pu,
      _frequence,
      _distance,
      _destination,
      _provenance,
      _vehicule,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // --- Données de référence ----------------------------------------------

  Activite? get _activiteChoisie {
    final activites = ref.read(activitesProvider).value ?? const <Activite>[];
    for (final a in activites) {
      if (a.code == _activite.text.trim()) return a;
    }
    return null;
  }

  District? _districtParNom(String nom) {
    final districts =
        ref.read(tousDistrictsProvider).value ?? const <District>[];
    for (final d in districts) {
      if (d.nom.toLowerCase() == nom.trim().toLowerCase()) return d;
    }
    return null;
  }

  /// Jours d'activité (date début → date fin inclus).
  int get _joursActivite {
    final a = _activiteChoisie;
    if (a == null || a.dateDebut == null || a.dateFin == null) return 0;
    final d = DateTime(a.dateDebut!.year, a.dateDebut!.month, a.dateDebut!.day);
    final f = DateTime(a.dateFin!.year, a.dateFin!.month, a.dateFin!.day);
    return f.difference(d).inDays + 1;
  }

  /// Jours d'activité retenus pour le calcul (au moins 1).
  int get _joursActiviteRetenus => _joursActivite > 0 ? _joursActivite : 1;

  /// Délai de route (aller + retour) du district de l'activité.
  double get _delaiRouteActivite {
    if (_delaiRoute.text.trim().isNotEmpty) return _nombre(_delaiRoute);
    final a = _activiteChoisie;
    if (a == null || (a.district ?? '').isEmpty) return 0;
    final d = _districtParNom(a.district!);
    return d?.delaiRouteTotal ?? 0;
  }

  double get _totalJours => _delaiRouteActivite + _joursActiviteRetenus;

  /// Zone d'indemnité déduite du district (chef-lieu de région ou district).
  String get _zone {
    final a = _activiteChoisie;
    if (a == null || (a.district ?? '').isEmpty) return 'Région';
    final d = _districtParNom(a.district!);
    if (d == null) return 'Région';
    return d.estChefLieuRegion ? 'Région' : 'District';
  }

  /// Taux d'indemnité pré-rempli depuis `REFERENTIEL_TARIFS`.
  double _tauxIndemnite(String ligne) {
    final tarifs =
        ref.read(tousTarifsProvider).value ?? const <TarifReferentiel>[];
    TarifReferentiel? trouve;
    for (final t in tarifs) {
      if (t.ligneBudgetaire.trim().toLowerCase() ==
          ligne.trim().toLowerCase()) {
        if (t.zone.trim().toLowerCase() == _zone.toLowerCase()) return t.tarif;
        trouve ??= t;
      }
    }
    if (trouve != null) return trouve.tarif;
    // Recherche par mots-clés (les libellés diffèrent légèrement).
    for (final t in tarifs) {
      if (t.ligneBudgetaire.toUpperCase().contains('INDEMNIT') &&
          t.zone.trim().toLowerCase() == _zone.toLowerCase()) {
        return t.tarif;
      }
    }
    return _zone.toLowerCase() == 'région' ? 200000 : 150000;
  }

  /// Taux réellement appliqué : celui saisi, sinon celui du référentiel.
  double get _tauxApplique {
    final saisi = _nombre(_taux);
    if (saisi > 0) return saisi;
    return _tauxIndemnite(_ligne.text);
  }

  /// Consommation (L/km) du type de véhicule choisi.
  double get _consommation {
    final regles = ref.read(reglesParametresProvider).value;
    if (regles == null) return 0;
    final cle = _vehicule.text.trim().toLowerCase();
    if (cle.isEmpty) return 0;
    for (final e in regles.consommationCarburant.entries) {
      if (e.key.toLowerCase() == cle || e.key.toLowerCase().contains(cle)) {
        return e.value;
      }
    }
    return 0;
  }

  /// District de référence pour la distance : le **lieu de destination**.
  ///
  /// Le référentiel `DISTANCES_DISTRICTS` ne connaît que les distances depuis
  /// Antananarivo : le trajet est donc toujours Antananarivo → district de
  /// destination (comme la ligne « Carburant » du classeur `BUDGET`, libellée
  /// « Si Trajet Antananarivo vers … »). La provenance n'est plus saisie.
  District? get _districtDistance => _districtParNom(_destination.text);

  /// Distance **aller** (km), calculée automatiquement.
  double get _distanceAllerKm => _districtDistance?.distanceAllerKm ?? 0;

  /// Distance **retour** (km) : même trajet qu'à l'aller.
  double get _distanceRetourKm => _distanceAllerKm;

  /// Distance aller-retour calculée automatiquement.
  double get _distanceARAuto => ReglesMetier.distanceAllerRetour(
    distanceAllerKm: _distanceAllerKm,
    distanceCarburantKm: _districtDistance?.distanceCarburantKm ?? 0,
  );

  /// Distance aller-retour retenue : la valeur forcée si elle est saisie,
  /// sinon la distance calculée.
  double get _distanceAR {
    final force = _nombre(_distance);
    return force > 0 ? force : _distanceARAuto;
  }

  // --- Calculs ------------------------------------------------------------

  double get _tauxForfaitaire {
    final lieu = _destination.text.trim();
    final districts =
        ref.read(tousDistrictsProvider).value ?? const <District>[];
    if (lieu.isEmpty || lieu.toUpperCase() == 'ANTANANARIVO') return 50000;
    for (final d in districts) {
      if (d.nom.toLowerCase() == lieu.toLowerCase()) {
        return d.estChefLieuRegion ? 30000 : 20000;
      }
    }
    return 20000;
  }

  /// Montant alloué selon le type déduit de la ligne budgétaire.
  double get _montantCalcule {
    switch (_type) {
      case TypeBudget.indemnitesEquipes:
      case TypeBudget.indemnitesChauffeurs:
        return ReglesMetier.indemniteTotale(
          participants: _nombre(_personnes).round(),
          delaiRoute: _delaiRouteActivite,
          joursActivite: _joursActiviteRetenus.toDouble(),
          taux: _tauxApplique,
          avecDejeuner: false,
          abattementRepas: false,
        );
      case TypeBudget.deplacementForfaitaire:
        return _nombre(_quantite) * _tauxForfaitaire;
      case TypeBudget.transfert:
      case TypeBudget.taxiBrousse:
        return _nombre(_quantite) *
            _nombre(_frequence, defaut: 1) *
            _nombre(_pu);
      case TypeBudget.billetAvion:
        return _nombre(_quantite) * _nombre(_pu);
      case TypeBudget.carburant:
        return ReglesMetier.montantCarburant(
          distanceAllerRetourKm: _distanceAR,
          consommation: _consommation,
          voitures: _nombre(_voitures).round(),
          prixUnitaire: _nombre(_pu),
        );
      case TypeBudget.location:
        return _nombre(_voitures) * _totalJours * _nombre(_pu);
      case TypeBudget.restauration:
        return _nombre(_quantite) *
            _joursActiviteRetenus *
            _nombre(_frequence, defaut: 1) *
            _nombre(_pu);
      case TypeBudget.fournitures:
        return _nombre(_quantite) *
            _nombre(_pu) *
            _nombre(_frequence, defaut: 1);
      default:
        return ReglesMetier.montantAlloue(
          quantite: _nombre(_quantite),
          nombreJours: _nombre(_jours),
          tauxUnitaire: _nombre(_taux),
        );
    }
  }

  /// Quantité stockée (valeur principale du type).
  double get _quantiteStockee => switch (_type) {
    TypeBudget.indemnitesEquipes ||
    TypeBudget.indemnitesChauffeurs => _nombre(_personnes),
    TypeBudget.deplacementForfaitaire ||
    TypeBudget.transfert ||
    TypeBudget.taxiBrousse ||
    TypeBudget.billetAvion => _nombre(_quantite),
    TypeBudget.carburant => _distanceAR,
    TypeBudget.location => _nombre(_voitures),
    TypeBudget.restauration || TypeBudget.fournitures => _nombre(_quantite),
    _ => _nombre(_quantite),
  };

  /// Jours / multiplicateur stocké.
  double get _joursStockes => switch (_type) {
    TypeBudget.indemnitesEquipes ||
    TypeBudget.indemnitesChauffeurs ||
    TypeBudget.location => _totalJours.toDouble(),
    TypeBudget.deplacementForfaitaire => 1,
    TypeBudget.transfert ||
    TypeBudget.taxiBrousse => _nombre(_frequence, defaut: 1),
    TypeBudget.billetAvion => 1,
    TypeBudget.carburant => _nombre(_voitures),
    TypeBudget.restauration => _joursActiviteRetenus.toDouble(),
    TypeBudget.fournitures => _nombre(_frequence, defaut: 1),
    _ => _nombre(_jours),
  };

  /// Taux / PU nominal stocké (la formule du type reste explicite).
  double get _tauxStocke => switch (_type) {
    TypeBudget.indemnitesEquipes ||
    TypeBudget.indemnitesChauffeurs => _tauxApplique,
    TypeBudget.deplacementForfaitaire => _tauxForfaitaire,
    TypeBudget.transfert ||
    TypeBudget.taxiBrousse ||
    TypeBudget.billetAvion ||
    TypeBudget.carburant ||
    TypeBudget.location ||
    TypeBudget.restauration ||
    TypeBudget.fournitures => _nombre(_pu),
    _ => _nombre(_taux),
  };

  String get _uniteCalculee => switch (_type) {
    TypeBudget.indemnitesEquipes ||
    TypeBudget.indemnitesChauffeurs => 'personne-jour',
    TypeBudget.deplacementForfaitaire => 'personne',
    TypeBudget.transfert => 'transfert',
    TypeBudget.taxiBrousse => 'trajet',
    TypeBudget.billetAvion => 'billet',
    TypeBudget.carburant => 'km-voiture',
    TypeBudget.location => 'voiture-jour',
    TypeBudget.restauration => 'unité-jour',
    TypeBudget.fournitures => 'unité',
    _ => _unite.text.trim().isEmpty ? 'jour-personne' : _unite.text.trim(),
  };

  Map<String, dynamic> get _details => switch (_type) {
    TypeBudget.indemnitesEquipes || TypeBudget.indemnitesChauffeurs => {
      'type': _type,
      'personnes': _nombre(_personnes).round(),
      'delaiRoute': _delaiRouteActivite,
      'joursActivite': _joursActiviteRetenus,
      'taux': _tauxApplique,
      'zone': _zone,
      if (_type == TypeBudget.indemnitesEquipes) 'restauration': _restauration,
      'abattementRepas': _type == TypeBudget.indemnitesEquipes,
    },
    TypeBudget.deplacementForfaitaire => {
      'type': _type,
      'provenance': _provenance.text.trim(),
      'destination': _destination.text.trim(),
      'taux': _tauxForfaitaire,
      'quantite': _nombre(_quantite),
    },
    TypeBudget.transfert ||
    TypeBudget.taxiBrousse ||
    TypeBudget.billetAvion => {
      'type': _type,
      'provenance': _provenance.text.trim(),
      'destination': _destination.text.trim(),
      'quantite': _nombre(_quantite),
      'frequence': _nombre(_frequence, defaut: 1),
      'pu': _nombre(_pu),
    },
    TypeBudget.carburant => {
      'type': _type,
      'destination': _destination.text.trim(),
      'distanceAller': _distanceAllerKm,
      'distanceRetour': _distanceRetourKm,
      'distance': _distanceAR,
      'distanceForce': _nombre(_distance),
      'vehicule': _vehicule.text.trim(),
      'consommation': _consommation,
      'voitures': _nombre(_voitures).round(),
      'pu': _nombre(_pu),
    },
    TypeBudget.location => {
      'type': _type,
      'voitures': _nombre(_voitures).round(),
      'delaiRoute': _delaiRouteActivite,
      'joursActivite': _joursActiviteRetenus,
      'pu': _nombre(_pu),
    },
    TypeBudget.restauration => {
      'type': _type,
      'quantite': _nombre(_quantite),
      'joursActivite': _joursActiviteRetenus,
      'frequence': _nombre(_frequence, defaut: 1),
      'pu': _nombre(_pu),
    },
    TypeBudget.fournitures => {
      'type': _type,
      'quantite': _nombre(_quantite),
      'frequence': _nombre(_frequence, defaut: 1),
      'pu': _nombre(_pu),
    },
    _ => {'type': _type},
  };

  // --- Pré-remplissages automatiques -------------------------------------

  /// Sélection d'une activité : jours d'activité, délai de route, repas.
  void _surActivite(String code) {
    final a = _activiteChoisie;
    if (a == null) return;
    setState(() {
      final d = (a.district ?? '').isEmpty
          ? null
          : _districtParNom(a.district!);
      if (d != null) _delaiRoute.text = _chiffre(d.delaiRouteTotal);
      // Le taux d'indemnité dépend de la zone du district de l'activité.
      if (_type == TypeBudget.indemnitesEquipes ||
          _type == TypeBudget.indemnitesChauffeurs) {
        _taux.text = _chiffre(_tauxIndemnite(_ligne.text));
      }
      // Carburant : la destination est le lieu de l'activité ; le départ
      // est toujours Antananarivo (référentiel des distances).
      if (_type == TypeBudget.carburant) _preRemplirTrajet(a);
    });
  }

  /// Pré-remplit la destination (district de l'activité) sans jamais écraser
  /// une saisie existante.
  void _preRemplirTrajet(Activite a) {
    if (_destination.text.trim().isEmpty) {
      final lieu = (a.district ?? '').trim();
      if (lieu.isNotEmpty) _destination.text = lieu;
    }
  }

  List<String> _lignesPourRubrique(
    List<TarifReferentiel> tarifs,
    List<String> toutes,
  ) {
    final rubrique = _rubrique.text.trim().toLowerCase();
    if (rubrique.isEmpty) return toutes;
    final resultat = <String>{};
    for (final t in tarifs) {
      if (t.rubrique.trim().toLowerCase() == rubrique &&
          t.ligneBudgetaire.trim().isNotEmpty) {
        resultat.add(t.ligneBudgetaire.trim());
      }
    }
    if (resultat.isEmpty) return toutes;
    return resultat.toList()..sort();
  }

  void _surRubrique(String valeur) {
    setState(() {
      _rubrique.text = valeur;
      final tarifs =
          ref.read(tousTarifsProvider).value ?? const <TarifReferentiel>[];
      final lignes = _lignesPourRubrique(
        tarifs,
        ref.read(valeursListeProvider('LIGNE_BUDGETAIRE')).value ?? const [],
      );
      if (_ligne.text.isNotEmpty && !lignes.contains(_ligne.text)) {
        _ligne.clear();
      }
      _montantConfirme = false;
    });
  }

  /// Rubriques déclarées dans les **paramètres** (`REFERENTIEL_TARIFS`, plus la
  /// liste `RUBRIQUE`). Aucune ligne budgétaire ne peut en sortir.
  List<String> get _rubriquesParametres {
    final tarifs =
        ref.read(tousTarifsProvider).value ?? const <TarifReferentiel>[];
    final liste =
        ref.read(valeursListeProvider('RUBRIQUE')).value ?? const <String>[];
    final vues = <String>[];
    // Les rubriques de la configuration (créées ou renommées par
    // l'utilisateur) font référence au même titre que le référentiel.
    final configurees = ref.read(configurationProvider).nomsRubriques;
    for (final brute in [
      ...configurees,
      ...liste,
      ...tarifs.map((t) => t.rubrique),
    ]) {
      final r = brute.trim();
      if (r.isEmpty) continue;
      if (vues.any(
        (v) => RubriquesBudget.normaliser(v) == RubriquesBudget.normaliser(r),
      )) {
        continue;
      }
      vues.add(r);
    }
    vues.sort();
    return vues;
  }

  /// Rubrique correspondante, **trouvée dans les paramètres** à partir du
  /// libellé de la ligne (et de son type) : il n'existe pas de rubrique libre.
  String _rubriqueAutomatique(String ligne) => RubriquesBudget.resoudreAvec(
    configuration: ref.read(configurationProvider),
    ligneBudgetaire: ligne,
    typeBudget: _type,
    rubriqueEnregistree: _rubrique.text,
    rubriquesReferentiel: _rubriquesParametres,
  );

  void _confirmerMontantAlloue() {
    final montant = _nombre(_montantAlloue);
    if (montant <= 0) {
      notifier(
        context,
        'Saisissez un montant alloué supérieur à 0.',
        erreur: true,
      );
      return;
    }
    setState(() => _montantConfirme = true);
  }

  void _annulerConfirmationMontant() {
    setState(() => _montantConfirme = false);
  }

  /// Sélection d'une ligne budgétaire : **type déduit automatiquement** et
  /// valeurs par défaut pré-remplies.
  void _surLigne(String ligne) {
    setState(() {
      _type = TypeBudget.typePourLigne(ligne);
      // La rubrique n'est jamais saisie : elle est retrouvée dans les
      // paramètres d'après la ligne choisie.
      _rubrique.text = _rubriqueAutomatique(ligne);
      _appliquerDefauts();
    });
  }

  /// Valeurs par défaut cohérentes avec le type courant.
  void _appliquerDefauts() {
    final tarifs =
        ref.read(tousTarifsProvider).value ?? const <TarifReferentiel>[];
    TarifReferentiel? tarif;
    for (final t in tarifs) {
      if (t.ligneBudgetaire.trim().toLowerCase() ==
          _ligne.text.trim().toLowerCase()) {
        if (t.zone.trim().toLowerCase() == _zone.toLowerCase()) {
          tarif = t;
          break;
        }
        tarif ??= t;
      }
    }
    switch (_type) {
      case TypeBudget.indemnitesEquipes:
      case TypeBudget.indemnitesChauffeurs:
        _taux.text = _chiffre(_tauxIndemnite(_ligne.text));
        if (_nombre(_personnes) <= 0) _personnes.text = '1';
      case TypeBudget.deplacementForfaitaire:
        if (_nombre(_quantite) <= 0) _quantite.text = '1';
        if (_destination.text.trim().isEmpty) {
          _destination.text = _activiteChoisie?.district ?? '';
        }
      case TypeBudget.transfert:
      case TypeBudget.taxiBrousse:
        if (_nombre(_quantite) <= 0) _quantite.text = '1';
        if (_nombre(_frequence, defaut: 1) <= 0) _frequence.text = '1';
        if (_nombre(_pu) <= 0 && tarif != null)
          _pu.text = _chiffre(tarif.tarif);
      case TypeBudget.billetAvion:
        if (_nombre(_quantite) <= 0) _quantite.text = '1';
      case TypeBudget.carburant:
        if (_vehicule.text.trim().isEmpty) _vehicule.text = '4x4';
        if (_nombre(_voitures) <= 0) _voitures.text = '1';
        if (_nombre(_pu) <= 0) _pu.text = '4860';
        final activite = _activiteChoisie;
        if (activite != null) _preRemplirTrajet(activite);
      case TypeBudget.location:
        if (_nombre(_voitures) <= 0) _voitures.text = '1';
        if (_nombre(_pu) <= 0 && tarif != null)
          _pu.text = _chiffre(tarif.tarif);
      case TypeBudget.restauration:
      case TypeBudget.fournitures:
        if (_nombre(_pu) <= 0 && tarif != null)
          _pu.text = _chiffre(tarif.tarif);
        if (_nombre(_frequence, defaut: 1) <= 0) _frequence.text = '1';
      default:
        if (_nombre(_taux) <= 0 && tarif != null)
          _taux.text = _chiffre(tarif.tarif);
    }
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_montantConfirme) {
      notifier(context, 'Confirmez d’abord le montant alloué.', erreur: true);
      return;
    }
    final repo = ref.read(lignesBudgetRepositoryProvider);
    final details = _details;
    details['type'] = _type;
    // Toujours une rubrique issue des paramètres : à défaut de choix explicite,
    // elle est retrouvée d'après le libellé de la ligne budgétaire.
    final rubriqueRetenue = _rubrique.text.trim().isEmpty
        ? _rubriqueAutomatique(_ligne.text)
        : _rubrique.text.trim();
    _rubrique.text = rubriqueRetenue;
    details['rubrique'] = rubriqueRetenue;
    details['montantPrevisionnel'] = _montantCalcule;
    details['montantAlloueConfirme'] = _nombre(_montantAlloue);
    details['montantAlloueConfirmeEtat'] = _montantConfirme;
    final companion = LignesBudgetCompanion(
      activiteCode: drift.Value(_activite.text.trim()),
      activiteLibelle: drift.Value(_activiteChoisie?.description),
      dateDebutPrevue: drift.Value(_activiteChoisie?.dateDebut),
      dateFinPrevue: drift.Value(_activiteChoisie?.dateFin),
      ligneBudgetaire: drift.Value(_ligne.text.trim()),
      typeBudget: drift.Value(_type),
      unite: drift.Value(_uniteCalculee),
      quantitePrevue: drift.Value(_quantiteStockee),
      nombreJours: drift.Value(_joursStockes),
      tauxUnitaire: drift.Value(_tauxStocke),
      montantAlloue: drift.Value(
        _montantConfirme ? _nombre(_montantAlloue) : 0,
      ),
      details: drift.Value(jsonEncode(details)),
      observation: drift.Value(_observation.text.trim()),
    );
    if (widget.ligne == null) {
      await repo.insert(companion);
    } else {
      await repo.update(widget.ligne!.id, companion);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final codesActivite =
        ref.watch(activitesCodesProvider).value ?? const <String>[];
    final lignesRef =
        ref.watch(valeursListeProvider('LIGNE_BUDGETAIRE')).value ?? const [];
    final tarifsRef =
        ref.watch(tousTarifsProvider).value ?? const <TarifReferentiel>[];
    final rubriquesRef = <String>{
      ...ref.watch(valeursListeProvider('RUBRIQUE')).value ?? const <String>[],
      ...tarifsRef.map((t) => t.rubrique),
    }.where((e) => e.trim().isNotEmpty).toList()..sort();
    final lignesDisponibles = _lignesPourRubrique(tarifsRef, lignesRef);
    final existantes =
        ref.watch(lignesBudgetProvider).value ?? const <LigneBudget>[];
    final districts =
        ref.watch(tousDistrictsProvider).value ?? const <District>[];
    final regles = ref.watch(reglesParametresProvider).value;
    final vehicules = {
      ...(regles?.consommationCarburant.keys ?? const <String>[]),
    }.toList();

    return AlertDialog(
      title: TitreDialogue(
        widget.ligne == null
            ? 'Nouvelle ligne budgétaire'
            : 'Modifier la ligne budgétaire',
        icone: Icons.savings_outlined,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 700),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BandeauType(type: TypeBudget.parId(_type)),
                const SizedBox(height: 12),
                _paire(
                  ChampListe(
                    controller: _activite,
                    label: 'Code activité *',
                    hint: 'PSN N°1',
                    valeurs: codesActivite,
                    prefixIcon: Icons.confirmation_number_outlined,
                    onChanged: _surActivite,
                    validator: (v) => validateurReference(
                      v,
                      codesActivite,
                      champ: 'Le code activité',
                    ),
                  ),
                  ChampListe(
                    controller: _rubrique,
                    label: 'Rubrique (déduite des paramètres) *',
                    hint: 'Choisissez d’abord la ligne budgétaire',
                    helperText:
                        'Trouvée automatiquement dans les paramètres : '
                        'aucune rubrique libre.',
                    valeurs: rubriquesRef,
                    prefixIcon: Icons.category_outlined,
                    onChanged: _surRubrique,
                    validator: (v) => validateurReference(
                      v,
                      rubriquesRef,
                      champ: 'La rubrique',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ChampListe(
                  controller: _ligne,
                  label: 'Ligne budgétaire *',
                  hint: 'Sélectionnez d’abord la rubrique',
                  valeurs: lignesDisponibles,
                  prefixIcon: Icons.receipt_outlined,
                  onChanged: _surLigne,
                  validator: (v) => validateurReference(
                    v,
                    lignesDisponibles,
                    champ: 'La ligne budgétaire',
                  ),
                ),
                const SizedBox(height: 14),
                _champsSelonType(vehicules, districts),
                const SizedBox(height: 14),
                _EncadreMontant(montant: _montantCalcule),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ChampNombre(
                        controller: _montantAlloue,
                        label: 'Montant alloué (Ar)',
                        step: 1000,
                        onChanged: () =>
                            setState(() => _montantConfirme = false),
                        validator: (v) =>
                            validateurMontant(v, obligatoire: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: FilledButton.tonalIcon(
                        onPressed: _montantConfirme
                            ? _annulerConfirmationMontant
                            : _confirmerMontantAlloue,
                        icon: Icon(
                          _montantConfirme
                              ? Icons.undo_outlined
                              : Icons.verified_outlined,
                        ),
                        label: Text(
                          _montantConfirme
                              ? 'Annuler la confirmation'
                              : 'Confirmer',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _montantConfirme
                      ? 'Le montant alloué confirmé sera intégré aux suivis et rapports.'
                      : 'Le montant prévisionnel calculé ci-dessus reste distinct du montant alloué confirmé.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                ChampListe(
                  controller: _observation,
                  label: 'Observation',
                  valeurs: _distinctes(existantes, (l) => l.observation ?? ''),
                  prefixIcon: Icons.notes_outlined,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: _enregistrer,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Enregistrer'),
        ),
      ],
    );
  }

  Widget _paire(Widget a, Widget b) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: a),
      const SizedBox(width: 12),
      Expanded(child: b),
    ],
  );

  /// Petite carte « valeur calculée automatiquement ».
  Widget _lecture(String label, String valeur, IconData icone) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(8),
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              icone,
              size: 15,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          valeur,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ],
    ),
  );

  Widget _champsSelonType(List<String> vehicules, List<District> districts) {
    final nomsDistricts = [for (final d in districts) d.nom];
    switch (_type) {
      case TypeBudget.indemnitesEquipes:
      case TypeBudget.indemnitesChauffeurs:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _paire(
              ChampNombre(
                controller: _personnes,
                label: 'Nombre de personnes',
                validator: (v) =>
                    validateurNombrePositif(v, champ: 'Le nombre de personnes'),
                onChanged: () => setState(() {}),
              ),
              ChampNombre(
                controller: _delaiRoute,
                label: 'Délai de route A/R (jours)',
                validator: (v) => validateurNombrePositif(
                  v,
                  champ: 'Le délai de route',
                  obligatoire: false,
                  zeroAutorise: true,
                ),
                decimales: true,
                step: 0.5,
                onChanged: () => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),
            _paire(
              _lecture(
                'Jours d’activité',
                '$_joursActiviteRetenus',
                Icons.event_available_outlined,
              ),
              ChampNombre(
                controller: _taux,
                label: 'Taux d’indemnité (Ar)',
                validator: (v) => validateurNombrePositif(v, champ: 'Le taux'),
                step: 1000,
                onChanged: () => setState(() {}),
              ),
            ),
          ],
        );
      case TypeBudget.deplacementForfaitaire:
        return Column(
          children: [
            _paire(
              ChampListe(
                controller: _provenance,
                label: 'Provenance',
                validator: (v) => validateurReference(
                  v,
                  nomsDistricts,
                  champ: 'La provenance',
                  obligatoire: false,
                ),
                valeurs: nomsDistricts,
                prefixIcon: Icons.flight_takeoff_outlined,
                onChanged: (_) => setState(() {}),
              ),
              ChampListe(
                controller: _destination,
                label: 'Lieu d’activité',
                validator: (v) => validateurReference(
                  v,
                  nomsDistricts,
                  champ: 'Le lieu',
                  obligatoire: false,
                ),
                valeurs: nomsDistricts,
                prefixIcon: Icons.location_on_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),
            _paire(
              ChampNombre(
                controller: _quantite,
                label: 'Nombre de personnes',
                validator: (v) =>
                    validateurNombrePositif(v, champ: 'La quantité'),
                onChanged: () => setState(() {}),
              ),
              _lecture(
                'Taux automatique',
                formatMontant(_tauxForfaitaire),
                Icons.auto_awesome_outlined,
              ),
            ),
          ],
        );
      case TypeBudget.transfert:
      case TypeBudget.taxiBrousse:
        return Column(
          children: [
            _paire(
              ChampListe(
                controller: _provenance,
                label: 'Provenance',
                validator: (v) => validateurReference(
                  v,
                  nomsDistricts,
                  champ: 'La provenance',
                  obligatoire: false,
                ),
                valeurs: nomsDistricts,
                prefixIcon: Icons.flight_takeoff_outlined,
              ),
              ChampListe(
                controller: _destination,
                label: 'Lieu d’activité',
                validator: (v) => validateurReference(
                  v,
                  nomsDistricts,
                  champ: 'Le lieu',
                  obligatoire: false,
                ),
                valeurs: nomsDistricts,
                prefixIcon: Icons.location_on_outlined,
              ),
            ),
            const SizedBox(height: 12),
            _paire(
              ChampNombre(
                controller: _quantite,
                label: 'Quantité',
                validator: (v) =>
                    validateurNombrePositif(v, champ: 'La quantité'),
                onChanged: () => setState(() {}),
              ),
              ChampNombre(
                controller: _frequence,
                label: 'Fréquence',
                validator: (v) =>
                    validateurNombrePositif(v, champ: 'La fréquence'),
                onChanged: () => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),
            ChampNombre(
              controller: _pu,
              label: 'Taux unitaire (Ar)',
              validator: (v) =>
                  validateurNombrePositif(v, champ: 'Le prix unitaire'),
              step: 1000,
              onChanged: () => setState(() {}),
            ),
          ],
        );
      case TypeBudget.billetAvion:
        return _paire(
          ChampNombre(
            controller: _quantite,
            label: 'Nombre de billets',
            validator: (v) => validateurNombrePositif(v, champ: 'La quantité'),
            onChanged: () => setState(() {}),
          ),
          ChampNombre(
            controller: _pu,
            label: 'Montant du billet (Ar)',
            validator: (v) =>
                validateurNombrePositif(v, champ: 'Le prix unitaire'),
            step: 1000,
            onChanged: () => setState(() {}),
          ),
        );
      case TypeBudget.carburant:
        final aller = _distanceAllerKm;
        final retour = _distanceRetourKm;
        final aro = _distanceARAuto;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _paire(
              _lecture('Départ', 'Antananarivo', Icons.trip_origin_outlined),
              ChampListe(
                controller: _destination,
                label: 'Lieu de destination',
                validator: (v) => validateurReference(
                  v,
                  nomsDistricts,
                  champ: 'Le lieu',
                  obligatoire: false,
                ),
                valeurs: nomsDistricts,
                prefixIcon: Icons.location_on_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),
            _paire(
              _lecture(
                'Distance aller (km)',
                aller > 0 ? _chiffre(aller) : '—',
                Icons.arrow_forward_outlined,
              ),
              _lecture(
                'Distance retour (km)',
                retour > 0 ? _chiffre(retour) : '—',
                Icons.arrow_back_outlined,
              ),
            ),
            const SizedBox(height: 12),
            _lecture(
              'Distance aller-retour (km)',
              aro > 0 ? _chiffre(aro) : '—',
              Icons.route_outlined,
            ),
            const SizedBox(height: 12),
            _paire(
              ChampListe(
                controller: _vehicule,
                label: 'Type de véhicule',
                validator: (v) => validateurReference(
                  v,
                  vehicules,
                  champ: 'Le type de véhicule',
                  obligatoire: false,
                ),
                valeurs: vehicules,
                prefixIcon: Icons.directions_car_outlined,
                onChanged: (_) => setState(() {}),
              ),
              ChampNombre(
                controller: _voitures,
                label: 'Nombre de voitures',
                validator: (v) =>
                    validateurNombrePositif(v, champ: 'Le nombre de voitures'),
                onChanged: () => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),
            _paire(
              ChampNombre(
                controller: _pu,
                label: 'Prix unitaire carburant (Ar/L)',
                validator: (v) =>
                    validateurNombrePositif(v, champ: 'Le prix unitaire'),
                step: 100,
                onChanged: () => setState(() {}),
              ),
              ChampNombre(
                controller: _distance,
                label: 'Ajuster distance A/R (km)',
                validator: (v) => validateurNombrePositif(
                  v,
                  champ: 'La distance',
                  obligatoire: false,
                  zeroAutorise: true,
                ),
                decimales: true,
                onChanged: () => setState(() {}),
              ),
            ),
          ],
        );
      case TypeBudget.location:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _paire(
              ChampNombre(
                controller: _voitures,
                label: 'Nombre de voitures',
                validator: (v) =>
                    validateurNombrePositif(v, champ: 'Le nombre de voitures'),
                onChanged: () => setState(() {}),
              ),
              ChampNombre(
                controller: _pu,
                label: 'Prix unitaire par jour (Ar)',
                validator: (v) =>
                    validateurNombrePositif(v, champ: 'Le prix unitaire'),
                step: 1000,
                onChanged: () => setState(() {}),
              ),
            ),
            const SizedBox(height: 8),
            _lecture(
              'Nombre de jours',
              '$_totalJours',
              Icons.event_available_outlined,
            ),
          ],
        );
      case TypeBudget.restauration:
        return Column(
          children: [
            _paire(
              ChampNombre(
                controller: _quantite,
                label: 'Quantité par jour',
                validator: (v) =>
                    validateurNombrePositif(v, champ: 'La quantité'),
                onChanged: () => setState(() {}),
              ),
              ChampNombre(
                controller: _frequence,
                label: 'Fréquence',
                validator: (v) =>
                    validateurNombrePositif(v, champ: 'La fréquence'),
                onChanged: () => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),
            _paire(
              ChampNombre(
                controller: _pu,
                label: 'Prix unitaire (Ar)',
                validator: (v) =>
                    validateurNombrePositif(v, champ: 'Le prix unitaire'),
                step: 1000,
                onChanged: () => setState(() {}),
              ),
              _lecture(
                'Jours d’activité',
                '$_joursActiviteRetenus',
                Icons.event_available_outlined,
              ),
            ),
          ],
        );
      case TypeBudget.fournitures:
        return Column(
          children: [
            _paire(
              ChampNombre(
                controller: _quantite,
                label: 'Quantité',
                validator: (v) =>
                    validateurNombrePositif(v, champ: 'La quantité'),
                onChanged: () => setState(() {}),
              ),
              ChampNombre(
                controller: _pu,
                label: 'Prix unitaire (Ar)',
                validator: (v) =>
                    validateurNombrePositif(v, champ: 'Le prix unitaire'),
                step: 1000,
                onChanged: () => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),
            ChampNombre(
              controller: _frequence,
              label: 'Fréquence',
              validator: (v) =>
                  validateurNombrePositif(v, champ: 'La fréquence'),
              onChanged: () => setState(() {}),
            ),
          ],
        );
      default:
        return Column(
          children: [
            _paire(
              ChampListe(
                controller: _unite,
                label: 'Unité',
                valeurs: _distinctes(
                  ref.watch(lignesBudgetProvider).value ?? const [],
                  (l) => l.unite,
                ),
                prefixIcon: Icons.straighten_outlined,
              ),
              ChampNombre(
                controller: _quantite,
                label: 'Quantité prévue',
                validator: (v) =>
                    validateurNombrePositif(v, champ: 'La quantité'),
                onChanged: () => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),
            _paire(
              ChampNombre(
                controller: _jours,
                label: 'Nombre de jours',
                validator: (v) => validateurNombrePositif(
                  v,
                  champ: 'Le nombre de jours',
                  zeroAutorise: true,
                ),
                onChanged: () => setState(() {}),
              ),
              ChampNombre(
                controller: _taux,
                label: 'Taux unitaire (Ar)',
                validator: (v) => validateurNombrePositif(v, champ: 'Le taux'),
                step: 1000,
                onChanged: () => setState(() {}),
              ),
            ),
          ],
        );
    }
  }
}

/// Bandeau indiquant le type de budget **déduit automatiquement** du libellé.
class _BandeauType extends StatelessWidget {
  const _BandeauType({required this.type});
  final TypeBudget type;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final automatique = type.id != TypeBudget.libres;
    final couleur = automatique ? scheme.primary : scheme.onSurfaceVariant;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: couleur.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            automatique
                ? Icons.auto_awesome_outlined
                : Icons.edit_note_outlined,
            size: 18,
            color: couleur,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Type de budget : ${type.libelle}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: couleur,
                        ),
                      ),
                    ),
                    Text(
                      automatique ? 'Automatique' : 'À choisir par le libellé',
                      style: TextStyle(fontSize: 11, color: couleur),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  automatique
                      ? 'Les valeurs sont pré-remplies automatiquement.'
                      : 'Choisissez une ligne budgétaire reconnue pour un '
                            'pré-remplissage automatique.',
                  style: const TextStyle(fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Encadré du montant calculé automatiquement.
///
/// Le détail du calcul n'est volontairement **pas** affiché : seul le montant
/// alloué est présenté (les formules restent appliquées en interne).
class _EncadreMontant extends StatelessWidget {
  const _EncadreMontant({required this.montant});

  final double montant;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.calculate_outlined, size: 22, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Budget prévisionnel (calculé automatiquement)',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatMontant(montant),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Résumé du calcul d'une ligne déjà enregistrée
// ---------------------------------------------------------------------------

double _num(Object? v) {
  if (v is num) return v.toDouble();
  return double.tryParse('$v'.replaceAll(',', '.')) ?? 0;
}

/// Résumé lisible du calcul d'une ligne budgétaire enregistrée, reconstruit
/// depuis les paramètres du générateur (`details`). Utilisé par le tableau des
/// budgets et l'aperçu.
String resumeLigneBudget(LigneBudget ligne) {
  Map<String, dynamic> d;
  try {
    d = ligne.details == null || ligne.details!.trim().isEmpty
        ? <String, dynamic>{}
        : (jsonDecode(ligne.details!) as Map).cast<String, dynamic>();
  } catch (_) {
    d = <String, dynamic>{};
  }
  switch (ligne.typeBudget) {
    case TypeBudget.indemnitesEquipes:
    case TypeBudget.indemnitesChauffeurs:
      final personnes = _num(d['personnes']).round();
      final delai = _num(d['delaiRoute']);
      final jours = _num(d['joursActivite']).round();
      final taux = _num(d['taux']) > 0 ? _num(d['taux']) : ligne.tauxUnitaire;
      final avecDejeuner = d['restauration'] == true;
      final abattement = ligne.typeBudget == TypeBudget.indemnitesEquipes;
      final tauxActivite = abattement && avecDejeuner ? taux * 0.85 : taux;
      return '$personnes pers. × [ route ${_nb(delai)} j × '
          '${formatMontant(taux)} + $jours j × ${formatMontant(tauxActivite)} ]';
    case TypeBudget.carburant:
      final aller = _num(d['distanceAller']);
      final retour = _num(d['distanceRetour']);
      final conso = _num(d['consommation']);
      final voitures = _num(d['voitures']).round();
      final pu = _num(d['pu']);
      final aro = aller > 0 ? aller + retour : ligne.quantitePrevue;
      return '${_nb(aro)} km A/R'
          '${conso > 0 ? ' × ${conso.toStringAsFixed(2)} L/km' : ''}'
          ' × $voitures voiture(s) × ${formatMontant(pu)}';
    case TypeBudget.location:
      return '${_num(d['voitures']).round()} voiture(s) × '
          '${_nb(_num(d['delaiRoute']) + _num(d['joursActivite']))} j '
          '× ${formatMontant(_num(d['pu']))}';
    case TypeBudget.restauration:
      return '${_nb(_num(d['quantite']))} × ${_nb(_num(d['joursActivite']))} j '
          '× fréq. ${_nb(_num(d['frequence']))} '
          '× ${formatMontant(_num(d['pu']))}';
    case TypeBudget.fournitures:
      return '${_nb(_num(d['quantite']))} × ${formatMontant(_num(d['pu']))} '
          '× fréq. ${_nb(_num(d['frequence']))}';
    default:
      return 'Quantité ${_nb(ligne.quantitePrevue)} × '
          'jours ${_nb(ligne.nombreJours)} × '
          'taux ${formatMontant(ligne.tauxUnitaire)}';
  }
}

double montantPrevisionnelLigneBudget(LigneBudget ligne) {
  try {
    final d = ligne.details == null || ligne.details!.trim().isEmpty
        ? <String, dynamic>{}
        : (jsonDecode(ligne.details!) as Map).cast<String, dynamic>();
    final valeur = d['montantPrevisionnel'];
    if (valeur is num) return valeur.toDouble();
    return double.tryParse('$valeur'.replaceAll(',', '.')) ??
        ligne.montantAlloue;
  } catch (_) {
    return ligne.montantAlloue;
  }
}

String _nb(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(2);
