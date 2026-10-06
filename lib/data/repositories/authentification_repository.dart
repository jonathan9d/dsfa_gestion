import 'dart:math';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:password_guard/password_guard.dart';

import '../database/database.dart';

/// Erreur d'authentification ou de gestion de compte, avec un message
/// directement compréhensible par l'utilisateur.
class AuthentificationException implements Exception {
  AuthentificationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthentificationRepository {
  AuthentificationRepository(this._db);
  final AppDatabase _db;

  /// Longueur minimale imposée pour un mot de passe.
  static const longueurMotDePasseMinimum = 6;

  // --- Comptes ------------------------------------------------------------

  Future<bool> aUnCompteConfigure() async {
    final rows = await (_db.select(
      _db.utilisateurs,
    )..where((user) => user.actif.equals(true))).get();
    return rows.any((user) => user.motDePasseHash != null);
  }

  Future<Utilisateur?> parIdentifiant(String identifiant) {
    final normalise = _normaliserIdentifiant(identifiant);
    return (_db.select(_db.utilisateurs)
          ..where((user) => user.identifiant.equals(normalise))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<Utilisateur?> parId(int id) => (_db.select(_db.utilisateurs)
        ..where((user) => user.id.equals(id))
        ..limit(1))
      .getSingleOrNull();

  /// Tous les comptes, du plus récent au plus ancien.
  Stream<List<Utilisateur>> watchTous() =>
      (_db.select(_db.utilisateurs)..orderBy([
            (t) => OrderingTerm.desc(t.actif),
            (t) => OrderingTerm.asc(t.nom),
          ]))
          .watch();

  Future<List<Utilisateur>> tous() => (_db.select(_db.utilisateurs)..orderBy([
            (t) => OrderingTerm.desc(t.actif),
            (t) => OrderingTerm.asc(t.nom),
          ]))
      .get();

  Future<Utilisateur> creerAdministrateur({
    required String identifiant,
    required String nom,
    required String motDePasse,
  }) async {
    if (await aUnCompteConfigure()) {
      throw AuthentificationException(
        'Un compte administrateur est déjà configuré.',
      );
    }
    final hash = await PasswordGuard.hash(password: motDePasse);
    final normalise = _normaliserIdentifiant(identifiant);
    final existant = await parIdentifiant(normalise);
    if (existant == null) {
      final id = await _db
          .into(_db.utilisateurs)
          .insert(
            UtilisateursCompanion.insert(
              identifiant: normalise,
              nom: nom.trim(),
              role: const Value('ADMIN'),
              motDePasseHash: Value(hash.hash),
              dateCreation: Value(DateTime.now()),
            ),
          );
      return (await (_db.select(
        _db.utilisateurs,
      )..where((user) => user.id.equals(id))).getSingle());
    }
    await (_db.update(
      _db.utilisateurs,
    )..where((user) => user.id.equals(existant.id))).write(
      UtilisateursCompanion(
        nom: Value(nom.trim()),
        actif: const Value(true),
        motDePasseHash: Value(hash.hash),
      ),
    );
    return (await (_db.select(
      _db.utilisateurs,
    )..where((user) => user.id.equals(existant.id))).getSingle());
  }

  /// Crée un nouveau compte utilisateur (réservé aux administrateurs).
  Future<Utilisateur> creerUtilisateur({
    required String identifiant,
    required String nom,
    String prenom = '',
    String role = 'GESTIONNAIRE',
    required String motDePasse,
    String fonction = '',
    String email = '',
    String telephone = '',
    String? photo,
    bool actif = true,
  }) async {
    final normalise = _normaliserIdentifiant(identifiant);
    if (normalise.isEmpty) {
      throw AuthentificationException(
        'Le nom d\'utilisateur est obligatoire.',
      );
    }
    if (nom.trim().isEmpty) {
      throw AuthentificationException('Le nom est obligatoire.');
    }
    _verifierMotDePasse(motDePasse);
    if (await parIdentifiant(normalise) != null) {
      throw AuthentificationException(
        'Le nom d\'utilisateur « $normalise » est déjà utilisé. '
        'Choisissez-en un autre.',
      );
    }
    final hash = await PasswordGuard.hash(password: motDePasse);
    final id = await _db
        .into(_db.utilisateurs)
        .insert(
          UtilisateursCompanion.insert(
            identifiant: normalise,
            nom: nom.trim(),
            role: Value(role),
            actif: Value(actif),
            motDePasseHash: Value(hash.hash),
            prenomUtilisateur: Value(_vide(prenom)),
            fonction: Value(_vide(fonction)),
            email: Value(_vide(email)),
            telephone: Value(_vide(telephone)),
            photo: Value(photo),
            dateCreation: Value(DateTime.now()),
          ),
        );
    return (await (_db.select(
      _db.utilisateurs,
    )..where((user) => user.id.equals(id))).getSingle());
  }

  /// Met à jour les informations d'un compte.
  Future<void> mettreAJourCompte(
    int id, {
    String? identifiant,
    String? nom,
    String? prenom,
    String? fonction,
    String? email,
    String? telephone,
    String? role,
    bool? actif,
    Object? photo = _nonModifie,
  }) async {
    if (identifiant != null) {
      final normalise = _normaliserIdentifiant(identifiant);
      if (normalise.isEmpty) {
        throw AuthentificationException(
          'Le nom d\'utilisateur est obligatoire.',
        );
      }
      final autre = await parIdentifiant(normalise);
      if (autre != null && autre.id != id) {
        throw AuthentificationException(
          'Le nom d\'utilisateur « $normalise » est déjà utilisé.',
        );
      }
    }
    if (nom != null && nom.trim().isEmpty) {
      throw AuthentificationException('Le nom est obligatoire.');
    }
    await (_db.update(_db.utilisateurs)..where((u) => u.id.equals(id))).write(
      UtilisateursCompanion(
        identifiant: identifiant == null
            ? const Value.absent()
            : Value(_normaliserIdentifiant(identifiant)),
        nom: nom == null ? const Value.absent() : Value(nom.trim()),
        prenomUtilisateur: Value(_vide(prenom)),
        fonction: Value(_vide(fonction)),
        email: Value(_vide(email)),
        telephone: Value(_vide(telephone)),
        role: role == null ? const Value.absent() : Value(role),
        actif: actif == null ? const Value.absent() : Value(actif),
        photo: identical(photo, _nonModifie)
            ? const Value.absent()
            : Value(photo as String?),
      ),
    );
  }

  /// Enregistre la date de dernière connexion réussie.
  Future<void> enregistrerConnexion(int id) async {
    await (_db.update(_db.utilisateurs)..where((u) => u.id.equals(id))).write(
      UtilisateursCompanion(derniereConnexion: Value(DateTime.now())),
    );
  }

  // --- Mots de passe ------------------------------------------------------

  Future<Utilisateur?> authentifier({
    required String identifiant,
    required String motDePasse,
  }) async {
    final user = await parIdentifiant(identifiant);
    final hash = user?.motDePasseHash;
    if (user == null || !user.actif || hash == null) return null;
    try {
      if (!await PasswordGuard.verify(password: motDePasse, hash: hash)) {
        return null;
      }
      await enregistrerConnexion(user.id);
      return (await parId(user.id)) ?? user;
    } on PasswordGuardException {
      return null;
    } on FormatException {
      return null;
    }
  }

  /// Vérifie un mot de passe sans modifier la session.
  Future<bool> verifierMotDePasse(int id, String motDePasse) async {
    final user = await parId(id);
    final hash = user?.motDePasseHash;
    if (hash == null) return false;
    try {
      return await PasswordGuard.verify(password: motDePasse, hash: hash);
    } on PasswordGuardException {
      return false;
    } on FormatException {
      return false;
    }
  }

  /// Change le mot de passe après vérification de l'ancien.
  Future<void> changerMotDePasse({
    required int id,
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  }) async {
    if (!await verifierMotDePasse(id, ancienMotDePasse)) {
      throw AuthentificationException(
        'L\'ancien mot de passe est incorrect. Vérifiez la saisie puis '
        'réessayez.',
      );
    }
    if (await verifierMotDePasse(id, nouveauMotDePasse)) {
      throw AuthentificationException(
        'Le nouveau mot de passe doit être différent de l\'ancien.',
      );
    }
    await definirMotDePasse(id: id, nouveauMotDePasse: nouveauMotDePasse);
  }

  /// Définit un mot de passe sans vérifier l'ancien (réinitialisation et
  /// création de compte par un administrateur).
  Future<void> definirMotDePasse({
    required int id,
    required String nouveauMotDePasse,
  }) async {
    _verifierMotDePasse(nouveauMotDePasse);
    final hash = await PasswordGuard.hash(password: nouveauMotDePasse);
    await (_db.update(_db.utilisateurs)..where((u) => u.id.equals(id))).write(
      UtilisateursCompanion(motDePasseHash: Value(hash.hash)),
    );
  }

  /// Supprime définitivement un compte (un administrateur ne peut pas
  /// supprimer son propre compte ni le dernier administrateur actif).
  Future<void> supprimerCompte(int id, {required int? demandeur}) async {
    if (demandeur != null && demandeur == id) {
      throw AuthentificationException(
        'Vous ne pouvez pas supprimer votre propre compte.',
      );
    }
    final comptes = await tous();
    final cible = comptes.where((c) => c.id == id).firstOrNull;
    if (cible == null) return;
    if (cible.role == 'ADMIN' &&
        comptes
                .where(
                  (c) => c.role == 'ADMIN' && c.actif && c.id != id,
                )
                .isEmpty) {
      throw AuthentificationException(
        'Ce compte est le dernier administrateur : il ne peut pas être '
        'supprimé.',
      );
    }
    await (_db.delete(_db.utilisateurs)..where((u) => u.id.equals(id))).go();
  }

  /// Génère un mot de passe robuste, facile à recopier.
  static String genererMotDePasse({int longueur = 12}) {
    const majuscules = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    const minuscules = 'abcdefghijkmnopqrstuvwxyz';
    const chiffres = '23456789';
    const symboles = '!@#\$%&*?';
    final melange = '$majuscules$minuscules$chiffres$symboles';
    final aleatoire = Random.secure();
    final caracteres = <String>[
      majuscules[aleatoire.nextInt(majuscules.length)],
      minuscules[aleatoire.nextInt(minuscules.length)],
      chiffres[aleatoire.nextInt(chiffres.length)],
      symboles[aleatoire.nextInt(symboles.length)],
      for (var i = 4; i < longueur; i++)
        melange[aleatoire.nextInt(melange.length)],
    ]..shuffle(aleatoire);
    return caracteres.join();
  }

  /// Score de robustesse (0 à 4) avec libellé, pour guider l'utilisateur.
  static ({int score, String libelle}) robustesse(String motDePasse) {
    if (motDePasse.isEmpty) {
      return (score: 0, libelle: 'Aucun mot de passe saisi');
    }
    var score = 0;
    if (motDePasse.length >= 8) score++;
    if (motDePasse.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(motDePasse) &&
        RegExp(r'[a-z]').hasMatch(motDePasse)) {
      score++;
    }
    if (RegExp(r'[0-9]').hasMatch(motDePasse) &&
        RegExp(r'[^A-Za-z0-9]').hasMatch(motDePasse)) {
      score++;
    }
    final libelle = switch (score) {
      0 || 1 => 'Faible',
      2 => 'Moyen',
      3 => 'Bon',
      _ => 'Excellent',
    };
    return (score: score, libelle: libelle);
  }

  void _verifierMotDePasse(String motDePasse) {
    if (motDePasse.isEmpty) {
      throw AuthentificationException('Le mot de passe est obligatoire.');
    }
    if (motDePasse.length < longueurMotDePasseMinimum) {
      throw AuthentificationException(
        'Le mot de passe doit contenir au moins '
        '$longueurMotDePasseMinimum caractères.',
      );
    }
  }

  static String? _vide(String? valeur) {
    final texte = valeur?.trim() ?? '';
    return texte.isEmpty ? null : texte;
  }

  static const _nonModifie = Object();

  static String _normaliserIdentifiant(String identifiant) =>
      identifiant.trim().toLowerCase();
}
