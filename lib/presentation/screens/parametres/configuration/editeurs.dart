import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../domain/configuration/configuration_app.dart';
import '../../../../domain/configuration/formules.dart';
import '../../../../domain/configuration/icones.dart';
import '../../../../domain/configuration/modules_par_defaut.dart';
import '../../../widgets/common.dart';
import '../../../widgets/icone_configuree.dart';

/// Palettes proposées pour les couleurs (statuts, rubriques, modules).
const _palette = <String>[
  'FF2E7D32',
  'FF43A047',
  'FF00897B',
  'FF1976D2',
  'FF3949AB',
  'FF5E35B1',
  'FF7E57C2',
  'FF8E24AA',
  'FFD81B60',
  'FFC62828',
  'FFE53935',
  'FFD84315',
  'FFE65100',
  'FFF9A825',
  'FFFFB300',
  'FF6D4C41',
  'FF546E7A',
  'FF455A64',
  'FF263238',
  'FF9E9E9E',
];

/// Choix d'une couleur : palette + code hexadécimal.
Future<Color?> choisirCouleur(
  BuildContext context, {
  Color? initiale,
  String titre = 'Choisir une couleur',
}) => showDialog<Color>(
  context: context,
  builder: (_) => _DialogueCouleur(initiale: initiale, titre: titre),
);

class _DialogueCouleur extends StatefulWidget {
  const _DialogueCouleur({required this.titre, this.initiale});

  final String titre;
  final Color? initiale;

  @override
  State<_DialogueCouleur> createState() => _DialogueCouleurState();
}

class _DialogueCouleurState extends State<_DialogueCouleur> {
  late final TextEditingController _hex = TextEditingController(
    text: couleurVersHex(widget.initiale ?? const Color(0xFF2E7D32)),
  );

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final choisie = couleurDepuisHex(_hex.text) ?? const Color(0xFF2E7D32);
    return AlertDialog(
      title: TitreDialogue(widget.titre, icone: Icons.palette_outlined),
      content: SizedBox(
        width: largeurDialogue(context, 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final hex in _palette)
                  InkWell(
                    onTap: () => setState(() => _hex.text = hex),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: couleurDepuisHex(hex),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: couleurDepuisHex(_hex.text) ==
                                  couleurDepuisHex(hex)
                              ? Theme.of(context).colorScheme.onSurface
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _hex,
              decoration: const InputDecoration(
                labelText: 'Code hexadécimal (AARRGGBB)',
                helperText: 'Exemple : FF2E7D32 (vert foncé)',
                prefixIcon: Icon(Icons.tag, size: 18),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 42,
                  height: 24,
                  decoration: BoxDecoration(
                    color: choisie,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black12),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Aperçu de la couleur',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(choisie),
          child: const Text('Utiliser cette couleur'),
        ),
      ],
    );
  }
}

/// Choix d'une icône : catalogue complet + **import d'une image**.
///
/// Renvoie la clé retenue et l'image importée (base 64) le cas échéant.
Future<({String cle, String? importee})?> choisirIcone(
  BuildContext context, {
  String? cleActuelle,
  String? importeeActuelle,
}) => showDialog<({String cle, String? importee})>(
  context: context,
  builder: (_) => _DialogueIcone(
    cleActuelle: cleActuelle,
    importeeActuelle: importeeActuelle,
  ),
);

class _DialogueIcone extends StatefulWidget {
  const _DialogueIcone({this.cleActuelle, this.importeeActuelle});

  final String? cleActuelle;
  final String? importeeActuelle;

  @override
  State<_DialogueIcone> createState() => _DialogueIconeState();
}

