import 'package:meta/meta.dart';

/// Modèles et règles issus de la feuille `PARAMETRES` de `parametres.xlsx`,
/// référence unique des règles DSFa / UNICEF.
///
/// La feuille `PARAMETRES` ne contient pas de listes de choix (celles-ci
/// restent dans `LISTES`) : uniquement les taux, consommations, seuils de
/// rapportage, sources de financement et la matrice des PJ requises.

/// Résultat d'évaluation d'une pièce requise par rapport à une date de PJ et
/// à la période de l'activité.
enum ConformitePiece {
  conforme('Conforme'),
  nonConforme('Non conforme'),
  aVerifier('À vérifier');

  const ConformitePiece(this.libelle);
  final String libelle;
}

/// Une ligne de la matrice des PJ requises (`PARAMETRES` section 5).
@immutable
class ReglePJRequise {
  const ReglePJRequise({
    required this.rubrique,
    required this.sousRubrique,
    required this.piece,
    required this.obligatoire,
    required this.regleDate,
    required this.typeControle,
    this.remarque = '',
    this.actif = true,
  });

  /// Rubrique budgétaire (RESTAURATION, FOURNITURE, INDEMNITE, …).
  final String rubrique;

  /// Sous-rubrique éventuelle (ex. « INDEMNITE CHAUFFEUR »).
  final String sousRubrique;

  /// Pièce justificative requise (ex. « FACTURE PROFORMA »).
  final String piece;

  /// La pièce est-elle obligatoire ?
  final bool obligatoire;

  /// Règle de date brute (ex. « Après date PV;Avant activité »).
  final String regleDate;

  /// `DATE` (vérification automatique) ou `MANUEL`.
  final String typeControle;
  final String remarque;
  final bool actif;

  /// Jalons de la règle de date, séparés par `;`.
  List<String> get jalons => regleDate
      .split(';')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  /// Identifiant lisible pour les listes déroulantes.
  String get libelle =>
      sousRubrique.isEmpty ? piece : '$sousRubrique — $piece';

  Map<String, dynamic> toJson() => {
    'rubrique': rubrique,
    'sousRubrique': sousRubrique,
    'piece': piece,
    'obligatoire': obligatoire,
    'regleDate': regleDate,
    'typeControle': typeControle,
    'remarque': remarque,
    'actif': actif,
  };

  factory ReglePJRequise.fromJson(Map<String, dynamic> json) => ReglePJRequise(
    rubrique: '${json['rubrique'] ?? ''}',
    sousRubrique: '${json['sousRubrique'] ?? ''}',
    piece: '${json['piece'] ?? ''}',
    obligatoire: json['obligatoire'] == true,
    regleDate: '${json['regleDate'] ?? ''}',
    typeControle: '${json['typeControle'] ?? 'DATE'}',
    remarque: '${json['remarque'] ?? ''}',
    actif: json['actif'] != false,
  );
}

/// Règles consolidées de la feuille `PARAMETRES`.
@immutable
class ReglesParametres {
  const ReglesParametres({
    this.tauxIndemnites = const {},
    this.consommationCarburant = const {},
    this.transferts = const {},
    this.forfaitaires = const {},
    this.seuilsRapportage = const {},
    this.sourcesFinancement = const [],
    this.matricePJ = const [],
  });

  /// Ex. `{'Taux Perdiem chef-lieu région': 200000}`.
  final Map<String, double> tauxIndemnites;

  /// Consommation (litres/km) par type de véhicule.
  final Map<String, double> consommationCarburant;

  /// Tarifs de transfert aéroport.
  final Map<String, double> transferts;

  /// Tarifs de déplacement forfaitaire.
  final Map<String, double> forfaitaires;

  /// Seuils de rapportage en jours (`UNICEF_ATTENTION`, `UNICEF_BLOQUE`,
  /// `AUTRES_ATTENTION`, `AUTRES_BLOQUE`).
  final Map<String, int> seuilsRapportage;

  /// Sources de financement (UNICEF, UNFPA, WISH2, UPNNC, AUTRES…).
  final List<String> sourcesFinancement;

  /// Matrice des pièces justificatives requises.
  final List<ReglePJRequise> matricePJ;

  bool get estVide =>
      tauxIndemnites.isEmpty &&
      consommationCarburant.isEmpty &&
      matricePJ.isEmpty;

  /// Rubriques distinctes de la matrice, dans l'ordre du classeur.
  List<String> get rubriques {
    final vues = <String>[];
    for (final r in matricePJ) {
      if (!vues.contains(r.rubrique)) vues.add(r.rubrique);
    }
    return vues;
  }

