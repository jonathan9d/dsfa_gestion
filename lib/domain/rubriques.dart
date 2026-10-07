import 'package:meta/meta.dart';

/// Résolution des **rubriques budgétaires**.
///
/// Une ligne budgétaire n'a jamais de rubrique « libre » : sa rubrique est
/// toujours déduite du libellé, puis retrouvée dans les **paramètres**
/// (`REFERENTIEL_TARIFS` / matrice des PJ de `PARAMETRES`). Les libellés du
/// classeur ne sont pas homogènes (accents, majuscules, « RESTAURATION /
/// FRAIS D'ORGANISATION »…) : la correspondance se fait par mots-clés, du plus
/// spécifique au plus général.
@immutable
class RubriquesBudget {
  const RubriquesBudget._();

  /// Rubrique affichée lorsqu'aucune correspondance n'est trouvée **et**
  /// qu'aucun référentiel n'est disponible. Ce n'est pas une saisie libre :
  /// c'est un marqueur explicite à compléter dans les paramètres.
  static const aPreciser = 'À PRÉCISER (paramètres)';

  /// Mots-clés → fragment de rubrique recherché dans le référentiel.
  ///
  /// L'ordre est significatif : « LOCATION DE SALLE ÉQUIPÉE » doit tomber sur
  /// **RESTAURATION / FRAIS D'ORGANISATION** (location des salles fait partie
  /// des frais d'organisation) et non sur les déplacements.
  static const _regles = <({List<String> mots, String rubrique})>[
    // 1. Location de salle : rattachée à la restauration / frais d'organisation.
    (
      mots: ['LOCATION DE SALLE', 'LOCATION SALLE', 'SALLE', 'SALLES'],
      rubrique: 'RESTAURATION',
    ),
    // 2. Indemnités (équipes, chauffeurs, missionnaires, perdiem).
    (
      mots: [
        'INDEMNIT',
        'PERDIEM',
        'PER DIEM',
        'CHAUFFEUR',
        'MISSIONNAIRE',
        'DEDOMMAGEMENT',
      ],
      rubrique: 'INDEMNIT',
    ),
    // 3. Carburant.
    (
      mots: ['CARBURANT', 'ESSENCE', 'GASOIL', 'DIESEL', 'FUEL'],
      rubrique: 'CARBURANT',
    ),
    // 4. Restauration et frais d'organisation.
    (
      mots: [
        'RESTAURATION',
        'ORGANISATION',
        'PAUSE',
        'CAFE',
        'DEJEUNER',
        'GOUTER',
        'COLLATION',
        'EAU',
        'FONTAINE',
        'REPAS',
      ],
      rubrique: 'RESTAURATION',
    ),
    // 5. Fournitures.
    (
      mots: [
        'FOURNITURE',
        'RAM',
        'PAPIER',
        'STYLO',
        'FLIP',
        'BLOC',
        'CHEMISE',
        'MASKING',
        'POST IT',
        'TONER',
        'FOURNIT',
      ],
      rubrique: 'FOURNITURE',
    ),
    // 6. Documents et visuels.
    (
      mots: [
        'MULTIPLICATION',
        'DOCUMENT',
        'VISUEL',
        'SUPPORT DE COMMUNICATION',
      ],
      rubrique: 'MULTIPLICATION',
    ),
    // 7. Couverture médiatique.
    (mots: ['MEDIATIQUE', 'SPOT', 'DIFFUSION'], rubrique: 'COUVERTURE'),
    // 8. Achat.
    (
      mots: ['ACHAT', 'MATERIEL', 'INFORMATIQUE', 'CREDIT DE COMMUNICATION'],
      rubrique: 'ACHAT',
    ),
    // 9. Déplacements (en dernier : « LOCATION » seul reste ambigu).
    (
      mots: [
        'DEPLACEMENT',
        'TRANSFERT',
        'TAXI',
        'BROUSSE',
        'AVION',
        'BILLET',
        'LOCATION',
        'LOCAT',
        'VOITURE',
        'VEHICULE',
        'CARBURANT',
        'TRANSPORT',
        'MISSION',
        'FRAIS',
      ],
      rubrique: 'DEPLACEMENT',
    ),
  ];

