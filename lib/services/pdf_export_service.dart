import 'dart:io';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/database/database.dart';
import '../data/repositories/activite_repository.dart';
import '../domain/models.dart';
import '../domain/services/controle_pj_service.dart';
import '../domain/services/dashboard_service.dart';
import '../domain/services/presence_indemnite_service.dart';
import '../domain/services/rapport_financier_service.dart';
import '../domain/services/rapprochement_service.dart';
import 'package:flutter/services.dart';

/// Service d'export des rapports PDF.
class PdfExportService {
  PdfExportService({
    required DashboardService dashboard,
    required PresenceIndemniteService presenceService,
    required ControlePJService controlePJ,
    required RapprochementService rapprochement,
    required ActivitesRepository activites,
  }) : _dashboard = dashboard,
       _presenceService = presenceService,
       _controlePJ = controlePJ,
       _rapprochement = rapprochement,
       _activites = activites;

  final DashboardService _dashboard;
  final PresenceIndemniteService _presenceService;
  final ControlePJService _controlePJ;
  final RapprochementService _rapprochement;
  final ActivitesRepository _activites;

  final _fmtMontant = NumberFormat('#,##0', 'fr_FR');
  final _fmtDate = DateFormat('dd/MM/yyyy');
  pw.MemoryImage? _logo;

  pw.ThemeData _theme() =>
      pw.ThemeData(defaultTextStyle: const pw.TextStyle(fontSize: 9));

  Future<void> _chargerLogo() async {
    if (_logo != null) return;
    final data = await rootBundle.load('assets/logo_dsfa1.jpeg');
    _logo = pw.MemoryImage(data.buffer.asUint8List());
  }

