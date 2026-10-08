import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../router/app_router.dart';
import '../../widgets/common.dart';
import '../../../services/ressources.dart';
import '../../../services/sauvegarde_service.dart';

/// Ligne d'information (icône + libellé + valeur), lisible et alignée.
class _LigneInfo extends StatelessWidget {
  const _LigneInfo({
    required this.icone,
    required this.label,
    required this.valeur,
    this.alerte = false,
  });

  final IconData icone;
  final String label;
  final String valeur;
  final bool alerte;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icone,
          size: 18,
          color: alerte ? Colors.orange.shade800 : scheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              SelectableText(valeur, style: const TextStyle(fontSize: 12.5)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Sauvegardes : sauvegarder et restaurer la base SQLite.
class SauvegardesScreen extends ConsumerStatefulWidget {
  const SauvegardesScreen({super.key});

  @override
  ConsumerState<SauvegardesScreen> createState() => _SauvegardesScreenState();
}

class _SauvegardesScreenState extends ConsumerState<SauvegardesScreen> {
  List<File> _sauvegardes = [];
  bool _chargement = true;
  bool _enCours = false;
  String? _dossier;
  String? _fichierBase;
  bool _basePresente = true;

  /// Mode sélection multiple (suppression groupée).
  bool _modeSelection = false;
  final Set<String> _selection = {};

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final service = ref.read(sauvegardeServiceProvider);
    final dossier = await service.dossierSauvegardes();
    final fichier = await service.fichierBase();
    final fichiers = await service.lister();
    if (!mounted) return;
    setState(() {
      _sauvegardes = fichiers;
      _dossier = dossier.path;
      _fichierBase = fichier.path;
      _basePresente = fichier.existsSync();
      _chargement = false;
    });
  }

  String _messageErreur(Object e) =>
      e is SauvegardeException ? e.message : messageErreurLisible(e);

  /// Taille lisible (Ko / Mo).
  String _taille(File f) {
    final octets = f.lengthSync();
    if (octets >= 1024 * 1024) {
      return '${(octets / (1024 * 1024)).toStringAsFixed(2)} Mo';
    }
    return '${(octets / 1024).toStringAsFixed(0)} Ko';
  }

  /// Date de modification lisible (jj/mm/aaaa hh:mm).
  String _date(File f) {
    final d = f.statSync().modified;
    String deux(int n) => n.toString().padLeft(2, '0');
    return '${deux(d.day)}/${deux(d.month)}/${d.year} à '
        '${deux(d.hour)}:${deux(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          EnTetePage(
            titre: 'Sauvegardes',
            module: 'sauvegardes',
            sousTitre:
                'Sauvegarde et restauration de la base de données locale',
            actions: [
              FilledButton.icon(
                onPressed: _sauvegarder,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Sauvegarder'),
              ),
              OutlinedButton.icon(
                onPressed: _sauvegardes.isEmpty || _enCours
                    ? null
                    : () => setState(() {
                        _modeSelection = !_modeSelection;
                        if (!_modeSelection) _selection.clear();
                      }),
                icon: Icon(
                  _modeSelection ? Icons.close : Icons.checklist,
                  size: 18,
                ),
                label: Text(_modeSelection ? 'Quitter' : 'Sélectionner'),
              ),
              OutlinedButton.icon(
                onPressed: _restaurerDepuisFichier,
                icon: const Icon(Icons.restore_outlined),
                label: const Text('Restaurer depuis un fichier'),
              ),
              OutlinedButton.icon(
                onPressed: _reinitialiserApplication,
                icon: const Icon(Icons.restart_alt_outlined),
                label: const Text('Réinitialiser l\'application'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: CarteSection(
              titre: 'Informations',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LigneInfo(
                    icone: Icons.storage_outlined,
                    label: 'Base de données utilisée',
                    valeur: _fichierBase ?? 'Recherche…',
                    alerte: !_basePresente,
                  ),
                  const SizedBox(height: 10),
                  _LigneInfo(
                    icone: Icons.folder_outlined,
                    label: 'Dossier des sauvegardes',
                    valeur: _dossier ?? 'Recherche…',
                  ),
                  const SizedBox(height: 10),
                  if (!_basePresente)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'La base de données n\'a pas encore été créée à cet '
                        'emplacement. Enregistrez une donnée, puis relancez la '
                        'sauvegarde.',
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Text(
                    'Une copie de sécurité de la base actuelle est automatiquement '
                    'créée avant toute restauration. Aucune base existante n\'est '
                    'supprimée sans avertissement.',
                    style: TextStyle(fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: CarteSection(
              titre: 'Sauvegardes disponibles (${_sauvegardes.length})',
              actions: [
                IconButton(
                  tooltip: 'Actualiser la liste',
                  onPressed: _chargement ? null : _charger,
                  icon: const Icon(Icons.refresh, size: 20),
                ),
              ],
              child: _chargement
                  ? const Center(child: CircularProgressIndicator())
                  : _sauvegardes.isEmpty
                  ? const EtatVide(
                      message:
                          'Aucune sauvegarde. Cliquez sur « Sauvegarder » pour en créer une.',
                      icone: Icons.backup_outlined,
                    )
                  : _listeSauvegardes(),
            ),
          ),
        ],
      ),
    );
  }

  // --- Liste, sélection multiple et renommage -----------------------------

  /// Liste des sauvegardes : cases à cocher en mode sélection et barre de
  /// suppression multiple en bas.
  Widget _listeSauvegardes() {
    final cibles = [
      for (final f in _sauvegardes)
        if (_selection.contains(f.path)) f,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final f in _sauvegardes) _carteSauvegarde(f),
        if (_modeSelection) ...[
          const SizedBox(height: 4),
          _barreSelection(cibles),
        ],
      ],
    );
  }

  Widget _carteSauvegarde(File f) {
    final scheme = Theme.of(context).colorScheme;
    final cochee = _selection.contains(f.path);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cochee
            ? scheme.primaryContainer.withValues(alpha: 0.45)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: cochee ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_modeSelection)
              Checkbox(
                visualDensity: VisualDensity.compact,
                value: cochee,
                onChanged: (_) => setState(() {
                  if (!_selection.remove(f.path)) _selection.add(f.path);
                }),
              ),
            const Icon(Icons.storage_outlined),
          ],
        ),
        title: SelectableText(
          f.uri.pathSegments.last,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
        ),
        subtitle: Text(
          '${_date(f)} · ${_taille(f)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.tonalIcon(
              onPressed: _enCours ? null : () => _restaurer(f),
              icon: const Icon(Icons.restore, size: 17),
              label: const Text('Charger'),
            ),
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Renommer cette sauvegarde',
              icon: const Icon(Icons.drive_file_rename_outline, size: 18),
              onPressed: _enCours ? null : () => _renommer(f),
            ),
            const SizedBox(width: 2),
            IconButton(
              tooltip: 'Supprimer cette sauvegarde',
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: _enCours
                  ? null
                  : () async {
                      final ok = await confirmer(
                        context,
                        titre: 'Supprimer la sauvegarde',
                        message: 'Supprimer définitivement cette sauvegarde ?',
                      );
                      if (!ok) return;
                      try {
                        await ref.read(sauvegardeServiceProvider).supprimer(f);
                        await _charger();
                      } on FileSystemException {
                        if (mounted) {
                          notifier(
                            context,
                            'Suppression impossible : le fichier est peut-être '
                            'utilisé par un autre programme.',
                            erreur: true,
                          );
                        }
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  /// Barre en bas de la liste : nombre de sélectionnées et suppression
  /// multiple.
  Widget _barreSelection(List<File> cibles) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_box_outlined, size: 16, color: scheme.primary),
              const SizedBox(width: 6),
              Text(
                cibles.isEmpty
                    ? 'Cochez les sauvegardes à supprimer'
                    : '${cibles.length} sauvegarde(s) sélectionnée(s)',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              if (_selection.isNotEmpty) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => setState(_selection.clear),
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: const Text('Tout désélectionner'),
                ),
              ],
            ],
          ),
          FilledButton.icon(
            onPressed: cibles.isEmpty || _enCours
                ? null
                : () => _supprimerSelection(cibles),
            icon: const Icon(Icons.delete_outline, size: 16),
            label: Text('Supprimer (${cibles.length})'),
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
          ),
        ],
      ),
    );
  }

  /// Suppression multiple, avec confirmation unique.
  Future<void> _supprimerSelection(List<File> cibles) async {
    if (cibles.isEmpty) return;
    final ok = await confirmer(
      context,
      titre: 'Supprimer les sauvegardes',
      message:
          'Supprimer définitivement ${cibles.length} sauvegarde(s) ? '
          'Cette action est irréversible.',
      confirmerLabel: 'Supprimer',
    );
    if (!ok) return;
    setState(() => _enCours = true);
    var echecs = 0;
    for (final f in cibles) {
      try {
        await ref.read(sauvegardeServiceProvider).supprimer(f);
      } on FileSystemException {
        echecs++;
      }
    }
    _selection.clear();
    await _charger();
    if (!mounted) return;
    setState(() => _enCours = false);
    if (echecs > 0) {
      notifier(
        context,
        '${cibles.length - echecs} sauvegarde(s) supprimée(s), '
        '$echecs impossible(s) à supprimer (fichier utilisé).',
        erreur: true,
      );
    } else {
      notifier(context, '${cibles.length} sauvegarde(s) supprimée(s).');
    }
  }

  /// Renomme une sauvegarde (le suffixe `.db` est ajouté si besoin).
  Future<void> _renommer(File fichier) async {
    final actuel = fichier.uri.pathSegments.last;
    final controleur = TextEditingController(text: actuel);
    final propose = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const TitreDialogue(
          'Renommer la sauvegarde',
          icone: Icons.drive_file_rename_outline,
        ),
        content: SizedBox(
          width: largeurDialogue(ctx, 460),
          child: TextField(
            controller: controleur,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nom du fichier',
              hintText: 'Ex. : sauvegarde_avant_mise_a_jour',
              suffixText: '.db',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(controleur.text),
            icon: const Icon(Icons.check),
            label: const Text('Renommer'),
          ),
        ],
      ),
    );
    controleur.dispose();
    if (propose == null || !mounted) return;

    var nom = propose.trim();
    if (nom.toLowerCase().endsWith('.db')) {
      nom = nom.substring(0, nom.length - 3);
    }
    nom = nom.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    if (nom.isEmpty) {
      notifier(
        context,
        'Le nom de la sauvegarde ne peut pas être vide.',
        erreur: true,
      );
      return;
    }
    final ancienSansExtension = actuel.toLowerCase().endsWith('.db')
        ? actuel.substring(0, actuel.length - 3).toLowerCase()
        : actuel.toLowerCase();
    if (nom.toLowerCase() == ancienSansExtension) return;

    final destination = File(p.join(fichier.parent.path, '$nom.db'));
    if (destination.existsSync()) {
      notifier(
        context,
        'Une sauvegarde nommée « $nom.db » existe déjà. Choisissez un autre nom.',
        erreur: true,
      );
      return;
    }
    try {
      await fichier.rename(destination.path);
    } on FileSystemException {
      if (mounted) {
        notifier(
          context,
          'Renommage impossible : le fichier est peut-être utilisé par un '
          'autre programme.',
          erreur: true,
        );
      }
      return;
    }
    await _charger();
    if (mounted) notifier(context, 'Sauvegarde renommée en « $nom.db ».');
  }

  Future<void> _sauvegarder() async {
    setState(() => _enCours = true);
    try {
      final fichier = await ref.read(sauvegardeServiceProvider).sauvegarder();
      await _charger();
      if (mounted) {
        notifier(
          context,
          'Sauvegarde créée : ${fichier.uri.pathSegments.last}',
        );
      }
    } catch (e) {
      if (mounted) notifier(context, _messageErreur(e), erreur: true);
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  Future<void> _restaurer(File fichier) async {
    final ok = await confirmer(
      context,
      titre: 'Charger cette sauvegarde',
      message:
          'Toutes les données actuelles seront remplacées par celles de cette '
          'sauvegarde. Une copie de sécurité de la base actuelle est créée '
          'automatiquement. Continuer ?',
      confirmerLabel: 'Charger',
    );
    if (!ok) return;
    setState(() => _enCours = true);
    Object? erreur;
    try {
      await ref.read(sauvegardeServiceProvider).restaurer(fichier);
    } catch (e) {
      erreur = e;
    }
    if (!mounted) return;
    // On recrée **toujours** la connexion à la base : la restauration ferme
    // la connexion pour pouvoir remplacer le fichier (Windows refuse de
    // l'écraser tant qu'il est ouvert), et dans le cas nominal les données
    // restaurées doivent être visibles immédiatement.
    ref.invalidate(databaseProvider);
    ref.invalidate(databaseBootstrapProvider);
    ref.invalidate(filtreRechercheProvider);
    await _charger();
    if (!mounted) return;
    if (erreur != null) {
      notifier(context, _messageErreur(erreur), erreur: true);
    } else {
      notifier(
        context,
        'Chargement terminé : les données de la sauvegarde sont maintenant utilisées.',
      );
    }
    setState(() => _enCours = false);
  }

  /// Réinitialisation complète : efface toutes les données locales (comptes
  /// utilisateurs inclus) et recharge les données de référence. L'application
  /// revient à l'écran de création du compte, comme au premier lancement.
  Future<void> _reinitialiserApplication() async {
    final ok = await confirmer(
      context,
      titre: 'Réinitialiser l\'application',
      message:
          'Toutes les données locales seront effacées (activités, participants, '
          'présences, budgets, dépenses, banque et comptes utilisateurs), puis '
          'les données de référence seront rechargées. Une sauvegarde de secours '
          'est créée avant l\'opération. Continuer ?',
      confirmerLabel: 'Réinitialiser',
    );
    if (!ok || !mounted) return;
    setState(() => _chargement = true);
    try {
      await ref.read(sauvegardeServiceProvider).sauvegarder();
      final source = await rootBundle.load(classeurReference);
      final service = ref.read(excelImportServiceProvider)
        ..chargerOctets(source.buffer.asUint8List());
      await service.reinitialiserApplication();
      if (!mounted) return;
      ref.read(sessionUtilisateurProvider.notifier).state = null;
      ref.invalidate(configurationCompteProvider);
      ref.invalidate(databaseBootstrapProvider);
      if (!mounted) return;
      context.go(AppRoutes.connexion);
      notifier(context, 'Application réinitialisée.');
    } catch (e) {
      if (mounted) {
        setState(() => _chargement = false);
        notifier(context, 'Réinitialisation impossible : $e', erreur: true);
      }
    }
  }

  Future<void> _restaurerDepuisFichier() async {
    final fichiers = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['db'],
      dialogTitle: 'Sélectionner un fichier de sauvegarde',
    );
    if (fichiers.isEmpty || fichiers.single.path == null) return;
    await _restaurer(File(fichiers.single.path!));
  }
}
