import 'package:flutter/material.dart';

import 'icones.dart';
import 'modules_par_defaut.dart';

/// Type d'un champ configurable.
enum TypeChamp {
  texte('texte', 'Texte'),
  nombre('nombre', 'Nombre'),
  montant('montant', 'Montant (Ar)'),
  date('date', 'Date'),
  liste('liste', 'Liste de valeurs'),
  statut('statut', 'Statut (couleur par valeur)'),
  booleen('booleen', 'Oui / Non'),
  calcul('calcul', 'Calculé par une formule');

  const TypeChamp(this.code, this.libelle);

  final String code;
  final String libelle;

  static TypeChamp depuisCode(String? code) => values.firstWhere(
    (t) => t.code == code,
    orElse: () => TypeChamp.texte,
  );

  /// Un champ calculé ou de statut ne se saisit pas : sa valeur vient d'une
  /// formule ou de la liste des statuts.
  bool get saisissable => this != TypeChamp.calcul;

  bool get numerique =>
      this == TypeChamp.nombre || this == TypeChamp.montant;
}

/// Actions qu'un onglet peut offrir. Les clés sont stables (persistées) et
/// chaque écran coche celles qu'il sait réellement exécuter.
class ActionsApp {
  const ActionsApp._();

  static const ajouter = 'ajouter';
  static const modifier = 'modifier';
  static const supprimer = 'supprimer';
  static const rechercher = 'rechercher';
  static const filtrer = 'filtrer';
  static const selectionner = 'selectionner';
  static const configuration = 'configuration';

  /// Action → libellé affiché dans la configuration.
  static const catalogue = <String, String>{
    ajouter: 'Ajouter une ligne',
    modifier: 'Modifier une ligne',
    supprimer: 'Supprimer',
    rechercher: 'Rechercher',
    filtrer: 'Filtrer les colonnes',
    selectionner: 'Sélection multiple',
    configuration: 'Bouton Configuration',
  };

  static const parDefaut = <String>[
    ajouter,
    modifier,
    supprimer,
    rechercher,
    filtrer,
    selectionner,
    configuration,
  ];

  static String libelle(String cle) => catalogue[cle] ?? cle;
}

/// Un **champ** (colonne de tableau ou case de formulaire) personnalisable.
@immutable
class ChampConfig {
  const ChampConfig({
    required this.cle,
    required this.libelle,
    this.type = TypeChamp.texte,
    this.aide,
    this.visible = true,
    this.obligatoire = false,
    this.largeur = 150,
    this.ordre = 0,
    this.parent,
    this.formule,
    this.valeurs = const [],
    this.couleurs = const {},
    this.modifiable = true,
  });

  /// Identifiant stable du champ (jamais renommé par l'utilisateur).
  final String cle;

  /// Libellé affiché (titre de colonne, étiquette de champ).
  final String libelle;

  final TypeChamp type;

  /// Texte d'aide affiché sous le champ de saisie.
  final String? aide;

  /// Champ affiché dans les tableaux et formulaires.
  final bool visible;

  /// Saisie obligatoire.
  final bool obligatoire;

  /// Largeur de colonne souhaitée (px) quand le champ est une colonne.
  final double largeur;

  /// Position du champ dans le tableau (croissant).
  final int ordre;

  /// Champ **parent** : la suppression du parent supprime (cascade) ses
  /// enfants, après confirmation explicite.
  final String? parent;

  /// Formule de calcul (types `calcul` et `statut`).
  final String? formule;

  /// Valeurs autorisées (type `liste`) : proposées, jamais imposées.
  final List<String> valeurs;

  /// Couleurs par valeur (type `statut`) : valeur → couleur hexadécimale.
  final Map<String, String> couleurs;

  /// Champ livré avec l'application : libellé, type et formule sont
  /// modifiables, la clé reste stable pour que les calculs continuent.
  final bool modifiable;

