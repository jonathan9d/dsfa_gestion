import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/configuration/configuration_app.dart';
import '../../../../domain/configuration/formules.dart';
import '../../../../domain/configuration/icones.dart';
import '../../../../domain/configuration/modules_par_defaut.dart';
import '../../../../domain/rubriques.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/configuration_providers.dart';
import '../../../widgets/common.dart';
import '../../../widgets/icone_configuree.dart';
import '../../../widgets/tableau.dart';
import 'editeurs.dart';

/// **Configuration** : tout ce qui s'affiche et se saisit dans l'application
/// se règle ici — titres, champs, formules, valeurs, couleurs par statut,
/// rubriques et lignes budgétaires, onglets et icônes.
///
/// Les automatismes ne sont jamais perdus : les règles et la matrice des PJ,
/// les districts, les tarifs et les calculs métier continuent de s'appliquer
/// quels que soient les libellés ou les formules choisis.
class ConfigurationOnglet extends ConsumerStatefulWidget {
  const ConfigurationOnglet({this.moduleInitial, super.key});

  /// Module ouvert d'emblée (bouton « Configuration » d'un onglet).
  final String? moduleInitial;

  @override
  ConsumerState<ConfigurationOnglet> createState() =>
      _ConfigurationOngletState();
}

class _ConfigurationOngletState extends ConsumerState<ConfigurationOnglet> {
  static const _sections = <({String cle, String label, IconData icone})>[
    (
      cle: 'modules',
      label: 'Onglets & présentation',
      icone: Icons.tune_outlined,
    ),
    (
      cle: 'champs',
      label: 'Champs & colonnes',
      icone: Icons.view_column_outlined,
    ),
    (cle: 'formules', label: 'Formules', icone: Icons.functions),
    (cle: 'statuts', label: 'Statuts & couleurs', icone: Icons.flag_outlined),
    (
      cle: 'rubriques',
      label: 'Rubriques & lignes',
      icone: Icons.category_outlined,
    ),
    (
      cle: 'onglets',
      label: 'Nouveaux onglets & icônes',
      icone: Icons.add_box_outlined,
    ),
  ];

  late String _section = widget.moduleInitial == null ? 'modules' : 'champs';
  late String? _module = widget.moduleInitial;

  @override
  Widget build(BuildContext context) {
    final configuration = ref.watch(configurationProvider);
    _module ??= configuration.modulesSysteme.isNotEmpty
        ? configuration.modulesSysteme.first.cle
        : (configuration.modules.isEmpty
              ? null
              : configuration.modules.first.cle);
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 246,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                child: Text(
                  'Configuration',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              for (final section in _sections)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: Material(
                    color: _section == section.cle
                        ? theme.colorScheme.primaryContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(9),
                      onTap: () => setState(() => _section = section.cle),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              section.icone,
                              size: 18,
                              color: _section == section.cle
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                section.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: _section == section.cle
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Les modifications sont appliquées immédiatement et '
                  'conservées au redémarrage.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: switch (_section) {
            'champs' => _VueChamps(
              module: _module!,
              onModule: (cle) => setState(() => _module = cle),
            ),
            'formules' => _VueFormules(
              onOuvrirChamp: (module) => setState(() {
                _module = module;
                _section = 'champs';
              }),
            ),
            'statuts' => const _VueStatuts(),
            'rubriques' => const _VueRubriques(),
            'onglets' => _VueOnglets(
              onModule: (cle) => setState(() {
                _module = cle;
                _section = 'champs';
              }),
            ),
            _ => const _VueModules(),
          },
        ),
      ],
    );
  }
}

/// En-tête de section : titre, explication et actions.
class _EnteteSection extends StatelessWidget {
  const _EnteteSection({
    required this.titre,
    required this.explication,
    this.actions = const [],
  });

  final String titre;
  final String explication;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  explication,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Wrap(spacing: 8, runSpacing: 8, children: actions),
        ],
      ),
    );
  }
}

// ===========================================================================
// 1. Onglets livrés : présentation, icône, couleur, actions
// ===========================================================================

