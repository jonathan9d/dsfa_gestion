import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:dsfa_gestion/data/database/database.dart';
import 'package:dsfa_gestion/data/repositories/referentiel_repository.dart';
import 'package:dsfa_gestion/presentation/providers/providers.dart';
import 'package:dsfa_gestion/presentation/router/app_router.dart';
import 'package:dsfa_gestion/presentation/screens/authentification/accueil_screen.dart';
import 'package:dsfa_gestion/presentation/theme/app_theme.dart';
import 'package:dsfa_gestion/presentation/theme/comportement_defilement.dart';

/// Marqueur affiché à la place du formulaire de connexion : il prouve que
/// l'écran d'accueil mène bien au parcours d'identifiants.
const _marqueurLogin = 'FORMULAIRE DE CONNEXION';

/// Salutation attendue selon l'heure locale, comme l'écran d'accueil.
String _salutationAttendue() =>
    DateTime.now().hour < 18 ? 'Bonjour' : 'Bonsoir';

Future<AppDatabase> _basePrete() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await ParametresRepository(db).ecrire(
    'classeur_reference_initialise_v1',
    'test',
  );
  // Un compte administrateur existe déjà : l'écran d'accueil accueille
  // l'utilisateur (« Continuer ») au lieu de proposer de créer le compte.
  await db
      .into(db.utilisateurs)
      .insert(
        UtilisateursCompanion.insert(
          identifiant: 'utilisateur-test',
          nom: 'Utilisateur test',
          role: const drift.Value('ADMIN'),
          motDePasseHash: const drift.Value('hash-factice'),
        ),
      );
  return db;
}

GoRouter _routeur() => GoRouter(
  initialLocation: AppRoutes.accueil,
  routes: [
    GoRoute(
      path: AppRoutes.accueil,
      builder: (_, _) => const AccueilScreen(),
    ),
    GoRoute(
      path: AppRoutes.connexion,
      builder: (_, _) => const Scaffold(
        body: Center(child: Text(_marqueurLogin)),
      ),
    ),
  ],
);

Widget _application(AppDatabase db) => ProviderScope(
  overrides: [databaseProvider.overrideWithValue(db)],
  child: MaterialApp.router(
    theme: AppTheme.light(),
    scrollBehavior: const ComportementDefilement(),
    routerConfig: _routeur(),
  ),
);

Future<void> _ouvrir(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(_application(db));
  // L'animation d'apparition de l'accueil dure moins d'une seconde.
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Laisse la transition de route (et le routeur) se stabiliser : plusieurs
/// frames sont nécessaires pour que la nouvelle page soit réellement montée.
Future<void> _laisserNaviguer(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void _taille(WidgetTester tester, double largeur, double hauteur) {
  tester.view.physicalSize = Size(largeur, hauteur);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('accueil : la salutation précède la connexion automatiquement', (
    tester,
  ) async {
    _taille(tester, 1366, 768);
    final db = await _basePrete();
    addTearDown(db.close);

    await _ouvrir(tester, db);

    expect(tester.takeException(), isNull);
    // L'écran salue, sans demander le moindre identifiant et sans bouton.
    expect(find.text(_salutationAttendue()), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Continuer'), findsNothing);
    expect(find.text('Appuyez sur Entrée pour continuer'), findsNothing);
    expect(find.text(_marqueurLogin), findsNothing);

    // Passée la salutation, la page de connexion s'ouvre d'elle-même.
    await _laisserNaviguer(tester);
    await _laisserNaviguer(tester);
    expect(find.text(_marqueurLogin), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('accueil : la touche Entrée ne déclenche plus rien', (
    tester,
  ) async {
    _taille(tester, 1366, 768);
    final db = await _basePrete();
    addTearDown(db.close);

    await _ouvrir(tester, db);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    // Encore dans la fenêtre des 1,5 s : l'appui n'a rien déclenché.
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text(_salutationAttendue()), findsOneWidget);
    expect(find.text(_marqueurLogin), findsNothing);

    // …jusqu'au passage automatique vers la connexion.
    await _laisserNaviguer(tester);
    await _laisserNaviguer(tester);
    expect(find.text(_marqueurLogin), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('accueil : aucun débordement à toutes les tailles de fenêtre', (
    tester,
  ) async {
    final db = await _basePrete();
    addTearDown(db.close);

    for (final taille in const [
      Size(1600, 900),
      Size(1366, 768),
      Size(1024, 700),
      Size(800, 560),
      Size(520, 420),
    ]) {
      _taille(tester, taille.width, taille.height);
      await _ouvrir(tester, db);
      expect(
        tester.takeException(),
        isNull,
        reason: 'débordement à ${taille.width}×${taille.height}',
      );
      // La salutation reste visible : rien n'est poussé hors de la fenêtre.
      expect(find.text(_salutationAttendue()), findsOneWidget);
      final position = tester.getRect(find.text(_salutationAttendue()));
      expect(position.top, greaterThanOrEqualTo(0));
      expect(position.bottom, lessThanOrEqualTo(taille.height));
    }
    await tester.pumpWidget(const SizedBox());
  });
}