class _DialogueIconeState extends State<_DialogueIcone> {
  late String _cle = widget.cleActuelle ?? IconesApp.defaut;
  late String? _importee = widget.importeeActuelle;
  final _recherche = TextEditingController();

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  /// Import d'une image : le fichier est **encodé dans la configuration**,
  /// donc aucune installation ni recompilation n'est nécessaire.
  Future<void> _importer() async {
    final fichiers = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'bmp'],
      dialogTitle: 'Choisir une icône (PNG ou JPEG, 512 × 512 maximum)',
    );
    if (fichiers.isEmpty || fichiers.single.path == null) return;
    final fichier = File(fichiers.single.path!);
    final octets = await fichier.readAsBytes();
    if (!mounted) return;
    if (octets.length > 400 * 1024) {
      notifier(
        context,
        'Image trop lourde (${(octets.length / 1024).round()} Ko) : '
        '400 Ko maximum. Réduisez l\'image à 512 × 512 pixels.',
        erreur: true,
      );
      return;
    }
    setState(() => _importee = base64Encode(octets));
    notifier(context, 'Icône importée : elle sera enregistrée avec la '
        'configuration');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cles = IconesApp.rechercher(_recherche.text);
    return AlertDialog(
      title: TitreDialogue(
        'Icône de l\'onglet',
        sousTitre: 'Catalogue Material ou image importée',
        icone: Icons.emoji_emotions_outlined,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 620),
        height: 460,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(
                    child: IconeConfiguree(
                      cle: _cle,
                      importee: _importee,
                      taille: 24,
                      couleur: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _recherche,
                    decoration: const InputDecoration(
                      labelText: 'Rechercher une icône',
                      hintText: 'exemple : banque, suivi, personne…',
                      prefixIcon: Icon(Icons.search, size: 18),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Flexible(
                  child: OutlinedButton.icon(
                    onPressed: _importer,
                    icon: const Icon(Icons.upload_file_outlined, size: 18),
                    label: const Text('Importer une image (PNG/JPEG)'),
                  ),
                ),
                if (_importee != null) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => setState(() => _importee = null),
                    icon: const Icon(Icons.layers_clear_outlined, size: 18),
                    label: const Text('Retirer l\'image importée'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 62,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                      ),
                  itemCount: cles.length,
                  itemBuilder: (context, index) {
                    final cle = cles[index];
                    final actif = cle == _cle && _importee == null;
                    return Tooltip(
                      message: IconesApp.libelle(cle),
                      child: InkWell(
                        onTap: () => setState(() {
                          _cle = cle;
                          _importee = null;
                        }),
                        borderRadius: BorderRadius.circular(9),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: actif
                                ? theme.colorScheme.primaryContainer
                                : null,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Center(
                            child: Icon(
                              IconesApp.iconeOuDefaut(cle),
                              size: 22,
                              color: actif
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 17,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        IconesApp.formatImport,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop((
            cle: _cle,
            importee: _importee,
          )),
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Utiliser cette icône'),
        ),
      ],
    );
  }
}

/// Édition de la **présentation d'un onglet** : titre, sous-titre, icône,
/// couleur, actions autorisées et, pour un onglet créé, sa source de données.
Future<ModuleConfig?> editerModule(
  BuildContext context, {
  required ModuleConfig module,
}) => showDialog<ModuleConfig>(
  context: context,
  builder: (_) => _DialogueModule(module: module),
);

class _DialogueModule extends StatefulWidget {
  const _DialogueModule({required this.module});

  final ModuleConfig module;

  @override
  State<_DialogueModule> createState() => _DialogueModuleState();
}

class _DialogueModuleState extends State<_DialogueModule> {
  late final TextEditingController _titre;
  late final TextEditingController _sousTitre;
  late final TextEditingController _groupe;
  late String _icone;
  late String? _importee;
  late String _couleur;
  late String _source;
  late bool _actif;
  late List<String> _actions;

  @override
  void initState() {
    super.initState();
    final m = widget.module;
    _titre = TextEditingController(text: m.titre);
    _sousTitre = TextEditingController(text: m.sousTitre);
    _groupe = TextEditingController(text: m.groupe);
    _icone = m.icone;
    _importee = m.iconeImportee;
    _couleur = m.couleur;
    _source = m.source.isEmpty
        ? sourcesOnglets.keys.first
        : m.source;
    _actif = m.actif;
    _actions = [...m.actions];
  }

  @override
  void dispose() {
    _titre.dispose();
    _sousTitre.dispose();
    _groupe.dispose();
    super.dispose();
  }

  Future<void> _choisirIcone2() async {
    final choix = await choisirIcone(
      context,
      cleActuelle: _icone,
      importeeActuelle: _importee,
    );
    if (choix == null || !mounted) return;
    setState(() {
      _icone = choix.cle;
      _importee = choix.importee;
    });
  }

  Future<void> _choisirCouleur() async {
    final choix = await choisirCouleur(
      context,
      initiale: couleurDepuisHex(_couleur),
      titre: 'Couleur de l\'onglet',
    );
    if (choix == null || !mounted) return;
    setState(() => _couleur = couleurVersHex(choix));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final module = widget.module;
    return AlertDialog(
      title: TitreDialogue(
        module.systeme ? 'Personnaliser l\'onglet' : 'Onglet créé',
        sousTitre:
            'Titre, icône, couleur et actions — l\'onglet entier est modifiable',
        icone: Icons.tune_outlined,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 620),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: IconeConfiguree(
                        cle: _icone,
                        importee: _importee,
                        taille: 26,
                        couleur: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _choisirIcone2,
                          icon: const Icon(Icons.emoji_symbols_outlined, size: 18),
                          label: const Text('Choisir l\'icône'),
                        ),
                        const SizedBox(height: 6),
                        OutlinedButton.icon(
                          onPressed: _choisirCouleur,
                          icon: const Icon(Icons.palette_outlined, size: 18),
                          label: const Text('Choisir la couleur'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _titre,
                decoration: const InputDecoration(
                  labelText: 'Titre de l\'onglet *',
                  prefixIcon: Icon(Icons.title, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _sousTitre,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Sous-titre / description',
                  prefixIcon: Icon(Icons.notes_outlined, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              if (!module.systeme) ...[
                DropdownButtonFormField<String>(
                  initialValue: _source,
                  decoration: const InputDecoration(
                    labelText: 'Contenu du tableau *',
                    prefixIcon: Icon(Icons.table_rows_outlined, size: 18),
                  ),
                  items: [
                    for (final entree in sourcesOnglets.entries)
                      DropdownMenuItem(
                        value: entree.key,
                        child: Text(
                          entree.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (v) =>
                      setState(() => _source = v ?? _source),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _groupe,
                  decoration: const InputDecoration(
                    labelText: 'Groupe dans le menu (facultatif)',
                    hintText: 'exemple : Administration',
                    prefixIcon: Icon(Icons.segment, size: 18),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                'Actions possibles dans l\'onglet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final entree in ActionsApp.catalogue.entries)
                    FilterChip(
                      label: Text(entree.value),
                      selected: _actions.contains(entree.key),
                      onSelected: (v) => setState(() {
                        if (v) {
                          _actions.add(entree.key);
                        } else {
                          _actions.remove(entree.key);
                        }
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              LigneBascule(
                label: 'Onglet visible dans le menu',
                sousTitre: 'Décochez pour masquer sans perdre les réglages',
                value: _actif,
                onChanged: (v) => setState(() => _actif = v),
              ),
              if (module.route != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Adresse de l\'écran : ${module.route}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: () {
            if (_titre.text.trim().isEmpty) {
              notifier(context, 'Le titre de l\'onglet est obligatoire',
                  erreur: true);
              return;
            }
            Navigator.of(context).pop(
              module.copyWith(
                titre: _titre.text.trim(),
                sousTitre: _sousTitre.text.trim(),
                icone: _icone,
                iconeImportee: _importee,
                supprimerIconeImportee: _importee == null,
                couleur: _couleur,
                actif: _actif,
                actions: _actions,
                source: module.systeme ? module.source : _source,
                groupe: _groupe.text.trim(),
              ),
            );
          },
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

/// Édition d'un **champ** : titre, type, formule, valeurs, couleurs, parent.
Future<ChampConfig?> editerChamp(
  BuildContext context, {
  required String module,
  required List<ChampConfig> champs,
  ChampConfig? champ,
}) => showDialog<ChampConfig>(
  context: context,
  builder: (_) => _DialogueChamp(module: module, champs: champs, champ: champ),
);

class _DialogueChamp extends StatefulWidget {
  const _DialogueChamp({
    required this.module,
    required this.champs,
    this.champ,
  });

  final String module;
  final List<ChampConfig> champs;
  final ChampConfig? champ;

  @override
  State<_DialogueChamp> createState() => _DialogueChampState();
}

class _DialogueChampState extends State<_DialogueChamp> {
  late final TextEditingController _cle;
  late final TextEditingController _libelle;
  late final TextEditingController _aide;
  late final TextEditingController _largeur;
  late final TextEditingController _valeurs;
  late final TextEditingController _formule;
  late TypeChamp _type;
  late bool _visible;
  late bool _obligatoire;
  late String? _parent;
  late Map<String, String> _couleurs;

  bool get _creation => widget.champ == null;

  @override
  void initState() {
    super.initState();
    final c = widget.champ;
    _cle = TextEditingController(text: c?.cle ?? '');
    _libelle = TextEditingController(text: c?.libelle ?? '');
    _aide = TextEditingController(text: c?.aide ?? '');
    _largeur = TextEditingController(text: (c?.largeur ?? 150).toStringAsFixed(0));
    _valeurs = TextEditingController(text: (c?.valeurs ?? const []).join(' ; '));
    _formule = TextEditingController(text: c?.formule ?? '');
    _type = c?.type ?? TypeChamp.texte;
    _visible = c?.visible ?? true;
    _obligatoire = c?.obligatoire ?? false;
    _parent = c?.parent;
    _couleurs = Map<String, String>.from(c?.couleurs ?? const {});
  }

  @override
  void dispose() {
    for (final c in [_cle, _libelle, _aide, _largeur, _valeurs, _formule]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _slug(String texte) {
    var valeur = texte.toUpperCase();
    const accents = {
      'À': 'A',
      'Â': 'A',
      'Ä': 'A',
      'Ç': 'C',
      'È': 'E',
      'É': 'E',
      'Ê': 'E',
      'Î': 'I',
      'Ï': 'I',
      'Ô': 'O',
      'Ù': 'U',
      'Û': 'U',
      "'": '',
      '’': '',
    };
    accents.forEach((a, b) => valeur = valeur.replaceAll(a, b));
    return valeur
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  List<String> get _valeursListe => _valeurs.text
      .split(RegExp(r'[;,\n]'))
      .map((v) => v.trim())
      .where((v) => v.isNotEmpty)
      .toList();

  String? get _erreurFormule {
    if (_type != TypeChamp.calcul && _type != TypeChamp.statut) return null;
    if (_formule.text.trim().isEmpty) return null;
    final connus = {
      for (final c in widget.champs)
        if (c.cle != widget.champ?.cle) ...[c.cle, c.libelle],
    };
    return Formule.verifier(_formule.text, champsConnus: connus);
  }

  String? get _apercuFormule {
    if (_erreurFormule != null || _formule.text.trim().isEmpty) return null;
    final variables = <String, num>{
      for (final c in widget.champs)
        if (c.cle != widget.champ?.cle) c.cle: 1,
    };
    final resultat = Formule.essayer(_formule.text, variables);
    if (resultat == null) return null;
    return 'Avec toutes les valeurs à 1, la formule donne : '
        '${resultat % 1 == 0 ? resultat.round() : resultat.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final autres = widget.champs
        .where((c) => c.cle != widget.champ?.cle)
        .toList();
    return AlertDialog(
      title: TitreDialogue(
        _creation ? 'Nouveau champ' : 'Modifier « ${widget.champ!.libelle} »',
        sousTitre: '${IconesApp.libelle(widget.module)} — titre, type, '
            'formule, couleurs',
        icone: Icons.view_column_outlined,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 700),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _libelle,
                      decoration: const InputDecoration(
                        labelText: 'Titre du champ *',
                        prefixIcon: Icon(Icons.title, size: 18),
                      ),
                      onChanged: (v) {
                        if (_creation) {
                          setState(() => _cle.text = _slug(v));
                        } else {
                          setState(() {});
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _cle,
                      enabled: _creation,
                      decoration: InputDecoration(
                        labelText: 'Clé technique',
                        helperText: _creation
                            ? 'Générée automatiquement, modifiable'
                            : 'La clé ne change jamais : les calculs continuent',
                        prefixIcon: const Icon(Icons.key_outlined, size: 18),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TypeChamp>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Type de champ',
                  prefixIcon: Icon(Icons.category_outlined, size: 18),
                ),
                items: [
                  for (final t in TypeChamp.values)
                    DropdownMenuItem(value: t, child: Text(t.libelle)),
                ],
                onChanged: (v) => setState(() => _type = v ?? _type),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _largeur,
                      decoration: const InputDecoration(
                        labelText: 'Largeur de colonne (px)',
                        prefixIcon: Icon(Icons.straighten, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      initialValue: _parent,
                      decoration: const InputDecoration(
                        labelText: 'Champ parent',
                        helperText: 'Supprimer le parent supprime ses enfants',
                        prefixIcon: Icon(Icons.account_tree_outlined, size: 18),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Aucun'),
                        ),
                        for (final c in autres)
                          DropdownMenuItem(
                            value: c.cle,
                            child: Text(
                              c.libelle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (v) => setState(() => _parent = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _aide,
                decoration: const InputDecoration(
                  labelText: 'Aide affichée sous le champ (facultatif)',
                  prefixIcon: Icon(Icons.help_outline, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              if (_type == TypeChamp.liste) ...[
                TextField(
                  controller: _valeurs,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Valeurs proposées',
                    helperText: 'Séparées par « ; » — la saisie libre reste '
                        'toujours possible',
                    prefixIcon: Icon(Icons.list_alt, size: 18),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (_type == TypeChamp.calcul || _type == TypeChamp.statut) ...[
                TextField(
                  controller: _formule,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Formule',
                    helperText: _erreurFormule ??
                        _apercuFormule ??
                        'Exemple : quantite * pu + [frais divers]',
                    prefixIcon: const Icon(Icons.functions, size: 18),
                    errorText: _erreurFormule == null ? null : ' ',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final c in autres.take(14))
                      ActionChip(
                        label: Text(
                          c.libelle,
                          style: const TextStyle(fontSize: 11.5),
                        ),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() {
                          _formule.text = '${_formule.text}${_formule.text
                              .trim()
                              .isEmpty ? '' : ' '}[${c.cle}]';
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Fonctions disponibles : ${Formule.fonctions.join(', ')} — '
                  'opérateurs : ${Formule.operateurs.join(' ')}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
              ],
              if (_type == TypeChamp.statut) ...[
                Text(
                  'Couleur de chaque valeur',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                for (final valeur in _valeursListe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(child: Text(valeur)),
                        InkWell(
                          onTap: () async {
                            final choix = await choisirCouleur(
                              context,
                              initiale: couleurDepuisHex(
                                _couleurs[valeur] ?? 'FF607D8B',
                              ),
                            );
                            if (choix == null) return;
                            setState(
                              () => _couleurs[valeur] =
                                  couleurVersHex(choix),
                            );
                          },
                          child: Container(
                            width: 90,
                            height: 26,
                            decoration: BoxDecoration(
                              color: couleurDepuisHex(
                                _couleurs[valeur] ?? 'FF607D8B',
                              ),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.black12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Choisir',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_valeursListe.isEmpty)
                  Text(
                    'Renseignez d\'abord les valeurs du champ : chaque valeur '
                    'peut recevoir sa couleur.',
                    style: theme.textTheme.bodySmall,
                  ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: LigneBascule(
                      label: 'Affiché dans le tableau',
                      value: _visible,
                      onChanged: (v) => setState(() => _visible = v),
                    ),
                  ),
                  Expanded(
                    child: LigneBascule(
                      label: 'Saisie obligatoire',
                      value: _obligatoire,
                      onChanged: (v) => setState(() => _obligatoire = v),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: () {
            if (_libelle.text.trim().isEmpty || _cle.text.trim().isEmpty) {
              notifier(context, 'Le titre et la clé du champ sont obligatoires',
                  erreur: true);
              return;
            }
            if (_erreurFormule != null) {
              notifier(context, _erreurFormule!, erreur: true);
              return;
            }
            final base =
                widget.champ ??
                ChampConfig(cle: _cle.text.trim(), libelle: _libelle.text.trim());
            Navigator.of(context).pop(
              base.copyWith(
                libelle: _libelle.text.trim(),
                type: _type,
                aide: _aide.text.trim().isEmpty ? null : _aide.text.trim(),
                visible: _visible,
                obligatoire: _obligatoire,
                largeur: double.tryParse(_largeur.text.replaceAll(',', '.')) ??
                    150,
                parent: _parent,
                supprimerParent: _parent == null,
                formule: _formule.text.trim().isEmpty
                    ? null
                    : _formule.text.trim(),
                supprimerFormule: _formule.text.trim().isEmpty,
                valeurs: _type == TypeChamp.liste
                    ? _valeursListe
                    : (widget.champ?.valeurs ?? const []),
                couleurs: _type == TypeChamp.statut
                    ? _couleurs
                    : (widget.champ?.couleurs ?? const {}),
              ),
            );
          },
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

/// Édition d'un **statut** (valeur, couleur, icône).
Future<StatutConfig?> editerStatut(
  BuildContext context, {
  StatutConfig? statut,
}) => showDialog<StatutConfig>(
  context: context,
  builder: (_) => _DialogueStatut(statut: statut),
);

class _DialogueStatut extends StatefulWidget {
  const _DialogueStatut({this.statut});

  final StatutConfig? statut;

  @override
  State<_DialogueStatut> createState() => _DialogueStatutState();
}

class _DialogueStatutState extends State<_DialogueStatut> {
  late final TextEditingController _valeur;
  late String _couleur;
  late String _icone;

  @override
  void initState() {
    super.initState();
    _valeur = TextEditingController(text: widget.statut?.valeur ?? '');
    _couleur = widget.statut?.couleur ?? 'FF2E7D32';
    _icone = widget.statut?.icone ?? 'verifie';
  }

  @override
  void dispose() {
    _valeur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final couleur = couleurDepuisHex(_couleur) ?? Colors.blueGrey;
    return AlertDialog(
      title: TitreDialogue(
        widget.statut == null ? 'Nouveau statut' : 'Modifier le statut',
        sousTitre: 'Libellé, couleur et icône — appliqués partout',
        icone: Icons.flag_outlined,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _valeur,
              decoration: const InputDecoration(
                labelText: 'Valeur du statut *',
                hintText: 'exemple : Conforme, Non conforme, Payé…',
                prefixIcon: Icon(Icons.label_outline, size: 18),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: couleur.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: couleur.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        IconesApp.iconeOuDefaut(_icone),
                        size: 14,
                        color: couleur,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _valeur.text.isEmpty ? 'Aperçu' : _valeur.text,
                        style: TextStyle(
                          fontSize: 12,
                          color: couleur,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () async {
                    final choix = await choisirCouleur(
                      context,
                      initiale: couleur,
                      titre: 'Couleur du statut',
                    );
                    if (choix == null) return;
                    setState(() => _couleur = couleurVersHex(choix));
                  },
                  icon: const Icon(Icons.palette_outlined, size: 18),
                  label: const Text('Couleur'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final choix = await choisirIcone(context, cleActuelle: _icone);
                    if (choix == null) return;
                    setState(() => _icone = choix.cle);
                  },
                  icon: const Icon(Icons.emoji_emotions_outlined, size: 18),
                  label: const Text('Icône'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: () {
            if (_valeur.text.trim().isEmpty) {
              notifier(context, 'La valeur du statut est obligatoire',
                  erreur: true);
              return;
            }
            Navigator.of(context).pop(
              (widget.statut ?? const StatutConfig(valeur: ''))
                  .copyWith(
                    valeur: _valeur.text.trim(),
                    couleur: _couleur,
                    icone: _icone,
                  ),
            );
          },
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

/// Édition d'une **rubrique** (+ copie des règles PJ d'une rubrique existante).
Future<({RubriqueConfig rubrique, String? modele})?> editerRubrique(
  BuildContext context, {
  required List<String> rubriques,
  RubriqueConfig? rubrique,
}) => showDialog<({RubriqueConfig rubrique, String? modele})>(
  context: context,
  builder: (_) => _DialogueRubrique(rubriques: rubriques, rubrique: rubrique),
);

class _DialogueRubrique extends StatefulWidget {
  const _DialogueRubrique({required this.rubriques, this.rubrique});

  final List<String> rubriques;
  final RubriqueConfig? rubrique;

  @override
  State<_DialogueRubrique> createState() => _DialogueRubriqueState();
}

class _DialogueRubriqueState extends State<_DialogueRubrique> {
  late final TextEditingController _nom;
  late String _couleur;
  String? _modele;

  @override
  void initState() {
    super.initState();
    _nom = TextEditingController(text: widget.rubrique?.nom ?? '');
    _couleur = widget.rubrique?.couleur ?? 'FF1976D2';
  }

  @override
  void dispose() {
    _nom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: TitreDialogue(
        widget.rubrique == null ? 'Nouvelle rubrique' : 'Renommer la rubrique',
        sousTitre: widget.rubrique == null
            ? 'Les lignes budgétaires seront classées dans cette rubrique'
            : 'Le renommage est appliqué en cascade aux lignes et aux règles PJ',
        icone: Icons.category_outlined,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nom,
              decoration: const InputDecoration(
                labelText: 'Nom de la rubrique *',
                hintText: 'exemple : RESTAURATION / FRAIS D\'ORGANISATION',
                prefixIcon: Icon(Icons.label_outline, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: (couleurDepuisHex(_couleur) ?? Colors.blueGrey)
                        .withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: couleurDepuisHex(_couleur) ?? Colors.blueGrey,
                    ),
                  ),
                  child: Text(
                    _nom.text.isEmpty ? 'Aperçu' : _nom.text,
                    style: const TextStyle(fontSize: 12.5),
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () async {
                    final choix = await choisirCouleur(
                      context,
                      initiale: couleurDepuisHex(_couleur),
                      titre: 'Couleur de la rubrique',
                    );
                    if (choix == null) return;
                    setState(() => _couleur = couleurVersHex(choix));
                  },
                  icon: const Icon(Icons.palette_outlined, size: 18),
                  label: const Text('Couleur'),
                ),
              ],
            ),
            if (widget.rubrique == null && widget.rubriques.isNotEmpty) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _modele,
                decoration: const InputDecoration(
                  labelText: 'Copier les règles PJ de…',
                  helperText: 'Les pièces justificatives requises seront '
                      'dupliquées pour la nouvelle rubrique',
                  prefixIcon: Icon(Icons.copy_all_outlined, size: 18),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Aucune (à définir plus tard)'),
                  ),
                  for (final nom in widget.rubriques)
                    DropdownMenuItem(
                      value: nom,
                      child: Text(
                        nom,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _modele = v),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              'Les automatismes restent en place : détection de rubrique par '
              'mots-clés, distances des districts, tarifs du référentiel et '
              'matrice des pièces justificatives.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: () {
            final nom = _nom.text.trim();
            if (nom.isEmpty) {
              notifier(context, 'Le nom de la rubrique est obligatoire',
                  erreur: true);
              return;
            }
            Navigator.of(context).pop((
              rubrique: (widget.rubrique ?? const RubriqueConfig(nom: ''))
                  .copyWith(nom: nom, couleur: _couleur),
              modele: _modele,
            ));
          },
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

/// Confirmation d'une **suppression avec cascade** : la liste des conséquences
/// est affichée avant toute modification.
Future<bool> confirmerSuppression(
  BuildContext context, {
  required String titre,
  required String element,
  required List<String> consequences,
  String confirmerLabel = 'Supprimer',
}) async {
  final res = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return AlertDialog(
        title: TitreDialogue(
          titre,
          sousTitre: element,
          icone: Icons.warning_amber_rounded,
        ),
        content: SizedBox(
          width: largeurDialogue(ctx, 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cette suppression est définitive. Voici ce qui sera modifié '
                'en cascade :',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              for (final consequence in consequences)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.subdirectory_arrow_right,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          consequence,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmerLabel),
          ),
        ],
      );
    },
  );
  return res ?? false;
}
