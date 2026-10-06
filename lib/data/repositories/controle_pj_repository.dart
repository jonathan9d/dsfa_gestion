import 'package:drift/drift.dart';

import '../database/database.dart';

class ControlesPJRepository {
  ControlesPJRepository(this._db);
  final AppDatabase _db;

  Stream<List<ControlePJ>> watchAll({String? recherche, String? activiteCode}) {
    final q = _db.select(_db.controlesPJ);
    if ((recherche ?? '').isNotEmpty) {
      final r = '%${recherche!.trim()}%';
      q.where((t) =>
          t.beneficiaire.like(r) | t.activiteCode.like(r) | t.ligneBudgetaire.like(r));
    }
    if ((activiteCode ?? '').isNotEmpty) {
      q.where((t) => t.activiteCode.equals(activiteCode!));
    }
    q.orderBy([(t) => OrderingTerm.desc(t.datePJ)]);
    return q.watch();
  }

  Future<List<ControlePJ>> getAll() => _db.select(_db.controlesPJ).get();

  Future<List<ControlePJ>> parActivite(String activiteCode) =>
      (_db.select(_db.controlesPJ)
            ..where((t) => t.activiteCode.equals(activiteCode)))
          .get();

  Future<int> insert(ControlesPJCompanion c) =>
      _db.into(_db.controlesPJ).insert(c);

  Future<void> update(int id, ControlesPJCompanion c) =>
      (_db.update(_db.controlesPJ)..where((t) => t.id.equals(id))).write(c);

  Future<void> delete(int id) =>
      (_db.delete(_db.controlesPJ)..where((t) => t.id.equals(id))).go();
}
