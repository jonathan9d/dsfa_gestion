import 'dart:math';

import '../../data/database/database.dart';
import '../../data/repositories/authentification_repository.dart';
import '../../data/repositories/referentiel_repository.dart';
import '../../services/notification_service.dart';

/// Erreur du parcours « mot de passe oublié », message destiné à l'utilisateur.
class ReinitialisationException implements Exception {
  ReinitialisationException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Résultat d'une demande de code de vérification.
class DemandeCode {
  const DemandeCode({
    required this.utilisateur,
    required this.code,
    required this.notificationEnvoyee,
  });

  final Utilisateur utilisateur;

  /// Code de vérification à saisir dans l'application.
  final String code;

  /// `true` si la notification a bien été affichée sur l'ordinateur.
  final bool notificationEnvoyee;
}

/// Parcours « mot de passe oublié » :
/// 1. l'utilisateur indique son nom d'utilisateur (et l'email du compte) ;
/// 2. un code de vérification est **envoyé en notification sur
///    l'ordinateur** ;
/// 3. l'utilisateur saisit le code puis un nouveau mot de passe ;
/// 4. il est reconnecté automatiquement.
class ReinitialisationService {
  ReinitialisationService({
    required ParametresRepository parametres,
    required AuthentificationRepository authentification,
    required NotificationService notifications,
  }) : _parametres = parametres,
       _authentification = authentification,
       _notifications = notifications;

  final ParametresRepository _parametres;
  final AuthentificationRepository _authentification;
  final NotificationService _notifications;

  static const cleCode = 'reinitialisation_code';
  static const cleExpiration = 'reinitialisation_code_expiration';
  static const cleUtilisateur = 'reinitialisation_code_utilisateur';
  static const cleTentatives = 'reinitialisation_code_tentatives';

  /// Durée de validité du code.
  static const dureeValidite = Duration(minutes: 15);

  /// Nombre d'essais autorisés avant de devoir demander un nouveau code.
  static const tentativesMax = 5;

  /// Compte correspondant au nom d'utilisateur (pour savoir si un email est
  /// exigé lors de la vérification).
  Future<Utilisateur?> compte(String identifiant) async {
    final utilisateur = await _authentification.parIdentifiant(identifiant);
    if (utilisateur == null || !utilisateur.actif) return null;
    return utilisateur;
  }

  /// Génère un code, l'envoie en notification et renvoie le résultat.
  Future<DemandeCode> envoyerCode({
    required String identifiant,
    String email = '',
  }) async {
    final utilisateur = await compte(identifiant);
    if (utilisateur == null) {
      throw ReinitialisationException(
        'Aucun compte actif ne correspond à ce nom d\'utilisateur. '
        'Vérifiez la saisie (les majuscules ne sont pas obligatoires).',
      );
    }
    final emailCompte = (utilisateur.email ?? '').trim();
    if (emailCompte.isNotEmpty) {
      if (email.trim().isEmpty) {
        throw ReinitialisationException(
          'Une adresse email est enregistrée sur ce compte : saisissez-la '
          'pour vérifier que vous en êtes bien le propriétaire.',
        );
      }
      if (email.trim().toLowerCase() != emailCompte.toLowerCase()) {
        throw ReinitialisationException(
          'L\'adresse email saisie ne correspond pas à celle enregistrée sur '
          'ce compte.',
        );
      }
    }

    final code = _genererCode();
    await _parametres.ecrire(cleCode, code);
    await _parametres.ecrire(
      cleExpiration,
      DateTime.now().add(dureeValidite).toIso8601String(),
    );
    await _parametres.ecrire(cleUtilisateur, utilisateur.id.toString());
    await _parametres.ecrire(cleTentatives, '0');

    final envoye = await _notifications.notifier(
      titre: 'DSFA Gestion — code de vérification',
      corps:
          'Votre code est $code. Il expire dans '
          '${dureeValidite.inMinutes} minutes.',
      sousTitre: 'Réinitialisation du mot de passe',
    );

    return DemandeCode(
      utilisateur: utilisateur,
      code: code,
      notificationEnvoyee: envoye,
    );
  }

  /// Vérifie le code saisi ; lève une [ReinitialisationException] expliquant
  /// précisément le problème le cas échéant.
  Future<void> verifierCode(String code) async {
    final attendu = (await _parametres.lire(cleCode)) ?? '';
    final expiration = DateTime.tryParse(
      (await _parametres.lire(cleExpiration)) ?? '',
    );
    if (attendu.isEmpty) {
      throw ReinitialisationException(
        'Aucun code de vérification n\'a été demandé. '
        'Cliquez sur « Recevoir un code » pour en obtenir un.',
      );
    }
    if (expiration == null || DateTime.now().isAfter(expiration)) {
      throw ReinitialisationException(
        'Ce code a expiré (validité : ${dureeValidite.inMinutes} minutes). '
        'Demandez un nouveau code.',
      );
    }
    final essais =
        int.tryParse((await _parametres.lire(cleTentatives)) ?? '0') ?? 0;
    if (essais >= tentativesMax) {
      throw ReinitialisationException(
        'Trop d\'essais incorrects. Demandez un nouveau code de vérification.',
      );
    }
    if (code.trim() != attendu) {
      final restants = tentativesMax - essais - 1;
      await _parametres.ecrire(cleTentatives, '${essais + 1}');
      throw ReinitialisationException(
        'Le code saisi est incorrect. '
        '${restants > 0 ? 'Il vous reste $restants essai(s).' : 'Demandez un nouveau code.'}',
      );
    }
  }

  /// Enregistre le nouveau mot de passe et renvoie le compte concerné.
  Future<Utilisateur> definirNouveauMotDePasse({
    required String code,
    required String nouveauMotDePasse,
    required String confirmation,
  }) async {
    await verifierCode(code);
    if (nouveauMotDePasse != confirmation) {
      throw ReinitialisationException(
        'Les deux mots de passe saisis ne sont pas identiques.',
      );
    }
    final id = int.tryParse((await _parametres.lire(cleUtilisateur)) ?? '');
    if (id == null) {
      throw ReinitialisationException(
        'La demande de réinitialisation n\'est plus valable. Recommencez.',
      );
    }
    await _authentification.definirMotDePasse(
      id: id,
      nouveauMotDePasse: nouveauMotDePasse,
    );
    await nettoyer();
    final utilisateur = await _authentification.parId(id);
    if (utilisateur == null) {
      throw ReinitialisationException(
        'Le compte à mettre à jour est introuvable. Recommencez la procédure.',
      );
    }
    return utilisateur;
  }

  /// Efface toute demande en cours (code, expiration, essais).
  Future<void> nettoyer() async {
    await _parametres.ecrire(cleCode, '');
    await _parametres.ecrire(cleExpiration, '');
    await _parametres.ecrire(cleUtilisateur, '');
    await _parametres.ecrire(cleTentatives, '0');
  }

  static String _genererCode() {
    final aleatoire = Random.secure();
    return List.generate(6, (_) => aleatoire.nextInt(10)).join();
  }
}
