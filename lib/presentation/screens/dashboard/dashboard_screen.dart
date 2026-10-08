import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';

/// Tableau de bord : indicateurs clés et graphiques, tous issus de SQLite.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indicateurs = ref.watch(indicateursProvider);
    return Scaffold(
      body: indicateurs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EtatErreur(
          erreur: e,
          onReessayer: () => ref.invalidate(indicateursProvider),
        ),
        data: (i) => _Contenu(indicateurs: i),
      ),
    );
  }
}

class _Contenu extends ConsumerWidget {
  const _Contenu({required this.indicateurs});
  final IndicateursDashboard indicateurs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parRubrique = ref.watch(depensesParRubriqueProvider);
    final evolution = ref.watch(evolutionDepensesProvider);
    final repartition = ref.watch(repartitionActivitesProvider);
    final largeur = MediaQuery.sizeOf(context).width;
    // 8 indicateurs : une seule rangée sur grand écran, sinon des rangées
    // complètes (4 puis 2) — aucune carte isolée, donc aucun espace vide.
    final colonnes = largeur > 1350
        ? 8
        : largeur > 950
        ? 4
        : largeur > 560
        ? 2
        : 1;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(indicateursProvider);
        ref.invalidate(depensesParRubriqueProvider);
        ref.invalidate(evolutionDepensesProvider);
        ref.invalidate(repartitionActivitesProvider);
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          EnTetePage(
            titre: 'Tableau de bord',
            module: 'tableau_de_bord',
            sousTitre:
                'Situation financière et état des contrôles — données en temps réel',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _GrilleKpi(indicateurs: indicateurs, colonnes: colonnes),
                const SizedBox(height: 14),
                _LigneConsommationPJ(
                  indicateurs: indicateurs,
                  largeur: largeur,
                ),
                const SizedBox(height: 14),
                _GrilleGraphiques(
                  parRubrique: parRubrique,
                  evolution: evolution,
                  repartition: repartition,
                  largeur: largeur,
                ),
                const SizedBox(height: 14),
                _SyntheseControles(indicateurs: indicateurs),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GrilleKpi extends StatelessWidget {
  const _GrilleKpi({required this.indicateurs, required this.colonnes});

  final IndicateursDashboard indicateurs;
  final int colonnes;

  @override
  Widget build(BuildContext context) {
    final cartes = <Widget>[
      CarteIndicateur(
        titre: 'Budget total alloué',
        valeur: formatMontant(indicateurs.montantTotalAlloue),
        icone: Icons.savings_outlined,
        couleur: const Color(0xFF1F4E79),
        compact: true,
      ),
      CarteIndicateur(
        titre: 'Dépenses / payé',
        valeur: formatMontant(indicateurs.montantTotalPaye),
        icone: Icons.trending_down,
        couleur: const Color(0xFFB26A00),
        compact: true,
      ),
      CarteIndicateur(
        titre: 'Solde disponible',
        valeur: formatMontant(indicateurs.soldeBudget),
        icone: Icons.account_balance_wallet_outlined,
        couleur: const Color(0xFF2E7D32),
        compact: true,
      ),
      CarteIndicateur(
        titre: 'Activités',
        valeur: '${indicateurs.nombreActivites}',
        icone: Icons.event_note_outlined,
        couleur: const Color(0xFF6A1B9A),
        compact: true,
      ),
      CarteIndicateur(
        titre: 'Participants',
        valeur: '${indicateurs.nombreParticipants}',
        icone: Icons.groups_outlined,
        couleur: const Color(0xFF00838F),
        compact: true,
      ),
      CarteIndicateur(
        titre: 'Présences saisies',
        valeur: '${indicateurs.nombrePresences}',
        icone: Icons.calendar_month_outlined,
        couleur: const Color(0xFF00695C),
        compact: true,
      ),
      CarteIndicateur(
        titre: 'Total indemnités théoriques',
        valeur: formatMontant(indicateurs.totalIndemnitesTheoriques),
        icone: Icons.payments_outlined,
        couleur: const Color(0xFF283593),
        compact: true,
      ),
      CarteIndicateur(
        titre: 'Solde bancaire',
        valeur: formatMontant(indicateurs.soldeBancaire),
        icone: Icons.account_balance_outlined,
        couleur: const Color(0xFF37474F),
        compact: true,
      ),
    ];

    return LayoutBuilder(
      builder: (context, contraintes) {
        const espace = 10.0;
        final largeurCarte = colonnes == 1
            ? contraintes.maxWidth
            : (contraintes.maxWidth - espace * (colonnes - 1)) / colonnes;
        return Wrap(
          spacing: espace,
          runSpacing: espace,
          children: [
            for (final c in cartes) SizedBox(width: largeurCarte, child: c),
          ],
        );
      },
    );
  }
}

class _LigneConsommationPJ extends StatelessWidget {
  const _LigneConsommationPJ({
    required this.indicateurs,
    required this.largeur,
  });

  final IndicateursDashboard indicateurs;
  final double largeur;

  @override
  Widget build(BuildContext context) {
    final consommation = _CarteConsommation(indicateurs: indicateurs);
    final pj = _CarteControlePJ(indicateurs: indicateurs);
    if (largeur < 900) {
      return Column(children: [consommation, const SizedBox(height: 16), pj]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: consommation),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: pj),
      ],
    );
  }
}

