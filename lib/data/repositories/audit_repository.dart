import 'package:drift/drift.dart';

import '../database/database.dart';

/// Journal d'audit : trace les modifications (utilisateur, action, entité,
/// ancienne/nouvelle valeur).
class AuditRepository {
  AuditRepository(this._db);
  final AppDatabase _db;

  Future<void> log({
    required String action,
    required String entite,
    String? entiteId,
    String? champ,
    Object? ancienneValeur,
    Object? nouvelleValeur,
    String utilisateur = 'systeme',
  }) async {
    await _db.into(_db.journalAudit).insert(
          JournalAuditCompanion.insert(
            action: action,
            entite: entite,
            utilisateur: Value(utilisateur),
            entiteId: Value(entiteId),
            champ: Value(champ),
            ancienneValeur: Value(ancienneValeur?.toString()),
            nouvelleValeur: Value(nouvelleValeur?.toString()),
          ),
        );
  }

  Future<List<JournalAuditEntry>> recents({int limit = 200}) {
    return (_db.select(_db.journalAudit)
          ..orderBy([(t) => OrderingTerm.desc(t.dateHeure)])
          ..limit(limit))
        .get();
  }
}
