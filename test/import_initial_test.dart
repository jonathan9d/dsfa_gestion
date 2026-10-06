import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:dsfa_gestion/data/database/database.dart';
import 'package:dsfa_gestion/data/repositories/activite_repository.dart';
import 'package:dsfa_gestion/data/repositories/controle_pj_repository.dart';
import 'package:dsfa_gestion/data/repositories/finance_repository.dart';
import 'package:dsfa_gestion/data/repositories/participant_repository.dart';
import 'package:dsfa_gestion/data/repositories/presence_repository.dart';
import 'package:dsfa_gestion/data/repositories/referentiel_repository.dart';
import 'package:dsfa_gestion/domain/regles_parametres.dart';
import 'package:dsfa_gestion/services/excel_import_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('imports source workbook data into a clean database', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    final importer = ExcelImportService(
      db: database,
      activites: ActivitesRepository(database),
      lignesBudget: LignesBudgetRepository(database),
      participants: ParticipantsRepository(database),
      activiteParticipants: ActiviteParticipantsRepository(database),
      presences: PresencesRepository(database),
      controles: ControlesPJRepository(database),
      depenses: DepensesRepository(database),
      banque: BanqueRepository(database),
      releve: ReleveBancaireRepository(database),
      districts: DistrictsRepository(database),
      tarifs: TarifsRepository(database),
      listes: ListesRepository(database),
    );
    final classeur = await rootBundle.load(
      'parametres.xlsx',
    );
    importer.chargerOctets(classeur.buffer.asUint8List());

    final preview = importer.analyser();
    expect(preview.peutImporter, isTrue);
    final rapport = await importer.importer();

    expect((await database.select(database.districts).get()).length, greaterThan(100));
    expect((await database.select(database.referentielTarifs).get()).length, greaterThan(20));
    expect((await database.select(database.activites).get()).length, greaterThanOrEqualTo(10));
    expect((await database.select(database.lignesBudget).get()).length, greaterThanOrEqualTo(3));
    expect((await database.select(database.presences).get()).length, greaterThan(0));
    expect((await database.select(database.controlesPJ).get()).length, greaterThan(0));
    expect((await database.select(database.banqueOperations).get()).length, greaterThan(0));
    expect(rapport.totalImportees, greaterThan(100));

    final activite = await ActivitesRepository(database).parCode('PSN N°1');
    expect(activite?.dateDebut, DateTime(2026, 5, 11));
    expect(activite?.dateFin, DateTime(2026, 5, 15));

    // La feuille LISTES de parametres.xlsx ajoute la colonne FINANCEMENT :
    // la correspondance par en-tête doit la reconnaître sans décaler les
    // autres catégories (rubrique, ligne budgétaire, etc.).
    final listes = ListesRepository(database);
    final financements = await listes.valeurs('FINANCEMENT');
    expect(financements, contains('UNICEF'));
    expect(financements, contains('IPAS'));
    final lignes = await listes.valeurs('LIGNE_BUDGETAIRE');
    expect(lignes, contains('Déjeuner'));
    expect(lignes, isNot(contains('UNICEF')));

    // Tarif actualisé dans parametres.xlsx (transfert aéroport extérieur).
    final transfert = await TarifsRepository(database).trouver(
      ligneBudgetaire: 'Frais de transfert aéroport Exterieur',
    );
    expect(transfert?.tarif, 500000);

    // La feuille PARAMETRES (référence unique des règles) est parsée : taux,
    // consommations, seuils de rapportage et matrice des PJ.
    final brut = await ParametresRepository(
      database,
    ).lire(ExcelImportService.cleParametres);
    expect(brut, isNotNull);
    final regles = ReglesParametres.fromJson(
      (jsonDecode(brut!) as Map).cast<String, dynamic>(),
    );
    expect(regles.tauxIndemnites.values, contains(200000));
    expect(regles.consommationCarburant.length, greaterThanOrEqualTo(6));
    expect(regles.seuilsRapportage['UNICEF_ATTENTION'], 90);
    expect(regles.seuilsRapportage['UNICEF_BLOQUE'], 180);
    expect(regles.matricePJ.length, greaterThanOrEqualTo(60));
    expect(regles.rubriques, contains('RESTAURATION'));
    expect(regles.piecesPour('ACHAT').length, greaterThanOrEqualTo(8));
  });
}
