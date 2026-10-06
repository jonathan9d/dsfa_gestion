import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsfa_gestion/data/database/database.dart';
import 'package:dsfa_gestion/services/sauvegarde_service.dart';

/// Régression du bug « La restauration a échoué » :
/// sur Windows, un fichier SQLite ne peut pas être écrasé tant que la
/// connexion le tient ouvert. La restauration doit fermer la connexion
/// puis remplacer le fichier.
void main() {
  late Directory dir;

  setUp(() {
    dir = Directory('${Directory.systemTemp.path}/dsfa_restauration_test');
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    dir.createSync(recursive: true);
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  Future<void> creerTable(AppDatabase db) async {
    await db.customSelect(
      'CREATE TABLE IF NOT EXISTS t (id INTEGER PRIMARY KEY, n TEXT)',
    ).get();
  }

  Future<List<String>> lire(AppDatabase db) async {
    final lignes = await db.customSelect('SELECT n FROM t ORDER BY id').get();
    return lignes.map((l) => l.read<String>('n')).toList();
  }

  test('restaurerDepuis remplace la base malgré une connexion ouverte',
      () async {
    final base = File('${dir.path}/DSFA.db.sqlite');
    final db = AppDatabase.forTesting(NativeDatabase(base));
    await creerTable(db);
    await db.customSelect("INSERT INTO t (n) VALUES ('ancienne')").get();

    final sauvegarde = File('${dir.path}/sauvegarde.db');
    await base.copy(sauvegarde.path);

    await db.customSelect("INSERT INTO t (n) VALUES ('ajoutee')").get();
    expect(await lire(db), ['ancienne', 'ajoutee']);

    await db.restaurerDepuis(sauvegarde);

    // Le fichier transitoire ne doit pas subsister.
    expect(File('${base.path}.restauration').existsSync(), isFalse);

    final rouverte = AppDatabase.forTesting(NativeDatabase(base));
    expect(await lire(rouverte), ['ancienne']);
    await rouverte.close();
    await db.close();
  });

  test('SauvegardeService.restaurer fonctionne avec la base ouverte',
      () async {
    final base = File('${dir.path}/DSFA.db.sqlite');
    final db = AppDatabase.forTesting(NativeDatabase(base));
    await creerTable(db);
    await db.customSelect("INSERT INTO t (n) VALUES ('avant')").get();

    final service = SauvegardeService(db);
    final copie = await service.sauvegarder();
    expect(copie.existsSync(), isTrue);

    await db.customSelect("INSERT INTO t (n) VALUES ('apres')").get();
    expect(await lire(db), ['avant', 'apres']);

    final secours = await service.restaurer(copie);
    expect(secours.existsSync(), isTrue);

    final rouverte = AppDatabase.forTesting(NativeDatabase(base));
    expect(await lire(rouverte), ['avant'],
        reason: 'les données de la sauvegarde doivent être rétablies');
    await rouverte.close();
    await db.close();
  });

  test('une sauvegarde dans la même seconde est numérotée', () async {
    final base = File('${dir.path}/DSFA.db.sqlite');
    final db = AppDatabase.forTesting(NativeDatabase(base));
    await creerTable(db);

    final service = SauvegardeService(db);
    final a = await service.sauvegarder();
    final b = await service.sauvegarder();
    expect(a.path == b.path, isFalse);
    expect((await service.lister()).length, greaterThanOrEqualTo(2));
    await db.close();
  });
}
