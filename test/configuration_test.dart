import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsfa_gestion/data/database/database.dart';
import 'package:dsfa_gestion/domain/configuration/configuration_app.dart';
import 'package:dsfa_gestion/domain/configuration/formules.dart';
import 'package:dsfa_gestion/domain/configuration/icones.dart';
import 'package:dsfa_gestion/presentation/providers/configuration_providers.dart';
import 'package:dsfa_gestion/presentation/providers/providers.dart';
import 'package:dsfa_gestion/presentation/screens/parametres/configuration/configuration_onglet.dart';
import 'package:dsfa_gestion/presentation/widgets/tableau.dart';

/// Configuration personnalisable : tout est modifiable (titres, champs,
/// formules, statuts, rubriques, onglets) **sans jamais casser** les
/// automatismes, et les modifications s'appliquent en cascade.
void main() {
  group('formules', () {
    test('évalue une formule de montant', () {
      expect(
        Formule.evaluer('nb_jr_mois * quantite * frequence * pu', {
          'nb_jr_mois': 2,
          'quantite': 3,
          'frequence': 1,
          'pu': 1000,
        }),
        6000,
      );
    });

    test('accepte les références entre crochets et les fonctions', () {
      expect(
        Formule.evaluer('[recettes] - [depenses]', {
          'recettes': 900,
          'depenses': 400,
        }),
        500,
      );
      expect(Formule.evaluer('arrondi(total * 0.2)', {'total': 1005}), 201);
      expect(
        Formule.evaluer('si(montant > 1000000, 1, 0)', {'montant': 2000000}),
        1,
      );
      expect(Formule.evaluer('max(a, b, 5)', {'a': 2, 'b': 9}), 9);
    });

    test('signale les erreurs en français', () {
      expect(
        Formule.verifier('quantite * ', champsConnus: {'quantite'}),
        isNotNull,
      );
      expect(
        Formule.verifier('champ_inconnu + 1', champsConnus: {'quantite'}),
        'Champ inconnu : « champ_inconnu ».',
      );
      expect(
        () => Formule.evaluer('1 / 0', const {}),
        throwsA(
          isA<ErreurFormule>().having(
            (e) => e.message,
            'message',
            contains('Division par zéro'),
          ),
        ),
      );
      expect(
        Formule.verifier('0,5 * 2'),
        contains('point'),
        reason: 'la virgule décimale est refusée avec une explication',
      );
    });

    test('liste les champs utilisés', () {
      expect(Formule.references('a * [total] + si(b > 1, c, 0)'), {
        'a',
        'total',
        'b',
        'c',
      });
    });
  });

  group('configuration livrée', () {
    test('contient les onglets et les champs attendus', () {
      final configuration = ConfigurationApp.parDefaut();
      expect(configuration.modules, isNotEmpty);
      final depenses = configuration.module('depenses');
      expect(depenses, isNotNull);
      // Les 3 champs ajoutés à la saisie des dépenses.
      expect(depenses!.champ('beneficiaire')?.libelle, 'Bénéficiaire');
      expect(depenses.champ('mode_paiement')?.libelle, 'Mode de paiement');
      expect(depenses.champ('reference_pj')?.libelle, 'Référence PJ');
      // Les colonnes affichées d'emblée sont exactement celles du tableau.
      expect(
        depenses.champsVisibles.map((c) => c.cle).toList(),
        containsAll(['date', 'designation', 'montant']),
      );
      expect(depenses.champ('beneficiaire')?.visible, isTrue);
    });

    test('conserve les personnalisations et ajoute les nouveautés', () {
      final configuration = ConfigurationApp.parDefaut();
      final depenses = configuration.module('depenses')!;
      final personnalisee = configuration.copyWith(
        modules: [
          for (final m in configuration.modules)
            if (m.cle == 'depenses')
              m.copyWith(
                titre: 'Mes dépenses',
                champs: [
                  for (final c in m.champs)
                    if (c.cle == 'montant')
                      c.copyWith(libelle: 'Total ligne')
                    else
                      c,
                ],
              )
            else
              m,
        ],
      );
      final relue = ConfigurationApp.fromJson(
        personnalisee.toJson(),
      ).fusionnerAvecDefauts();
      final relueDepenses = relue.module('depenses')!;
      expect(relueDepenses.titre, 'Mes dépenses');
      expect(relueDepenses.champ('montant')?.libelle, 'Total ligne');
      expect(relueDepenses.champ('beneficiaire'), isNotNull);
      // Aucun champ livré n'est perdu, même après personnalisation.
      expect(
        relueDepenses.champs.length,
        greaterThanOrEqualTo(depenses.champs.length),
      );
    });

    test('statuts et rubriques sont modifiables', () {
      final configuration = ConfigurationApp.parDefaut();
      final statut = configuration.statut('Conforme');
      expect(statut, isNotNull);
      final rouge = configuration.copyWith(
        statuts: [
          for (final s in configuration.statuts)
            if (s.valeur == 'Conforme') s.copyWith(couleur: 'FFC62828') else s,
        ],
      );
      expect(rouge.couleurStatut('Conforme'), const Color(0xFFC62828));
      // Une rubrique créée rejoint la liste et sert au classement.
      final avecRubrique = rouge.copyWith(
        rubriques: [
          ...rouge.rubriques,
          const RubriqueConfig(nom: 'FRAIS DIVERS'),
        ],
      );
      expect(avecRubrique.nomsRubriques, contains('FRAIS DIVERS'));
      final classee = avecRubrique.copyWith(
        affectationsLignes: const {'FRAIS DIVERS': 'FRAIS DIVERS'},
      );
      expect(classee.rubriquePourLigne('Frais divers'), 'FRAIS DIVERS');
    });

    test('le catalogue d\'icônes couvre les modules livrés', () {
      final configuration = ConfigurationApp.parDefaut();
      for (final module in configuration.modules) {
        expect(
          IconesApp.parCle(module.icone),
          isNotNull,
          reason: 'icône inconnue : ${module.icone} (${module.titre})',
        );
      }
    });
  });

  group('suppression en cascade', () {
    test('un champ parent emporte ses enfants et vide les formules', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });
      final notifier = container.read(configurationProvider.notifier);
      // Attend le chargement de la configuration enregistrée.
      for (var i = 0; i < 40; i++) {
        if (container.read(configurationProvider).modules.isNotEmpty) break;
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await notifier.ajouterChamp(
        'depenses',
        const ChampConfig(cle: 'parent_test', libelle: 'Parent'),
      );
      await notifier.ajouterChamp(
        'depenses',
        const ChampConfig(
          cle: 'enfant_test',
          libelle: 'Enfant',
          parent: 'parent_test',
        ),
      );
      await notifier.ajouterChamp(
        'depenses',
        const ChampConfig(
          cle: 'calcule_test',
          libelle: 'Calculé',
          type: TypeChamp.calcul,
          formule: 'parent_test * 2',
        ),
      );

      final resultat = await notifier.supprimerChamp('depenses', 'parent_test');
      expect(resultat.enfants, 1, reason: 'un champ enfant supprimé');
      expect(resultat.formules, 1, reason: 'une formule vidée');
      final module = container.read(configurationProvider).module('depenses')!;
      expect(module.champ('parent_test'), isNull);
      expect(module.champ('enfant_test'), isNull);
      expect(module.champ('calcule_test')?.formule, isNull);
      // La configuration est enregistrée : elle survit au redémarrage.
      final relue = await container
          .read(configurationRepositoryProvider)
          .charger();
      expect(relue.module('depenses')!.champ('parent_test'), isNull);
    });
  });

  group('onglet Configuration', () {
    testWidgets('les 6 sections s\'ouvrent sans erreur', (tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(() async => db.close());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const MaterialApp(
            home: Scaffold(
              body: ConfigurationOnglet(moduleInitial: 'depenses'),
            ),
          ),
        ),
      );
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 120));
      }
      expect(tester.takeException(), isNull);
      // Le module demandé est ouvert d'emblée sur ses champs.
      expect(find.text('Champs & colonnes — Dépenses'), findsOneWidget);
      expect(find.text('Bénéficiaire'), findsWidgets);

      for (final section in const [
        'Formules',
        'Statuts & couleurs',
        'Rubriques & lignes',
        'Nouveaux onglets & icônes',
        'Onglets & présentation',
      ]) {
        await tester.tap(find.text(section));
        for (var i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 120));
        }
        expect(tester.takeException(), isNull, reason: 'section « $section »');
      }
      // La section « Onglets & présentation » liste les modules livrés.
      expect(find.text('Dépenses'), findsWidgets);

      // On démonte explicitement : les flux de la base se ferment et leurs
      // minuteries sont purgées avant la fin du test (sinon « A Timer is
      // still pending » et la fermeture de la base n'en finit plus).
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 120));
    });
  });

  group('tableaux pilotés par la configuration', () {
    testWidgets('masque et renomme les colonnes', (tester) async {
      final configuration = ConfigurationApp(
        modules: [
          const ModuleConfig(
            cle: 'essai',
            titre: 'Essai',
            champs: [
              ChampConfig(cle: 'nom', libelle: 'Nom du participant', ordre: 1),
              ChampConfig(
                cle: 'secret',
                libelle: 'Donnée réservée',
                ordre: 2,
                visible: false,
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ConfigurationScope(
          configuration: configuration,
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 400,
                child: TableauGestion<({int id, String nom, String secret})>(
                  cleModule: 'essai',
                  lignes: const [(id: 1, nom: 'Amina', secret: 'confidentiel')],
                  cleLigne: (l) => l.id,
                  colonnes: [
                    ColonneTableau(
                      cle: 'nom',
                      label: 'Nom',
                      valeur: (l) => l.nom,
                    ),
                    ColonneTableau(
                      cle: 'secret',
                      label: 'Confidentiel',
                      valeur: (l) => l.secret,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 120));

      // Le titre vient de la configuration, la colonne masquée disparaît.
      expect(find.text('Nom du participant'), findsOneWidget);
      expect(find.text('Confidentiel'), findsNothing);
      expect(find.text('confidentiel'), findsNothing);
      expect(find.text('Amina'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 120));
    });
  });
}
