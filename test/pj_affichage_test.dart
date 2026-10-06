import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsfa_gestion/data/database/database.dart';
import 'package:dsfa_gestion/presentation/providers/providers.dart';
import 'package:dsfa_gestion/presentation/screens/dossier_pj/dossier_pj_screen.dart';
import 'package:dsfa_gestion/presentation/screens/pieces_justificatives/pieces_justificatives_screen.dart';

/// Rendu réel du dossier PJ : aucun débordement (« écrasement ») sur les trois
/// onglets, et le bas de la liste des pièces justificatives doit rester
/// atteignable au défilement.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    for (var i = 1; i <= 14; i++) {
      await db
          .into(db.controlesPJ)
          .insert(
            ControlesPJCompanion(
              activiteCode: drift.Value('PSN N°$i'),
              ligneBudgetaire: const drift.Value(
                'Indemnité des équipes centraux et régionaux',
              ),
              beneficiaire: drift.Value('Bénéficiaire $i'),
              typePJ: const drift.Value('État de paiement'),
              datePJ: drift.Value(DateTime(2026, 10, 1 + (i % 5))),
              dateDebutActivite: drift.Value(DateTime(2026, 9, 28)),
              dateFinActivite: drift.Value(DateTime(2026, 9, 30)),
              montantAlloue: drift.Value(1000000 + i * 1000),
              montantPaye: drift.Value(1000000 + i * 1000),
              montantPJ: drift.Value(1000000 + i * 1000),
              pjRecue: const drift.Value('Oui'),
              pjConforme: const drift.Value('Oui'),
            ),
          );
    }
    await db
        .into(db.lignesBudget)
        .insert(
          const LignesBudgetCompanion(
            activiteCode: drift.Value('PSN N°1'),
            ligneBudgetaire: drift.Value(
              'Indemnité des équipes centraux et régionaux',
            ),
            montantAlloue: drift.Value(2000000),
          ),
        );
  });

  tearDown(() async => db.close());

  /// `pumpAndSettle` est proscrit ici : plusieurs écrans affichent un
  /// indicateur de chargement animé en boucle. On avance donc le temps
  /// explicitement pour laisser les flux se résoudre.
  Future<void> stabiliser(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> pomper(WidgetTester tester, Size taille, Widget ecran) async {
    tester.view.physicalSize = taille;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: Scaffold(body: ecran)),
      ),
    );
    await stabiliser(tester);
  }

  for (final taille in const [
    Size(1600, 900),
    Size(1366, 768),
    Size(1100, 700),
    Size(900, 620),
    Size(800, 600),
    Size(700, 520),
  ]) {
    testWidgets('dossier PJ : les 3 onglets tiennent @ ${taille.width}'
        'x${taille.height} (${taille.width.toInt()})', (tester) async {
      await pomper(tester, taille, const DossierPjScreen());
      expect(tester.takeException(), isNull, reason: 'Onglet Présences');

      for (final onglet in ['Indemnités', 'Pièces justificatives']) {
        await tester.tap(find.text(onglet));
        await stabiliser(tester);
        expect(tester.takeException(), isNull, reason: 'Onglet $onglet');
      }

      // La barre d'outils de l'onglet PJ est bien rendue (elle est hors de la
      // zone défilante, donc toujours construite).
      expect(find.text('Nouveau contrôle'), findsOneWidget);

      // Démontage explicite puis purge du timer de fermeture des flux drift
      // (sinon le framework signale un timer en attente en fin de test).
      await tester.pumpWidget(const SizedBox());
      await stabiliser(tester);
    });
  }

  for (final taille in const [Size(1366, 768), Size(900, 620)]) {
    testWidgets('écran PJ autonome @ ${taille.width}x${taille.height}',
        (tester) async {
      await pomper(tester, taille, const PiecesJustificativesScreen());
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await stabiliser(tester);
    });
  }

  testWidgets('le bas de la liste des PJ est atteignable par défilement',
      (tester) async {
    await pomper(tester, const Size(1366, 768), const DossierPjScreen());
    await tester.tap(find.text('Pièces justificatives'));
    await stabiliser(tester);

    expect(
      find.textContaining('Bénéficiaire 14'),
      findsNothing,
      reason: 'La liste défile : le dernier dossier est hors écran.',
    );

    // Plusieurs glissements successifs : sur une liste paresseuse, un seul
    // glissement très long peut s'arrêter avant la fin.
    for (var i = 0; i < 12; i++) {
      await tester.drag(
        find.byType(ListView).first,
        const Offset(0, -600),
      );
      await tester.pump(const Duration(milliseconds: 40));
    }
    await stabiliser(tester);

    expect(
      find.textContaining('Bénéficiaire 14'),
      findsAtLeastNWidgets(1),
      reason: 'Après défilement, le dernier dossier doit être visible.',
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    await stabiliser(tester);
  });
}