  /// Sous-rubriques d'une rubrique (peut contenir la chaîne vide).
  List<String> sousRubriquesDe(String rubrique) {
    final vues = <String>[];
    for (final r in matricePJ.where((e) => e.rubrique == rubrique)) {
      if (!vues.contains(r.sousRubrique)) vues.add(r.sousRubrique);
    }
    return vues;
  }

  /// Pièces requises pour une rubrique (et éventuellement une sous-rubrique),
  /// filtrées sur les lignes actives.
  List<ReglePJRequise> piecesPour(String rubrique, {String? sousRubrique}) {
    return matricePJ
        .where(
          (r) =>
              r.actif &&
              r.rubrique.toUpperCase() == rubrique.toUpperCase() &&
              (sousRubrique == null ||
                  r.sousRubrique.toUpperCase() == sousRubrique.toUpperCase()),
        )
        .toList();
  }

  Map<String, dynamic> toJson() => {
    'tauxIndemnites': tauxIndemnites,
    'consommationCarburant': consommationCarburant,
    'transferts': transferts,
    'forfaitaires': forfaitaires,
    'seuilsRapportage': seuilsRapportage,
    'sourcesFinancement': sourcesFinancement,
    'matricePJ': matricePJ.map((e) => e.toJson()).toList(),
  };

  factory ReglesParametres.fromJson(Map<String, dynamic> json) {
    Map<String, double> nombres(String cle) => (json[cle] as Map?)
        ?.map((k, v) => MapEntry('$k', _double(v))) ??
        <String, double>{};
    final seuils = (json['seuilsRapportage'] as Map?)
        ?.map((k, v) => MapEntry('$k', _double(v).round())) ??
        <String, int>{};
    final sources = (json['sourcesFinancement'] as List?)
        ?.map((e) => '$e')
        .toList() ??
        <String>[];
    final matrice = (json['matricePJ'] as List?)
        ?.whereType<Map>()
        .map((e) => ReglePJRequise.fromJson(e.cast<String, dynamic>()))
        .toList() ??
        <ReglePJRequise>[];
    return ReglesParametres(
      tauxIndemnites: nombres('tauxIndemnites'),
      consommationCarburant: nombres('consommationCarburant'),
      transferts: nombres('transferts'),
      forfaitaires: nombres('forfaitaires'),
      seuilsRapportage: seuils,
      sourcesFinancement: sources,
      matricePJ: matrice,
    );
  }

  static double _double(Object? v) {
    if (v is num) return v.toDouble();
    return double.tryParse('$v'.replaceAll(',', '.')) ?? 0;
  }
}

/// Évaluation d'une pièce requise à partir de la règle de date.
///
/// Le contrôle ne peut porter que sur la date de la PJ comparée à la période
/// de l'activité. Lorsqu'un jalon fait référence à la date d'une AUTRE pièce
/// (ex. « Après date PV »), le résultat est indéterminé et la vérification
/// est signalée « À vérifier ».
@immutable
class EvaluationPiecePJ {
  const EvaluationPiecePJ({
    required this.piece,
    required this.conformite,
    required this.jalons,
  });

  final ReglePJRequise piece;
  final ConformitePiece conformite;

  /// Détail lisible jalon → verdict (`true`, `false` ou `null` = indéterminé).
  final Map<String, bool?> jalons;

  bool get conforme => conformite == ConformitePiece.conforme;
}

/// Évaluer une pièce par rapport à la date de PJ et à la période d'activité.
EvaluationPiecePJ evaluerPiecePJ({
  required ReglePJRequise regle,
  required DateTime? datePJ,
  required DateTime? dateDebut,
  required DateTime? dateFin,
}) {
  final jalons = <String, bool?>{};
  for (final jalon in regle.jalons) {
    jalons[jalon] = _evaluerJalon(
      jalon: jalon,
      datePJ: datePJ,
      dateDebut: dateDebut,
      dateFin: dateFin,
    );
  }

  final ConformitePiece conformite;
  if (jalons.isEmpty) {
    // Aucune règle de date exploitable : contrôle manuel.
    conformite = regle.typeControle.toUpperCase() == 'MANUEL'
        ? ConformitePiece.aVerifier
        : ConformitePiece.conforme;
  } else if (jalons.values.any((v) => v == false)) {
    conformite = ConformitePiece.nonConforme;
  } else if (jalons.values.any((v) => v == null)) {
    conformite = ConformitePiece.aVerifier;
  } else {
    conformite = ConformitePiece.conforme;
  }

  return EvaluationPiecePJ(
    piece: regle,
    conformite: conformite,
    jalons: jalons,
  );
}