  ChampConfig copyWith({
    String? libelle,
    TypeChamp? type,
    String? aide,
    bool? visible,
    bool? obligatoire,
    double? largeur,
    int? ordre,
    String? parent,
    bool supprimerParent = false,
    String? formule,
    bool supprimerFormule = false,
    List<String>? valeurs,
    Map<String, String>? couleurs,
    bool? modifiable,
  }) => ChampConfig(
    cle: cle,
    libelle: libelle ?? this.libelle,
    type: type ?? this.type,
    aide: aide ?? this.aide,
    visible: visible ?? this.visible,
    obligatoire: obligatoire ?? this.obligatoire,
    largeur: largeur ?? this.largeur,
    ordre: ordre ?? this.ordre,
    parent: supprimerParent ? null : (parent ?? this.parent),
    formule: supprimerFormule ? null : (formule ?? this.formule),
    valeurs: valeurs ?? this.valeurs,
    couleurs: couleurs ?? this.couleurs,
    modifiable: modifiable ?? this.modifiable,
  );

  Map<String, dynamic> toJson() => {
    'cle': cle,
    'libelle': libelle,
    'type': type.code,
    'aide': aide,
    'visible': visible,
    'obligatoire': obligatoire,
    'largeur': largeur,
    'ordre': ordre,
    'parent': parent,
    'formule': formule,
    'valeurs': valeurs,
    'couleurs': couleurs,
    'modifiable': modifiable,
  };

  factory ChampConfig.fromJson(Map<String, dynamic> json) => ChampConfig(
    cle: '${json['cle'] ?? ''}',
    libelle: '${json['libelle'] ?? json['cle'] ?? ''}',
    type: TypeChamp.depuisCode(json['type'] as String?),
    aide: json['aide'] as String?,
    visible: json['visible'] as bool? ?? true,
    obligatoire: json['obligatoire'] as bool? ?? false,
    largeur: (json['largeur'] as num?)?.toDouble() ?? 150,
    ordre: (json['ordre'] as num?)?.toInt() ?? 0,
    parent: json['parent'] as String?,
    formule: json['formule'] as String?,
    valeurs: (json['valeurs'] as List?)?.map((v) => '$v').toList() ?? const [],
    couleurs:
        (json['couleurs'] as Map?)?.map((k, v) => MapEntry('$k', '$v')) ??
        const {},
    modifiable: json['modifiable'] as bool? ?? true,
  );

  /// Couleur associée à une valeur de statut (ou `null`).
  Color? couleurDe(String valeur) {
    final brut = couleurs[valeur];
    if (brut == null) return null;
    return couleurDepuisHex(brut);
  }
}

/// Un **module** = un onglet de l'application (livré ou créé par
/// l'utilisateur) : sa présentation, ses champs (colonnes) et ses actions.
@immutable
class ModuleConfig {
  const ModuleConfig({
    required this.cle,
    required this.titre,
    this.sousTitre = '',
    this.icone = IconesApp.defaut,
    this.iconeImportee,
    this.couleur = '',
    this.ordre = 0,
    this.actif = true,
    this.systeme = true,
    this.source = '',
    this.actions = ActionsApp.parDefaut,
    this.champs = const [],
    this.route,
    this.groupe = '',
  });

  /// Identifiant stable (clé de configuration et segment d'adresse).
  final String cle;

  final String titre;
  final String sousTitre;

  /// Clé d'icône du catalogue ([IconesApp]).
  final String icone;

  /// Icône importée (PNG encodé en base 64), prioritaire sur [icone].
  final String? iconeImportee;

  /// Couleur d'accent (hexadécimal) ; vide = couleur de l'application.
  final String couleur;

  final int ordre;

  /// Module affiché dans la navigation.
  final bool actif;

  /// Module livré avec l'application (non supprimable, mais entièrement
  /// modifiable).
  final bool systeme;

