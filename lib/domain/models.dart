import 'package:meta/meta.dart';

import 'statuts.dart';

/// Résultat calculé d'une ligne de présence/indemnité.
/// Jamais persisté : dérivé des données source par les services métier.
@immutable
class ResultatPresenceIndemnite {
  const ResultatPresenceIndemnite({
    required this.presenceId,
    required this.activiteCode,
    required this.participantId,
    required this.participantNom,
    required this.date,
    required this.statutPresence,
    required this.tauxJournalier,
    required this.indemniteTheorique,
    required this.indemniteRecue,
    required this.dateDansPeriode,
    required this.presenceJustifiePaiement,
    required this.montantConforme,
    required this.resultat,
  });

  final int presenceId;
  final String activiteCode;
  final int participantId;
  final String participantNom;
  final DateTime date;
  final String statutPresence;
  final double tauxJournalier;
  final double indemniteTheorique;
  final double indemniteRecue;

  /// `OUI` / `NON` (colonne `Date dans période ?`).
  final bool dateDansPeriode;

  /// `OUI` / `NON` / `À vérifier` (colonne `Présence justifie paiement ?`).
  final String presenceJustifiePaiement;

  final bool montantConforme;

  /// Une des valeurs de [ResultatPresence].
  final String resultat;

  double get ecart => indemniteRecue - indemniteTheorique;

  StatutControle get statut => ResultatPresence.versStatut(resultat);

  bool get estConforme => resultat == ResultatPresence.conforme;
}

/// Synthèse des indemnités d'un participant pour une activité.
@immutable
class SyntheseIndemniteParticipant {
  const SyntheseIndemniteParticipant({
    required this.participantId,
    required this.participantNom,
    required this.nombreJours,
    required this.nombreJoursPresents,
    required this.tauxJournalier,
    required this.indemniteTheorique,
    required this.indemniteRecue,
    required this.statut,
  });

  final int participantId;
  final String participantNom;
  final int nombreJours;
  final int nombreJoursPresents;
  final double tauxJournalier;
  final double indemniteTheorique;
  final double indemniteRecue;
  final StatutControle statut;

  double get ecart => indemniteRecue - indemniteTheorique;
}

/// Résultat calculé d'une ligne de contrôle PJ.
@immutable
class ResultatControlePJ {
  const ResultatControlePJ({
    required this.controleId,
    required this.ecartBudget,
    required this.ecartPJ,
    required this.datePJCoherente,
    required this.montantControle,
    required this.budgetIndemnitesDisponible,
    required this.controlePresenceIndemnite,
    required this.statutFinal,
  });

  final int controleId;

  /// `Montant payé − Montant alloué`.
  final double ecartBudget;

  /// `Montant PJ − Montant payé`.
  final double ecartPJ;

  final bool datePJCoherente;
  final double montantControle;
  final double budgetIndemnitesDisponible;

  /// Une des valeurs de [ControlePresenceIndemnite].
  final String controlePresenceIndemnite;

  /// Une des valeurs de [StatutFinalPJ].
  final String statutFinal;

  StatutControle get statut => StatutFinalPJ.versStatut(statutFinal);
}

/// Indicateurs du tableau de bord (feuille `TABLEAU_DE_BORD`).
@immutable
class IndicateursDashboard {
  const IndicateursDashboard({
    required this.montantTotalAlloue,
    required this.montantTotalPaye,
    required this.montantTotalPJ,
    required this.ecartBudgetTotal,
    required this.ecartPJTotal,
    required this.nombreActivites,
    required this.nombreParticipants,
    required this.nombrePresences,
    required this.totalIndemnitesTheoriques,
    required this.totalIndemnitesRecues,
    required this.totalDepenses,
    required this.soldeBancaire,
    required this.dossiersConformes,
    required this.dossiersNonConformes,
    required this.pjNonRecues,
    required this.datesPJNonConformes,
    required this.anomaliesPresence,
    required this.pjAverifier,
  });

  final double montantTotalAlloue;
  final double montantTotalPaye;
  final double montantTotalPJ;
  final double ecartBudgetTotal;
  final double ecartPJTotal;
  final int nombreActivites;
  final int nombreParticipants;
  final int nombrePresences;
  final double totalIndemnitesTheoriques;
  final double totalIndemnitesRecues;
  final double totalDepenses;
  final double soldeBancaire;
  final int dossiersConformes;
  final int dossiersNonConformes;
  final int pjNonRecues;
  final int datesPJNonConformes;
  final int anomaliesPresence;
  final int pjAverifier;

  double get soldeBudget => montantTotalAlloue - montantTotalPaye;

  double get tauxConsommation =>
      montantTotalAlloue == 0 ? 0 : montantTotalPaye / montantTotalAlloue;
}

/// Ligne de rapprochement bancaire.
@immutable
class LigneRapprochement {
  const LigneRapprochement({
    required this.date,
    required this.reference,
    required this.libelle,
    required this.montantJournal,
    required this.montantReleve,
    required this.statut,
  });

  final DateTime? date;
  final String reference;
  final String libelle;
  final double montantJournal;
  final double montantReleve;
  final StatutRapprochement statut;

  double get ecart => montantJournal - montantReleve;
}

/// Résultat global du rapprochement bancaire.
@immutable
class ResultatRapprochement {
  const ResultatRapprochement({
    required this.soldeJournal,
    required this.soldeReleve,
    required this.lignes,
  });

  final double soldeJournal;
  final double soldeReleve;
  final List<LigneRapprochement> lignes;

  double get ecart => soldeJournal - soldeReleve;

  bool get equilibre => ecart.abs() < 0.000001;
}

/// Point d'une série pour les graphiques.
@immutable
class SeriePoint {
  const SeriePoint(this.label, this.valeur);
  final String label;
  final double valeur;
}

/// Résultat d'une ligne de validation d'import.
@immutable
class LigneImport {
  const LigneImport({
    required this.feuille,
    required this.ligne,
    required this.message,
    required this.estErreur,
  });
  final String feuille;
  final int ligne;
  final String message;
  final bool estErreur;
}

/// Rapport d'import Excel.
@immutable
class RapportImport {
  const RapportImport({
    required this.lignesImportees,
    required this.lignesIgnorees,
    required this.details,
  });

  final Map<String, int> lignesImportees;
  final Map<String, int> lignesIgnorees;
  final List<LigneImport> details;

  int get totalImportees => lignesImportees.values.fold(0, (a, b) => a + b);
  int get totalIgnorees => lignesIgnorees.values.fold(0, (a, b) => a + b);
  List<LigneImport> get erreurs => details.where((d) => d.estErreur).toList();
}
