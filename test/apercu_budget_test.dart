import 'package:dsfa_gestion/data/database/database.dart';
import 'package:dsfa_gestion/presentation/screens/budgets/apercu_budget_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

LigneBudget _ligne(int id, String ligne, String type, {int q = 10}) =>
    LigneBudget(
      id: id,
      activiteCode: 'PSN N°1 — Atelier de planification régionale',
      ligneBudgetaire: ligne,
      typeBudget: type,
      unite: 'unité',
      quantitePrevue: q.toDouble(),
      nombreJours: 3,
      tauxUnitaire: 5000,
      montantAlloue: 150000,
    );

Future<void> _pump(WidgetTester tester, Size taille, List<LigneBudget> lignes) async {
  tester.view.physicalSize = taille;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => ApercuBudgetDialog(lignes: lignes),
              ),
              child: const Text('Voir'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Voir'));
  await tester.pumpAndSettle();
}

void main() {
  final lignes = [
    for (var i = 0; i < 12; i++)
      _ligne(
        i + 1,
        i.isEven
            ? 'Indemnité des équipes centraux et régionaux'
            : 'Carburant',
        i.isEven ? 'Indemnités équipes' : 'Carburant',
        q: i + 1,
      ),
  ];

  for (final taille in const [
    Size(1920, 1080),
    Size(1366, 768),
    Size(1024, 700),
    Size(900, 650),
    Size(800, 600),
  ]) {
    testWidgets('ApercuBudgetDialog @ ${taille.width}x${taille.height}', (
      tester,
    ) async {
      await _pump(tester, taille, lignes);
      expect(find.text('Pré-impression du budget'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('le bouton « Fermer » (×) ferme le dialogue', (tester) async {
    await _pump(tester, const Size(1366, 768), lignes);
    expect(find.text('Pré-impression du budget'), findsOneWidget);

    await tester.tap(find.byTooltip('Fermer'));
    await tester.pumpAndSettle();

    expect(find.text('Pré-impression du budget'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chaque rubrique affiche son total après ses lignes', (
    tester,
  ) async {
    await _pump(tester, const Size(1366, 768), lignes);

    expect(find.text('Total de la rubrique'), findsNWidgets(2));
    expect(find.text('Désignation'), findsWidgets);
    expect(find.text('Ligne budgétaire'), findsNothing);
    expect(find.text('TOTAL GÉNÉRAL'), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('un clic en dehors du dialogue le referme', (tester) async {
    await _pump(tester, const Size(1366, 768), lignes);
    expect(find.text('Pré-impression du budget'), findsOneWidget);

    // Coin supérieur gauche : hors du dialogue, dans la zone d'ombre.
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    expect(find.text('Pré-impression du budget'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
