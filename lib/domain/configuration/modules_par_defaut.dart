import 'configuration_app.dart';

/// Champs, modules, statuts et rubriques **livrés** avec l'application.
///
/// Ils constituent le point de départ de la configuration : tout est
/// modifiable (libellés, ordre, visibilité, largeur, formules, couleurs),
/// et de nouveaux champs, onglets, rubriques ou statuts peuvent être ajoutés.
/// Les clés (`cle`) ne changent jamais : c'est ce qui garantit que les
/// automatismes (calculs, règles et matrice PJ, districts, tarifs) continuent
/// de fonctionner malgré les modifications.
///
/// Raccourci de description d'un champ : `(clé, libellé, type, largeur)`.
ChampConfig _ch(
  String cle,
  String libelle,
  TypeChamp type,
  double largeur, [
  String? formule,
]) => ChampConfig(
  cle: cle,
  libelle: libelle,
  type: type,
  largeur: largeur,
  formule: formule,
);

/// Champ **non affiché en colonne** par défaut : il reste modifiable dans les
/// formulaires de saisie, mais n'encombre pas le tableau. L'utilisateur peut
/// l'afficher d'un clic depuis la configuration.
ChampConfig _masque(ChampConfig champ) => champ.copyWith(visible: false);

List<ChampConfig> _champs(List<ChampConfig> champs) => [
  for (var i = 0; i < champs.length; i++) champs[i].copyWith(ordre: i + 1),
];

ModuleConfig _module({
  required String cle,
  required String titre,
  required String sousTitre,
  required String icone,
  required String route,
  List<ChampConfig> champs = const [],
  String groupe = '',
  int ordre = 0,
  List<String>? actions,
}) => ModuleConfig(
  cle: cle,
  titre: titre,
  sousTitre: sousTitre,
  icone: icone,
  route: route,
  groupe: groupe,
  ordre: ordre,
  champs: _champs(champs),
  actions: actions ?? ActionsApp.parDefaut,
);

