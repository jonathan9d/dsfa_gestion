import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/services/rapport_financier_service.dart';
import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/tableau.dart';

/// Rapport financier : code activité, code budget, description, ligne
/// budgétaire, montant alloué, dépenses réalisées, écart et observation.
///
/// Les dépenses réalisées sont saisies automatiquement par le dossier PJ.
class RapportFinancierSection extends ConsumerWidget {
  const RapportFinancierSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rapport = ref.watch(rapportFinancierProvider);
    return rapport.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: EtatErreur(erreur: e),
      ),
      data: (r) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: CarteSection(
          titre: 'Rapport financier',
          actions: [
            FilledButton.icon(
              onPressed: () => _ouvrirApercu(context, ref, r),
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('Voir'),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _Indicateur(
                    label: 'Montant total alloué',
                    valeur: formatMontant(r.totalAlloue),
                    couleur: const Color(0xFF1F4E79),
                  ),
                  _Indicateur(
                    label: 'Dépenses réalisées',
                    valeur: formatMontant(r.totalRealise),
                    couleur: const Color(0xFF283593),
                  ),
                  _Indicateur(
                    label: 'Écart',
                    valeur: formatMontant(r.totalEcart),
                    couleur: r.totalEcart < 0
                        ? const Color(0xFFC62828)
                        : const Color(0xFF2E7D32),
                  ),
                  _Indicateur(
                    label: 'Taux de consommation',
                    valeur:
                        '${(r.tauxConsommation * 100).toStringAsFixed(1)} %',
                    couleur: const Color(0xFF662583),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TableauGestion<LigneRapportFinancier>(
                lignes: r.lignes,
                cleLigne: (l) => '${l.codeActivite}|${l.ligneBudgetaire}',
                cleModule: 'rapport_financier',
                taillePage: 25,
                messageVide:
                    'Aucune ligne budgétaire pour construire le rapport financier.',
                colonnes: [
                  ColonneTableau(
                    label: 'Code activité',
                    flex: 2,
                    valeur: (l) => l.codeActivite,
                    cellule: (_, l) => Text(
                      l.codeActivite,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  ColonneTableau(
                    label: 'Code budget',
                    flex: 2,
                    valeur: (l) => l.codeBudget,
                  ),
                  ColonneTableau(
                    label: 'Description activité',
                    flex: 4,
                    valeur: (l) => l.descriptionActivite,
                  ),
                  ColonneTableau(
                    label: 'Ligne budgetaire',
                    flex: 4,
                    valeur: (l) => l.ligneBudgetaire,
                  ),
                  ColonneTableau(
                    label: 'Montant alloué',
                    flex: 3,
                    numerique: true,
                    valeur: (l) => formatMontant(l.montantAlloue),
                    cleTri: (l) => l.montantAlloue,
                  ),
                  ColonneTableau(
                    label: 'Dépenses réalisées',
                    flex: 3,
                    numerique: true,
                    valeur: (l) => formatMontant(l.depensesRealisees),
                    cleTri: (l) => l.depensesRealisees,
                  ),
                  ColonneTableau(
                    label: 'Écart',
                    flex: 3,
                    numerique: true,
                    valeur: (l) => formatMontant(l.ecart),
                    cleTri: (l) => l.ecart,
                    cellule: (_, l) => Text(
                      formatMontant(l.ecart),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: l.ecart < 0
                            ? const Color(0xFFC62828)
                            : const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  ColonneTableau(
                    label: 'Observation',
                    flex: 3,
                    valeur: (l) => l.observationFinale,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _ouvrirApercu(
    BuildContext context,
    WidgetRef ref,
    ResumeRapportFinancier r,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (_) => ApercuRapportFinancierDialog(rapport: r),
    );
  }
}

class _Indicateur extends StatelessWidget {
  const _Indicateur({
    required this.label,
    required this.valeur,
    required this.couleur,
  });
  final String label;
  final String valeur;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: couleur.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valeur,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: couleur,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pré-impression du rapport financier, puis export PDF / Excel.
class ApercuRapportFinancierDialog extends ConsumerStatefulWidget {
  const ApercuRapportFinancierDialog({required this.rapport, super.key});

  final ResumeRapportFinancier rapport;

  @override
  ConsumerState<ApercuRapportFinancierDialog> createState() =>
      _ApercuRapportFinancierDialogState();
}

class _ApercuRapportFinancierDialogState
    extends ConsumerState<ApercuRapportFinancierDialog> {
  bool _enCours = false;

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
      if (mounted)
        notifier(context, 'Fichier enregistré : ${uri.toFilePath()}');
    } catch (e) {
      if (mounted) notifier(context, 'Export impossible : $e', erreur: true);
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.rapport;
    final theme = Theme.of(context);
    return AlertDialog(
      title: const TitreDialogue(
        'Pré-impression — rapport financier',
        sousTitre: 'Budget alloué, dépenses réalisées et écarts',
        icone: Icons.assessment_outlined,
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
                  _Recap(label: 'Alloué', valeur: formatMontant(r.totalAlloue)),
                  _Recap(
                    label: 'Réalisé',
                    valeur: formatMontant(r.totalRealise),
                  ),
                  _Recap(label: 'Écart', valeur: formatMontant(r.totalEcart)),
                  _Recap(
                    label: 'Consommation',
                    valeur:
                        '${(r.tauxConsommation * 100).toStringAsFixed(1)} %',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                      ),
                      children: const [
                        _Cellule('Code activité', gras: true),
                        _Cellule('Code budget', gras: true),
                        _Cellule('Description activité', gras: true),
                        _Cellule('Ligne budgetaire', gras: true),
                        _Cellule('Montant alloué', gras: true),
                        _Cellule('Dépenses réalisées', gras: true),
                        _Cellule('Écart', gras: true),
                        _Cellule('Observation', gras: true),
                      ],
                    ),
                    for (final l in r.lignes)
                      TableRow(
                        children: [
                          _Cellule(l.codeActivite),
                          _Cellule(l.codeBudget),
                          _Cellule(l.descriptionActivite),
                          _Cellule(l.ligneBudgetaire),
                          _Cellule(formatMontant(l.montantAlloue)),
                          _Cellule(formatMontant(l.depensesRealisees)),
                          _Cellule(formatMontant(l.ecart)),
                          _Cellule(l.observationFinale),
                        ],
                      ),
                    TableRow(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.6),
                      ),
                      children: [
                        const _Cellule('TOTAL', gras: true),
                        const _Cellule(''),
                        const _Cellule(''),
                        const _Cellule(''),
                        _Cellule(formatMontant(r.totalAlloue), gras: true),
                        _Cellule(formatMontant(r.totalRealise), gras: true),
                        _Cellule(formatMontant(r.totalEcart), gras: true),
                        const _Cellule(''),
                      ],
                    ),
                  ],
                ),
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
                  generer: () => ref
                      .read(excelExportServiceProvider)
                      .exporterRapportFinancier(r),
                  titre: 'Enregistrer le rapport Excel',
                  nomFichier: 'DSFA_rapport_financier',
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
                      .rapportFinancierDetaille(r),
                  titre: 'Enregistrer le rapport PDF',
                  nomFichier: 'DSFA_rapport_financier',
                  extension: 'pdf',
                ),
          icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
          label: const Text('Exporter PDF'),
        ),
      ],
    );
  }
}

class _Recap extends StatelessWidget {
  const _Recap({required this.label, required this.valeur});
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
          ),
          Text(
            valeur,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _Cellule extends StatelessWidget {
  const _Cellule(this.valeur, {this.gras = false});
  final String valeur;
  final bool gras;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 90, maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Text(
        valeur,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: gras ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}
