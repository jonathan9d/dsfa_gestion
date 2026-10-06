import 'package:drift/drift.dart';

import '../database/database.dart';

class PresencesRepository {
  PresencesRepository(this._db);
  final AppDatabase _db;

  Stream<List<Presence>> watchParActivite(String activiteCode) =>
      (_db.select(_db.presences)
            ..where((t) => t.activiteCode.equals(activiteCode))
            ..orderBy([
              (t) => OrderingTerm.asc(t.date),
              (t) => OrderingTerm.asc(t.participantId),
            ]))
          .watch();

  Future<List<Presence>> parActivite(String activiteCode) =>
      (_db.select(_db.presences)
            ..where((t) => t.activiteCode.equals(activiteCode)))
          .get();

  Future<List<Presence>> parActiviteEtParticipant(
          String activiteCode, int participantId) =>
      (_db.select(_db.presences)
            ..where((t) =>
                t.activiteCode.equals(activiteCode) &
                t.participantId.equals(participantId)))
          .get();

  Future<Presence?> trouver(
          String activiteCode, int participantId, DateTime date) =>
      (_db.select(_db.presences)
            ..where((t) =>
                t.activiteCode.equals(activiteCode) &
                t.participantId.equals(participantId) &
                t.date.equals(date))
            ..limit(1))
          .getSingleOrNull();

  Future<List<Presence>> getAll() => _db.select(_db.presences).get();

  Future<int> insert(PresencesCompanion c) =>
      _db.into(_db.presences).insert(c);

  Future<void> upsert(PresencesCompanion c) async {
    final existante = await trouver(
      c.activiteCode.value,
      c.participantId.value,
      c.date.value,
    );
    if (existante == null) {
      await _db.into(_db.presences).insert(c);
    } else {
      await (_db.update(_db.presences)..where((t) => t.id.equals(existante.id)))
          .write(c);
    }
  }

  Future<void> update(int id, PresencesCompanion c) =>
      (_db.update(_db.presences)..where((t) => t.id.equals(id))).write(c);

  Future<void> delete(int id) =>
      (_db.delete(_db.presences)..where((t) => t.id.equals(id))).go();

  Future<void> deleteParActivite(String activiteCode) =>
      (_db.delete(_db.presences)
            ..where((t) => t.activiteCode.equals(activiteCode)))
          .go();
}

/// Saisies d'indemnités (dossier PJ ▸ onglet Indemnités).
class IndemnitesSaisiesRepository {
  IndemnitesSaisiesRepository(this._db);
  final AppDatabase _db;

  Stream<List<IndemniteSaisie>> watchParActivite(String activiteCode) =>
      (_db.select(_db.indemnitesSaisies)
            ..where((t) => t.activiteCode.equals(activiteCode))
            ..orderBy([(t) => OrderingTerm.asc(t.participantNom)]))
          .watch();

  Future<List<IndemniteSaisie>> parActivite(String activiteCode) =>
      (_db.select(_db.indemnitesSaisies)
            ..where((t) => t.activiteCode.equals(activiteCode)))
          .get();

  Future<List<IndemniteSaisie>> getAll() =>
      (_db.select(_db.indemnitesSaisies)
            ..orderBy([(t) => OrderingTerm.asc(t.activiteCode)]))
          .get();

  Future<int> insert(IndemnitesSaisiesCompanion c) =>
      _db.into(_db.indemnitesSaisies).insert(c);

  Future<void> update(int id, IndemnitesSaisiesCompanion c) =>
      (_db.update(_db.indemnitesSaisies)..where((t) => t.id.equals(id)))
          .write(c);

  Future<void> delete(int id) =>
      (_db.delete(_db.indemnitesSaisies)..where((t) => t.id.equals(id))).go();
}
