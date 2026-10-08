import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/configuration_repository.dart';
import '../../domain/configuration/cascade_configuration.dart';
import '../../domain/configuration/configuration_app.dart';
import 'providers.dart';

/// Accès à la configuration enregistrée (table `parametres`).
final configurationRepositoryProvider = Provider<ConfigurationRepository>(
  (ref) => ConfigurationRepository(ref.watch(parametresRepositoryProvider)),
);

/// Mises à jour en cascade (lignes des tarifs, règles PJ).
final cascadeConfigurationProvider = Provider<CascadeConfiguration>(
  (ref) => CascadeConfiguration(
    tarifs: ref.watch(tarifsRepositoryProvider),
    parametres: ref.watch(parametresRepositoryProvider),
  ),
);

/// Configuration **courante** de l'application.
///
/// Toute modification est appliquée immédiatement à l'état (l'interface se
/// met à jour sans redémarrage) puis enregistrée en base. Les règles métier,
/// les districts, les tarifs et la matrice des PJ ne dépendent pas de cette
/// configuration : ils continuent de s'appliquer quels que soient les
/// libellés, formules et couleurs choisis.
class ConfigurationNotifier extends Notifier<ConfigurationApp> {
  @override
  ConfigurationApp build() {
    _charger();
    return ConfigurationApp.parDefaut();
  }

  Future<void> _charger() async {
    try {
      final chargee = await ref.read(configurationRepositoryProvider).charger();
      if (ref.mounted) state = chargee;
    } catch (_) {
      // Une configuration illisible ne doit jamais empêcher l'ouverture de
      // l'application : les valeurs livrées restent en place.
    }
  }

  /// Enregistre une configuration complète (appliquée tout de suite).
  Future<void> definir(ConfigurationApp configuration) async {
    state = configuration;
    await ref.read(configurationRepositoryProvider).enregistrer(configuration);
  }

  // --- Modules -------------------------------------------------------------

  Future<void> majModule(ModuleConfig module) => definir(
    state.copyWith(
      modules: [
        for (final m in state.modules)
          if (m.cle == module.cle) module else m,
      ],
    ),
  );

  Future<void> ajouterModule(ModuleConfig module) =>
      definir(state.copyWith(modules: [...state.modules, module]));

  /// Supprime un onglet créé par l'utilisateur (les onglets livrés ne peuvent
  /// pas être supprimés, seulement désactivés).
  Future<void> supprimerModule(String cle) => definir(
    state.copyWith(modules: state.modules.where((m) => m.cle != cle).toList()),
  );

  // --- Champs --------------------------------------------------------------

  Future<void> majChamp(String module, ChampConfig champ) async {
    final cible = state.module(module);
    if (cible == null) return;
    final champs = [
      for (final c in cible.champs)
        if (c.cle == champ.cle) champ else c,
    ]..sort((a, b) => a.ordre.compareTo(b.ordre));
    await majModule(cible.copyWith(champs: champs));
  }

  Future<void> ajouterChamp(String module, ChampConfig champ) async {
    final cible = state.module(module);
    if (cible == null) return;
    final ordre = cible.champs.isEmpty
        ? 1
        : cible.champs.map((c) => c.ordre).reduce((a, b) => a > b ? a : b) + 1;
    await majModule(
      cible.copyWith(
        champs: [
          ...cible.champs,
          champ.copyWith(ordre: ordre),
        ],
      ),
    );
  }

  /// Supprime un champ. En **cascade**, ses champs enfants (`parent`) sont
  /// supprimés et les formules qui le référencent sont vidées : le nombre
  /// d'éléments touchés est renvoyé pour la confirmation.
  Future<({int enfants, int formules})> supprimerChamp(
    String module,
    String cle,
  ) async {
    final cible = state.module(module);
    if (cible == null) return (enfants: 0, formules: 0);
    final enfants = cible.champs.where((c) => c.parent == cle).length;
    var formules = 0;
    final restants = <ChampConfig>[];
    for (final champ in cible.champs) {
      if (champ.cle == cle) continue;
      if (champ.parent == cle) continue;
      var copie = champ;
      final formule = champ.formule ?? '';
      if (formule.isNotEmpty && referenceLaChamp(formule, cle)) {
        copie = copie.copyWith(supprimerFormule: true);
        formules++;
      }
      restants.add(copie);
    }
    await majModule(cible.copyWith(champs: restants));
    return (enfants: enfants, formules: formules);
  }

  /// Vrai si la formule utilise le champ [cle] (par clé ou par libellé).
  static bool referenceLaChamp(String formule, String cle) =>
      RegExp(
        r'\[\s*' + RegExp.escape(cle) + r'\s*\]',
        caseSensitive: false,
      ).hasMatch(formule) ||
      RegExp(
        r'(?<![A-Za-z0-9_])' + RegExp.escape(cle) + r'(?![A-Za-z0-9_])',
        caseSensitive: false,
      ).hasMatch(formule);

  /// Enregistre l'ordre d'affichage d'une liste de champs.
  Future<void> reordonnerChamps(String module, List<String> cles) async {
    final cible = state.module(module);
    if (cible == null) return;
    await majModule(
      cible.copyWith(
        champs: [
          for (var i = 0; i < cles.length; i++)
            if (cible.champ(cles[i]) != null)
              cible.champ(cles[i])!.copyWith(ordre: i + 1),
        ],
      ),
    );
  }