/// Modules (onglets) livrés avec l'application.
List<ModuleConfig> modulesParDefaut() => [
  _module(
    cle: 'tableau_de_bord',
    titre: 'Tableau de bord',
    sousTitre: 'Vue d\'ensemble des activités, budgets et contrôles',
    icone: 'tableau_de_bord',
    route: '/',
    ordre: 1,
    champs: [
      _ch('activites_total', 'Activités', TypeChamp.nombre, 110),
      _ch('budget_alloue', 'Budget alloué', TypeChamp.montant, 150),
      _ch('depenses_total', 'Dépenses réalisées', TypeChamp.montant, 160),
      _ch('taux_execution', 'Taux d\'exécution (%)', TypeChamp.nombre, 130),
      _ch('pj_conformes', 'PJ conformes', TypeChamp.nombre, 120),
      _ch('pj_a_verifier', 'PJ à vérifier', TypeChamp.nombre, 120),
      _ch('pj_non_conformes', 'PJ non conformes', TypeChamp.nombre, 130),
    ],
  ),
  _module(
    cle: 'activites',
    titre: 'Activités',
    sousTitre: 'Activités programmées, financements et périodes',
    icone: 'activite',
    route: '/activites',
    ordre: 2,
    champs: [
      _ch('code', 'Code', TypeChamp.texte, 120),
      _ch('description', 'Description', TypeChamp.texte, 300),
      _ch('code_budget', 'Code budget', TypeChamp.texte, 150),
      _ch('source_financement', 'Source de financement', TypeChamp.liste, 200),
      _ch('lieu', 'Lieu d\'activité', TypeChamp.liste, 170),
      _ch('jours', 'Jours', TypeChamp.nombre, 90),
      _ch('date_debut', 'Début', TypeChamp.date, 110),
      _ch('date_fin', 'Fin', TypeChamp.date, 110),
      _ch('montant_alloue', 'Montant alloué', TypeChamp.montant, 150),
      _masque(_ch('type', 'Type d\'activité', TypeChamp.liste, 170)),
      _masque(_ch('district', 'District', TypeChamp.liste, 160)),
      _masque(_ch('observation', 'Observation', TypeChamp.texte, 200)),
    ],
  ),
  _module(
    cle: 'budgets',
    titre: 'Budgets',
    sousTitre: 'Lignes budgétaires classées par rubrique',
    icone: 'budget',
    route: '/budgets',
    ordre: 3,
    champs: [
      _ch('activite', 'Activité', TypeChamp.texte, 140),
      _ch('rubrique', 'Rubrique', TypeChamp.liste, 230),
      _ch('ligne_budgetaire', 'Ligne budgétaire', TypeChamp.liste, 260),
      _ch('unite', 'Unité', TypeChamp.liste, 110),
      _ch('quantite', 'Quantité / Base', TypeChamp.nombre, 130),
      _ch('nombre_jours', 'Jours / Multiplicateur', TypeChamp.nombre, 150),
      _ch('taux_unitaire', 'Taux / PU', TypeChamp.montant, 120),
      _ch('budget_previsionnel', 'Budget prévisionnel', TypeChamp.calcul, 160,
          'quantite * nombre_jours * taux_unitaire'),
      _ch('montant_alloue', 'Montant alloué', TypeChamp.montant, 150),
      _masque(_ch('montant_confirme', 'Montant confirmé', TypeChamp.statut, 150)),
      _ch('observation', 'Observation', TypeChamp.texte, 200),
    ],
  ),
  _module(
    cle: 'suivi',
    titre: 'Suivi',
    sousTitre: 'Avancement des activités et écarts budgétaires',
    icone: 'suivi',
    route: '/suivi',
    ordre: 4,
    champs: [
      _ch('date', 'Date', TypeChamp.date, 110),
      _ch('code_activite', 'Code activité', TypeChamp.texte, 130),
      _ch('code_budget', 'Code budget', TypeChamp.texte, 140),
      _ch('description', 'Description activité', TypeChamp.texte, 280),
      _ch('date_reception_fonds', 'Date réception fonds', TypeChamp.date, 150),
      _ch('source_financement', 'Source de financement', TypeChamp.liste, 200),
      _ch('montant_alloue', 'Montant alloué', TypeChamp.montant, 150),
      _ch('depenses', 'Dépenses réalisées', TypeChamp.montant, 160),
      _ch('ecart', 'Écart', TypeChamp.calcul, 140,
          'montant_alloue - depenses'),
      _ch('date_reception_pj', 'Date réception PJ', TypeChamp.date, 150),
      _ch('date_rapportage', 'Date de rapportage', TypeChamp.date, 150),
      _ch('statut', 'Statut', TypeChamp.statut, 140),
    ],
  ),
  _module(
    cle: 'dossier_pj',
    titre: 'Dossier PJ',
    sousTitre: 'Présences, indemnités et pièces justificatives',
    icone: 'dossier',
    route: '/dossier-pj',
    ordre: 5,
    champs: [
      _ch('code_activite', 'Code activité', TypeChamp.texte, 130),
      _ch('description', 'Description', TypeChamp.texte, 260),
      _ch('rubrique', 'Rubrique', TypeChamp.liste, 220),
      _ch('piece', 'Pièce justificative', TypeChamp.texte, 260),
      _ch('obligatoire', 'Obligatoire', TypeChamp.booleen, 120),
      _ch('regle_date', 'Règle de date', TypeChamp.texte, 200),
      _ch('statut', 'Statut', TypeChamp.statut, 150),
    ],
  ),
  _module(
    cle: 'depenses',
    titre: 'Dépenses',
    sousTitre:
        'Journal des dépenses — montant = nbr jr/mois × quantité × fréquence × P.U.',
    icone: 'depense',
    route: '/depenses',
    ordre: 6,
    champs: [
      _ch('date', 'Date', TypeChamp.date, 110),
      _ch('code_activite', 'Code activité', TypeChamp.texte, 130),
      _ch('designation', 'Désignation', TypeChamp.liste, 260),
      _ch('beneficiaire', 'Bénéficiaire', TypeChamp.texte, 200),
      _ch('mode_paiement', 'Mode de paiement', TypeChamp.liste, 160),
      _ch('statut_pj', 'Statut PJ', TypeChamp.statut, 150),
      _ch('quantite', 'Qté', TypeChamp.nombre, 90),
      _ch('pu', 'P.U.', TypeChamp.montant, 120),
      _ch('montant', 'Montant', TypeChamp.calcul, 150,
          'nb_jr_mois * quantite * frequence * pu'),
      _masque(_ch('code_budget', 'Code budget', TypeChamp.texte, 150)),
      _masque(_ch('reference_pj', 'Référence PJ', TypeChamp.texte, 160)),
      _masque(
        _ch('reference_decaissement', 'Réf décaissement', TypeChamp.texte, 160),
      ),
      _masque(_ch('dct', 'DCT N°', TypeChamp.texte, 130)),
      _masque(_ch('description_pj', 'Description des PJ', TypeChamp.texte, 200)),
      _masque(_ch('unite', 'Unité', TypeChamp.liste, 110)),
      _masque(_ch('nb_jr_mois', 'Nbr jr/mois', TypeChamp.nombre, 110)),
      _masque(_ch('frequence', 'Fréquence', TypeChamp.nombre, 100)),
      _masque(_ch('observation', 'Observation', TypeChamp.texte, 200)),
    ],
  ),
  _module(
    cle: 'banque',
    titre: 'Banque',
    sousTitre: 'Journal de banque et de caisse',
    icone: 'banque',
    route: '/banque',
    ordre: 7,
    champs: [
      _ch('date', 'Date', TypeChamp.date, 110),
      _ch('reference', 'Réf pièce', TypeChamp.texte, 160),
      _ch('type', 'Type', TypeChamp.liste, 150),
      _ch('description', 'Description', TypeChamp.texte, 280),
      _ch('recettes', 'Recettes', TypeChamp.montant, 140),
      _ch('depenses', 'Dépenses', TypeChamp.montant, 140),
      _ch('solde', 'Solde', TypeChamp.calcul, 140, 'recettes - depenses'),
      _masque(_ch('bailleur', 'Bailleur', TypeChamp.texte, 160)),
      _masque(_ch('beneficiaire', 'Bénéficiaire', TypeChamp.texte, 180)),
    ],
  ),
  _module(
    cle: 'rapprochement',
    titre: 'Rapprochement',
    sousTitre: 'Comparaison du journal de banque et du relevé',
    icone: 'rapprochement',
    route: '/rapprochement',
    ordre: 8,
    champs: [
      _ch('date', 'Date', TypeChamp.date, 110),
      _ch('libelle', 'Libellé', TypeChamp.texte, 280),
      _ch('montant_releve', 'Montant relevé', TypeChamp.montant, 150),
      _ch('montant_journal', 'Montant journal', TypeChamp.montant, 150),
      _ch('ecart', 'Écart', TypeChamp.calcul, 130,
          'montant_journal - montant_releve'),
      _ch('statut', 'Statut', TypeChamp.statut, 150),
    ],
  ),
  _module(
    cle: 'rapports',
    titre: 'Rapports',
    sousTitre: 'Rapport financier : alloué, réalisé, écarts',
    icone: 'rapport',
    route: '/rapports',
    groupe: 'Administration',
    ordre: 9,
    champs: [
      _ch('rubrique', 'Rubrique', TypeChamp.liste, 230),
      _ch('ligne_budgetaire', 'Ligne budgétaire', TypeChamp.texte, 260),
      _ch('alloue', 'Alloué', TypeChamp.montant, 150),
      _ch('depense', 'Dépensé', TypeChamp.montant, 150),
      _ch('ecart', 'Écart', TypeChamp.calcul, 140, 'alloue - depense'),
      _ch('taux', 'Taux (%)', TypeChamp.nombre, 110),
    ],
  ),
  _module(
    cle: 'participants',
    titre: 'Participants',
    sousTitre: 'Participants aux activités et indemnités',
    icone: 'personnes',
    route: '/participants',
    ordre: 10,
    champs: [
      _ch('nom', 'Nom', TypeChamp.texte, 160),
      _ch('prenom', 'Prénom', TypeChamp.texte, 160),
      _ch('statut', 'Statut', TypeChamp.statut, 130),
      _ch('observation', 'Observation', TypeChamp.texte, 200),
      _masque(_ch('fonction', 'Fonction', TypeChamp.liste, 180)),
      _masque(_ch('structure', 'Structure', TypeChamp.texte, 180)),
      _masque(_ch('telephone', 'Téléphone', TypeChamp.texte, 140)),
      _masque(_ch('email', 'Courriel', TypeChamp.texte, 180)),
    ],
  ),
  _module(
    cle: 'parametres',
    titre: 'Paramètres',
    sousTitre: 'Référentiels, listes de valeurs et configuration',
    icone: 'parametres',
    route: '/parametres',
    groupe: 'Administration',
    ordre: 11,
  ),
  _module(
    cle: 'sauvegardes',
    titre: 'Sauvegardes',
    sousTitre: 'Copies de sécurité de la base de données',
    icone: 'sauvegarde',
    route: '/sauvegardes',
    groupe: 'Administration',
    ordre: 12,
  ),
  _module(
    cle: 'profil',
    titre: 'Profil',
    sousTitre: 'Informations du compte connecté',
    icone: 'personne',
    route: '/profil',
    ordre: 13,
  ),
];