bool? _evaluerJalon({
  required String jalon,
  required DateTime? datePJ,
  required DateTime? dateDebut,
  required DateTime? dateFin,
}) {
  if (datePJ == null) return null;
  final j = _sansAccent(jalon).toLowerCase();
  final d = _jour(datePJ);

  // Jalons référençant une autre pièce : non vérifiables automatiquement.
  if (j.contains('date de demande') ||
      j.contains('date pv') ||
      j.contains('nature de depense')) {
    return null;
  }

  final debut = dateDebut == null ? null : _jour(dateDebut);
  final fin = dateFin == null ? null : _jour(dateFin);

  if (j.contains('avant') && j.contains('pendant')) {
    if (fin == null) return null;
    return !d.isAfter(fin);
  }
  if (j.contains('avant')) {
    if (debut == null) return null;
    return !d.isAfter(debut);
  }
  if (j.contains('apres')) {
    if (fin == null) return null;
    return !d.isBefore(fin);
  }
  if (j.contains('pendant')) {
    if (debut == null || fin == null) return null;
    return !d.isBefore(debut) && !d.isAfter(fin);
  }
  return null;
}

DateTime _jour(DateTime d) => DateTime(d.year, d.month, d.day);

String _sansAccent(String valeur) {
  const accents = <String, String>{
    'À': 'A', 'Â': 'A', 'Ä': 'A', 'Á': 'A', 'Ã': 'A', 'Å': 'A',
    'Ç': 'C',
    'È': 'E', 'É': 'E', 'Ê': 'E', 'Ë': 'E',
    'Ì': 'I', 'Î': 'I', 'Ï': 'I', 'Í': 'I',
    'Ò': 'O', 'Ô': 'O', 'Ö': 'O', 'Ó': 'O', 'Õ': 'O',
    'Ù': 'U', 'Û': 'U', 'Ü': 'U', 'Ú': 'U',
    'Ÿ': 'Y',
    'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a', 'å': 'a',
    'ç': 'c',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'î': 'i', 'ï': 'i', 'í': 'i',
    'ò': 'o', 'ô': 'o', 'ö': 'o', 'ó': 'o', 'õ': 'o',
    'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u',
    'ÿ': 'y',
  };
  var texte = valeur;
  accents.forEach((accent, base) => texte = texte.replaceAll(accent, base));
  return texte;
}

/// Rattache une ligne budgétaire ou un libellé à une rubrique de la matrice
/// des PJ, par correspondance de mots-clés (les libellés de `LISTES` et de
/// `CONTROLE_PJ` ne reprennent pas exactement ceux de `PARAMETRES`).
String rubriquePourLibelle(String libelle, List<String> rubriques) {
  final l = _sansAccent(libelle).toUpperCase();
  bool contient(String mot) => l.contains(mot);
  String trouve(String motCle) => rubriques.firstWhere(
    (r) => _sansAccent(r).toUpperCase().contains(motCle),
    orElse: () => '',
  );

  if (contient('INDEMNIT')) return trouve('INDEMNIT');
  if (contient('CARBURANT')) return trouve('CARBURANT');
  if (contient('RESTAURATION') ||
      contient('EAU') ||
      contient('PAUSE') ||
      contient('DEJEUNER') ||
      contient('SALLE')) {
    return trouve('RESTAURATION');
  }
  if (contient('FOURNITURE') ||
      contient('PAPIER') ||
      contient('STYLO') ||
      contient('FLIP') ||
      contient('BLOC') ||
      contient('CHEMISE') ||
      contient('MASKING') ||
      contient('POST IT')) {
    return trouve('FOURNITURE');
  }
  if (contient('MULTIPLICATION') ||
      contient('DOCUMENT') ||
      contient('VISUEL')) {
    return trouve('MULTIPLICATION');
  }
  if (contient('MEDIATIQUE') || contient('SPOT') || contient('DIFFUSION')) {
    return trouve('COUVERTURE');
  }
  if (contient('ACHAT')) return trouve('ACHAT');
  if (contient('DEPLACEMENT') ||
      contient('TRANSFERT') ||
      contient('AVION') ||
      contient('TAXI')) {
    return trouve('DEPLACEMENT');
  }
  return trouve('AUTRES');
}
