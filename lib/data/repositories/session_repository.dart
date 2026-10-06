import '../database/database.dart';
import 'authentification_repository.dart';
import 'referentiel_repository.dart';

/// Restauration du résultat de connexion enregistré localement.
class ResultatRestaurationSession {
  const ResultatRestaurationSession({
    required this.utilisateur,
    required this.joursDepuisDerniereOuverture,
  });

  final Utilisateur utilisateur;

  /// Nombre de jours écoulés depuis la dernière ouverture de l'application.
  final double joursDepuisDerniereOuverture;

  /// Vrai lorsque l'application n'a pas été ouverte depuis plus de 2 jours :
  /// le mot de passe doit alors être ressaisi.
  bool get motDePasseRequis => joursDepuisDerniereOuverture > 2;
}

/// Mémorise la session pour permettre la **reconnexion automatique**.
///
/// La session est conservée dans la table `Parametres` :
/// * `session_utilisateur_id` : identifiant du dernier compte connecté ;
/// * `session_derniere_ouverture` : date de la dernière ouverture de
///   l'application. Au-delà de **2 jours** sans ouverture, l'utilisateur doit
///   ressaisir son nom d'utilisateur et son mot de passe.
class SessionRepository {
  SessionRepository(this._parametres, this._authentification);

  final ParametresRepository _parametres;
  final AuthentificationRepository _authentification;

  static const cleUtilisateur = 'session_utilisateur_id';
  static const cleDerniereOuverture = 'session_derniere_ouverture';

  /// Clé du réglage « nombre de jours de reconnexion automatique ».
  static const cleDureeJours = 'session_duree_jours';

  /// Durée par défaut (en jours) sans ouverture avant d'exiger le mot de passe.
  static const dureeMaximaleSansOuvertureJours = 2;

  /// Durée configurable (réglage « Paramètres »), bornée entre 1 et 30 jours.
  Future<int> dureeJours() async {
    final brut = await _parametres.lire(cleDureeJours);
    final valeur = int.tryParse(brut ?? '') ?? dureeMaximaleSansOuvertureJours;
    return valeur.clamp(1, 30);
  }

  /// Compte à reconnecter automatiquement, ou `null` si une saisie est
  /// nécessaire (aucune session, session expirée, compte désactivé…).
  Future<ResultatRestaurationSession?> restaurer() async {
    final idTexte = await _parametres.lire(cleUtilisateur);
    final ouvertureTexte = await _parametres.lire(cleDerniereOuverture);
    if (idTexte == null || idTexte.isEmpty) return null;
    final id = int.tryParse(idTexte);
    if (id == null) {
      await effacer();
      return null;
    }
    final utilisateur = await _authentification.parId(id);
    if (utilisateur == null || !utilisateur.actif) {
      await effacer();
      return null;
    }
    final derniere = DateTime.tryParse(ouvertureTexte ?? '');
    final ecart = derniere == null
        ? const Duration(days: 999)
        : DateTime.now().difference(derniere);
    final jours = ecart.inMinutes / (60 * 24);
    final duree = await dureeJours();
    if (ecart > Duration(days: duree)) {
      // Session expirée : le mot de passe est demandé, mais l'identifiant du
      // dernier compte est conservé pour pré-remplir le formulaire.
      return ResultatRestaurationSession(
        utilisateur: utilisateur,
        joursDepuisDerniereOuverture: jours,
      );
    }
    return ResultatRestaurationSession(
      utilisateur: utilisateur,
      joursDepuisDerniereOuverture: jours,
    );
  }

  /// Mémorise le compte connecté et l'horodatage d'ouverture.
  Future<void> enregistrer(Utilisateur utilisateur) async {
    await _parametres.ecrire(cleUtilisateur, utilisateur.id.toString());
    await marquerOuverture();
  }

  /// Met à jour l'horodatage d'ouverture (appelé au démarrage puis
  /// périodiquement tant que l'application reste ouverte).
  Future<void> marquerOuverture() async {
    await _parametres.ecrire(
      cleDerniereOuverture,
      DateTime.now().toIso8601String(),
    );
  }

  /// Dernier identifiant utilisé (pour pré-remplir l'écran de connexion).
  Future<String?> dernierIdentifiant() async {
    final idTexte = await _parametres.lire(cleUtilisateur);
    final id = int.tryParse(idTexte ?? '');
    if (id == null) return null;
    final utilisateur = await _authentification.parId(id);
    return utilisateur?.identifiant;
  }

  /// Oublie la session (déconnexion explicite ou session invalide).
  Future<void> effacer() async {
    await _parametres.ecrire(cleUtilisateur, '');
  }
}
