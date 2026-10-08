import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'database.g.dart';

/// Base de données locale SQLite de DSFA Gestion.
///
/// Source unique de vérité : toutes les données persistent ici et sont
/// accessibles hors ligne.
@DriftDatabase(
  tables: [
    Districts,
    ReferentielTarifs,
    ReferenceValeurs,
    Activites,
    LignesBudget,
    Participants,
    ActiviteParticipants,
    Presences,
    IndemnitesSaisies,
    ControlesPJ,
    Depenses,
    BanqueOperations,
    ReleveBancaire,
    Utilisateurs,
    JournalAudit,
    Parametres,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructeur pour les tests (base en mémoire).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIndexes();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(utilisateurs, utilisateurs.motDePasseHash);
      }
      // Version 3 : profil utilisateur (état civil, contacts, photo).
      if (from < 3) {
        await m.addColumn(utilisateurs, utilisateurs.prenomUtilisateur);
        await m.addColumn(utilisateurs, utilisateurs.fonction);
        await m.addColumn(utilisateurs, utilisateurs.email);
        await m.addColumn(utilisateurs, utilisateurs.telephone);
        await m.addColumn(utilisateurs, utilisateurs.photo);
        await m.addColumn(utilisateurs, utilisateurs.dateCreation);
        await m.addColumn(utilisateurs, utilisateurs.derniereConnexion);
      }
      // Version 4 : source de financement, type/détails de budget et
      // checklist des PJ requises.
      if (from < 4) {
        await m.addColumn(activites, activites.sourceFinancement);
        await m.addColumn(lignesBudget, lignesBudget.typeBudget);
        await m.addColumn(lignesBudget, lignesBudget.details);
        await m.addColumn(controlesPJ, controlesPJ.checklistPJ);
        await m.addColumn(depenses, depenses.controlePJId);
      }
      // Version 5 : table des saisies d'indemnités (dossier PJ).
      if (from < 5) {
        await m.createTable(indemnitesSaisies);
      }
      // Version 6 : bénéficiaire du journal des dépenses.
      if (from < 6) {
        await m.addColumn(depenses, depenses.beneficiaire);
      }
    },
  );

  Future<void> _createIndexes() async {
    // Index supplémentaires utiles aux filtres/recherches fréquents.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_presence_date ON presences (date)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_depense_date ON depenses (date_enregistrement)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_lignebudget_ligne ON lignes_budget (ligne_budgetaire)',
    );
  }

  /// Nom logique de la base.
  static const databaseName = 'DSFA.db';

  /// Nom réel du fichier créé par `drift_flutter` (`<nom>.sqlite`).
  static const nomFichier = '$databaseName.sqlite';

  /// Chemin du fichier de base de données (utilisé pour la sauvegarde).
  ///
  /// `drift_flutter` enregistre la base dans le dossier « Documents » de
  /// l'utilisateur sous le nom `<databaseName>.sqlite`.
  static Future<File> databaseFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final fichiers = [
      File(p.join(dir.path, nomFichier)),
      File(p.join(dir.path, databaseName)),
    ];
    for (final fichier in fichiers) {
      if (await fichier.exists()) return fichier;
    }
    return fichiers.first;
  }

  /// Chemin réel du fichier de la base actuellement ouverte.
  ///
  /// Interroge SQLite (`PRAGMA database_list`) : la sauvegarde porte ainsi
  /// toujours sur le bon fichier, quelle que soit la configuration.
  Future<File> fichierBaseOuverte() async {
    try {
      final lignes = await customSelect('PRAGMA database_list').get();
      for (final ligne in lignes) {
        final nom = ligne.read<String>('name');
        final chemin = ligne.read<String>('file');
        if (nom == 'main' && chemin.isNotEmpty) return File(chemin);
      }
    } catch (_) {
      // On retombe sur l'emplacement par défaut.
    }
    return databaseFile();
  }

  /// Remplace la base courante par un fichier de sauvegarde.
  ///
  /// Sur Windows, un fichier SQLite ne peut pas être écrasé tant que la
  /// connexion le tient ouvert (ce qui provoquait « La restauration a échoué »).
  /// La restauration se fait donc en plusieurs temps :
  ///  1. la sauvegarde est copiée **à côté** de la base (fichier encore ouvert
  ///     mais non modifié) ;
  ///  2. la connexion est fermée pour libérer le fichier ;
  ///  3. le fichier est remplacé d'un seul bloc (renommage atomique) ;
  ///  4. les journaux éventuels de l'ancienne base sont purgés.
  ///
  /// Si une étape échoue, la base d'origine reste intacte : l'appelant doit
  /// recréer la connexion (invalider le provider) pour poursuivre.
  Future<void> restaurerDepuis(File sauvegarde) async {
    final cible = await fichierBaseOuverte();
    await cible.parent.create(recursive: true);

    // 1. Copie de la sauvegarde dans un fichier transitoire.
    final temporaire = File('${cible.path}.restauration');
    if (await temporaire.exists()) {
      try {
        await temporaire.delete();
      } on FileSystemException catch (_) {
        // On retentera la copie ; l'erreur éventuelle est remontée ci-dessous.
      }
    }
    await sauvegarde.copy(temporaire.path);

    // 2. Fermeture : libère le fichier auprès du système.
    await close();

    // 3. Remplacement effectif de la base.
    await temporaire.rename(cible.path);

    // 4. Purge des journaux (wal / shm) éventuels de l'ancienne base.
    for (final suffixe in const ['-wal', '-shm']) {
      final journal = File('${cible.path}$suffixe');
      if (await journal.exists()) {
        try {
          await journal.delete();
        } on FileSystemException catch (_) {
          // Simple nettoyage : une erreur ici n'empêche pas la restauration.
        }
      }
    }
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: AppDatabase.databaseName,
    native: const DriftNativeOptions(shareAcrossIsolates: true),
  );
}

/// Connexion en mémoire pour les tests.
QueryExecutor openMemoryConnection() => NativeDatabase.memory();