  /// Source de données d'un onglet **créé** par l'utilisateur
  /// (`activites`, `budgets`, `depenses`, `banque`, `participants`…).
  final String source;

  /// Actions autorisées dans ce module.
  final List<String> actions;

  /// Champs (colonnes) du module, dans l'ordre d'affichage.
  final List<ChampConfig> champs;

  /// Adresse du module livré (`/depenses`…) ; `null` pour un onglet créé.
  final String? route;

  /// Groupe de navigation (« Administration » par exemple).
  final String groupe;

  bool actionAutorisee(String cle) => actions.contains(cle);

  IconData get iconeAffichee => IconesApp.iconeOuDefaut(icone);

  Color? get couleurAffichee =>
      couleur.isEmpty ? null : couleurDepuisHex(couleur);

  /// Champs visibles, dans l'ordre.
  List<ChampConfig> get champsVisibles =>
      champs.where((c) => c.visible).toList()
        ..sort((a, b) => a.ordre.compareTo(b.ordre));

  ChampConfig? champ(String cle) {
    for (final c in champs) {
      if (c.cle == cle) return c;
    }
    return null;
  }

  ModuleConfig copyWith({
    String? titre,
    String? sousTitre,
    String? icone,
    String? iconeImportee,
    bool supprimerIconeImportee = false,
    String? couleur,
    int? ordre,
    bool? actif,
    String? source,
    List<String>? actions,
    List<ChampConfig>? champs,
    String? groupe,
    String? route,
  }) => ModuleConfig(
    cle: cle,
    titre: titre ?? this.titre,
    sousTitre: sousTitre ?? this.sousTitre,
    icone: icone ?? this.icone,
    iconeImportee: supprimerIconeImportee
        ? null
        : (iconeImportee ?? this.iconeImportee),
    couleur: couleur ?? this.couleur,
    ordre: ordre ?? this.ordre,
    actif: actif ?? this.actif,
    systeme: systeme,
    source: source ?? this.source,
    actions: actions ?? this.actions,
    champs: champs ?? this.champs,
    route: route ?? this.route,
    groupe: groupe ?? this.groupe,
  );

  Map<String, dynamic> toJson() => {
    'cle': cle,
    'titre': titre,
    'sousTitre': sousTitre,
    'icone': icone,
    'iconeImportee': iconeImportee,
    'couleur': couleur,
    'ordre': ordre,
    'actif': actif,
    'systeme': systeme,
    'source': source,
    'actions': actions,
    'champs': champs.map((c) => c.toJson()).toList(),
    'route': route,
    'groupe': groupe,
  };

  factory ModuleConfig.fromJson(Map<String, dynamic> json) => ModuleConfig(
    cle: '${json['cle'] ?? ''}',
    titre: '${json['titre'] ?? json['cle'] ?? ''}',
    sousTitre: '${json['sousTitre'] ?? ''}',
    icone: '${json['icone'] ?? IconesApp.defaut}',
    iconeImportee: json['iconeImportee'] as String?,
    couleur: '${json['couleur'] ?? ''}',
    ordre: (json['ordre'] as num?)?.toInt() ?? 0,
    actif: json['actif'] as bool? ?? true,
    systeme: json['systeme'] as bool? ?? true,
    source: '${json['source'] ?? ''}',
    actions:
        (json['actions'] as List?)?.map((a) => '$a').toList() ??
        ActionsApp.parDefaut,
    champs:
        (json['champs'] as List?)
            ?.whereType<Map>()
            .map((c) => ChampConfig.fromJson(c.cast<String, dynamic>()))
            .toList() ??
        const [],
    route: json['route'] as String?,
    groupe: '${json['groupe'] ?? ''}',
  );
}

/// Un **statut** avec sa couleur et son icône (PJ, indemnités, paiements…).
@immutable
class StatutConfig {
  const StatutConfig({
    required this.valeur,
    this.couleur = 'FF607D8B',
    this.icone = 'recherche',
    this.systeme = false,
  });

