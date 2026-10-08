import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsfa_gestion/data/database/database.dart';
import 'package:dsfa_gestion/data/repositories/referentiel_repository.dart';
import 'package:dsfa_gestion/presentation/providers/app_providers.dart';
import 'package:dsfa_gestion/presentation/providers/providers.dart';
import 'package:dsfa_gestion/presentation/screens/budgets/ligne_budget_dialog.dart';
import 'package:dsfa_gestion/services/excel_import_service.dart';

/// Vérifie que la distance carburant suit la règle du classeur :
/// **Antananarivo ↔ district de destination** (le référentiel ne connaît que
/// les distances depuis Antananarivo). Contrôle aussi qu'une recherche saisie
/// sur un autre écran ne fausse plus le calcul (référentiel non filtré).
void main() {
  late AppDatabase db;

  Future<void> semer() async {
    await db
        .into(db.districts)
        .insert(
          DistrictsCompanion.insert(
            chefLieuRegion: 'Antananarivo-Renivohitra',
            region: 'ANALAMANGA',
            nom: 'Antananarivo-Renivohitra',
            estChefLieuRegion: const drift.Value(true),
            distanceAllerKm: const drift.Value(10),
            distanceCarburantKm: const drift.Value(20),
            delaiRouteTotal: const drift.Value(0),
          ),
        );
    await db
        .into(db.districts)
        .insert(
          DistrictsCompanion.insert(
            chefLieuRegion: 'Antsirabe I',
            region: 'VAKINAKARATRA',
            nom: 'Antsirabe I',
            distanceAllerKm: const drift.Value(170),
            distanceCarburantKm: const drift.Value(340),
            delaiRouteTotal: const drift.Value(2),
          ),
        );
    await db
        .into(db.referenceValeurs)
        .insert(
          ReferenceValeursCompanion.insert(
            categorie: 'LIGNE_BUDGETAIRE',
            valeur: 'Carburant',
          ),
        );
    await ParametresRepository(db).ecrire(
      ExcelImportService.cleParametres,
      jsonEncode({
        'consommationCarburant': {'Moto': 0.05, '4x4': 0.15},
      }),
    );
  }

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await semer();
  });

  tearDown(() async => db.close());

  Future<void> stabiliser(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 60));
    }
  }

  Future<void> pomper(
    WidgetTester tester, {
    String recherche = '',
  }) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          filtreRechercheProvider.overrideWith((ref) => recherche),
        ],
        child: const MaterialApp(
          home: Scaffold(body: LigneBudgetDialog()),
        ),
      ),
    );
    await stabiliser(tester);
  }

  /// Saisit la ligne budgétaire puis la destination du trajet : la
  /// provenance n'est plus saisie (le départ est toujours Antananarivo).
  Future<void> saisirTrajet(
    WidgetTester tester, {
    required String destination,
  }) async {
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ligne budgétaire *'),
      'Carburant',
    );
    await tester.pump(const Duration(milliseconds: 120));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Lieu de destination'),
      destination,
    );
    await tester.pump(const Duration(milliseconds: 80));
  }

  Future<void> demonter(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await stabiliser(tester);
  }

  testWidgets('la distance suit la destination (Antananarivo ↔ district)', (
    tester,
  ) async {
    await pomper(tester);
    await saisirTrajet(tester, destination: 'Antsirabe I');

    expect(find.text('170'), findsWidgets, reason: 'distance aller');
    expect(find.text('340'), findsWidgets, reason: 'distance aller-retour');
    expect(tester.takeException(), isNull);
    await demonter(tester);
  });

  testWidgets('le champ de provenance a disparu (départ fixe à Tana)', (
    tester,
  ) async {
    await pomper(tester);
    await saisirTrajet(tester, destination: 'Antananarivo-Renivohitra');

    // Destination = Antananarivo (10 km aller, 20 km A/R).
    expect(find.text('10'), findsWidgets);
    expect(find.text('170'), findsNothing);
    // Plus aucun champ « Provenance » dans le formulaire carburant.
    expect(find.text('Provenance'), findsNothing);
    expect(tester.takeException(), isNull);
    await demonter(tester);
  });

  testWidgets('la confirmation du montant alloué peut être annulée', (
    tester,
  ) async {
    await pomper(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Montant alloué (Ar)'),
      '1000',
    );
    await tester.pump();
    await tester.tap(find.text('Confirmer'));
    await tester.pump();
    expect(find.text('Annuler la confirmation'), findsOneWidget);

    await tester.tap(find.text('Annuler la confirmation'));
    await tester.pump();
    expect(find.text('Confirmer'), findsOneWidget);
    await demonter(tester);
  });

  testWidgets(
      'une recherche d’un autre écran ne fausse plus le calcul (référentiel '
      'non filtré)', (tester) async {
    // Le filtre ne correspond à aucun district : le référentiel doit rester
    // complet pour que le calcul soit juste.
    await pomper(tester, recherche: 'zzz-aucun-district');
    await saisirTrajet(tester, destination: 'Antsirabe I');

    expect(find.text('340'), findsWidgets);
    expect(tester.takeException(), isNull);
    await demonter(tester);
  });
}