  // --- Statuts -------------------------------------------------------------

  Future<void> majStatut(StatutConfig statut, {String? ancienneValeur}) async {
    final ancienne = ancienneValeur ?? statut.valeur;
    await definir(
      state.copyWith(
        statuts: [
          for (final s in state.statuts)
            if (normaliser(s.valeur) == normaliser(ancienne)) statut else s,
        ],
      ),
    );
  }

  Future<void> ajouterStatut(StatutConfig statut) =>
      definir(state.copyWith(statuts: [...state.statuts, statut]));

  Future<void> supprimerStatut(String valeur) => definir(
    state.copyWith(
      statuts: [
        for (final s in state.statuts)
          if (normaliser(s.valeur) != normaliser(valeur)) s,
      ],
    ),
  );

  // --- Rubriques -----------------------------------------------------------

  Future<void> majRubrique(RubriqueConfig rubrique) => definir(
    state.copyWith(
      rubriques: [
        for (final r in state.rubriques)
          if (normaliser(r.nom) == normaliser(rubrique.nom)) rubrique else r,
      ],
    ),
  );

  /// Ajoute une rubrique ; [modele] permet de **copier les règles PJ** d'une
  /// rubrique existante (les automatismes sont donc immédiatement en place).
  Future<void> ajouterRubrique(
    RubriqueConfig rubrique, {
    String? modele,
  }) async {
    await definir(state.copyWith(rubriques: [...state.rubriques, rubrique]));
    if (modele != null && modele.trim().isNotEmpty) {
      await ref
          .read(cascadeConfigurationProvider)
          .dupliquerReglesPJ(modele: modele, vers: rubrique.nom);
    }
  }

  /// Renomme une rubrique : **cascade** sur les lignes du référentiel des
  /// tarifs, les règles PJ et les affectations déjà enregistrées.
  Future<void> renommerRubrique(String avant, String apres) async {
    final nom = apres.trim();
    if (nom.isEmpty) return;
    final rubriques = [
      for (final r in state.rubriques)
        if (normaliser(r.nom) == normaliser(avant)) r.copyWith(nom: nom) else r,
    ];
    final affectations = {
      for (final entree in state.affectationsLignes.entries)
        entree.key: normaliser(entree.value) == normaliser(avant)
            ? nom
            : entree.value,
    };
    await definir(
      state.copyWith(rubriques: rubriques, affectationsLignes: affectations),
    );
    final cascade = ref.read(cascadeConfigurationProvider);
    await cascade.reclasserLignes(de: avant, vers: nom);
    await cascade.reclasserReglesPJ(rubrique: avant, vers: nom);
  }

  /// Supprime une rubrique : les lignes concernées sont **reclassées**
  /// automatiquement (détection par mots-clés) et les règles PJ liées sont
  /// désactivées — jamais perdues.
  Future<({int lignes, int regles})> supprimerRubrique(
    String nom, {
    bool desactiverRegles = true,
  }) async {
    final cascade = ref.read(cascadeConfigurationProvider);
    final lignes = await cascade.reclasserLignes(de: nom, vers: null);
    final regles = desactiverRegles
        ? await cascade.reclasserReglesPJ(rubrique: nom, desactiver: true)
        : 0;
    final affectations = {
      for (final entree in state.affectationsLignes.entries)
        if (normaliser(entree.value) != normaliser(nom))
          entree.key: entree.value,
    };
    await definir(
      state.copyWith(
        rubriques: [
          for (final r in state.rubriques)
            if (normaliser(r.nom) != normaliser(nom)) r,
        ],
        affectationsLignes: affectations,
      ),
    );
    return (lignes: lignes, regles: regles);
  }

  /// Classe des lignes budgétaires dans une rubrique (ou les dé-classe avec
  /// [rubrique] à `null`).
  Future<void> affecterLignes(List<String> lignes, String? rubrique) async {
    final affectations = Map<String, String>.from(state.affectationsLignes);
    for (final ligne in lignes) {
      if (rubrique == null || rubrique.trim().isEmpty) {
        affectations.removeWhere((k, _) => normaliser(k) == normaliser(ligne));
      } else {
        affectations[ligne] = rubrique;
      }
    }
    await definir(state.copyWith(affectationsLignes: affectations));
    if (rubrique == null || rubrique.trim().isEmpty) return;
    // Les lignes du référentiel des tarifs portent le **libellé** de la ligne
    // budgétaire : on reclasse chacune d'elles dans la rubrique choisie.
    final cascade = ref.read(cascadeConfigurationProvider);
    for (final ligne in lignes) {
      await cascade.classerLigneBudgetaire(
        ligneBudgetaire: ligne,
        rubrique: rubrique,
      );
    }
  }

  /// Remet la configuration livrée (onglets et champs créés perdus).
  Future<void> reinitialiser() async {
    state = await ref.read(configurationRepositoryProvider).reinitialiser();
  }

  /// Normalise un libellé (majuscules, sans accents) pour les comparaisons.
  static String normaliser(String valeur) {
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
}

final configurationProvider =
    NotifierProvider<ConfigurationNotifier, ConfigurationApp>(
      ConfigurationNotifier.new,
    );
