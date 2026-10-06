import 'package:drift/native.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsfa_gestion/data/database/database.dart';
import 'package:dsfa_gestion/data/repositories/activite_repository.dart';
import 'package:dsfa_gestion/data/repositories/controle_pj_repository.dart';
import 'package:dsfa_gestion/data/repositories/finance_repository.dart';
import 'package:dsfa_gestion/data/repositories/participant_repository.dart';
import 'package:dsfa_gestion/data/repositories/presence_repository.dart';
import 'package:dsfa_gestion/data/repositories/referentiel_repository.dart';
import 'package:dsfa_gestion/domain/services/controle_pj_service.dart';
import 'package:dsfa_gestion/domain/services/presence_indemnite_service.dart';
import 'package:dsfa_gestion/domain/services/rapprochement_service.dart';
import 'package:dsfa_gestion/services/excel_export_service.dart';
import 'package:dsfa_gestion/services/excel_import_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('les exports Excel se génèrent à partir des données importées', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    final activites = ActivitesRepository(database);
    final lignesBudget = LignesBudgetRepository(database);
    final participants = ParticipantsRepository(database);
    final presences = PresencesRepository(database);
    final controles = ControlesPJRepository(database);
    final depenses = DepensesRepository(database);
    final banque = BanqueRepository(database);
    final releve = ReleveBancaireRepository(database);
    final districts = DistrictsRepository(database);
    final tarifs = TarifsRepository(database);
    final listes = ListesRepository(database);

    final importer = ExcelImportService(
      db: database,
      activites: activites,
      lignesBudget: lignesBudget,
      participants: participants,
      activiteParticipants: ActiviteParticipantsRepository(database),
      presences: presences,
      controles: controles,
      depenses: depenses,
      banque: banque,
      releve: releve,
      districts: districts,
      tarifs: tarifs,
      listes: listes,
    );
    final classeur = await rootBundle.load(
      'parametres.xlsx',
    );
    importer.chargerOctets(classeur.buffer.asUint8List());
    await importer.importer();

    final presenceService = PresenceIndemniteService(
      presences: presences,
      participants: participants,
      activites: activites,
    );
    final controlePJService = ControlePJService(
      controles: controles,
      lignesBudget: lignesBudget,
      presenceService: presenceService,
    );
    final rapprochementService = RapprochementService(
      banque: banque,
      releve: releve,
    );

    final export = ExcelExportService(
      activites: activites,
      lignesBudget: lignesBudget,
      participants: participants,
      presences: presences,
      depenses: depenses,
      banque: banque,
      presenceService: presenceService,
      controlePJService: controlePJService,
      rapprochementService: rapprochementService,
    );

    final bytes = await export.exporterComplet();
    expect(bytes.length, greaterThan(2000));

    // Le classeur produit doit rester lisible et contenir la synthèse.
    final relu = Excel.decodeBytes(bytes);
    expect(relu.tables.keys, contains('Résumé'));
    expect(relu.tables.keys, contains('Activités'));
    expect(relu.tables.keys, contains('Budgets'));
  });
}
