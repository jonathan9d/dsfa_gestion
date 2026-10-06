import 'package:drift/drift.dart';

import '../database/database.dart';

/// Référentiel géographique (districts).
class DistrictsRepository {
  DistrictsRepository(this._db);
  final AppDatabase _db;

  Stream<List<District>> watchAll({String? recherche, String? region}) {
    final q = _db.select(_db.districts);
    if (recherche != null && recherche.trim().isNotEmpty) {
      final r = '%${recherche.trim()}%';
      q.where((t) => t.nom.like(r) | t.region.like(r));
    }
    if (region != null && region.isNotEmpty) {
      q.where((t) => t.region.equals(region));
    }
    q.orderBy([(t) => OrderingTerm.asc(t.region), (t) => OrderingTerm.asc(t.nom)]);
    return q.watch();
  }

  Future<List<District>> getAll() =>
      (_db.select(_db.districts)..orderBy([(t) => OrderingTerm.asc(t.nom)]))
          .get();

  Future<District?> parNom(String nom) => (_db.select(_db.districts)
        ..where((t) => t.nom.equals(nom))
        ..limit(1))
      .getSingleOrNull();

  Future<List<String>> regions() async {
    final rows = await _db
        .customSelect('SELECT DISTINCT region FROM districts ORDER BY region')
        .get();
    return rows.map((r) => r.read<String>('region')).toList();
  }

  Future<int> insert(DistrictsCompanion c) =>
      _db.into(_db.districts).insert(c);

  Future<void> update(int id, DistrictsCompanion c) =>
      (_db.update(_db.districts)..where((t) => t.id.equals(id))).write(c);

  Future<void> upsert(DistrictsCompanion c) async {
    final existing = await parNom(c.nom.value);
    if (existing == null) {
      await _db.into(_db.districts).insert(c);
    } else {
      await (_db.update(_db.districts)..where((t) => t.id.equals(existing.id)))
          .write(c);
    }
  }

  Future<void> delete(int id) =>
      (_db.delete(_db.districts)..where((t) => t.id.equals(id))).go();
}

/// Référentiel des tarifs.
class TarifsRepository {
  TarifsRepository(this._db);
  final AppDatabase _db;

  Stream<List<TarifReferentiel>> watchAll({String? recherche}) {
    final q = _db.select(_db.referentielTarifs);
    if (recherche != null && recherche.trim().isNotEmpty) {
      final r = '%${recherche.trim()}%';
      q.where((t) => t.ligneBudgetaire.like(r) | t.rubrique.like(r));
    }
    q.orderBy([(t) => OrderingTerm.asc(t.rubrique), (t) => OrderingTerm.asc(t.ligneBudgetaire)]);
    return q.watch();
  }

  Future<List<TarifReferentiel>> getAll({bool actifsSeulement = false}) {
    final q = _db.select(_db.referentielTarifs);
    if (actifsSeulement) q.where((t) => t.actif.equals(true));
    q.orderBy([(t) => OrderingTerm.asc(t.ligneBudgetaire)]);
    return q.get();
  }

  /// Tarif actif correspondant à une ligne budgétaire et une zone.
  Future<TarifReferentiel?> trouver({
    required String ligneBudgetaire,
    String? zone,
    String? typeActivite,
  }) async {
    final tous = await getAll(actifsSeulement: true);
    final candidats = tous.where((t) =>
        t.ligneBudgetaire.toUpperCase() == ligneBudgetaire.toUpperCase());
    if (candidats.isEmpty) return null;
    if (zone != null) {
      final parZone = candidats.where(
          (t) => t.zone.toUpperCase() == zone.toUpperCase());
      if (parZone.isNotEmpty) return parZone.first;
    }
    if (typeActivite != null) {
      final parType = candidats.where(
          (t) => t.typeActivite.toUpperCase() == typeActivite.toUpperCase());
      if (parType.isNotEmpty) return parType.first;
    }
    return candidats.first;
  }

  Future<int> insert(ReferentielTarifsCompanion c) =>
      _db.into(_db.referentielTarifs).insert(c);

  Future<void> update(int id, ReferentielTarifsCompanion c) =>
      (_db.update(_db.referentielTarifs)..where((t) => t.id.equals(id)))
          .write(c);

  Future<void> delete(int id) =>
      (_db.delete(_db.referentielTarifs)..where((t) => t.id.equals(id))).go();
}

/// Listes de valeurs de référence.
class ListesRepository {
  ListesRepository(this._db);
  final AppDatabase _db;

  Stream<List<ReferenceValeur>> watchCategorie(String categorie) =>
      (_db.select(_db.referenceValeurs)
            ..where((t) => t.categorie.equals(categorie) & t.actif.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.ordre)]))
          .watch();

  Future<List<ReferenceValeur>> parCategorie(String categorie) =>
      (_db.select(_db.referenceValeurs)
            ..where((t) => t.categorie.equals(categorie) & t.actif.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.ordre)]))
          .get();

  Future<List<String>> valeurs(String categorie) async =>
      (await parCategorie(categorie)).map((e) => e.valeur).toList();

  Stream<List<ReferenceValeur>> watchAll() =>
      (_db.select(_db.referenceValeurs)
            ..orderBy([
              (t) => OrderingTerm.asc(t.categorie),
              (t) => OrderingTerm.asc(t.ordre),
            ]))
          .watch();

  Future<int> insert(ReferenceValeursCompanion c) =>
      _db.into(_db.referenceValeurs).insert(c);

  Future<void> update(int id, ReferenceValeursCompanion c) =>
      (_db.update(_db.referenceValeurs)..where((t) => t.id.equals(id))).write(c);

  Future<void> delete(int id) =>
      (_db.delete(_db.referenceValeurs)..where((t) => t.id.equals(id))).go();
}

/// Paramètres clé/valeur.
class ParametresRepository {
  ParametresRepository(this._db);
  final AppDatabase _db;

  Future<Map<String, String>> tous() async {
    final rows = await _db.select(_db.parametres).get();
    return {for (final r in rows) r.cle: r.valeur};
  }

  Future<String?> lire(String cle) async => (_db.select(_db.parametres)
        ..where((t) => t.cle.equals(cle))
        ..limit(1))
      .getSingleOrNull()
      .then((v) => v?.valeur);

  Future<void> ecrire(String cle, String valeur) async {
    await _db.into(_db.parametres).insertOnConflictUpdate(
          ParametresCompanion.insert(cle: cle, valeur: Value(valeur)),
        );
  }
}