  final String valeur;
  final String couleur;
  final String icone;
  final bool systeme;

  Color get couleurAffichee => couleurDepuisHex(couleur) ?? Colors.blueGrey;

  IconData get iconeAffichee => IconesApp.iconeOuDefaut(icone);

  StatutConfig copyWith({String? valeur, String? couleur, String? icone}) =>
      StatutConfig(
        valeur: valeur ?? this.valeur,
        couleur: couleur ?? this.couleur,
        icone: icone ?? this.icone,
        systeme: systeme,
      );

  Map<String, dynamic> toJson() => {
    'valeur': valeur,
    'couleur': couleur,
    'icone': icone,
    'systeme': systeme,
  };

  factory StatutConfig.fromJson(Map<String, dynamic> json) => StatutConfig(
    valeur: '${json['valeur'] ?? ''}',
    couleur: '${json['couleur'] ?? 'FF607D8B'}',
    icone: '${json['icone'] ?? 'recherche'}',
    systeme: json['systeme'] as bool? ?? false,
  );
}

/// Une **rubrique budgétaire** (regroupement de lignes budgétaires).
@immutable
class RubriqueConfig {
  const RubriqueConfig({
    required this.nom,
    this.couleur = '',
    this.ordre = 0,
    this.systeme = false,
  });

  final String nom;
  final String couleur;
  final int ordre;
  final bool systeme;

  Color? get couleurAffichee =>
      couleur.isEmpty ? null : couleurDepuisHex(couleur);

  RubriqueConfig copyWith({String? nom, String? couleur, int? ordre}) =>
      RubriqueConfig(
        nom: nom ?? this.nom,
        couleur: couleur ?? this.couleur,
        ordre: ordre ?? this.ordre,
        systeme: systeme,
      );

  Map<String, dynamic> toJson() => {
    'nom': nom,
    'couleur': couleur,
    'ordre': ordre,
    'systeme': systeme,
  };

  factory RubriqueConfig.fromJson(Map<String, dynamic> json) => RubriqueConfig(
    nom: '${json['nom'] ?? ''}',
    couleur: '${json['couleur'] ?? ''}',
    ordre: (json['ordre'] as num?)?.toInt() ?? 0,
    systeme: json['systeme'] as bool? ?? false,
  );
}

/// Configuration complète de l'application : **tout** ce qui est affiché et
/// saisi peut être modifié ici, sans jamais casser les automatismes
/// (règles & matrice PJ, districts, tarifs, calculs).
@immutable
class ConfigurationApp {
  const ConfigurationApp({
    this.version = 1,
    this.modules = const [],
    this.statuts = const [],
    this.rubriques = const [],
    this.affectationsLignes = const {},
  });

  final int version;
  final List<ModuleConfig> modules;
  final List<StatutConfig> statuts;
  final List<RubriqueConfig> rubriques;

  /// Ligne budgétaire (normalisée) → rubrique choisie par l'utilisateur.
  final Map<String, String> affectationsLignes;

  /// Configuration livrée avec l'application (voir [modulesParDefaut]).
  static ConfigurationApp parDefaut() => ConfigurationApp(
    modules: modulesParDefaut(),
    statuts: statutsParDefaut(),
    rubriques: rubriquesParDefaut(),
  );

  /// Configuration courante lue dans l'arbre de widgets ; les valeurs livrées
  /// sont utilisées quand aucun [ConfigurationScope] n'est posé (tests,
  /// widgets isolés) — l'application, elle, en pose toujours un.
  static ConfigurationApp of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<ConfigurationScope>()
          ?.configuration ??
      _defautPartage;

  static final ConfigurationApp _defautPartage = ConfigurationApp.parDefaut();

