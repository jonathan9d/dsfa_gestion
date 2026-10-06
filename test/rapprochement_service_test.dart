import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dsfa_gestion/data/database/database.dart';
import 'package:dsfa_gestion/data/repositories/finance_repository.dart';
import 'package:dsfa_gestion/domain/services/rapprochement_service.dart';
import 'package:dsfa_gestion/domain/statuts.dart';

void main() {
  test(
    'apparie une seule ligne de relevé par opération, même si la référence se répète',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final banque = BanqueRepository(database);
      final releve = ReleveBancaireRepository(database);
      final date = DateTime(2026, 10, 3);

      await banque.insert(
        BanqueOperationsCompanion.insert(
          date: date,
          refPiece: const Value('REF-1'),
          description: const Value('Opération 100'),
          recettes: const Value(100),
        ),
      );
      await banque.insert(
        BanqueOperationsCompanion.insert(
          date: date,
          refPiece: const Value('REF-1'),
          description: const Value('Opération 200'),
          recettes: const Value(200),
        ),
      );
      await releve.insert(
        ReleveBancaireCompanion.insert(
          date: Value(date),
          reference: const Value('REF-1'),
          credit: const Value(200),
        ),
      );
      await releve.insert(
        ReleveBancaireCompanion.insert(
          date: Value(date),
          reference: const Value('REF-1'),
          credit: const Value(100),
        ),
      );

      final resultat = await RapprochementService(
        banque: banque,
        releve: releve,
      ).calculer();

      expect(resultat.lignes, hasLength(2));
      expect(
        resultat.lignes.map((ligne) => ligne.statut),
        everyElement(StatutRapprochement.rapproche),
      );
    },
  );
}
