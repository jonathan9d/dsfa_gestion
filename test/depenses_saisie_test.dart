import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsfa_gestion/data/database/database.dart';
import 'package:dsfa_gestion/presentation/providers/providers.dart';
import 'package:dsfa_gestion/presentation/screens/depenses/depenses_screen.dart';

/// Saisie des dépenses : **même saisie que le budget** (rubrique déduite des
/// paramètres, ligne budgétaire, unité, quantités, P.U., observation), plus
/// les trois champs propres aux dépenses : référence PJ, bénéficiaire et mode
/// de paiement. Le montant reste calculé automatiquement.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db
        .into(db.activites)
        .insert(
          ActivitesCompanion(
            code: const drift.Value('ACT-0001'),
            description: const drift.Value('Atelier'),
            dateDebut: drift.Value(DateTime(2026, 1, 5)),
            dateFin: drift.Value(DateTime(2026, 1, 6)),
            statut: const drift.Value('En cours'),
          ),
        );
    // Référentiel : la désignation « EAU POUR LES ATELIERS » est rattachée à la
    // rubrique « RESTAURATION / FRAIS D'ORGANISATION » (comme dans le classeur).
    await db
        .into(db.referentielTarifs)
        .insert(
          ReferentielTarifsCompanion(
            rubrique: const drift.Value("RESTAURATION / FRAIS D'ORGANISATION"),
            ligneBudgetaire: const drift.Value('EAU POUR LES ATELIERS'),
            unite: const drift.Value('litre'),
            tarif: const drift.Value(1500),
          ),
        );
  });

  tearDown(() async => db.close());

  Future<void> pomper(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: DepensesScreen()),
      ),
    );
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> stabiliser(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('la saisie reprend le budget et ajoute les 3 champs', (
    tester,
  ) async {
    await pomper(tester);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Nouvelle dépense'));
    await stabiliser(tester);
    expect(tester.takeException(), isNull);

    // Les trois champs supplémentaires des dépenses.
    expect(find.text('Référence PJ'), findsOneWidget);
    expect(find.text('Bénéficiaire'), findsOneWidget);
    expect(find.text('Mode de paiement'), findsOneWidget);
    // Même saisie que le budget : désignation, unité, quantités, P.U.
    expect(find.text('Désignation *'), findsOneWidget);
    expect(find.text('Unité'), findsOneWidget);
    expect(find.text('Quantité *'), findsOneWidget);
    expect(find.text('Fréquence *'), findsOneWidget);
    expect(find.text('P.U. (Ar) *'), findsOneWidget);
    // La rubrique est déduite des paramètres : jamais saisie librement.
    expect(
      find.textContaining('Rubrique (déduite des paramètres)'),
      findsOneWidget,
    );

    // Saisie complète puis enregistrement.
    Future<void> remplir(String label, String valeur) async {
      final champ = find
          .ancestor(of: find.text(label), matching: find.byType(TextFormField))
          .first;
      await tester.enterText(champ, valeur);
      await tester.pump();
    }

    await remplir('Désignation *', 'EAU POUR LES ATELIERS');
    await stabiliser(tester);
    expect(
      find.textContaining("RESTAURATION / FRAIS D'ORGANISATION"),
      findsWidgets,
      reason: 'la rubrique est déduite du référentiel des tarifs',
    );
    await remplir('Référence PJ', 'PJ-2026-01');
    await remplir('Bénéficiaire', 'Rakoto Jean');
    await remplir('Quantité *', '2');
    await remplir('Fréquence *', '1');
    await remplir('P.U. (Ar) *', '1500');
    await stabiliser(tester);

    // Montant calculé affiché (2 × 1 × 1500).
    expect(find.textContaining('Montant calculé'), findsOneWidget);

    await tester.tap(find.text('Enregistrer'));
    await stabiliser(tester);
    expect(tester.takeException(), isNull);

    final depenses = await db.select(db.depenses).get();
    expect(depenses.length, 1);
    expect(depenses.single.designation, 'EAU POUR LES ATELIERS');
    expect(depenses.single.beneficiaire, 'Rakoto Jean');
    expect(depenses.single.refPieceDepense, 'PJ-2026-01');
    expect(depenses.single.quantite, 2);
    expect(depenses.single.pu, 1500);

    await tester.pumpWidget(const SizedBox());
    await stabiliser(tester);
  });
}