  ConfigurationApp copyWith({
    List<ModuleConfig>? modules,
    List<StatutConfig>? statuts,
    List<RubriqueConfig>? rubriques,
    Map<String, String>? affectationsLignes,
  }) => ConfigurationApp(
    version: version,
    modules: modules ?? this.modules,
    statuts: statuts ?? this.statuts,
    rubriques: rubriques ?? this.rubriques,
    affectationsLignes: affectationsLignes ?? this.affectationsLignes,
  );

  ModuleConfig? module(String cle) {
    for (final m in modules) {
      if (m.cle == cle) return m;
    }
    return null;
  }

  /// Module d'une adresse de navigation (`/depenses` → module « depenses »).
  ModuleConfig? moduleParRoute(String? route) {
    if (route == null) return null;
    for (final m in modules) {
      if (m.route == route) return m;
    }
    return null;
  }

  /// Onglets **créés** par l'utilisateur, dans l'ordre.
  List<ModuleConfig> get ongletsPersonnalises {
    final liste = modules.where((m) => !m.systeme && m.actif).toList();
    liste.sort((a, b) => a.ordre.compareTo(b.ordre));
    return liste;
  }

  /// Modules livrés, dans l'ordre d'affichage.
  List<ModuleConfig> get modulesSysteme {
    final liste = modules.where((m) => m.systeme).toList();
    liste.sort((a, b) => a.ordre.compareTo(b.ordre));
    return liste;
  }

  ChampConfig? champ(String moduleCle, String cle) =>
      module(moduleCle)?.champ(cle);

  StatutConfig? statut(String valeur) {
    final cherche = _normaliser(valeur);
    for (final s in statuts) {
      if (_normaliser(s.valeur) == cherche) return s;
    }
    return null;
  }

