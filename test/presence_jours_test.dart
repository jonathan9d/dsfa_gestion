import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsfa_gestion/data/database/database.dart';
import 'package:dsfa_gestion/presentation/providers/app_providers.dart';
import 'package:dsfa_gestion/presentation/providers/providers.dart';
import 'package:dsfa_gestion/presentation/screens/dossier_pj/presences_indemnites_screen.dart';

/// Bout en bout : les dates de présence sont cochées dans le calendrier du
/// dossier PJ et la sélection exacte est enregistrée avec l'indemnité.
void main() {
  /// Activité du 28 au 30 septembre 2026 → 3 jours.
  final debut = DateTime(2026, 9, 28);
  final fin = DateTime(2026, 9, 30);

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db
        .into(db.activites)
        .insert(
          ActivitesCompanion(
            code: const drift.Value('PSN N°1'),
            description: const drift.Value('Atelier de suivi'),
            dateDebut: drift.Value(debut),
            dateFin: drift.Value(fin),
            statut: const drift.Value('En cours'),
          ),
        );
    await db
        .into(db.participants)
        .insert(
          const ParticipantsCompanion(
            nom: drift.Value('Rakoto'),
            prenom: drift.Value('Jean'),
          ),
        );
    await db
        .into(db.activiteParticipants)
        .insert(
          const ActiviteParticipantsCompanion(
            activiteCode: drift.Value('PSN N°1'),
            participantId: drift.Value(1),
            role: drift.Value('Participant'),
          ),
        );
  });

  tearDown(() async => db.close());

  Future<void> pomper(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          // Activité déjà choisie : c'est l'état normal dans le dossier PJ.
          activiteSelectionneeProvider.overrideWith((ref) => 'PSN N°1'),
        ],
        child: const MaterialApp(
          home: Scaffold(body: PresencesIndemnitesScreen()),
        ),
      ),
    );
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> stabiliser(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('les dates cochées écrivent la fiche de présence', (
    tester,
  ) async {
    await pomper(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Rakoto Jean'), findsWidgets);
    // Aucune présence au départ.
    expect(await db.select(db.presences).get(), isEmpty);

    // Un clic sur la cellule des jours ouvre le calendrier.
    await tester.tap(find.byKey(const ValueKey('jours-activite-1')));
    await stabiliser(tester);

    await tester.tap(
      find.byKey(const ValueKey('presence-jour-2026-09-28T00:00:00.000')),
    );
    await tester.tap(
      find.byKey(const ValueKey('presence-jour-2026-09-30T00:00:00.000')),
    );
    await tester.tap(find.text('Enregistrer'));
    await stabiliser(tester);

    // La sélection non contiguë est conservée exactement.
    final presences = await db.select(db.presences).get()
      ..sort((a, b) => a.date.compareTo(b.date));
    expect(presences.length, 3, reason: '3 jours d’activité au calendrier');
    expect(presences.map((p) => p.date).toList(), [
      debut,
      debut.add(const Duration(days: 1)),
      fin,
    ]);
    expect(
      presences.map((p) => p.statut).toList(),
      ['Présent', 'Absent', 'Présent'],
      reason: 'seules les deux dates cochées sont marquées présentes',
    );

    // L'indemnité correspondante est enregistrée avec ces jours.
    final saisies = await db.select(db.indemnitesSaisies).get();
    expect(saisies.length, 1);
    expect(saisies.single.participantId, 1);
    expect(saisies.single.nombreJoursActivite, 2);
    // Règle d'or avec un délai de route nul : 2 jours × taux.
    expect(
      saisies.single.montantAlloue,
      closeTo(2 * saisies.single.taux, 0.01),
    );

    await tester.pumpWidget(const SizedBox());
    await stabiliser(tester);
  });

  testWidgets('le calendrier ne propose que les jours de l’activité', (
    tester,
  ) async {
    await pomper(tester);
    await tester.tap(find.byKey(const ValueKey('jours-activite-1')));
    await stabiliser(tester);

    expect(
      find.byKey(const ValueKey('presence-jour-2026-09-28T00:00:00.000')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('presence-jour-2026-09-30T00:00:00.000')),
      findsOneWidget,
    );
    for (final jour in [debut, debut.add(const Duration(days: 1)), fin]) {
      await tester.tap(
        find.byKey(ValueKey('presence-jour-${jour.toIso8601String()}')),
      );
    }
    await tester.tap(find.text('Enregistrer'));
    await stabiliser(tester);

    // Les trois dates de l'activité sont sélectionnables et enregistrées.
    final presences = await db.select(db.presences).get();
    expect(presences, hasLength(3));
    expect(presences.every((p) => p.statut == 'Présent'), isTrue);
    expect(await db.select(db.indemnitesSaisies).get(), hasLength(1));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    await stabiliser(tester);
  });

  testWidgets('un seul jour coché enregistre une présence', (tester) async {
    await pomper(tester);
    await tester.tap(find.byKey(const ValueKey('jours-activite-1')));
    await stabiliser(tester);

    await tester.tap(
      find.byKey(const ValueKey('presence-jour-2026-09-28T00:00:00.000')),
    );
    await tester.tap(find.text('Enregistrer'));
    await stabiliser(tester);

    final presences = await db.select(db.presences).get();
    expect(presences.where((p) => p.statut == 'Présent').length, 1);
    expect(presences.length, 3);

    await tester.pumpWidget(const SizedBox());
    await stabiliser(tester);
  });
}
