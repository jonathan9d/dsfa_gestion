import 'package:flutter/material.dart';

/// Statut global d'un dossier / d'une ligne de contrôle.
enum StatutControle {
  conforme('CONFORME', 'Conforme'),
  aVerifier('A_VERIFIER', 'À vérifier'),
  nonConforme('NON_CONFORME', 'Non conforme');

  const StatutControle(this.code, this.libelle);
  final String code;
  final String libelle;

  static StatutControle fromCode(String? code) {
    return StatutControle.values.firstWhere(
      (s) => s.code == code || s.libelle == code,
      orElse: () => StatutControle.aVerifier,
    );
  }

  /// Couleur du statut, **adaptée automatiquement** au thème clair/sombre :
  /// les teintes foncées deviennent plus claires sur fond sombre pour rester
  /// lisibles sans jamais perdre leur signification.
  Color color(ColorScheme scheme) {
    final sombre = scheme.brightness == Brightness.dark;
    return switch (this) {
      StatutControle.conforme =>
        sombre ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
      StatutControle.aVerifier =>
        sombre ? const Color(0xFFFFD54F) : const Color(0xFFF9A825),
      StatutControle.nonConforme =>
        sombre ? const Color(0xFFEF5350) : const Color(0xFFC62828),
    };
  }

  IconData get icon => switch (this) {
        StatutControle.conforme => Icons.check_circle,
        StatutControle.aVerifier => Icons.warning_amber_rounded,
        StatutControle.nonConforme => Icons.cancel,
      };
}

/// Résultats de contrôle d'une ligne de présence/indemnité (feuille
/// `PRESENCES_INDEMNITES`, colonne `Résultat contrôle`).
class ResultatPresence {
  static const conforme = 'CONFORME';
  static const dateHorsPeriode = 'DATE HORS PÉRIODE';
  static const paiementSansPresence = 'PAIEMENT SANS PRÉSENCE';
  static const presenceAVerifier = 'PRÉSENCE À VÉRIFIER';
  static const montantNonConforme = 'MONTANT NON CONFORME';

  static StatutControle versStatut(String resultat) => switch (resultat) {
        conforme => StatutControle.conforme,
        dateHorsPeriode => StatutControle.nonConforme,
        paiementSansPresence => StatutControle.nonConforme,
        montantNonConforme => StatutControle.nonConforme,
        _ => StatutControle.aVerifier,
      };
}

/// Statuts finaux de `CONTROLE_PJ` (colonne `Statut final`).
class StatutFinalPJ {
  static const conforme = 'Conforme';
  static const aVerifier = 'À vérifier';
  static const nonConforme = 'Non conforme';
  static const pjNonRecue = 'PJ non reçue';
  static const datePjNonConforme = 'Date PJ non conforme';

  static StatutControle versStatut(String? valeur) => switch (valeur) {
        conforme => StatutControle.conforme,
        aVerifier => StatutControle.aVerifier,
        nonConforme => StatutControle.nonConforme,
        pjNonRecue => StatutControle.nonConforme,
        datePjNonConforme => StatutControle.nonConforme,
        _ => StatutControle.aVerifier,
      };
}

/// Résultat du contrôle présence/indemnité au niveau activité (`CONTROLE_PJ`).
class ControlePresenceIndemnite {
  static const conforme = 'Conforme';
  static const anomalie = 'Anomalie détectée';
  static const depassement = 'Dépassement budget indemnités';
}

/// Statuts de rapprochement bancaire.
enum StatutRapprochement {
  rapproche('Rapproché'),
  difference('Différence'),
  nonTrouve('Non trouvé');

  const StatutRapprochement(this.libelle);
  final String libelle;
}

/// Rôles utilisateurs.
/// Rôles des comptes utilisateurs et droits associés.
enum RoleUtilisateur {
  admin('ADMIN'),
  gestionnaire('GESTIONNAIRE'),
  lecteur('LECTEUR');

  const RoleUtilisateur(this.code);
  final String code;

  /// Libellé lisible affiché dans l'application.
  String get libelle => switch (this) {
    RoleUtilisateur.admin => 'Administrateur',
    RoleUtilisateur.gestionnaire => 'Gestionnaire',
    RoleUtilisateur.lecteur => 'Lecteur',
  };

  /// Description des droits, affichée dans la gestion des comptes.
  String get description => switch (this) {
    RoleUtilisateur.admin =>
      'Accès complet : comptes utilisateurs, paramètres, sauvegardes et '
          'toutes les saisies.',
    RoleUtilisateur.gestionnaire =>
      'Saisie et modification des activités, budgets, participants, dépenses '
          'et contrôles. Pas d\'accès à la gestion des comptes.',
    RoleUtilisateur.lecteur =>
      'Consultation seule : aucune modification ni suppression.',
  };

  bool get peutModifier => this != RoleUtilisateur.lecteur;
  bool get peutAdministrer => this == RoleUtilisateur.admin;
  bool get peutGererComptes => this == RoleUtilisateur.admin;

  static RoleUtilisateur depuisCode(String? code) => values.firstWhere(
    (role) => role.code == (code ?? '').toUpperCase(),
    orElse: () => RoleUtilisateur.lecteur,
  );
}

/// Valeurs de oui/non/à compléter utilisées par les colonnes Excel.
class OuiNon {
  static const oui = 'Oui';
  static const non = 'Non';
  static const aVerifier = 'À vérifier';
  static const aCompleter = 'À compléter';
}