  /// Couleur d'un statut (par libellé), ou `null` si le statut est inconnu.
  Color? couleurStatut(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) return null;
    return statut(valeur)?.couleurAffichee;
  }

  IconData? iconeStatut(String? valeur) {
    if (valeur == null) return null;
    return statut(valeur)?.iconeAffichee;
  }

  /// Rubriques triées, noms seuls.
  List<String> get nomsRubriques {
    final liste = rubriques.map((r) => r.nom).where((n) => n.isNotEmpty).toList();
    liste.sort();
    return liste;
  }

  /// Rubrique retenue pour une ligne budgétaire : l'affectation explicite
  /// d'abord, sinon une correspondance directe sur le nom de rubrique.
  String? rubriquePourLigne(String ligneBudgetaire) {
    final cle = _normaliser(ligneBudgetaire);
    if (cle.isEmpty) return null;
    for (final entree in affectationsLignes.entries) {
      if (_normaliser(entree.key) == cle) return entree.value;
    }
    for (final r in rubriques) {
      final nom = _normaliser(r.nom);
      if (nom.isNotEmpty && (nom == cle || cle.contains(nom))) return r.nom;
    }
    return null;
  }

  static String _normaliser(String valeur) {
    var texte = valeur.toUpperCase();
    const accents = {
      'À': 'A',
      'Â': 'A',
      'Ä': 'A',
      'Á': 'A',
      'Ç': 'C',
      'È': 'E',
      'É': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'Î': 'I',
      'Ï': 'I',
      'Ô': 'O',
      'Ö': 'O',
      'Ù': 'U',
      'Û': 'U',
      'Ü': 'U',
      "'": ' ',
      '’': ' ',
    };
    accents.forEach((a, b) => texte = texte.replaceAll(a, b));
    return texte.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'modules': modules.map((m) => m.toJson()).toList(),
    'statuts': statuts.map((s) => s.toJson()).toList(),
    'rubriques': rubriques.map((r) => r.toJson()).toList(),
    'affectationsLignes': affectationsLignes,
  };

  factory ConfigurationApp.fromJson(Map<String, dynamic> json) =>
      ConfigurationApp(
        version: (json['version'] as num?)?.toInt() ?? 1,
        modules:
            (json['modules'] as List?)
                ?.whereType<Map>()
                .map((m) => ModuleConfig.fromJson(m.cast<String, dynamic>()))
                .toList() ??
            const [],
        statuts:
            (json['statuts'] as List?)
                ?.whereType<Map>()
                .map((s) => StatutConfig.fromJson(s.cast<String, dynamic>()))
                .toList() ??
            const [],
        rubriques:
            (json['rubriques'] as List?)
                ?.whereType<Map>()
                .map((r) => RubriqueConfig.fromJson(r.cast<String, dynamic>()))
                .toList() ??
            const [],
        affectationsLignes:
            (json['affectationsLignes'] as Map?)?.map(
              (k, v) => MapEntry('$k', '$v'),
            ) ??
            const {},
      );

  /// Fusionne une configuration enregistrée avec les modules livrés : un
  /// module apparu dans une nouvelle version est ajouté, un module livré
  /// disparu n'est jamais perdu (les personnalisations sont conservées).
  ConfigurationApp fusionnerAvecDefauts() {
    final defauts = ConfigurationApp.parDefaut();
    final modules = <ModuleConfig>[];
    final utilises = <String>{};
    for (final defaut in defauts.modules) {
      final enregistre = module(defaut.cle);
      if (enregistre == null) {
        modules.add(defaut);
      } else {
        modules.add(_fusionnerModule(defaut, enregistre));
      }
      utilises.add(defaut.cle);
    }
    for (final m in this.modules) {
      if (!utilises.contains(m.cle)) modules.add(m);
    }
    final statuts = [...this.statuts];
    for (final s in defauts.statuts) {
      if (statut(s.valeur) == null) statuts.add(s);
    }
    final rubriques = [...this.rubriques];
    for (final r in defauts.rubriques) {
      if (!rubriques.any((autre) => _normaliser(autre.nom) == _normaliser(r.nom))) {
        rubriques.add(r);
      }
    }
    return ConfigurationApp(
      version: defauts.version,
      modules: modules,
      statuts: statuts,
      rubriques: rubriques,
      affectationsLignes: affectationsLignes,
    );
  }

  /// Un module enregistré reçoit les champs **nouveaux** des versions
  /// suivantes, sans perdre les libellés, formules et couleurs personnalisés.
  static ModuleConfig _fusionnerModule(
    ModuleConfig defaut,
    ModuleConfig enregistre,
  ) {
    final champs = <ChampConfig>[...enregistre.champs];
    for (final champ in defaut.champs) {
      if (!champs.any((c) => c.cle == champ.cle)) champs.add(champ);
    }
    return enregistre.copyWith(
      champs: champs,
      actions: enregistre.actions,
      route: defaut.route,
      groupe: enregistre.groupe.isEmpty ? defaut.groupe : enregistre.groupe,
    );
  }
}

/// Diffuse la configuration dans l'arbre de widgets : les écrans, tableaux et
/// dialogues lisent les titres, colonnes, formules et couleurs **sans** être
/// des `Consumer` (comme [ReglagesAffichageScope] pour l'affichage).
class ConfigurationScope extends InheritedWidget {
  const ConfigurationScope({
    required this.configuration,
    required super.child,
    super.key,
  });

  final ConfigurationApp configuration;

  @override
  bool updateShouldNotify(ConfigurationScope oldWidget) =>
      configuration != oldWidget.configuration;
}

/// Décode une couleur hexadécimale (`FF2E7D32`, `2E7D32`, `#2E7D32`…).
Color? couleurDepuisHex(String? texte) {
  if (texte == null) return null;
  var valeur = texte.trim().replaceFirst('#', '').replaceFirst('0x', '');
  if (valeur.isEmpty) return null;
  if (valeur.length == 6) valeur = 'FF$valeur';
  final nombre = int.tryParse(valeur, radix: 16);
  return nombre == null ? null : Color(nombre);
}

/// Encode une couleur en hexadécimal (format d'enregistrement).
String couleurVersHex(Color couleur) =>
    couleur.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