class _CarteConsommation extends StatelessWidget {
  const _CarteConsommation({required this.indicateurs});
  final IndicateursDashboard indicateurs;

  @override
  Widget build(BuildContext context) {
    final taux = indicateurs.tauxConsommation.clamp(0.0, 1.0);
    final theme = Theme.of(context);
    return CarteSection(
      titre: 'Consommation budgétaire',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(taux * 100).toStringAsFixed(1)} %',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'du budget consommé',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: taux,
              minHeight: 14,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MiniStat(
                label: 'Alloué',
                valeur: formatMontant(indicateurs.montantTotalAlloue),
              ),
              _MiniStat(
                label: 'Payé',
                valeur: formatMontant(indicateurs.montantTotalPaye),
              ),
              _MiniStat(
                label: 'Solde',
                valeur: formatMontant(indicateurs.soldeBudget),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.valeur});
  final String label;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valeur,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarteControlePJ extends StatelessWidget {
  const _CarteControlePJ({required this.indicateurs});
  final IndicateursDashboard indicateurs;

  @override
  Widget build(BuildContext context) {
    return CarteSection(
      titre: 'Contrôle des pièces justificatives',
      child: Column(
        children: [
          _LigneControle(
            icone: Icons.check_circle,
            couleur: const Color(0xFF2E7D32),
            label: 'Conforme',
            valeur: indicateurs.dossiersConformes,
          ),
          _LigneControle(
            icone: Icons.warning_amber_rounded,
            couleur: const Color(0xFFF9A825),
            label: 'À vérifier',
            valeur: indicateurs.pjAverifier,
          ),
          _LigneControle(
            icone: Icons.cancel,
            couleur: const Color(0xFFC62828),
            label: 'Non conforme',
            valeur: indicateurs.dossiersNonConformes,
          ),
          _LigneControle(
            icone: Icons.attach_file_outlined,
            couleur: const Color(0xFFC62828),
            label: 'PJ non reçue',
            valeur: indicateurs.pjNonRecues,
          ),
          _LigneControle(
            icone: Icons.event_busy_outlined,
            couleur: const Color(0xFFC62828),
            label: 'Date PJ non conforme',
            valeur: indicateurs.datesPJNonConformes,
          ),
        ],
      ),
    );
  }
}

class _LigneControle extends StatelessWidget {
  const _LigneControle({
    required this.icone,
    required this.couleur,
    required this.label,
    required this.valeur,
  });

  final IconData icone;
  final Color couleur;
  final String label;
  final int valeur;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icone, size: 18, color: couleur),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          Text('$valeur', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _GrilleGraphiques extends StatelessWidget {
  const _GrilleGraphiques({
    required this.parRubrique,
    required this.evolution,
    required this.repartition,
    required this.largeur,
  });

  final AsyncValue<List<SeriePoint>> parRubrique;
  final AsyncValue<List<SeriePoint>> evolution;
  final AsyncValue<List<SeriePoint>> repartition;
  final double largeur;

  @override
  Widget build(BuildContext context) {
    final graphiqueRubrique = CarteSection(
      titre: 'Dépenses par ligne budgétaire',
      child: SizedBox(
        height: 260,
        child: parRubrique.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EtatErreur(erreur: e),
          data: (points) => points.isEmpty
              ? const EtatVide(
                  message: 'Aucune dépense enregistrée',
                  icone: Icons.bar_chart_outlined,
                )
              : _BarresHorizontales(points: points),
        ),
      ),
    );

    final graphiqueEvolution = CarteSection(
      titre: 'Évolution des dépenses',
      child: SizedBox(
        height: 260,
        child: evolution.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EtatErreur(erreur: e),
          data: (points) => points.isEmpty
              ? const EtatVide(
                  message: 'Aucune donnée de dépense',
                  icone: Icons.show_chart_outlined,
                )
              : _Courbe(points: points),
        ),
      ),
    );

    final graphiqueActivites = CarteSection(
      titre: 'Répartition des activités',
      child: SizedBox(
        height: 260,
        child: repartition.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EtatErreur(erreur: e),
          data: (points) => points.isEmpty
              ? const EtatVide(
                  message: 'Aucune activité enregistrée',
                  icone: Icons.pie_chart_outline,
                )
              : _Camembert(points: points),
        ),
      ),
    );

