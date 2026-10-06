import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/database/database.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import 'ligne_budget_dialog.dart';

/// Pré-impression du budget : récapitulatif automatique de toutes les lignes
/// budgétaires, puis export PDF ou Excel.
class ApercuBudgetDialog extends ConsumerStatefulWidget {
  const ApercuBudgetDialog({required this.lignes, super.key});

  final List<LigneBudget> lignes;

  @override
  ConsumerState<ApercuBudgetDialog> createState() => _ApercuBudgetDialogState();
}

class _ApercuBudgetDialogState extends ConsumerState<ApercuBudgetDialog> {
  bool _enCours = false;

  Map<String, (int, double)> get _parLigne {
    final map = <String, (int, double)>{};
    for (final l in widget.lignes) {
      final courant = map[l.ligneBudgetaire] ?? (0, 0.0);
      map[l.ligneBudgetaire] = (courant.$1 + 1, courant.$2 + l.montantAlloue);
    }
    return map;
  }

  double get _total =>
      widget.lignes.fold<double>(0, (s, l) => s + l.montantAlloue);

  Map<String, (int, double)> get _parActivite {
    final map = <String, (int, double)>{};
    for (final l in widget.lignes) {
      final courant = map[l.activiteCode] ?? (0, 0.0);
      map[l.activiteCode] = (courant.$1 + 1, courant.$2 + l.montantAlloue);
    }
    return map;
  }

