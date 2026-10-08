import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsfa_gestion/data/database/database.dart';
import 'package:dsfa_gestion/data/repositories/authentification_repository.dart';
import 'package:dsfa_gestion/data/repositories/referentiel_repository.dart';
import 'package:dsfa_gestion/main.dart';
import 'package:dsfa_gestion/presentation/providers/providers.dart';
import 'package:dsfa_gestion/presentation/shell/app_shell.dart';

/// Dépôt d'authentification factice : évite le hachage par isolate
/// (qui ne progresse pas sous le faux temps des tests de widgets).
class _FauxAuthentification extends AuthentificationRepository {
  _FauxAuthentification(super.db, {this.compteConfigure = true});

  final bool compteConfigure;

  @override
  Future<bool> aUnCompteConfigure() async => compteConfigure;

  @override
  Future<Utilisateur?> authentifier({
    required String identifiant,
    required String motDePasse,
  }) async {
    if (identifiant.trim().toLowerCase() == 'admin' && motDePasse == 'secret') {
      return _utilisateur;
    }
    return null;
  }

  @override
  Future<Utilisateur> creerAdministrateur({
    required String identifiant,
    required String nom,
    required String motDePasse,
  }) async => _utilisateur;

  static const _utilisateur = Utilisateur(
    id: 1,
    identifiant: 'admin',
    nom: 'Admin',
    role: 'ADMIN',
    actif: true,
    motDePasseHash: 'hash-factice',
  );
}

Future<AppDatabase> _basePrete() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  // Court-circuite l'import initial du classeur.
  await ParametresRepository(
    db,
  ).ecrire('classeur_reference_initialise_v1', 'test');
  return db;
}

Future<void> _pomper(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _lancer(
  WidgetTester tester,
  AppDatabase db, {
  bool compteConfigure = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        authentificationRepositoryProvider.overrideWithValue(
          _FauxAuthentification(db, compteConfigure: compteConfigure),
        ),
      ],
      child: const DsfaGestionApp(),
    ),
  );
  await _pomper(tester);
}

void main() {
  testWidgets(
    'connexion : saisie conservée, œil, puis accès à l\'application',
    (tester) async {
      final db = await _basePrete();
      addTearDown(db.close);
      await _lancer(tester, db);

      // L'application salue d'abord sur un écran dédié ; le formulaire
      // d'identifiants vient ensuite automatiquement, sans salutation à
      // l'intérieur.
      expect(find.text('Se connecter'), findsNothing);
      // L'écran de démarrage (2,6 s) puis la salutation (1,5 s) précèdent
      // désormais le formulaire de connexion.
      for (var i = 0; i < 42; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('Se connecter'), findsOneWidget);

      // La saisie est conservée (pas de perte de caractères).
      await tester.enterText(find.byType(TextFormField).first, 'admin');
      await tester.pump();
      expect(find.text('admin'), findsOneWidget);

      // Le bouton « œil » bascule la visibilité du mot de passe.
      expect(find.byIcon(Icons.visibility_outlined), findsWidgets);
      await tester.tap(find.byIcon(Icons.visibility_outlined).first);
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsWidgets);

      await tester.enterText(find.byType(TextFormField).at(1), 'secret');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
      await _pomper(tester);

      // On est bien entré dans l'application, sans écran de chargement bloqué.
      expect(find.byType(AppShell), findsOneWidget);
      expect(find.text('Se connecter'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await _pomper(tester);
    },
  );

  test(
    'premier administrateur : les identifiants choisis permettent la connexion',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = AuthentificationRepository(db);

      expect(await repo.aUnCompteConfigure(), isFalse);
      final admin = await repo.creerAdministrateur(
        identifiant: 'gestionnaire',
        nom: 'Administrateur',
        motDePasse: 'mot-de-passe-securise',
      );
      expect(await repo.aUnCompteConfigure(), isTrue);
      expect(admin.role, 'ADMIN');

      final bon = await repo.authentifier(
        identifiant: 'gestionnaire',
        motDePasse: 'mot-de-passe-securise',
      );
      expect(bon, isNotNull);
      expect(bon!.role, 'ADMIN');

      final mauvais = await repo.authentifier(
        identifiant: 'gestionnaire',
        motDePasse: 'mauvais',
      );
      expect(mauvais, isNull);

      await expectLater(
        repo.creerAdministrateur(
          identifiant: 'autre',
          nom: 'Autre',
          motDePasse: 'autre-mot-de-passe',
        ),
        throwsA(isA<AuthentificationException>()),
      );
      final utilisateurs = await db.select(db.utilisateurs).get();
      expect(utilisateurs.length, 1);
    },
  );
}