/// Statuts livrés : valeur, couleur et icône. **Tous** sont modifiables et de
/// nouveaux statuts peuvent être créés (les couleurs s'appliquent partout :
/// tableaux, pastilles, dossiers PJ).
List<StatutConfig> statutsParDefaut() => const [
  StatutConfig(
    valeur: 'Conforme',
    couleur: 'FF2E7D32',
    icone: 'verifie',
    systeme: true,
  ),
  StatutConfig(
    valeur: 'À vérifier',
    couleur: 'FFF9A825',
    icone: 'alerte',
    systeme: true,
  ),
  StatutConfig(
    valeur: 'Non conforme',
    couleur: 'FFC62828',
    icone: 'erreur',
    systeme: true,
  ),
  StatutConfig(
    valeur: 'PJ non reçue',
    couleur: 'FF8E24AA',
    icone: 'document',
    systeme: true,
  ),
  StatutConfig(
    valeur: 'Date PJ non conforme',
    couleur: 'FFD84315',
    icone: 'calendrier',
    systeme: true,
  ),
  StatutConfig(valeur: 'Rapproché', couleur: 'FF2E7D32', icone: 'verifie'),
  StatutConfig(valeur: 'Différence', couleur: 'FFC62828', icone: 'alerte'),
  StatutConfig(valeur: 'Non trouvé', couleur: 'FFF9A825', icone: 'recherche'),
  StatutConfig(valeur: 'Payé', couleur: 'FF2E7D32', icone: 'paiement'),
  StatutConfig(valeur: 'Partiel', couleur: 'FFF9A825', icone: 'horloge'),
  StatutConfig(valeur: 'À payer', couleur: 'FF1976D2', icone: 'horloge'),
  StatutConfig(valeur: 'Non payé', couleur: 'FFC62828', icone: 'erreur'),
  StatutConfig(valeur: 'Présent', couleur: 'FF2E7D32', icone: 'verifie'),
  StatutConfig(valeur: 'Absent', couleur: 'FFC62828', icone: 'erreur'),
  StatutConfig(valeur: 'Confirmé', couleur: 'FF2E7D32', icone: 'verifie'),
  StatutConfig(valeur: 'Non confirmé', couleur: 'FFF9A825', icone: 'alerte'),
  StatutConfig(valeur: 'Anomalie détectée', couleur: 'FFC62828', icone: 'alerte'),
  StatutConfig(
    valeur: 'Dépassement budget indemnités',
    couleur: 'FFD84315',
    icone: 'alerte',
  ),
  StatutConfig(valeur: 'Planifiée', couleur: 'FF7E57C2', icone: 'calendrier'),
  StatutConfig(valeur: 'En cours', couleur: 'FF1976D2', icone: 'horloge'),
  StatutConfig(valeur: 'Clôturée', couleur: 'FF546E7A', icone: 'archive'),
];