class _VueModules extends ConsumerWidget {
  const _VueModules();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configuration = ref.watch(configurationProvider);
    final modules = [...configuration.modules]
      ..sort((a, b) => a.ordre.compareTo(b.ordre));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EnteteSection(
          titre: 'Onglets & présentation',
          explication:
              'Titre, description, icône, couleur et actions de chaque onglet. '
              'Les onglets livrés ne peuvent pas être supprimés : ils se '
              'masquent ou se personnalisent entièrement.',
          actions: [
            FilledButton.icon(
              onPressed: () => _creerOnglet(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Créer un onglet'),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              return _LigneModule(
                module: module,
                premier: index == 0,
                dernier: index == modules.length - 1,
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _creerOnglet(BuildContext context, WidgetRef ref) async {
    final configuration = ref.read(configurationProvider);
    final cle = 'onglet_${DateTime.now().millisecondsSinceEpoch}';
    final modele = ModuleConfig(
      cle: cle,
      titre: 'Nouvel onglet',
      sousTitre: 'Onglet créé depuis la configuration',
      icone: 'liste',
      systeme: false,
      source: sourcesOnglets.keys.first,
      ordre: configuration.modules.length + 1,
      actions: const [
        ActionsApp.rechercher,
        ActionsApp.filtrer,
        ActionsApp.selectionner,
        ActionsApp.supprimer,
        ActionsApp.configuration,
      ],
      champs: const [],
    );
    final edite = await editerModule(context, module: modele);
    if (edite == null) return;
    await ref.read(configurationProvider.notifier).ajouterModule(edite);
    if (context.mounted) notifier(context, 'Onglet « ${edite.titre} » créé');
  }
}

class _LigneModule extends ConsumerWidget {
  const _LigneModule({
    required this.module,
    required this.premier,
    required this.dernier,
  });

  final ModuleConfig module;
  final bool premier;
  final bool dernier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifierConfig = ref.read(configurationProvider.notifier);
    final couleur = module.couleurAffichee ?? theme.colorScheme.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Center(
                child: IconeConfiguree(
                  cle: module.icone,
                  importee: module.iconeImportee,
                  taille: 22,
                  couleur: couleur,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          module.titre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _Etiquette(
                        texte: module.systeme ? 'livré' : 'créé',
                        couleur: module.systeme
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.primary,
                      ),
                      if (!module.actif) ...[
                        const SizedBox(width: 6),
                        _Etiquette(
                          texte: 'masqué',
                          couleur: theme.colorScheme.error,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    module.sousTitre.isEmpty
                        ? 'Sans description'
                        : module.sousTitre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${module.champs.length} champ(s) · '
                    '${module.actions.length} action(s) · '
                    '${module.route ?? '/onglet/${module.cle}'}',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Monter',
              onPressed: premier
                  ? null
                  : () => notifierConfig.majModule(
                      module.copyWith(ordre: (module.ordre - 2).clamp(0, 999)),
                    ),
              icon: const Icon(Icons.keyboard_arrow_up, size: 20),
            ),
            IconButton(
              tooltip: 'Descendre',
              onPressed: dernier
                  ? null
                  : () => notifierConfig.majModule(
                      module.copyWith(ordre: module.ordre + 2),
                    ),
              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            ),
            IconButton(
              tooltip: module.actif
                  ? 'Masquer l\'onglet'
                  : 'Afficher l\'onglet',
              onPressed: () => notifierConfig.majModule(
                module.copyWith(actif: !module.actif),
              ),
              icon: Icon(
                module.actif
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
              ),
            ),
            IconButton(
              tooltip: 'Modifier la présentation',
              onPressed: () async {
                final edite = await editerModule(context, module: module);
                if (edite == null) return;
                await notifierConfig.majModule(edite);
              },
              icon: const Icon(Icons.edit_outlined, size: 20),
            ),
            if (!module.systeme)
              IconButton(
                tooltip: 'Supprimer l\'onglet',
                onPressed: () async {
                  final ok = await confirmerSuppression(
                    context,
                    titre: 'Supprimer l\'onglet',
                    element: module.titre,
                    consequences: [
                      'L\'onglet disparaît du menu et de la navigation.',
                      'Ses ${module.champs.length} champ(s) et ses réglages '
                          'sont supprimés.',
                      'Les données enregistrées (activités, budgets, '
                          'dépenses…) ne sont pas touchées.',
                    ],
                  );
                  if (!ok) return;
                  await notifierConfig.supprimerModule(module.cle);
                  if (context.mounted) {
                    notifier(context, 'Onglet « ${module.titre} » supprimé');
                  }
                },
                icon: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: theme.colorScheme.error,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Etiquette extends StatelessWidget {
  const _Etiquette({required this.texte, required this.couleur});

  final String texte;
  final Color couleur;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: couleur.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: couleur.withValues(alpha: 0.35)),
    ),
    child: Text(
      texte,
      style: TextStyle(
        fontSize: 10.5,
        color: couleur,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

// ===========================================================================
// 2. Champs & colonnes d'un module
// ===========================================================================

class _VueChamps extends ConsumerWidget {
  const _VueChamps({required this.module, required this.onModule});

  final String module;
  final ValueChanged<String> onModule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configuration = ref.watch(configurationProvider);
    final cible = configuration.module(module);
    final champs = [...(cible?.champs ?? const <ChampConfig>[])]
      ..sort((a, b) => a.ordre.compareTo(b.ordre));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EnteteSection(
          titre: 'Champs & colonnes — ${cible?.titre ?? module}',
          explication:
              'Ajoutez, renommez, masquez, réordonnez : tout le contenu du '
              'tableau et des formulaires est modifiable. Un champ peut avoir '
              'un parent (suppression en cascade) et une formule de calcul.',
          actions: [
            SizedBox(
              width: 260,
              child: DropdownButtonFormField<String>(
                initialValue: cible?.cle,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Onglet',
                  isDense: true,
                ),
                items: [
                  for (final m in configuration.modules)
                    DropdownMenuItem(
                      value: m.cle,
                      child: Text(
                        m.titre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) => v == null ? null : onModule(v),
              ),
            ),
            FilledButton.icon(
              onPressed: cible == null
                  ? null
                  : () async {
                      final champ = await editerChamp(
                        context,
                        module: module,
                        champs: champs,
                      );
                      if (champ == null) return;
                      await ref
                          .read(configurationProvider.notifier)
                          .ajouterChamp(module, champ);
                      if (context.mounted) {
                        notifier(context, 'Champ « ${champ.libelle} » ajouté');
                      }
                    },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nouveau champ'),
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: TableauGestion<ChampConfig>(
              lignes: champs,
              cleLigne: (c) => c.cle,
              cleModule: 'configuration_champs',
              taillePage: 30,
              messageVide:
                  'Aucun champ : ajoutez le premier avec « Nouveau '
                  'champ ».',
              colonnes: [
                ColonneTableau(
                  label: 'Ordre',
                  flex: 1,
                  triable: false,
                  filtrable: false,
                  valeur: (c) => '${c.ordre}',
                  cellule: (_, c) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Monter',
                        visualDensity: VisualDensity.compact,
                        onPressed: c.ordre <= 1
                            ? null
                            : () => ref
                                  .read(configurationProvider.notifier)
                                  .reordonnerChamps(
                                    module,
                                    _deplacer(
                                      champs.map((e) => e.cle).toList(),
                                      c.cle,
                                      -1,
                                    ),
                                  ),
                        icon: const Icon(Icons.arrow_upward, size: 14),
                      ),
                      IconButton(
                        tooltip: 'Descendre',
                        visualDensity: VisualDensity.compact,
                        onPressed: c.ordre >= champs.length
                            ? null
                            : () => ref
                                  .read(configurationProvider.notifier)
                                  .reordonnerChamps(
                                    module,
                                    _deplacer(
                                      champs.map((e) => e.cle).toList(),
                                      c.cle,
                                      1,
                                    ),
                                  ),
                        icon: const Icon(Icons.arrow_downward, size: 14),
                      ),
                    ],
                  ),
                ),
                ColonneTableau(
                  label: 'Titre affiché',
                  flex: 4,
                  valeur: (c) => c.libelle,
                ),
                ColonneTableau(
                  label: 'Clé',
                  flex: 3,
                  valeur: (c) => c.cle,
                  cellule: (_, c) => Text(
                    c.cle,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                    ),
                  ),
                ),
                ColonneTableau(
                  label: 'Type',
                  flex: 3,
                  valeur: (c) => c.type.libelle,
                ),
                ColonneTableau(
                  label: 'Affiché',
                  flex: 2,
                  triable: false,
                  valeur: (c) => c.visible ? 'Oui' : 'Non',
                  cellule: (_, c) => SwitchCompact(
                    value: c.visible,
                    onChanged: (v) => ref
                        .read(configurationProvider.notifier)
                        .majChamp(module, c.copyWith(visible: v)),
                  ),
                ),
                ColonneTableau(
                  label: 'Obligatoire',
                  flex: 2,
                  triable: false,
                  valeur: (c) => c.obligatoire ? 'Oui' : 'Non',
                  cellule: (_, c) => SwitchCompact(
                    value: c.obligatoire,
                    onChanged: (v) => ref
                        .read(configurationProvider.notifier)
                        .majChamp(module, c.copyWith(obligatoire: v)),
                  ),
                ),
                ColonneTableau(
                  label: 'Largeur',
                  flex: 2,
                  numerique: true,
                  valeur: (c) => c.largeur.toStringAsFixed(0),
                ),
                ColonneTableau(
                  label: 'Parent',
                  flex: 2,
                  valeur: (c) => cible?.champ(c.parent ?? '')?.libelle ?? '',
                ),
                ColonneTableau(
                  label: 'Formule',
                  flex: 4,
                  valeur: (c) => c.formule ?? '',
                ),
              ],
              actions: [
                ActionTableau<ChampConfig>(
                  icone: Icons.edit_outlined,
                  infobulle: 'Modifier le champ',
                  onTap: (c) async {
                    final champ = await editerChamp(
                      context,
                      module: module,
                      champs: champs,
                      champ: c,
                    );
                    if (champ == null) return;
                    await ref
                        .read(configurationProvider.notifier)
                        .majChamp(module, champ);
                    if (context.mounted) {
                      notifier(context, 'Champ « ${champ.libelle} » modifié');
                    }
                  },
                ),
                ActionTableau<ChampConfig>(
                  icone: Icons.delete_outline,
                  infobulle: 'Supprimer le champ',
                  couleur: Theme.of(context).colorScheme.error,
                  onTap: (c) async {
                    final enfants = champs
                        .where((e) => e.parent == c.cle)
                        .length;
                    final formules = champs
                        .where(
                          (e) =>
                              e.cle != c.cle &&
                              (e.formule ?? '').isNotEmpty &&
                              ConfigurationNotifier.referenceLaChamp(
                                e.formule!,
                                c.cle,
                              ),
                        )
                        .length;
                    final ok = await confirmerSuppression(
                      context,
                      titre: 'Supprimer le champ',
                      element: c.libelle,
                      consequences: [
                        'Le champ disparaît du tableau et des formulaires de '
                            '« ${cible?.titre ?? module} ».',
                        if (enfants > 0)
                          '$enfants champ(s) enfant(s) seront supprimés '
                              '(cascade).'
                        else
                          'Aucun champ enfant à supprimer.',
                        if (formules > 0)
                          '$formules formule(s) qui utilisaient ce champ '
                              'seront vidées pour éviter tout calcul faux.'
                        else
                          'Aucune formule n\'utilise ce champ.',
                        'Les données déjà enregistrées ne sont pas modifiées.',
                      ],
                    );
                    if (!ok) return;
                    await ref
                        .read(configurationProvider.notifier)
                        .supprimerChamp(module, c.cle);
                    if (context.mounted) {
                      notifier(context, 'Champ « ${c.libelle} » supprimé');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static List<String> _deplacer(List<String> cles, String cle, int delta) {
    final liste = [...cles];
    final index = liste.indexOf(cle);
    if (index < 0) return liste;
    final cible = index + delta;
    if (cible < 0 || cible >= liste.length) return liste;
    liste.removeAt(index);
    liste.insert(cible, cle);
    return liste;
  }
}

// ===========================================================================
// 3. Formules
// ===========================================================================

class _VueFormules extends ConsumerWidget {
  const _VueFormules({required this.onOuvrirChamp});

  final ValueChanged<String> onOuvrirChamp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configuration = ref.watch(configurationProvider);
    final avecFormule = <({ModuleConfig module, ChampConfig champ})>[];
    for (final module in configuration.modules) {
      for (final champ in module.champs) {
        if ((champ.formule ?? '').trim().isNotEmpty) {
          avecFormule.add((module: module, champ: champ));
        }
      }
    }
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _EnteteSection(
          titre: 'Formules de calcul',
          explication:
              'Une formule attribue une valeur à un champ à partir des autres '
              'champs. Elle est vérifiée avant enregistrement : une formule '
              'erronée ne peut jamais bloquer l\'application.',
          actions: [],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              CarteSection(
                titre: 'Écrire une formule',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Références : [quantite] ou quantite · Opérateurs : '
                      '${Formule.operateurs.join(' ')} · Comparaisons : '
                      '< <= > >= = !=',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Fonctions : ${Formule.fonctions.join(', ')}',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Exemples : quantite * pu + [frais divers] · '
                      'si(montant > 1000000, 1, 0) · '
                      'arrondi(recettes - depenses, 0)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (avecFormule.isEmpty)
                CarteSection(
                  titre: 'Aucune formule',
                  child: Text(
                    'Ouvrez un champ de type « Calculé par une formule » dans '
                    '« Champs & colonnes » pour lui attribuer une formule.',
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              else
                for (final entree in avecFormule)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: IconeConfiguree(
                        cle: entree.module.icone,
                        importee: entree.module.iconeImportee,
                        taille: 22,
                      ),
                      title: Text(
                        '${entree.module.titre} ▸ ${entree.champ.libelle}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        entree.champ.formule ?? '',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _EtatFormule(
                            champ: entree.champ,
                            module: entree.module,
                          ),
                          IconButton(
                            tooltip: 'Modifier',
                            onPressed: () => onOuvrirChamp(entree.module.cle),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EtatFormule extends StatelessWidget {
  const _EtatFormule({required this.champ, required this.module});

  final ChampConfig champ;
  final ModuleConfig module;

  @override
  Widget build(BuildContext context) {
    final erreur = Formule.verifier(
      champ.formule ?? '',
      champsConnus: {
        for (final c in module.champs) ...[c.cle, c.libelle],
      },
    );
    final theme = Theme.of(context);
    return Tooltip(
      message: erreur ?? 'Formule valide',
      child: Icon(
        erreur == null ? Icons.check_circle_outline : Icons.error_outline,
        size: 18,
        color: erreur == null
            ? theme.colorScheme.primary
            : theme.colorScheme.error,
      ),
    );
  }
}

// ===========================================================================
// 4. Statuts & couleurs
// ===========================================================================

class _VueStatuts extends ConsumerWidget {
  const _VueStatuts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configuration = ref.watch(configurationProvider);
    final statuts = [...configuration.statuts];
    final notifierConfig = ref.read(configurationProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EnteteSection(
          titre: 'Statuts & couleurs',
          explication:
              'Chaque statut (PJ, paiement, indemnité, rapprochement…) a sa '
              'couleur et son icône, utilisées partout dans l\'application.',
          actions: [
            FilledButton.icon(
              onPressed: () async {
                final statut = await editerStatut(context);
                if (statut == null) return;
                await notifierConfig.ajouterStatut(statut);
                if (context.mounted) {
                  notifier(context, 'Statut « ${statut.valeur} » ajouté');
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nouveau statut'),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: statuts.length,
            itemBuilder: (context, index) {
              final statut = statuts[index];
              final couleur = statut.couleurAffichee;
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  dense: true,
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: couleur.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: couleur.withValues(alpha: 0.4)),
                    ),
                    child: Center(
                      child: Icon(
                        statut.iconeAffichee,
                        size: 19,
                        color: couleur,
                      ),
                    ),
                  ),
                  title: Text(
                    statut.valeur,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: couleur,
                    ),
                  ),
                  subtitle: Text(
                    '${couleurVersHex(couleur)} · '
                    '${statut.systeme ? 'statut livré' : 'statut créé'}',
                    style: const TextStyle(fontSize: 11.5),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 46,
                        height: 22,
                        decoration: BoxDecoration(
                          color: couleur,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Modifier',
                        onPressed: () async {
                          final edite = await editerStatut(
                            context,
                            statut: statut,
                          );
                          if (edite == null) return;
                          await notifierConfig.majStatut(
                            edite,
                            ancienneValeur: statut.valeur,
                          );
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                      ),
                      IconButton(
                        tooltip: 'Supprimer',
                        onPressed: () async {
                          final ok = await confirmerSuppression(
                            context,
                            titre: 'Supprimer le statut',
                            element: statut.valeur,
                            consequences: [
                              'Les lignes qui portent ce statut gardent leur '
                                  'valeur, mais perdent leur couleur '
                                  'personnalisée.',
                              'Les règles et la matrice des PJ ne sont pas '
                                  'modifiées.',
                            ],
                          );
                          if (!ok) return;
                          await notifierConfig.supprimerStatut(statut.valeur);
                          if (context.mounted) {
                            notifier(context, 'Statut supprimé');
                          }
                        },
                        icon: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// 5. Rubriques & lignes budgétaires (CRUD + classement)
// ===========================================================================

class _VueRubriques extends ConsumerWidget {
  const _VueRubriques();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configuration = ref.watch(configurationProvider);
    final tarifs = ref.watch(tousTarifsProvider).value ?? const [];
    final lignesBudget =
        ref.watch(toutesLignesBudgetProvider).value ?? const [];
    final regles = ref.watch(reglesParametresProvider).value;
    final rubriquesPJ = <String>{};
    if (regles != null) {
      for (final regle in regles.matricePJ) {
        if (regle.rubrique.trim().isNotEmpty) rubriquesPJ.add(regle.rubrique);
      }
    }

    // Lignes budgétaires connues, toutes sources confondues.
    final lignes = <String, _LigneBudgetResume>{};
    void ajouter(String libelle, String rubrique, String source, double tarif) {
      final l = libelle.trim();
      if (l.isEmpty) return;
      final existante = lignes[l];
      if (existante == null) {
        lignes[l] = _LigneBudgetResume(
          libelle: l,
          rubrique: rubrique,
          sources: {source},
          tarif: tarif,
        );
      } else {
        existante.sources.add(source);
        if (existante.rubrique.isEmpty && rubrique.isNotEmpty) {
          existante.rubrique = rubrique;
        }
        if (existante.tarif == 0 && tarif > 0) existante.tarif = tarif;
      }
    }

    for (final tarif in tarifs) {
      ajouter(tarif.ligneBudgetaire, tarif.rubrique, 'Tarifs', tarif.tarif);
    }
    for (final ligne in lignesBudget) {
      ajouter(ligne.ligneBudgetaire, '', 'Budget', ligne.tauxUnitaire);
    }
    final listeLignes = lignes.values.toList()
      ..sort((a, b) => a.libelle.compareTo(b.libelle));

    // Une ligne est « classée » si la rubrique figure dans la configuration.
    final rubriquesConnues = configuration.nomsRubriques;
    String rubriqueDe(_LigneBudgetResume ligne) {
      final affectee = configuration.rubriquePourLigne(ligne.libelle);
      if (affectee != null && affectee.isNotEmpty) return affectee;
      if (ligne.rubrique.isNotEmpty &&
          RubriquesBudget.estConnue(ligne.rubrique, rubriquesConnues)) {
        return ligne.rubrique;
      }
      final deduite = RubriquesBudget.pourLibelle(
        ligne.libelle,
        rubriquesConnues,
      );
      return deduite == RubriquesBudget.aPreciser ? '' : deduite;
    }

    final nonClassees = listeLignes.where((l) => rubriqueDe(l).isEmpty).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _EnteteSection(
          titre: 'Rubriques & lignes budgétaires',
          explication:
              'Créez, renommez ou supprimez des rubriques, puis classez chaque '
              'ligne budgétaire. Tout est appliqué en cascade : référence des '
              'tarifs, règles de la matrice PJ et contrôle des pièces.',
          actions: [],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              CarteSection(
                titre: 'Rubriques (${configuration.rubriques.length})',
                actions: [
                  FilledButton.icon(
                    onPressed: () async {
                      final resultat = await editerRubrique(
                        context,
                        rubriques: configuration.nomsRubriques,
                      );
                      if (resultat == null) return;
                      await ref
                          .read(configurationProvider.notifier)
                          .ajouterRubrique(
                            resultat.rubrique,
                            modele: resultat.modele,
                          );
                      if (context.mounted) {
                        notifier(
                          context,
                          'Rubrique « ${resultat.rubrique.nom} » créée',
                        );
                      }
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nouvelle rubrique'),
                  ),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final rubrique in configuration.rubriques)
                      _LigneRubrique(
                        rubrique: rubrique,
                        nombreLignes: listeLignes
                            .where(
                              (l) => _memeTexte(rubriqueDe(l), rubrique.nom),
                            )
                            .length,
                        nombreReglesPJ: regles == null
                            ? 0
                            : regles.matricePJ
                                  .where(
                                    (r) => _memeTexte(r.rubrique, rubrique.nom),
                                  )
                                  .length,
                      ),
                    if (configuration.rubriques.isEmpty)
                      Text(
                        'Aucune rubrique : créez la première pour classer les '
                        'lignes budgétaires.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              CarteSection(
                titre:
                    'Lignes budgétaires (${listeLignes.length}) — '
                    '$nonClassees sans rubrique',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Chaque ligne reçoit sa rubrique. Les calculs de '
                            'budget, les tarifs et les contrôles PJ suivent '
                            'automatiquement.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: nonClassees == 0
                              ? null
                              : () async {
                                  final notifierConfig = ref.read(
                                    configurationProvider.notifier,
                                  );
                                  var classees = 0;
                                  for (final ligne in listeLignes) {
                                    if (rubriqueDe(ligne).isNotEmpty) continue;
                                    final rubrique =
                                        RubriquesBudget.pourLibelle(
                                          ligne.libelle,
                                          rubriquesConnues,
                                        );
                                    if (rubrique.isEmpty ||
                                        rubrique == RubriquesBudget.aPreciser) {
                                      continue;
                                    }
                                    await notifierConfig.affecterLignes([
                                      ligne.libelle,
                                    ], rubrique);
                                    classees++;
                                  }
                                  if (context.mounted) {
                                    notifier(
                                      context,
                                      classees == 0
                                          ? 'Aucune ligne reconnue '
                                                'automatiquement'
                                          : '$classees ligne(s) classée(s)',
                                    );
                                  }
                                },
                          icon: const Icon(
                            Icons.auto_fix_high_outlined,
                            size: 18,
                          ),
                          label: const Text('Classer automatiquement'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 420,
                      child: TableauGestion<_LigneBudgetResume>(
                        lignes: listeLignes,
                        cleLigne: (l) => l.libelle,
                        cleModule: 'configuration_lignes_budget',
                        taillePage: 40,
                        messageVide: 'Aucune ligne budgétaire connue.',
                        colonnes: [
                          ColonneTableau(
                            label: 'Ligne budgétaire',
                            flex: 6,
                            valeur: (l) => l.libelle,
                          ),
                          ColonneTableau(
                            label: 'Source',
                            flex: 3,
                            valeur: (l) => l.sources.join(' + '),
                          ),
                          ColonneTableau(
                            label: 'Tarif (Ar)',
                            flex: 2,
                            numerique: true,
                            valeur: (l) => l.tarif.toStringAsFixed(0),
                          ),
                          ColonneTableau(
                            label: 'Rubrique',
                            flex: 5,
                            triable: false,
                            valeur: (l) => rubriqueDe(l),
                            cellule: (_, l) {
                              final actuelle = rubriqueDe(l);
                              final options = configuration.nomsRubriques;
                              return DropdownButton<String>(
                                isExpanded: true,
                                underline: const SizedBox.shrink(),
                                hint: const Text(
                                  'À classer',
                                  style: TextStyle(fontSize: 12),
                                ),
                                value:
                                    actuelle.isEmpty ||
                                        !options.any(
                                          (o) => _memeTexte(o, actuelle),
                                        )
                                    ? null
                                    : actuelle,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                items: [
                                  for (final option in options)
                                    DropdownMenuItem(
                                      value: option,
                                      child: Text(
                                        option,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12.5),
                                      ),
                                    ),
                                ],
                                onChanged: (v) async {
                                  await ref
                                      .read(configurationProvider.notifier)
                                      .affecterLignes([l.libelle], v);
                                  if (context.mounted) {
                                    notifier(
                                      context,
                                      v == null
                                          ? 'Rubrique retirée'
                                          : '« ${l.libelle} » classée dans $v',
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static bool _memeTexte(String a, String b) =>
      ConfigurationNotifier.normaliser(a) ==
      ConfigurationNotifier.normaliser(b);
}

class _LigneRubrique extends ConsumerWidget {
  const _LigneRubrique({
    required this.rubrique,
    required this.nombreLignes,
    required this.nombreReglesPJ,
  });

  final RubriqueConfig rubrique;
  final int nombreLignes;
  final int nombreReglesPJ;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final couleur = rubrique.couleurAffichee ?? theme.colorScheme.primary;
    final notifierConfig = ref.read(configurationProvider.notifier);
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: couleur.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: couleur.withValues(alpha: 0.4)),
          ),
          child: Center(
            child: Icon(Icons.category_outlined, size: 17, color: couleur),
          ),
        ),
        title: Text(
          rubrique.nom,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '$nombreLignes ligne(s) budgétaire(s) · '
          '$nombreReglesPJ règle(s) PJ',
          style: const TextStyle(fontSize: 11.5),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Renommer',
              onPressed: () async {
                final resultat = await editerRubrique(
                  context,
                  rubriques: ref.read(configurationProvider).nomsRubriques,
                  rubrique: rubrique,
                );
                if (resultat == null) return;
                final nouveau = resultat.rubrique.nom;
                if (_memeTexte(nouveau, rubrique.nom)) {
                  await notifierConfig.majRubrique(
                    rubrique.copyWith(couleur: resultat.rubrique.couleur),
                  );
                  return;
                }
                await notifierConfig.renommerRubrique(rubrique.nom, nouveau);
                await notifierConfig.majRubrique(
                  resultat.rubrique.copyWith(nom: nouveau),
                );
                if (context.mounted) {
                  notifier(
                    context,
                    'Rubrique renommée : lignes et règles PJ mises à jour',
                  );
                }
              },
              icon: const Icon(Icons.edit_outlined, size: 18),
            ),
            IconButton(
              tooltip: 'Supprimer',
              onPressed: () async {
                final ok = await confirmerSuppression(
                  context,
                  titre: 'Supprimer la rubrique',
                  element: rubrique.nom,
                  consequences: [
                    '$nombreLignes ligne(s) du référentiel des tarifs '
                        'seront reclassées automatiquement (détection par '
                        'mots-clés).',
                    if (nombreReglesPJ > 0)
                      '$nombreReglesPJ règle(s) de la matrice PJ seront '
                          'désactivées — les pièces restent dans '
                          'l\'historique.'
                    else
                      'Aucune règle PJ n\'est rattachée à cette rubrique.',
                    'Les affectations de lignes qui pointaient vers cette '
                        'rubrique seront retirées.',
                    'Les budgets, dépenses et activités déjà saisis ne sont '
                        'pas supprimés.',
                  ],
                );
                if (!ok) return;
                final resultat = await notifierConfig.supprimerRubrique(
                  rubrique.nom,
                );
                if (context.mounted) {
                  notifier(
                    context,
                    'Rubrique supprimée : ${resultat.lignes} ligne(s) '
                    'reclassée(s), ${resultat.regles} règle(s) PJ désactivée(s)',
                  );
                }
              },
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bool _memeTexte(String a, String b) =>
      ConfigurationNotifier.normaliser(a) ==
      ConfigurationNotifier.normaliser(b);
}

class _LigneBudgetResume {
  _LigneBudgetResume({
    required this.libelle,
    required this.rubrique,
    required this.sources,
    required this.tarif,
  });

  final String libelle;
  String rubrique;
  final Set<String> sources;
  double tarif;
}

// ===========================================================================
// 6. Nouveaux onglets & icônes
// ===========================================================================

class _VueOnglets extends ConsumerWidget {
  const _VueOnglets({required this.onModule});

  final ValueChanged<String> onModule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configuration = ref.watch(configurationProvider);
    final crees = configuration.ongletsPersonnalises;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EnteteSection(
          titre: 'Nouveaux onglets & icônes',
          explication:
              'Créez autant d\'onglets que nécessaire, choisissez leur icône '
              '(catalogue Material ou image importée), leur contenu et les '
              'actions autorisées.',
          actions: [
            FilledButton.icon(
              onPressed: () async {
                final cle = 'onglet_${DateTime.now().millisecondsSinceEpoch}';
                final modele = ModuleConfig(
                  cle: cle,
                  titre: 'Nouvel onglet',
                  sousTitre: 'Contenu choisi dans la configuration',
                  icone: 'liste',
                  systeme: false,
                  source: sourcesOnglets.keys.first,
                  ordre: configuration.modules.length + 1,
                  actions: const [
                    ActionsApp.rechercher,
                    ActionsApp.filtrer,
                    ActionsApp.selectionner,
                    ActionsApp.supprimer,
                    ActionsApp.configuration,
                  ],
                );
                final edite = await editerModule(context, module: modele);
                if (edite == null) return;
                await ref
                    .read(configurationProvider.notifier)
                    .ajouterModule(edite);
                if (context.mounted) {
                  notifier(context, 'Onglet « ${edite.titre} » créé');
                }
              },
              icon: const Icon(Icons.add_box_outlined, size: 18),
              label: const Text('Créer un onglet'),
            ),
          ],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              CarteSection(
                titre: 'Onglets créés (${crees.length})',
                child: crees.isEmpty
                    ? Text(
                        'Aucun onglet créé pour le moment. Un onglet peut '
                        'afficher les activités, les budgets, les dépenses, '
                        'la banque, les participants, les présences, les '
                        'indemnités ou les contrôles PJ.',
                        style: theme.textTheme.bodyMedium,
                      )
                    : Column(
                        children: [
                          for (final module in crees)
                            ListTile(
                              dense: true,
                              leading: IconeConfiguree(
                                cle: module.icone,
                                importee: module.iconeImportee,
                                taille: 22,
                              ),
                              title: Text(module.titre),
                              subtitle: Text(
                                '${sourcesOnglets[module.source] ?? module.source}'
                                ' · ${module.actions.length} action(s)',
                                style: const TextStyle(fontSize: 11.5),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => onModule(module.cle),
                                    child: const Text('Champs'),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    tooltip: 'Modifier',
                                    onPressed: () async {
                                      final edite = await editerModule(
                                        context,
                                        module: module,
                                      );
                                      if (edite == null) return;
                                      await ref
                                          .read(configurationProvider.notifier)
                                          .majModule(edite);
                                    },
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              CarteSection(
                titre: 'Icônes : catalogue et import',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      IconesApp.formatImport,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${IconesApp.catalogue.length} icônes du catalogue sont '
                      'disponibles (tableau de bord, activités, argent, suivi, '
                      'administration…) et une image personnalisée peut être '
                      'importée pour n\'importe quel onglet ou statut.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final cle in IconesApp.clesTriees().take(24))
                          Tooltip(
                            message: IconesApp.libelle(cle),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(
                                  IconesApp.iconeOuDefaut(cle),
                                  size: 19,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => choisirIcone(context),
                      icon: const Icon(Icons.grid_view_outlined, size: 18),
                      label: const Text('Ouvrir la galerie complète'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