  /// Texte sans accent ni majuscule, pour comparer des libellés hétérogènes.
  static String normaliser(String valeur) {
    var texte = valeur.toUpperCase();
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
      'Ÿ': 'Y',
      '’': "'",
      '‘': "'",
      '\u00A0': ' ',
    };
    accents.forEach((a, b) => texte = texte.replaceAll(a, b));
    return texte.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Libellés de rubriques distincts d'un référentiel de tarifs, dans
  /// l'ordre d'apparition.
  static List<String> depuisTarifs(Iterable<String> rubriques) {
    final vues = <String>[];
    for (final brute in rubriques) {
      final r = brute.trim();
      if (r.isEmpty) continue;
      if (vues.any((v) => normaliser(v) == normaliser(r))) continue;
      vues.add(r);
    }
    return vues;
  }

  /// Rubrique du référentiel contenant [motCle], ou `''`.
  static String _trouve(List<String> rubriques, String motCle) {
    for (final r in rubriques) {
      if (normaliser(r).contains(normaliser(motCle))) return r;
    }
    return '';
  }

  /// Rubrique **correspondante** d'un libellé de ligne budgétaire.
  ///
  /// Retourne toujours une rubrique issue de [rubriques] (les paramètres) ;
  /// jamais une valeur saisie librement. Si aucune correspondance n'existe,
  /// retourne [aPreciser].
  static String pourLibelle(String libelle, List<String> rubriques) {
    final l = normaliser(libelle);
    if (l.isEmpty) return aPreciser;
    for (final regle in _regles) {
      for (final mot in regle.mots) {
        if (l.contains(normaliser(mot))) {
          final trouve = _trouve(rubriques, regle.rubrique);
          if (trouve.isNotEmpty) return trouve;
        }
      }
    }
    // Aucun mot-clé connu : on tente une correspondance directe avec le
    // libellé complet, puis on s'arrête sur le marqueur à compléter.
    for (final r in rubriques) {
      final n = normaliser(r);
      if (n.isNotEmpty && (l.contains(n) || n.contains(l))) return r;
    }
    return aPreciser;
  }

  /// Rubrique déduite du **type de budget** déjà calculé (les types du
  /// générateur `BUDGET` suivent exactement les rubriques du référentiel).
  static String? rubriqueDuType(String typeBudget, List<String> rubriques) {
    final t = normaliser(typeBudget);
    String parMots(List<String> mots) {
      for (final mot in mots) {
        final r = _trouve(rubriques, mot);
        if (r.isNotEmpty) return r;
      }
      return '';
    }

    if (t.contains('INDEMNIT')) {
      return parMots(['INDEMNIT']);
    }
    if (t.contains('CARBURANT')) return parMots(['CARBURANT', 'DEPLACEMENT']);
    if (t.contains('LOCATION DE VOITURE') ||
        t.contains('DEPLACEMENT') ||
        t.contains('TRANSFERT') ||
        t.contains('TAXI') ||
        t.contains('AVION')) {
      return parMots(['DEPLACEMENT']);
    }
    if (t.contains('SALLE')) return parMots(['RESTAURATION']);
    if (t.contains('RESTAURATION')) return parMots(['RESTAURATION']);
    if (t.contains('FOURNITURE')) return parMots(['FOURNITURE']);
    return null;
  }

  /// Rubrique à retenir pour une ligne budgétaire : d'abord le libellé, puis
  /// le type, puis la rubrique déjà enregistrée si elle figure encore dans le
  /// référentiel. Le résultat appartient **toujours** à [rubriques], sauf si
  /// celui-ci est vide (auquel cas [aPreciser]).
  static String resoudre({
    required String ligneBudgetaire,
    String? typeBudget,
    String? rubriqueEnregistree,
    required List<String> rubriques,
  }) {
    if (rubriques.isEmpty) return aPreciser;
    final duLibelle = pourLibelle(ligneBudgetaire, rubriques);
    if (duLibelle != aPreciser) return duLibelle;
    if (typeBudget != null && typeBudget.trim().isNotEmpty) {
      final duType = rubriqueDuType(typeBudget, rubriques);
      if (duType != null && duType.isNotEmpty) return duType;
    }
    if (rubriqueEnregistree != null && rubriqueEnregistree.trim().isNotEmpty) {
      final enregistree = rubriqueEnregistree.trim();
      for (final r in rubriques) {
        if (normaliser(r) == normaliser(enregistree)) return r;
      }
    }
    return aPreciser;
  }

  /// La rubrique est-elle déclarée dans les paramètres ?
  static bool estConnue(String rubrique, List<String> rubriques) =>
      rubriques.any((r) => normaliser(r) == normaliser(rubrique));

  /// Rubriques qui ne sont ni libres ni vides.
  static bool estLibre(String rubrique) {
    final r = normaliser(rubrique);
    return r.isEmpty || r == normaliser(aPreciser) || r == 'LIBRE';
  }
}
