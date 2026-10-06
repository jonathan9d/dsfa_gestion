import 'package:drift/drift.dart';

import '../database/database.dart';

class ParticipantsRepository {
  ParticipantsRepository(this._db);
  final AppDatabase _db;

  Stream<List<Participant>> watchAll({String? recherche, bool? actif}) {
    final q = _db.select(_db.participants);
    if ((recherche ?? '').isNotEmpty) {
      final r = '%${recherche!.trim()}%';
      q.where((t) =>
          t.nom.like(r) | t.prenom.like(r) | t.structure.like(r) | t.fonction.like(r));
    }
    if (actif != null) q.where((t) => t.actif.equals(actif));
    q.orderBy([(t) => OrderingTerm.asc(t.nom), (t) => OrderingTerm.asc(t.prenom)]);
    return q.watch();
  }

  Future<List<Participant>> getAll() =>
      (_db.select(_db.participants)..orderBy([(t) => OrderingTerm.asc(t.nom)]))
          .get();

  Future<Participant?> parId(int id) => (_db.select(_db.participants)
        ..where((t) => t.id.equals(id))
        ..limit(1))
      .getSingleOrNull();

  Future<List<Participant>> parActivite(String activiteCode) async {
    final query = _db.select(_db.participants).join([
      innerJoin(
        _db.activiteParticipants,
        _db.activiteParticipants.participantId.equalsExp(_db.participants.id),
      ),
    ])
      ..where(_db.activiteParticipants.activiteCode.equals(activiteCode));
    final rows = await query.get();
    return rows.map((r) => r.readTable(_db.participants)).toList();
  }

  Future<int> insert(ParticipantsCompanion c) =>
      _db.into(_db.participants).insert(c);

  Future<void> update(int id, ParticipantsCompanion c) =>
      (_db.update(_db.participants)..where((t) => t.id.equals(id))).write(c);

  Future<void> delete(int id) =>
      (_db.delete(_db.participants)..where((t) => t.id.equals(id))).go();
}

class ActiviteParticipantsRepository {
  ActiviteParticipantsRepository(this._db);
  final AppDatabase _db;

  Future<List<ActiviteParticipant>> parActivite(String activiteCode) =>
      (_db.select(_db.activiteParticipants)
            ..where((t) => t.activiteCode.equals(activiteCode)))
          .get();

  Stream<List<ActiviteParticipant>> watchParActivite(String activiteCode) =>
      (_db.select(_db.activiteParticipants)
            ..where((t) => t.activiteCode.equals(activiteCode)))
          .watch();

  Future<int> insert(ActiviteParticipantsCompanion c) =>
      _db.into(_db.activiteParticipants).insert(c);

  Future<void> supprimerAffectation(int id) =>
      (_db.delete(_db.activiteParticipants)..where((t) => t.id.equals(id))).go();

  Future<void> supprimerParActivite(String activiteCode) =>
      (_db.delete(_db.activiteParticipants)
            ..where((t) => t.activiteCode.equals(activiteCode)))
          .go();
}