    if (largeur < 900) {
      return Column(
        children: [
          graphiqueRubrique,
          const SizedBox(height: 16),
          graphiqueEvolution,
          const SizedBox(height: 16),
          graphiqueActivites,
        ],
      );
    }
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: graphiqueRubrique),
            const SizedBox(width: 16),
            Expanded(child: graphiqueEvolution),
          ],
        ),
        const SizedBox(height: 16),
        graphiqueActivites,
      ],
    );
  }
}

class _BarresHorizontales extends StatelessWidget {
  const _BarresHorizontales({required this.points});
  final List<SeriePoint> points;

  @override
  Widget build(BuildContext context) {
    final max = points
        .map((p) => p.valeur)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final theme = Theme.of(context);
    return ListView(
      children: [
        for (final p in points.take(12))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Text(
                      formatMontant(p.valeur),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: max == 0 ? 0 : p.valeur / max,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Courbe extends StatelessWidget {
  const _Courbe({required this.points});
  final List<SeriePoint> points;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxY = points
        .map((p) => p.valeur)
        .fold<double>(0, (a, b) => a > b ? a : b);
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) => FlLine(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              getTitlesWidget: (v, meta) => Text(
                v >= 1000000
                    ? '${(v / 1000000).toStringAsFixed(0)}M'
                    : v >= 1000
                    ? '${(v / 1000).toStringAsFixed(0)}k'
                    : v.toStringAsFixed(0),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= points.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    points[i].label,
                    style: const TextStyle(fontSize: 9),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: maxY == 0 ? 1 : maxY * 1.15,
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < points.length; i++)
                FlSpot(i.toDouble(), points[i].valeur),
            ],
            isCurved: true,
            barWidth: 3,
            color: scheme.primary,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: scheme.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _Camembert extends StatelessWidget {
  const _Camembert({required this.points});
  final List<SeriePoint> points;

  static const _couleurs = [
    Color(0xFF1F4E79),
    Color(0xFF2E7D32),
    Color(0xFFF9A825),
    Color(0xFF6A1B9A),
    Color(0xFF00838F),
    Color(0xFFC62828),
  ];

  @override
  Widget build(BuildContext context) {
    final total = points.fold<double>(0, (s, p) => s + p.valeur);
    if (total == 0) {
      return const EtatVide(message: 'Aucune donnée');
    }
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                for (var i = 0; i < points.length; i++)
                  PieChartSectionData(
                    value: points[i].valeur,
                    color: _couleurs[i % _couleurs.length],
                    radius: 55,
                    title:
                        '${(points[i].valeur / total * 100).toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ListView(
            children: [
              for (var i = 0; i < points.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _couleurs[i % _couleurs.length],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          points[i].label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}

class _SyntheseControles extends StatelessWidget {
  const _SyntheseControles({required this.indicateurs});
  final IndicateursDashboard indicateurs;

  @override
  Widget build(BuildContext context) {
    return CarteSection(
      titre: 'Synthèse des écarts',
      child: Wrap(
        spacing: 20,
        runSpacing: 12,
        children: [
          _Ecart(
            label: 'Écart budget total',
            valeur: indicateurs.ecartBudgetTotal,
          ),
          _Ecart(label: 'Écart PJ total', valeur: indicateurs.ecartPJTotal),
          _Ecart(
            label: 'Indemnités reçues',
            valeur: indicateurs.totalIndemnitesRecues,
          ),
          _Ecart(label: 'Dépenses journal', valeur: indicateurs.totalDepenses),
        ],
      ),
    );
  }
}

class _Ecart extends StatelessWidget {
  const _Ecart({required this.label, required this.valeur});
  final String label;
  final double valeur;

  @override
  Widget build(BuildContext context) {
    final couleur = valeur == 0
        ? const Color(0xFF2E7D32)
        : valeur > 0
        ? const Color(0xFFC62828)
        : const Color(0xFFB26A00);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          formatMontant(valeur),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: couleur,
          ),
        ),
      ],
    );
  }
}