  Future<void> _exporter({
    required Future<List<int>> Function() generer,
    required String titre,
    required String nomFichier,
    required String extension,
  }) async {
    setState(() => _enCours = true);
    try {
      final octets = await generer();
      if (!mounted) return;
      final horodatage = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final uri = await FilePicker.saveFile(
        dialogTitle: titre,
        fileName: '${nomFichier}_$horodatage.$extension',
        bytes: Uint8List.fromList(octets),
        type: FileType.custom,
        allowedExtensions: [extension],
      );
      if (uri == null) return;
      await ref
          .read(excelExportServiceProvider)
          .sauvegarder(octets, uri.toFilePath());
      if (mounted) notifier(context, 'Fichier enregistré : ${uri.toFilePath()}');
    } catch (e) {
      if (mounted) notifier(context, 'Export impossible : $e', erreur: true);
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resume = _parLigne.entries.toList()
      ..sort((a, b) => b.value.$2.compareTo(a.value.$2));
    final activites = _parActivite.entries.toList()
      ..sort((a, b) => b.value.$2.compareTo(a.value.$2));

    return AlertDialog(
      title: const TitreDialogue(
        'Pré-impression du budget',
        sousTitre: 'Récapitulatif automatique et exports',
        icone: Icons.visibility_outlined,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 900),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Pasteille(
                    label: 'Lignes budgétaires',
                    valeur: '${widget.lignes.length}',
                  ),
                  _Pasteille(
                    label: 'Total alloué',
                    valeur: formatMontant(_total),
                  ),
                  _Pasteille(
                    label: 'Activités concernées',
                    valeur: '${activites.length}',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _titre(theme, 'Récapitulatif automatique par ligne budgétaire'),
              const SizedBox(height: 8),
              _TableauApercu(
                entetes: const ['Ligne budgétaire', 'Lignes', 'Montant alloué'],
                lignes: [
                  for (final e in resume)
                    [e.key, '${e.value.$1}', formatMontant(e.value.$2)],
                ],
                totaux: [
                  'TOTAL GÉNÉRAL',
                  '${widget.lignes.length}',
                  formatMontant(_total),
                ],
              ),
              const SizedBox(height: 16),
              _titre(theme, 'Détail par activité'),
              const SizedBox(height: 8),
              _TableauApercu(
                entetes: const ['Activité', 'Lignes', 'Montant alloué'],
                lignes: [
                  for (final e in activites)
                    [e.key, '${e.value.$1}', formatMontant(e.value.$2)],
                ],
                totaux: [
                  'TOTAL',
                  '${widget.lignes.length}',
                  formatMontant(_total),
                ],
              ),
              const SizedBox(height: 16),
              _titre(theme, 'Toutes les lignes'),
              const SizedBox(height: 8),
              _TableauApercu(
                entetes: const [
                  'Activité',
                  'Ligne budgétaire',
                  'Type',
                  'Montant',
                ],
                lignes: [
                  for (final l in widget.lignes)
                    [
                      l.activiteCode,
                      l.ligneBudgetaire,
                      TypeBudget.parId(l.typeBudget).libelle,
                      formatMontant(l.montantAlloue),
                    ],
                ],
                totaux: [
                  'TOTAL',
                  '',
                  '',
                  formatMontant(_total),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
        OutlinedButton.icon(
          onPressed: _enCours
              ? null
              : () => _exporter(
                    generer: () =>
                        ref.read(excelExportServiceProvider).exporterBudget(),
                    titre: 'Enregistrer le budget Excel',
                    nomFichier: 'DSFA_budget',
                    extension: 'xlsx',
                  ),
          icon: const Icon(Icons.table_view_outlined, size: 18),
          label: const Text('Exporter Excel'),
        ),
        FilledButton.icon(
          onPressed: _enCours
              ? null
              : () => _exporter(
                    generer: () => ref
                        .read(pdfExportServiceProvider)
                        .apercuBudget(widget.lignes),
                    titre: 'Enregistrer le budget PDF',
                    nomFichier: 'DSFA_budget',
                    extension: 'pdf',
                  ),
          icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
          label: const Text('Exporter PDF'),
        ),
      ],
    );
  }

  Widget _titre(ThemeData theme, String texte) => Text(
        texte,
        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      );
}

/// Tableau de l'aperçu : les colonnes s'étirent sur la largeur disponible
/// quand le contenu est étroit, et un **défilement horizontal avec barre
/// visible** prend le relais dès que le contenu dépasse — aucune colonne n'est
/// coupée, aucune valeur n'est illisible.
class _TableauApercu extends StatefulWidget {
  const _TableauApercu({
    required this.entetes,
    required this.lignes,
    this.totaux,
  });

  final List<String> entetes;
  final List<List<String>> lignes;
  final List<String>? totaux;

  @override
  State<_TableauApercu> createState() => _TableauApercuState();
}

class _TableauApercuState extends State<_TableauApercu> {
  final _controleur = ScrollController();

  /// La barre de défilement n'apparaît que si le tableau dépasse réellement la
  /// largeur disponible (aucune barre inutile sous un tableau qui tient).
  bool _defilable = false;

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, contraintes) {
        final dispo =
            contraintes.maxWidth.isFinite ? contraintes.maxWidth : 640.0;
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: NotificationListener<ScrollMetricsNotification>(
            onNotification: (notification) {
              final defilable = notification.metrics.maxScrollExtent > 0.5;
              if (defilable != _defilable) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _defilable = defilable);
                });
              }
              return false;
            },
            child: Scrollbar(
              controller: _controleur,
              thumbVisibility: _defilable,
              thickness: 6,
              radius: const Radius.circular(6),
              child: SingleChildScrollView(
                controller: _controleur,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(bottom: _defilable ? 10 : 0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: dispo),
                  child: Table(
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                        ),
                        children: [
                          for (final e in widget.entetes)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              child: Text(
                                e,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      for (final l in widget.lignes)
                        TableRow(
                          children: [
                            for (final v in l)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 7,
                                ),
                                child: Text(
                                  v,
                                  style: const TextStyle(fontSize: 12.5),
                                ),
                              ),
                          ],
                        ),
                      if (widget.totaux != null)
                        TableRow(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.6),
                          ),
                          children: [
                            for (final v in widget.totaux!)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                child: Text(
                                  v,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Pasteille extends StatelessWidget {
  const _Pasteille({required this.label, required this.valeur});
  final String label;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11.5, color: scheme.onSurfaceVariant)),
          Text(valeur,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ],
      ),
    );
  }
}
