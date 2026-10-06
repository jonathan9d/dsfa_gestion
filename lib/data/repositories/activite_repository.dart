import 'package:drift/drift.dart';

import '../database/database.dart';

/// Filtres de recherche sur les activités.
class FiltreActivite {
  const FiltreActivite({
    this.recherche,
    this.annee,
    this.statut,
    this.type,
    this.district,
    this.dateDebut,
    this.dateFin,
  });

  final String? recherche;
  final int? annee;
  final String? statut;
  final String? type;
  final String? district;
  final DateTime? dateDebut;
  final DateTime? dateFin;

  bool get estVide =>
      (recherche ?? '').isEmpty &&
      annee == null &&
      statut == null &&
      type == null &&
      district == null &&
      dateDebut == null &&
      dateFin == null;
}

class ActivitesRepository {
  ActivitesRepository(this._db);
  final AppDatabase _db;

  Stream<List<Activite>> watchAll({FiltreActivite filtre = const FiltreActivite()}) {
    final q = _db.select(_db.activites);
    if ((filtre.recherche ?? '').isNotEmpty) {
      final r = '%${filtre.recherche!.trim()}%';
      q.where((t) => t.code.like(r) | t.description.like(r));
    }
    if (filtre.annee != null) q.where((t) => t.annee.equals(filtre.annee!));
    if ((filtre.statut ?? '').isNotEmpty) {
      q.where((t) => t.statut.equals(filtre.statut!));
    }
    if ((filtre.type ?? '').isNotEmpty) {
      q.where((t) => t.type.equals(filtre.type!));
    }
    if ((filtre.district ?? '').isNotEmpty) {
      q.where((t) => t.district.equals(filtre.district!));
    }
    if (filtre.dateDebut != null) {
      q.where((t) => t.dateDebut.isBiggerOrEqualValue(filtre.dateDebut!));
    }
    if (filtre.dateFin != null) {
      q.where((t) => t.dateFin.isSmallerOrEqualValue(filtre.dateFin!));
    }
    q.orderBy([(t) => OrderingTerm.desc(t.dateDebut)]);
    return q.watch();
  }

  Future<List<Activite>> getAll() =>
      (_db.select(_db.activites)..orderBy([(t) => OrderingTerm.asc(t.code)]))
          .get();

  Future<Activite?> parCode(String code) => (_db.select(_db.activites)
        ..where((t) => t.code.equals(code))
        ..limit(1))
      .getSingleOrNull();

  Future<Activite?> parId(int id) => (_db.select(_db.activites)
        ..where((t) => t.id.equals(id))
        ..limit(1))
      .getSingleOrNull();

  Future<int> insert(ActivitesCompanion c) =>
      _db.into(_db.activites).insert(c);

  Future<void> update(int id, ActivitesCompanion c) =>
      (_db.update(_db.activites)..where((t) => t.id.equals(id))).write(c);

  /// Marqueur des lignes du journal des dépenses créées automatiquement pour
  /// les indemnités (`JournalDepensesService.marqueurIndemnite`).
  static const marqueurIndemnites = 'AUTO-INDEMNITES';

  /// Supprime une activité **et tout ce qui en dépend**.
  ///
  /// Lignes budgétaires, affectations de participants, présences, saisies
  /// d'indemnités, contrôles PJ et lignes de dépense générées automatiquement
  /// (contrôles PJ et indemnités) sont retirés dans la même transaction : un
  /// dossier partiellement supprimé fausserait le tableau de bord et le
  /// rapport financier.
  Future<void> delete(int id) async {
    final activite = await parId(id);
    if (activite == null) {
      await (_db.delete(_db.activites)..where((t) => t.id.equals(id))).go();
      return;
    }
    final code = activite.code;
    await _db.transaction(() async {
      final controles = await (_db.select(
        _db.controlesPJ,
      )..where((t) => t.activiteCode.equals(code))).get();
      for (final c in controles) {
        await (_db.delete(
          _db.depenses,
        )..where((t) => t.controlePJId.equals(c.id))).go();
      }
      await (_db.delete(
        _db.controlesPJ,
      )..where((t) => t.activiteCode.equals(code))).go();
      await (_db.delete(_db.depenses)..where(
            (t) =>
                t.codeActivite.equals(code) &
                t.refDecaissement.equals(marqueurIndemnites),
          ))
          .go();
      await (_db.delete(
        _db.indemnitesSaisies,
      )..where((t) => t.activiteCode.equals(code))).go();
      await (_db.delete(
        _db.presences,
      )..where((t) => t.activiteCode.equals(code))).go();
      await (_db.delete(
        _db.activiteParticipants,
      )..where((t) => t.activiteCode.equals(code))).go();
      await (_db.delete(
        _db.lignesBudget,
      )..where((t) => t.activiteCode.equals(code))).go();
      await (_db.delete(_db.activites)..where((t) => t.id.equals(id))).go();
    });
  }

  /// Codes d'activité distincts (pour les listes déroulantes).
  Future<List<String>> codes() async {
    final rows =
        await _db.customSelect('SELECT code FROM activites ORDER BY code').get();
    return rows.map((r) => r.read<String>('code')).toList();
  }
}

class LignesBudgetRepository {
  LignesBudgetRepository(this._db);
  final AppDatabase _db;

  Stream<List<LigneBudget>> watchParActivite(String activiteCode) =>
      (_db.select(_db.lignesBudget)
            ..where((t) => t.activiteCode.equals(activiteCode))
            ..orderBy([(t) => OrderingTerm.asc(t.ligneBudgetaire)]))
          .watch();

  Stream<List<LigneBudget>> watchAll({String? recherche}) {
    final q = _db.select(_db.lignesBudget);
    if ((recherche ?? '').isNotEmpty) {
      final r = '%${recherche!.trim()}%';
      q.where((t) => t.activiteCode.like(r) | t.ligneBudgetaire.like(r));
    }
    q.orderBy([
      (t) => OrderingTerm.asc(t.activiteCode),
      (t) => OrderingTerm.asc(t.ligneBudgetaire),
    ]);
    return q.watch();
  }

  Future<List<LigneBudget>> getAll() => _db.select(_db.lignesBudget).get();

  Future<List<LigneBudget>> parActivite(String activiteCode) =>
      (_db.select(_db.lignesBudget)
            ..where((t) => t.activiteCode.equals(activiteCode)))
          .get();

  Future<int> insert(LignesBudgetCompanion c) =>
      _db.into(_db.lignesBudget).insert(c);

  Future<void> update(int id, LignesBudgetCompanion c) =>
      (_db.update(_db.lignesBudget)..where((t) => t.id.equals(id))).write(c);

  Future<void> delete(int id) =>
      (_db.delete(_db.lignesBudget)..where((t) => t.id.equals(id))).go();

  Future<void> deleteParActivite(String activiteCode) =>
      (_db.delete(_db.lignesBudget)
            ..where((t) => t.activiteCode.equals(activiteCode)))
          .go();
}