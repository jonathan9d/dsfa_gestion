import 'package:drift/drift.dart';

import '../database/database.dart';

class DepensesRepository {
  DepensesRepository(this._db);
  final AppDatabase _db;

  Stream<List<Depense>> watchAll({
    String? recherche,
    String? codeActivite,
    DateTime? du,
    DateTime? au,
  }) {
    final q = _db.select(_db.depenses);
    if ((recherche ?? '').isNotEmpty) {
      final r = '%${recherche!.trim()}%';
      q.where((t) =>
          t.designation.like(r) |
          t.codeActivite.like(r) |
          t.refPieceDepense.like(r));
    }
    if ((codeActivite ?? '').isNotEmpty) {
      q.where((t) => t.codeActivite.equals(codeActivite!));
    }
    if (du != null) {
      q.where((t) => t.dateEnregistrement.isBiggerOrEqualValue(du));
    }
    if (au != null) {
      q.where((t) => t.dateEnregistrement.isSmallerOrEqualValue(au));
    }
    q.orderBy([(t) => OrderingTerm.desc(t.dateEnregistrement)]);
    return q.watch();
  }

  Future<List<Depense>> getAll() => _db.select(_db.depenses).get();

  Future<List<Depense>> parActivite(String codeActivite) =>
      (_db.select(_db.depenses)
            ..where((t) => t.codeActivite.equals(codeActivite)))
          .get();

  Future<int> insert(DepensesCompanion c) =>
      _db.into(_db.depenses).insert(c);

  Future<void> update(int id, DepensesCompanion c) =>
      (_db.update(_db.depenses)..where((t) => t.id.equals(id))).write(c);

  Future<void> delete(int id) =>
      (_db.delete(_db.depenses)..where((t) => t.id.equals(id))).go();
}

class BanqueRepository {
  BanqueRepository(this._db);
  final AppDatabase _db;

  Stream<List<BanqueOperation>> watchAll({String? recherche, String? type}) {
    final q = _db.select(_db.banqueOperations);
    if ((recherche ?? '').isNotEmpty) {
      final r = '%${recherche!.trim()}%';
      q.where((t) =>
          t.description.like(r) | t.refPiece.like(r) | t.beneficiaire.like(r));
    }
    if ((type ?? '').isNotEmpty) q.where((t) => t.type.equals(type!));
    q.orderBy([(t) => OrderingTerm.asc(t.date)]);
    return q.watch();
  }

  Future<List<BanqueOperation>> getAll() =>
      (_db.select(_db.banqueOperations)
            ..orderBy([(t) => OrderingTerm.asc(t.date)]))
          .get();

  Future<int> insert(BanqueOperationsCompanion c) =>
      _db.into(_db.banqueOperations).insert(c);

  Future<void> update(int id, BanqueOperationsCompanion c) =>
      (_db.update(_db.banqueOperations)..where((t) => t.id.equals(id))).write(c);

  Future<void> delete(int id) =>
      (_db.delete(_db.banqueOperations)..where((t) => t.id.equals(id))).go();
}

class ReleveBancaireRepository {
  ReleveBancaireRepository(this._db);
  final AppDatabase _db;

  Stream<List<ReleveBancaireLigne>> watchAll() =>
      (_db.select(_db.releveBancaire)
            ..orderBy([(t) => OrderingTerm.asc(t.date)]))
          .watch();

  Future<List<ReleveBancaireLigne>> getAll() =>
      (_db.select(_db.releveBancaire)..orderBy([(t) => OrderingTerm.asc(t.date)]))
          .get();

  Future<int> insert(ReleveBancaireCompanion c) =>
      _db.into(_db.releveBancaire).insert(c);

  Future<void> update(int id, ReleveBancaireCompanion c) =>
      (_db.update(_db.releveBancaire)..where((t) => t.id.equals(id))).write(c);

  Future<void> delete(int id) =>
      (_db.delete(_db.releveBancaire)..where((t) => t.id.equals(id))).go();
}
