import 'dart:io';

import 'package:path/path.dart' as p;

import '../data/database/database.dart';

/// Erreur de sauvegarde explicite (message destiné à l'utilisateur).
class SauvegardeException implements Exception {
  SauvegardeException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Service de sauvegarde et de restauration de la base SQLite.
class SauvegardeService {
  SauvegardeService(this._db);

  final AppDatabase _db;

  /// Dossier qui contient les sauvegardes (à côté de la base).
  Future<Directory> dossierSauvegardes() async {
    final base = await _db.fichierBaseOuverte();
    final dir = Directory(p.join(base.parent.path, 'sauvegardes'));
    await dir.create(recursive: true);
    return dir;
  }

  /// Fichier de base actuellement utilisé (affiché dans l'écran Sauvegardes).
  Future<File> fichierBase() => _db.fichierBaseOuverte();

  /// Crée une sauvegarde séquencée, ou remplace la plus récente à la fermeture.
  Future<File> sauvegarder({bool automatique = false}) async {
    final source = await _db.fichierBaseOuverte();
    if (!await source.exists()) {
      throw SauvegardeException(
        'La base de données est introuvable'
        '${source.path.isEmpty ? '' : ' ($source.path)'}. '
        'Créez au moins une donnée puis relancez la sauvegarde. '
        'Si le problème persiste, redémarrez l\'application.',
      );
    }
    final dir = await dossierSauvegardes();
    final precedentes = await lister();
    var plusGrandNumero = 0;
    File? derniereSequence;
    for (final fichier in precedentes) {
      final match = RegExp(
        r'^save_(\d+)\.db$',
        caseSensitive: false,
      ).firstMatch(p.basename(fichier.path));
      final numero = int.tryParse(match?.group(1) ?? '');
      if (numero != null && numero > plusGrandNumero) {
        plusGrandNumero = numero;
        derniereSequence = fichier;
      }
    }
    File destination;
    if (automatique && precedentes.isNotEmpty) {
      destination = derniereSequence ?? precedentes.first;
    } else {
      destination = File(
        p.join(dir.path, 'save_${plusGrandNumero + 1}.db'),
      );
    }
    try {
      await source.copy(destination.path);
    } on FileSystemException catch (e) {
      throw SauvegardeException(
        'La copie de la base a échoué (${e.osError?.message ?? e.message}). '
        'Vérifiez que le dossier « ${dir.path} » est accessible.',
      );
    }
    return destination;
  }

  /// Liste les sauvegardes disponibles, de la plus récente à la plus ancienne.
  Future<List<File>> lister() async {
    final dir = await dossierSauvegardes();
    final fichiers = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.db'))
        .toList();
    final dates = <String, DateTime>{
      for (final fichier in fichiers)
        fichier.path: await fichier.lastModified(),
    };
    fichiers.sort((a, b) {
      final parDate = dates[b.path]!.compareTo(dates[a.path]!);
      return parDate != 0 ? parDate : a.path.compareTo(b.path);
    });
    return fichiers;
  }

  /// Restaure une sauvegarde.
  ///
  /// La base courante est sauvegardée au préalable (copie de secours), puis le
  /// fichier de base est remplacé. L'écran de restauration recrée ensuite la
  /// connexion pour que les données restaurées soient immédiatement visibles.
  Future<File> restaurer(File sauvegarde) async {
    if (!await sauvegarde.exists()) {
      throw SauvegardeException(
        'Le fichier de sauvegarde « ${p.basename(sauvegarde.path)} » '
        'est introuvable. Il a peut-être été déplacé ou supprimé.',
      );
    }
    final secours = await sauvegarder();
    try {
      await _db.restaurerDepuis(sauvegarde);
    } on FileSystemException catch (e) {
      // La connexion peut avoir été fermée avant l'échec : l'écran recrée
      // systématiquement la connexion après une tentative de restauration.
      throw SauvegardeException(
        'La restauration a échoué (${e.osError?.message ?? e.message}). '
        'Votre base actuelle est intacte : une sauvegarde de secours a été '
        'créée dans le dossier des sauvegardes.',
      );
    }
    return secours;
  }

  Future<void> supprimer(File fichier) async {
    if (await fichier.exists()) {
      await fichier.delete();
    }
  }
}
