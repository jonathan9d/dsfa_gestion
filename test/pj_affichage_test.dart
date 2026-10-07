import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsfa_gestion/data/database/database.dart';
import 'package:dsfa_gestion/domain/regles_parametres.dart';
import 'package:dsfa_gestion/presentation/providers/providers.dart';
import 'package:dsfa_gestion/presentation/screens/dossier_pj/dossier_pj_screen.dart';
import 'package:dsfa_gestion/presentation/screens/pieces_justificatives/checklist_pj_screen.dart';
import 'package:dsfa_gestion/presentation/screens/pieces_justificatives/pieces_justificatives_screen.dart';

/// Dossier PJ : **deux** onglets (présences & indemnités, pièces
/// justificatives), aucun débordement à toutes les tailles de fenêtre, et la
/// checklist affiche bien les pièces requises par rubrique.
void main() {
  late AppDatabase db;

  /// Matrice des PJ requises, réduite à deux rubriques, telle qu'elle sort de
  /// `parametres.xlsx` (feuille `PARAMETRES`, section 5).
  const regles = ReglesParametres(
    tauxIndemnites: {'Taux Perdiem chef-lieu région': 200000},
    matricePJ: [
      ReglePJRequise(
        rubrique: 'RESTAURATION',
        sousRubrique: '',
        piece: 'LOCATION DE SALLE EQUIPEE',
        obligatoire: true,
        regleDate: 'Avant activité',
        typeControle: 'DATE',
      ),
      ReglePJRequise(
        rubrique: 'RESTAURATION',
        sousRubrique: '',
        piece: 'BON DE COMMANDE',
        obligatoire: true,
        regleDate: 'Après date PV;Avant activité',
        typeControle: 'DATE',
      ),
      ReglePJRequise(
        rubrique: 'INDEMNITE',
        sousRubrique: 'INDEMNITE CHAUFFEUR',
        piece: 'FICHE DE PRESENCE',
        obligatoire: true,
        regleDate: 'Pendant activité',
        typeControle: 'DATE',
      ),
    ],
  );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    for (var i = 1; i <= 4; i++) {
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
        .into(db.activites)
        .insert(
          ActivitesCompanion(
            code: const drift.Value('PSN N°1'),
            description: const drift.Value('Atelier de suivi'),
            dateDebut: drift.Value(DateTime(2026, 9, 28)),
            dateFin: drift.Value(DateTime(2026, 9, 30)),
            district: const drift.Value('Antananarivo'),
            statut: const drift.Value('En cours'),
          ),
        );
    await db
        .into(db.lignesBudget)
        .insert(
          const LignesBudgetCompanion(
            activiteCode: drift.Value('PSN N°1'),
            ligneBudgetaire: drift.Value('Location de salle équipée'),
            typeBudget: drift.Value('Restauration'),
            montantAlloue: drift.Value(2000000),
          ),
        );
    await db
        .into(db.parametres)
        .insertOnConflictUpdate(
          ParametresCompanion.insert(
            cle: 'regles_parametres',
            valeur: drift.Value(jsonEncode(regles.toJson())),
          ),
        );
    // L'onglet « Pièces justificatives » a besoin d'une activité choisie.
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
            role: drift.Value('Chauffeur'),
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
    testWidgets('dossier PJ : les 2 onglets tiennent @ ${taille.width}'
        'x${taille.height} (${taille.width.toInt()})', (tester) async {
      await pomper(tester, taille, const DossierPjScreen());
      expect(tester.takeException(), isNull, reason: 'Onglet Présences');

      for (final onglet in [
        'Pièces justificatives',
        'Présences & indemnités',
      ]) {
        await tester.tap(find.text(onglet));
        await stabiliser(tester);
        expect(tester.takeException(), isNull, reason: 'Onglet $onglet');
      }

      // Démontage explicite puis purge du timer de fermeture des flux drift
      // (sinon le framework signale un timer en attente en fin de test).
      await tester.pumpWidget(const SizedBox());
      await stabiliser(tester);
    });
  }

  for (final taille in const [Size(1366, 768), Size(900, 620)]) {
    testWidgets('écran PJ autonome @ ${taille.width}x${taille.height}', (
      tester,
    ) async {
      await pomper(tester, taille, const PiecesJustificativesScreen());
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await stabiliser(tester);
    });
  }

  testWidgets('l’onglet PJ n’affiche que la checklist des pièces requises', (
    tester,
  ) async {
    await pomper(tester, const Size(1366, 768), const ChecklistPJScreen());
    expect(tester.takeException(), isNull);

    // Aucun des blocs de l'ancien écran de contrôle ne subsiste.
    expect(find.text('Nouveau contrôle'), findsNothing);
    expect(find.byType(DropdownButtonFormField<String?>), findsNothing);
    expect(find.textContaining('Bénéficiaire'), findsNothing);
    expect(find.textContaining('Conformité'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await stabiliser(tester);
  });

  testWidgets('la checklist regroupe les pièces par rubrique des paramètres', (
    tester,
  ) async {
    await pomper(tester, const Size(1600, 900), const ChecklistPJScreen());
    await estabiliserActivite(tester);

    expect(find.text('RESTAURATION'), findsWidgets);
    expect(find.textContaining('BON DE COMMANDE'), findsWidgets);
    expect(
      find.textContaining('Vérifier les dates selon les règles'),
      findsWidgets,
    );

    await tester.pumpWidget(const SizedBox());
    await stabiliser(tester);
  });

  testWidgets('les jours d’activité d’un participant sont modifiables', (
    tester,
  ) async {
    await pomper(tester, const Size(1600, 900), const DossierPjScreen());
    await estabiliserActivite(tester);

    // Une ligne par participant affecté.
    expect(find.text('Rakoto Jean'), findsWidgets);
    expect(find.textContaining('Jours d’activité'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
    await stabiliser(tester);
  });
}

/// Choisit l'activité « PSN N°1 » dans la liste déroulante de l'écran affiché.
Future<void> estabiliserActivite(WidgetTester tester) async {
  final liste = find.byType(DropdownButtonFormField<String>);
  if (liste.evaluate().isEmpty) return;
  await tester.tap(liste.first);
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
  final choix = find.textContaining('PSN N°1').last;
  await tester.tap(choix, warnIfMissed: false);
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}
