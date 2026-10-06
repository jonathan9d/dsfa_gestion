import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsfa_gestion/data/database/database.dart';
import 'package:dsfa_gestion/data/repositories/activite_repository.dart';
import 'package:dsfa_gestion/data/repositories/controle_pj_repository.dart';
import 'package:dsfa_gestion/data/repositories/finance_repository.dart';
import 'package:dsfa_gestion/data/repositories/presence_repository.dart';
import 'package:dsfa_gestion/domain/services/journal_depenses_service.dart';

/// Cohérence métier de la suppression : un gestionnaire ne doit jamais
/// retrouver de lignes orphelines (présences, indemnités, contrôles PJ,
/// dépenses automatiques) après la suppression d'une activité, ni une ligne
/// d'indemnités périmée dans le journal.
void main() {
  late AppDatabase db;
  late ActivitesRepository activites;
  late LignesBudgetRepository lignesBudget;
  late PresencesRepository presences;
  late IndemnitesSaisiesRepository indemnites;
  late ControlesPJRepository controles;
  late DepensesRepository depenses;
  late JournalDepensesService journal;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    activites = ActivitesRepository(db);
    lignesBudget = LignesBudgetRepository(db);
    presences = PresencesRepository(db);
    indemnites = IndemnitesSaisiesRepository(db);
    controles = ControlesPJRepository(db);
    depenses = DepensesRepository(db);
    journal = JournalDepensesService(depenses: depenses, activites: activites);

    await activites.insert(
      const ActivitesCompanion(
        code: drift.Value('ACT-1'),
        description: drift.Value('Atelier'),
      ),
    );
    await activites.insert(
      const ActivitesCompanion(
        code: drift.Value('ACT-2'),
        description: drift.Value('Réunion'),
      ),
    );
  });

  tearDown(() async => db.close());

  Future<void> remplirActivite(String code) async {
    await lignesBudget.insert(
      LignesBudgetCompanion(
        activiteCode: drift.Value(code),
        ligneBudgetaire: const drift.Value('Indemnité des équipes'),
        montantAlloue: const drift.Value(1000000),
      ),
    );
    final participant = await db
        .into(db.participants)
        .insert(const ParticipantsCompanion(nom: drift.Value('Rakoto')));
    await presences.insert(
      PresencesCompanion(
        activiteCode: drift.Value(code),
        participantId: drift.Value(participant),
        date: drift.Value(DateTime(2026, 10, 1)),
        tauxJournalier: const drift.Value(200000),
      ),
    );
    await indemnites.insert(
      IndemnitesSaisiesCompanion(
        activiteCode: drift.Value(code),
        participantNom: const drift.Value('Rakoto'),
        montantAlloue: const drift.Value(340000),
        montantPaye: const drift.Value(340000),
        taux: const drift.Value(200000),
        delaiRoute: const drift.Value(1),
      ),
    );
    final controleId = await controles.insert(
      ControlesPJCompanion(
        activiteCode: drift.Value(code),
        ligneBudgetaire: const drift.Value('Indemnité des équipes'),
        montantAlloue: const drift.Value(1000000),
        montantPaye: const drift.Value(1000000),
        montantPJ: const drift.Value(1000000),
      ),
    );
    // Dépense créée automatiquement par le dossier PJ.
    await depenses.insert(
      DepensesCompanion.insert(
        designation: const drift.Value('État de paiement'),
        pu: const drift.Value(1000000),
        codeActivite: drift.Value(code),
        controlePJId: drift.Value(controleId),
      ),
    );
    // Ligne d'indemnités créée automatiquement par l'onglet Indemnités.
    await journal.synchroniserIndemnites(
      activiteCode: code,
      montant: 340000,
    );
  }

  test('supprimer une activité retire toutes ses données liées', () async {
    await remplirActivite('ACT-1');
    await remplirActivite('ACT-2');

    // Les deux activités ont bien leurs données.
    expect(await lignesBudget.parActivite('ACT-1'), hasLength(1));
    expect(await depenses.parActivite('ACT-1'), hasLength(2));

    final aSupprimer = await activites.parCode('ACT-1');
    await activites.delete(aSupprimer!.id);

    expect(await activites.parCode('ACT-1'), isNull);
    expect(await lignesBudget.parActivite('ACT-1'), isEmpty);
    expect(await presences.parActivite('ACT-1'), isEmpty);
    expect(await indemnites.parActivite('ACT-1'), isEmpty);
    expect(
      (await controles.getAll()).where((c) => c.activiteCode == 'ACT-1'),
      isEmpty,
    );
    expect(await depenses.parActivite('ACT-1'), isEmpty);

    // L'autre activité n'est pas touchée.
    expect(await activites.parCode('ACT-2'), isNotNull);
    expect(await lignesBudget.parActivite('ACT-2'), hasLength(1));
    expect(await depenses.parActivite('ACT-2'), hasLength(2));
  });

  test('remettre les indemnités à zéro retire la ligne automatique du journal',
      () async {
    await remplirActivite('ACT-1');
    final avant = await depenses.parActivite('ACT-1');
    expect(
      avant.where(
        (d) => d.refDecaissement == JournalDepensesService.marqueurIndemnite,
      ),
      hasLength(1),
    );

    // Toutes les indemnités repassent « à payer » : plus rien de payé.
    await journal.synchroniserIndemnites(activiteCode: 'ACT-1', montant: 0);

    final apres = await depenses.parActivite('ACT-1');
    expect(
      apres.where(
        (d) => d.refDecaissement == JournalDepensesService.marqueurIndemnite,
      ),
      isEmpty,
    );
    // La dépense du dossier PJ est conservée.
    expect(apres.any((d) => d.controlePJId != null), isTrue);
  });
}
