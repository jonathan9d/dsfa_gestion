import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../services/excel_import_service.dart';
import '../../../services/ressources.dart';
import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import 'rapport_financier_section.dart';

/// Rapports : import Excel, export Excel et export PDF.
class RapportsScreen extends ConsumerStatefulWidget {
  const RapportsScreen({super.key});

  @override
  ConsumerState<RapportsScreen> createState() => _RapportsScreenState();
}

class _RapportsScreenState extends ConsumerState<RapportsScreen> {
  bool _enCours = false;
  String? _message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          EnTetePage(
            titre: 'Rapports',
            module: 'rapports',
            sousTitre: 'Import Excel, export Excel et export PDF',
            actions: [
              OutlinedButton.icon(
                onPressed: _enCours ? null : _reinitialiserDepuisClasseur,
                icon: const Icon(Icons.restore),
                label: const Text('Réinitialiser aux données source'),
              ),
            ],
          ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      if (_enCours)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        const Icon(Icons.info_outline),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_message!)),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          const RapportFinancierSection(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: LayoutBuilder(
              builder: (context, c) {
                final colonnes = c.maxWidth > 1000
                    ? 3
                    : c.maxWidth > 640
                    ? 2
                    : 1;
                const espace = 16.0;
                final largeur = colonnes == 1
                    ? c.maxWidth
                    : (c.maxWidth - espace * (colonnes - 1)) / colonnes;
                return Wrap(
                  spacing: espace,
                  runSpacing: espace,
                  children: [
                    SizedBox(
                      width: largeur,
                      child: _CarteRapport(
                        titre: 'Importer Excel',
                        description:
                            'Analyser le classeur de référence, valider, prévisualiser puis importer dans SQLite.',
                        icone: Icons.upload_file_outlined,
                        couleur: const Color(0xFF1F4E79),
                        bouton: 'Sélectionner un fichier',
                        onPressed: _enCours ? null : _importerExcel,
                      ),
                    ),
                    SizedBox(
                      width: largeur,
                      child: _CarteRapport(
                        titre: 'Exporter Excel',
                        description:
                            'Exporter activités, budgets, présences, indemnités, PJ, dépenses, banque et rapprochement.',
                        icone: Icons.download_outlined,
                        couleur: const Color(0xFF2E7D32),
                        bouton: 'Générer le classeur',
                        onPressed: _enCours ? null : _exporterExcel,
                      ),
                    ),
                    SizedBox(
                      width: largeur,
                      child: _CarteRapport(
                        titre: 'Exporter PDF',
                        description:
                            'Générer un rapport financier professionnel avec totaux, synthèses et anomalies.',
                        icone: Icons.picture_as_pdf_outlined,
                        couleur: const Color(0xFFC62828),
                        bouton: 'Générer le rapport',
                        onPressed: _enCours ? null : _exporterPdf,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: CarteSection(
              titre: 'Exports détaillés',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _BoutonExport(
                    label: 'Activités',
                    icone: Icons.event_note_outlined,
                    onPressed: _enCours
                        ? null
                        : () => _exporterExcelSpecifique('activites'),
                  ),
                  _BoutonExport(
                    label: 'Présences',
                    icone: Icons.calendar_month_outlined,
                    onPressed: _enCours
                        ? null
                        : () => _exporterExcelSpecifique('presences'),
                  ),
                  _BoutonExport(
                    label: 'Indemnités',
                    icone: Icons.payments_outlined,
                    onPressed: _enCours
                        ? null
                        : () => _exporterExcelSpecifique('indemnites'),
                  ),
                  _BoutonExport(
                    label: 'Pièces justificatives',
                    icone: Icons.attach_file_outlined,
                    onPressed: _enCours
                        ? null
                        : () => _exporterExcelSpecifique('pj'),
                  ),
                  _BoutonExport(
                    label: 'Dépenses',
                    icone: Icons.receipt_long_outlined,
                    onPressed: _enCours
                        ? null
                        : () => _exporterExcelSpecifique('depenses'),
                  ),
                  _BoutonExport(
                    label: 'Banque',
                    icone: Icons.account_balance_outlined,
                    onPressed: _enCours
                        ? null
                        : () => _exporterExcelSpecifique('banque'),
                  ),
                  _BoutonExport(
                    label: 'Rapprochement PDF',
                    icone: Icons.sync_alt_outlined,
                    onPressed: _enCours ? null : _exporterRapprochementPdf,
                  ),
                  _BoutonExport(
                    label: 'Contrôle PJ PDF',
                    icone: Icons.verified_outlined,
                    onPressed: _enCours ? null : _exporterControlePJPdf,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reinitialiserDepuisClasseur() async {
    final ok = await confirmer(
      context,
      titre: 'Réinitialiser les données',
      message:
          'Toutes les données saisies dans l’application seront remplacées par les données du classeur de référence. Une sauvegarde de secours sera créée avant cette opération.',
      confirmerLabel: 'Sauvegarder et réinitialiser',
    );
    if (!ok || !mounted) return;

    setState(() {
      _enCours = true;
      _message = 'Sauvegarde des données actuelles…';
    });
    try {
      final sauvegarde = await ref
          .read(sauvegardeServiceProvider)
          .sauvegarder();
      setState(() => _message = 'Restauration du classeur source…');
      final source = await rootBundle.load(classeurReference);
      final service = ref.read(excelImportServiceProvider)
        ..chargerOctets(source.buffer.asUint8List());
      final rapport = await service.reinitialiserDepuisClasseur();
      ref.invalidate(databaseBootstrapProvider);
      ref.invalidate(activitesProvider);
      ref.invalidate(lignesBudgetProvider);
      ref.invalidate(participantsProvider);
      ref.invalidate(tousParticipantsProvider);
      ref.invalidate(affectationsActiviteProvider);
      ref.invalidate(presencesActiviteProvider);
      ref.invalidate(resultatsPresencesProvider);
      ref.invalidate(syntheseIndemnitesProvider);
      ref.invalidate(controlesPJProvider);
      ref.invalidate(resultatsControlePJProvider);
      ref.invalidate(depensesProvider);
      ref.invalidate(banqueProvider);
      ref.invalidate(releveBancaireProvider);
      ref.invalidate(rapprochementProvider);
      ref.invalidate(districtsProvider);
      ref.invalidate(tousDistrictsProvider);
      ref.invalidate(tarifsProvider);
      ref.invalidate(tousTarifsProvider);
      ref.invalidate(listesProvider);
      ref.invalidate(indicateursProvider);
      if (!mounted) return;
      setState(() {
        _enCours = false;
        _message =
            'Réinitialisation terminée : '
            '${rapport.totalImportees} ligne(s) restaurée(s). '
            'Sauvegarde de secours : ${sauvegarde.path}';
      });
      notifier(context, 'Les données source ont été restaurées.');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _enCours = false;
        _message = 'Réinitialisation annulée : $e';
      });
      notifier(
        context,
        'Erreur pendant la réinitialisation : $e',
        erreur: true,
      );
    }
  }

  Future<void> _importerExcel() async {
    final fichiers = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      dialogTitle: 'Sélectionner le classeur Excel de référence',
    );
    if (fichiers.isEmpty || fichiers.single.path == null) return;
    final fichier = File(fichiers.single.path!);

    setState(() {
      _enCours = true;
      _message = 'Analyse du classeur…';
    });
    try {
      final service = ref.read(excelImportServiceProvider);
      service.charger(fichier);
      final apercu = service.analyser();
      if (!mounted) return;

      final strategie = await showDialog<StrategieDoublon>(
        context: context,
        builder: (_) => _DialogueApercu(apercu: apercu),
      );
      if (strategie == null) {
        setState(() {
          _enCours = false;
          _message = 'Import annulé.';
        });
        return;
      }

      setState(() => _message = 'Import en cours…');
      final rapport = await service.importer(strategie: strategie);
      if (!mounted) return;
      setState(() {
        _enCours = false;
        _message =
            'Import terminé : ${rapport.totalImportees} ligne(s) importée(s), '
            '${rapport.totalIgnorees} ignorée(s).';
      });
      // Rafraîchit toutes les vues dépendantes.
      ref.invalidate(activitesProvider);
      ref.invalidate(participantsProvider);
      ref.invalidate(tousParticipantsProvider);
      ref.invalidate(controlesPJProvider);
      ref.invalidate(depensesProvider);
      ref.invalidate(banqueProvider);
      ref.invalidate(districtsProvider);
      ref.invalidate(tousDistrictsProvider);
      ref.invalidate(tarifsProvider);
      ref.invalidate(tousTarifsProvider);
      ref.invalidate(indicateursProvider);
      notifier(context, 'Import Excel terminé');
    } catch (e) {
      setState(() {
        _enCours = false;
        _message = 'Erreur pendant l\'import : $e';
      });
    }
  }

  Future<void> _exporterExcel() async {
    await _exporter(
      (service) => service.exporterComplet(),
      'DSFA_export_complet',
    );
  }

  Future<void> _exporterExcelSpecifique(String type) async {
    await _exporter(
      (service) => switch (type) {
        'activites' => service.exporterActivites(),
        'presences' => service.exporterPresences(),
        'indemnites' => service.exporterIndemnites(),
        'pj' => service.exporterControlePJ(),
        'depenses' => service.exporterDepenses(),
        'banque' => service.exporterBanque(),
        _ => service.exporterComplet(),
      },
      'DSFA_$type',
    );
  }

  Future<void> _exporter(
    Future<List<int>> Function(dynamic service) generer,
    String nomBase,
  ) async {
    setState(() {
      _enCours = true;
      _message = 'Génération du fichier…';
    });
    try {
      final service = ref.read(excelExportServiceProvider);
      final bytes = await generer(service);
      if (!mounted) return;
      final horodatage = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final uri = await FilePicker.saveFile(
        dialogTitle: 'Enregistrer l\'export Excel',
        fileName: '${nomBase}_$horodatage.xlsx',
        bytes: Uint8List.fromList(bytes),
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
      if (uri == null) {
        setState(() {
          _enCours = false;
          _message = 'Export annulé.';
        });
        return;
      }
      final chemin = uri.toFilePath();
      await service.sauvegarder(bytes, chemin);
      setState(() {
        _enCours = false;
        _message = 'Export Excel enregistré : $chemin';
      });
      if (mounted) notifier(context, 'Export Excel enregistré');
    } catch (e) {
      setState(() {
        _enCours = false;
        _message = 'Erreur pendant l\'export : $e';
      });
    }
  }

  Future<void> _exporterPdf() async {
    setState(() {
      _enCours = true;
      _message = 'Génération du rapport PDF…';
    });
    try {
      final service = ref.read(pdfExportServiceProvider);
      final bytes = await service.rapportFinancier();
      if (!mounted) return;
      final horodatage = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final uri = await FilePicker.saveFile(
        dialogTitle: 'Enregistrer le rapport PDF',
        fileName: 'DSFA_rapport_financier_$horodatage.pdf',
        bytes: Uint8List.fromList(bytes),
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (uri == null) {
        setState(() {
          _enCours = false;
          _message = 'Export annulé.';
        });
        return;
      }
      final chemin = uri.toFilePath();
      await service.sauvegarder(bytes, chemin);
      setState(() {
        _enCours = false;
        _message = 'Rapport PDF enregistré : $chemin';
      });
      if (mounted) notifier(context, 'Rapport PDF enregistré');
    } catch (e) {
      setState(() {
        _enCours = false;
        _message = 'Erreur pendant l\'export PDF : $e';
      });
    }
  }

  Future<void> _exporterRapprochementPdf() async {
    await _exporterPdfGenerique(
      (service) => service.rapportRapprochement(),
      'DSFA_rapprochement',
    );
  }

  Future<void> _exporterControlePJPdf() async {
    await _exporterPdfGenerique(
      (service) => service.rapportControlePJ(),
      'DSFA_controle_pj',
    );
  }

  Future<void> _exporterPdfGenerique(
    Future<List<int>> Function(dynamic service) generer,
    String nomBase,
  ) async {
    setState(() {
      _enCours = true;
      _message = 'Génération du PDF…';
    });
    try {
      final service = ref.read(pdfExportServiceProvider);
      final bytes = await generer(service);
      if (!mounted) return;
      final horodatage = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final uri = await FilePicker.saveFile(
        dialogTitle: 'Enregistrer le rapport PDF',
        fileName: '${nomBase}_$horodatage.pdf',
        bytes: Uint8List.fromList(bytes),
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (uri == null) {
        setState(() {
          _enCours = false;
          _message = 'Export annulé.';
        });
        return;
      }
      final chemin = uri.toFilePath();
      await service.sauvegarder(bytes, chemin);
      setState(() {
        _enCours = false;
        _message = 'PDF enregistré : $chemin';
      });
    } catch (e) {
      setState(() {
        _enCours = false;
        _message = 'Erreur : $e';
      });
    }
  }
}

class _CarteRapport extends StatelessWidget {
  const _CarteRapport({
    required this.titre,
    required this.description,
    required this.icone,
    required this.couleur,
    required this.bouton,
    required this.onPressed,
  });

  final String titre;
  final String description;
  final IconData icone;
  final Color couleur;
  final String bouton;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icone, color: couleur),
            ),
            const SizedBox(height: 14),
            Text(
              titre,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(backgroundColor: couleur),
              child: Text(bouton),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoutonExport extends StatelessWidget {
  const _BoutonExport({
    required this.label,
    required this.icone,
    required this.onPressed,
  });

  final String label;
  final IconData icone;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icone, size: 18),
      label: Text(label),
    );
  }
}

/// Dialogue d'aperçu avant import (validation + stratégie de doublons).
class _DialogueApercu extends StatefulWidget {
  const _DialogueApercu({required this.apercu});
  final ApercuImport apercu;

  @override
  State<_DialogueApercu> createState() => _DialogueApercuState();
}

class _DialogueApercuState extends State<_DialogueApercu> {
  StrategieDoublon _strategie = StrategieDoublon.ignorer;

  @override
  Widget build(BuildContext context) {
    final apercu = widget.apercu;
    return AlertDialog(
      title: const TitreDialogue(
        'Aperçu de l\'import Excel',
        icone: Icons.table_view_outlined,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 640),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Vérifiez les lignes détectées avant d\'importer. '
                'Les données existantes ne sont jamais écrasées silencieusement.',
              ),
              const SizedBox(height: 16),
              if (apercu.aCompter.isEmpty)
                const Text('Aucune donnée exploitable détectée.')
              else
                Table(
                  border: TableBorder.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  children: [
                    const TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Feuille',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Lignes détectées',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    for (final e in apercu.aCompter.entries)
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(e.key),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text('${e.value}'),
                          ),
                        ],
                      ),
                  ],
                ),
              if (apercu.details.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Points de vigilance (${apercu.details.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 160,
                  child: ListView(
                    children: [
                      for (final d in apercu.details.take(50))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                d.estErreur
                                    ? Icons.error_outline
                                    : Icons.info_outline,
                                size: 14,
                                color: d.estErreur
                                    ? Colors.red
                                    : const Color(0xFFF9A825),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${d.feuille} ligne ${d.ligne} : ${d.message}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Gestion des doublons',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              RadioGroup<StrategieDoublon>(
                groupValue: _strategie,
                onChanged: (v) => setState(() => _strategie = v ?? _strategie),
                child: Column(
                  children: const [
                    RadioListTile<StrategieDoublon>(
                      value: StrategieDoublon.ignorer,
                      title: Text('Ignorer les doublons'),
                      subtitle: Text(
                        'Les lignes déjà présentes sont conservées',
                      ),
                      dense: true,
                    ),
                    RadioListTile<StrategieDoublon>(
                      value: StrategieDoublon.remplacer,
                      title: Text('Ajouter / remplacer'),
                      subtitle: Text(
                        'Les lignes existantes sont mises à jour quand c\'est possible',
                      ),
                      dense: true,
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
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: apercu.peutImporter
              ? () => Navigator.of(context).pop(_strategie)
              : null,
          icon: const Icon(Icons.download_outlined),
          label: const Text('Confirmer l\'import'),
        ),
      ],
    );
  }
}