  /// Rapport financier complet : indicateurs, budgets, contrôle PJ, anomalies.
  Future<List<int>> rapportFinancier({DateTime? debut, DateTime? fin}) async {
    await _chargerLogo();
    final indicateurs = await _dashboard.calculer();
    final controles = await _controlePJ.evaluerTout();
    final activites = await _activites.getAll();
    final parRubrique = await _dashboard.depensesParRubrique();

    final doc = pw.Document(theme: _theme());

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => _entete('RAPPORT FINANCIER', debut, fin),
        footer: (ctx) => _piedDePage(ctx),
        build: (ctx) => [
          _sectionTitre('1. Synthèse générale'),
          _tableauIndicateurs(indicateurs),
          pw.SizedBox(height: 16),
          _sectionTitre('2. Consommation budgétaire'),
          _tableauConsommation(indicateurs),
          pw.SizedBox(height: 16),
          _sectionTitre('3. Contrôle des pièces justificatives'),
          _tableauStatutsPJ(indicateurs),
          pw.SizedBox(height: 16),
          _sectionTitre('4. Dépenses par ligne budgétaire'),
          _tableauDepensesParRubrique(parRubrique),
          pw.SizedBox(height: 16),
          _sectionTitre('5. Détail des activités'),
          _tableauActivites(activites),
          pw.SizedBox(height: 16),
          _sectionTitre('6. Anomalies détectées'),
          _tableauAnomalies(controles),
        ],
      ),
    );

    return doc.save();
  }

  /// Rapport de contrôle PJ.
  Future<List<int>> rapportControlePJ() async {
    await _chargerLogo();
    final controles = await _controlePJ.evaluerTout();
    final doc = pw.Document(theme: _theme());
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        header: (ctx) =>
            _entete('CONTRÔLE DES PIÈCES JUSTIFICATIVES', null, null),
        footer: (ctx) => _piedDePage(ctx),
        build: (ctx) => [_tableauControlesPJ(controles)],
      ),
    );
    return doc.save();
  }

  /// Rapport des présences et indemnités d'une activité.
  Future<List<int>> rapportPresences(String activiteCode) async {
    await _chargerLogo();
    final activite = await _activites.parCode(activiteCode);
    final syntheses = await _presenceService.syntheseParParticipant(
      activiteCode,
    );
    final doc = pw.Document(theme: _theme());
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        header: (ctx) => _entete(
          'PRÉSENCES ET INDEMNITÉS — ${activite?.code ?? activiteCode}',
          activite?.dateDebut,
          activite?.dateFin,
        ),
        footer: (ctx) => _piedDePage(ctx),
        build: (ctx) => [
          pw.Text(
            activite?.description ?? '',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          _tableauSynthesesIndemnites(syntheses),
        ],
      ),
    );
    return doc.save();
  }

  /// État de rapprochement bancaire.
  Future<List<int>> rapportRapprochement() async {
    await _chargerLogo();
    final resultat = await _rapprochement.calculer();
    final doc = pw.Document(theme: _theme());
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => _entete('ÉTAT DE RAPPROCHEMENT BANCAIRE', null, null),
        footer: (ctx) => _piedDePage(ctx),
        build: (ctx) => [_tableauRapprochement(resultat)],
      ),
    );
    return doc.save();
  }

  /// Pré-impression du budget : récapitulatif automatique par ligne
  /// budgétaire puis détail de toutes les lignes.
  Future<List<int>> apercuBudget(List<LigneBudget> lignes) async {
    await _chargerLogo();
    final doc = pw.Document(theme: _theme());

    final parLigne = <String, (int, double)>{};
    var total = 0.0;
    for (final l in lignes) {
      final courant = parLigne[l.ligneBudgetaire] ?? (0, 0.0);
      parLigne[l.ligneBudgetaire] =
          (courant.$1 + 1, courant.$2 + l.montantAlloue);
      total += l.montantAlloue;
    }
    final resume = parLigne.entries.toList()
      ..sort((a, b) => b.value.$2.compareTo(a.value.$2));

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        header: (ctx) => _entete('PRÉ-IMPRESSION DU BUDGET', null, null),
        footer: (ctx) => _piedDePage(ctx),
        build: (ctx) => [
          _sectionTitre('1. Récapitulatif automatique'),
          _tableau(
            ['Ligne budgétaire', 'Lignes', 'Montant alloué (Ar)'],
            [
              for (final e in resume)
                [e.key, '${e.value.$1}', _fmtMontant.format(e.value.$2)],
            ],
            totaux: [
              'TOTAL GÉNÉRAL',
              '${lignes.length}',
              _fmtMontant.format(total),
            ],
          ),
          pw.SizedBox(height: 16),
          _sectionTitre('2. Détail des lignes budgétaires'),
          _tableau(
            [
              'Activité',
              'Ligne budgétaire',
              'Type',
              'Unité',
              'Qté',
              'Jours',
              'Taux',
              'Montant alloué',
              'Observation',
            ],
            [
              for (final l in lignes)
                [
                  l.activiteCode,
                  l.ligneBudgetaire,
                  l.typeBudget,
                  l.unite,
                  _fmtMontant.format(l.quantitePrevue),
                  _fmtMontant.format(l.nombreJours),
                  _fmtMontant.format(l.tauxUnitaire),
                  _fmtMontant.format(l.montantAlloue),
                  l.observation ?? '',
                ],
            ],
            totaux: [
              'TOTAL',
              '',
              '',
              '',
              '',
              '',
              '',
              _fmtMontant.format(total),
              '',
            ],
          ),
        ],
      ),
    );
    return doc.save();
  }

  /// Rapport financier : alloué / dépenses réalisées / écart.
  Future<List<int>> rapportFinancierDetaille(
    ResumeRapportFinancier rapport,
  ) async {
    await _chargerLogo();
    final doc = pw.Document(theme: _theme());
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        header: (ctx) => _entete('RAPPORT FINANCIER DÉTAILLÉ', null, null),
        footer: (ctx) => _piedDePage(ctx),
        build: (ctx) => [
          _sectionTitre('1. Récapitulatif global'),
          _tableau(
            ['Indicateur', 'Valeur (Ar)'],
            [
              ['Montant total alloué', _fmtMontant.format(rapport.totalAlloue)],
              ['Dépenses réalisées', _fmtMontant.format(rapport.totalRealise)],
              ['Écart', _fmtMontant.format(rapport.totalEcart)],
              [
                'Taux de consommation',
                '${(rapport.tauxConsommation * 100).toStringAsFixed(1)} %',
              ],
              ['Nombre de lignes', '${rapport.lignes.length}'],
            ],
          ),
          pw.SizedBox(height: 16),
          _sectionTitre('2. Détail par ligne budgétaire'),
          _tableau(
            [
              'Code activité',
              'Code budget',
              'Description activité',
              'Ligne budgétaire',
              'Montant alloué',
              'Dépenses réalisées',
              'Écart',
              'Observation',
            ],
            [
              for (final l in rapport.lignes)
                [
                  l.codeActivite,
                  l.codeBudget,
                  l.descriptionActivite,
                  l.ligneBudgetaire,
                  _fmtMontant.format(l.montantAlloue),
                  _fmtMontant.format(l.depensesRealisees),
                  _fmtMontant.format(l.ecart),
                  l.observationFinale,
                ],
            ],
            totaux: [
              'TOTAL',
              '',
              '',
              '',
              _fmtMontant.format(rapport.totalAlloue),
              _fmtMontant.format(rapport.totalRealise),
              _fmtMontant.format(rapport.totalEcart),
              '',
            ],
          ),
        ],
      ),
    );
    return doc.save();
  }

  Future<void> sauvegarder(List<int> bytes, String chemin) async {
    final file = File(chemin);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);
  }

  // --- Blocs ---

  pw.Widget _entete(String titre, DateTime? debut, DateTime? fin) {
    final periode = debut != null && fin != null
        ? 'Période : du ${_fmtDate.format(debut)} au ${_fmtDate.format(fin)}'
        : 'Période : toutes les données';
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColor.fromInt(0xFF2C806F), width: 2),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (_logo != null) ...[
            pw.Image(_logo!, width: 38, height: 38),
            pw.SizedBox(width: 10),
          ],
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'DSFA GESTION',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFF1F4E79),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  titre,
                  maxLines: 2,
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFF17354F),
                  ),
                ),
                pw.Text(periode, style: const pw.TextStyle(fontSize: 8)),
              ],
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Text(
            'Généré le ${_fmtDate.format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  pw.Widget _piedDePage(pw.Context ctx) => pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        'DSFA Gestion — Document généré automatiquement',
        style: const pw.TextStyle(fontSize: 8),
      ),
      pw.Text(
        'Page ${ctx.pageNumber}/${ctx.pagesCount}',
        style: const pw.TextStyle(fontSize: 8),
      ),
    ],
  );

  pw.Widget _sectionTitre(String titre) => pw.Text(
    titre,
    style: pw.TextStyle(
      fontSize: 11,
      fontWeight: pw.FontWeight.bold,
      color: const PdfColor.fromInt(0xFF1F4E79),
    ),
  );

  pw.Widget _tableau(
    List<String> entetes,
    List<List<String>> lignes, {
    List<String>? totaux,
  }) {
    final data = <List<String>>[...lignes];
    if (totaux != null) data.add(totaux);
    return pw.TableHelper.fromTextArray(
      headers: entetes,
      data: data,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 8,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF1F4E79),
      ),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellAlignment: pw.Alignment.centerRight,
      headerAlignment: pw.Alignment.center,
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.4),
      cellPadding: const pw.EdgeInsets.all(3),
      oddRowDecoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF5F8FA),
      ),
      rowDecoration: totaux == null
          ? null
          : const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE9F0F4)),
    );
  }

  pw.Widget _tableauIndicateurs(IndicateursDashboard i) {
    final lignes = [
      ['Montant total alloué', _fmtMontant.format(i.montantTotalAlloue), 'Ar'],
      ['Montant total payé', _fmtMontant.format(i.montantTotalPaye), 'Ar'],
      ['Montant total PJ', _fmtMontant.format(i.montantTotalPJ), 'Ar'],
      ['Écart budget total', _fmtMontant.format(i.ecartBudgetTotal), 'Ar'],
      ['Écart PJ total', _fmtMontant.format(i.ecartPJTotal), 'Ar'],
      [
        'Total indemnités théoriques',
        _fmtMontant.format(i.totalIndemnitesTheoriques),
        'Ar',
      ],
      [
        'Total indemnités reçues',
        _fmtMontant.format(i.totalIndemnitesRecues),
        'Ar',
      ],
      ['Total dépenses', _fmtMontant.format(i.totalDepenses), 'Ar'],
      ['Solde bancaire', _fmtMontant.format(i.soldeBancaire), 'Ar'],
      ['Nombre d\'activités', '${i.nombreActivites}', ''],
      ['Nombre de participants', '${i.nombreParticipants}', ''],
      ['Nombre de présences', '${i.nombrePresences}', ''],
    ];
    return _tableau(['Indicateur', 'Valeur', 'Unité'], lignes);
  }

  pw.Widget _tableauConsommation(IndicateursDashboard i) {
    final taux = (i.tauxConsommation * 100).toStringAsFixed(1);
    return _tableau(
      ['Budget total', 'Dépenses', 'Solde', 'Taux de consommation'],
      [
        [
          _fmtMontant.format(i.montantTotalAlloue),
          _fmtMontant.format(i.montantTotalPaye),
          _fmtMontant.format(i.soldeBudget),
          '$taux %',
        ],
      ],
    );
  }

  pw.Widget _tableauStatutsPJ(IndicateursDashboard i) => _tableau(
    [
      'Conforme',
      'À vérifier',
      'Non conforme',
      'PJ non reçue',
      'Date PJ non conforme',
    ],
    [
      [
        '${i.dossiersConformes}',
        '${i.pjAverifier}',
        '${i.dossiersNonConformes}',
        '${i.pjNonRecues}',
        '${i.datesPJNonConformes}',
      ],
    ],
  );

  pw.Widget _tableauDepensesParRubrique(List<SeriePoint> points) {
    final lignes = points
        .map((p) => [p.label, _fmtMontant.format(p.valeur)])
        .toList();
    final total = points.fold<double>(0, (s, p) => s + p.valeur);
    return _tableau(
      ['Ligne budgétaire', 'Montant payé (Ar)'],
      lignes,
      totaux: ['TOTAL', _fmtMontant.format(total)],
    );
  }

  pw.Widget _tableauActivites(List<dynamic> activites) {
    final lignes = activites
        .map<List<String>>(
          (a) => [
            a.code as String,
            (a.description as String?) ?? '',
            a.dateDebut == null ? '' : _fmtDate.format(a.dateDebut as DateTime),
            a.dateFin == null ? '' : _fmtDate.format(a.dateFin as DateTime),
            a.statut as String,
          ],
        )
        .toList();
    return _tableau(['Code', 'Description', 'Début', 'Fin', 'Statut'], lignes);
  }

  pw.Widget _tableauAnomalies(List<(dynamic, ResultatControlePJ)> controles) {
    final anomalies = controles
        .where(
          (e) => e.$2.statutFinal.isNotEmpty && e.$2.statutFinal != 'Conforme',
        )
        .map<List<String>>(
          (e) => [
            (e.$1.activiteCode as String?) ?? '',
            (e.$1.beneficiaire as String?) ?? '',
            (e.$1.ligneBudgetaire as String?) ?? '',
            _fmtMontant.format(e.$2.ecartBudget),
            e.$2.statutFinal,
          ],
        )
        .toList();
    if (anomalies.isEmpty) {
      return pw.Text(
        'Aucune anomalie détectée.',
        style: const pw.TextStyle(fontSize: 9),
      );
    }
    return _tableau([
      'Activité',
      'Bénéficiaire',
      'Ligne',
      'Écart budget (Ar)',
      'Statut',
    ], anomalies);
  }

  pw.Widget _tableauControlesPJ(List<(dynamic, ResultatControlePJ)> controles) {
    final lignes = controles.map<List<String>>((e) {
      final c = e.$1;
      final r = e.$2;
      return [
        (c.activiteCode as String?) ?? '',
        (c.datePJ as DateTime?) == null
            ? ''
            : _fmtDate.format(c.datePJ as DateTime),
        (c.beneficiaire as String?) ?? '',
        (c.ligneBudgetaire as String?) ?? '',
        _fmtMontant.format(c.montantAlloue as double),
        _fmtMontant.format(c.montantPaye as double),
        _fmtMontant.format(c.montantPJ as double),
        _fmtMontant.format(r.ecartBudget),
        _fmtMontant.format(r.ecartPJ),
        r.datePJCoherente ? 'Oui' : 'Non',
        r.statutFinal,
      ];
    }).toList();
    return _tableau([
      'Activité',
      'Date PJ',
      'Bénéficiaire',
      'Ligne',
      'Alloué',
      'Payé',
      'PJ',
      'Écart budget',
      'Écart PJ',
      'Date OK',
      'Statut final',
    ], lignes);
  }

  pw.Widget _tableauSynthesesIndemnites(
    List<SyntheseIndemniteParticipant> syntheses,
  ) {
    final lignes = syntheses
        .map<List<String>>(
          (s) => [
            s.participantNom,
            '${s.nombreJours}',
            '${s.nombreJoursPresents}',
            _fmtMontant.format(s.tauxJournalier),
            _fmtMontant.format(s.indemniteTheorique),
            _fmtMontant.format(s.indemniteRecue),
            _fmtMontant.format(s.ecart),
            s.statut.libelle,
          ],
        )
        .toList();
    final totTheo = syntheses.fold<double>(
      0,
      (s, e) => s + e.indemniteTheorique,
    );
    final totRecue = syntheses.fold<double>(0, (s, e) => s + e.indemniteRecue);
    return _tableau(
      [
        'Participant',
        'Jours',
        'Présents',
        'Taux',
        'Théorique',
        'Reçue',
        'Écart',
        'Statut',
      ],
      lignes,
      totaux: [
        'TOTAL',
        '',
        '',
        '',
        _fmtMontant.format(totTheo),
        _fmtMontant.format(totRecue),
        _fmtMontant.format(totRecue - totTheo),
        '',
      ],
    );
  }

  pw.Widget _tableauRapprochement(ResultatRapprochement r) {
    final lignes = r.lignes
        .map<List<String>>(
          (l) => [
            l.date == null ? '' : _fmtDate.format(l.date!),
            l.reference,
            l.libelle,
            _fmtMontant.format(l.montantJournal),
            _fmtMontant.format(l.montantReleve),
            _fmtMontant.format(l.ecart),
            l.statut.libelle,
          ],
        )
        .toList();
    return pw.Column(
      children: [
        _tableau([
          'Date',
          'Réf',
          'Libellé',
          'Journal',
          'Relevé',
          'Écart',
          'Statut',
        ], lignes),
        pw.SizedBox(height: 12),
        _tableau(
          ['Indicateur', 'Montant (Ar)'],
          [
            ['Solde rapproché journal', _fmtMontant.format(r.soldeJournal)],
            ['Solde rapproché relevé', _fmtMontant.format(r.soldeReleve)],
            ['Écart', _fmtMontant.format(r.ecart)],
          ],
        ),
      ],
    );
  }
}