/// Rubriques budgétaires livrées (issues du référentiel `REFERENTIEL_TARIFS`).
List<RubriqueConfig> rubriquesParDefaut() => const [
  RubriqueConfig(
    nom: 'INDEMNITÉS DES MISSIONNAIRES',
    couleur: 'FF7E57C2',
    ordre: 1,
    systeme: true,
  ),
  RubriqueConfig(
    nom: 'DÉPLACEMENTS DES MISSIONNAIRES',
    couleur: 'FF1976D2',
    ordre: 2,
    systeme: true,
  ),
  RubriqueConfig(
    nom: 'CARBURANT',
    couleur: 'FF00897B',
    ordre: 3,
    systeme: true,
  ),
  RubriqueConfig(
    nom: 'RESTAURATION / FRAIS D\'ORGANISATION',
    couleur: 'FFE65100',
    ordre: 4,
    systeme: true,
  ),
  RubriqueConfig(
    nom: 'FOURNITURES',
    couleur: 'FF6D4C41',
    ordre: 5,
    systeme: true,
  ),
  RubriqueConfig(
    nom: 'MULTIPLICATION DE DOCUMENT/VISUEL',
    couleur: 'FF3949AB',
    ordre: 6,
    systeme: true,
  ),
  RubriqueConfig(
    nom: 'COUVERTURE MÉDIATIQUE',
    couleur: 'FFD81B60',
    ordre: 7,
    systeme: true,
  ),
  RubriqueConfig(nom: 'ACHAT', couleur: 'FF455A64', ordre: 8, systeme: true),
];

/// Sources de données disponibles pour un onglet créé par l'utilisateur.
///
/// Clé → description affichée dans la configuration. Seules les sources
/// **réellement disponibles** sont proposées : le tableau de l'onglet créé
/// affiche les données saisies dans l'application, sans copie ni ressaisie.
const sourcesOnglets = <String, String>{
  'activites': 'Activités (code, dates, lieu, financement, montant alloué)',
  'budgets': 'Lignes budgétaires (rubrique, quantités, taux, montants)',
  'depenses': 'Dépenses (date, désignation, bénéficiaire, mode, montant)',
  'banque': 'Journal de banque (date, type, recettes, dépenses)',
  'participants': 'Participants (nom, prénom, statut, observation)',
};
