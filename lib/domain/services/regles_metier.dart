import '../statuts.dart';

/// Règles métier pures, transposées des formules du classeur Excel.
///
/// Toutes les méthodes sont sans effet de bord et facilement testables.
/// Aucune donnée n'est stockée ici : ces règles s'appliquent aux données
/// source lues depuis SQLite.
class ReglesMetier {
  const ReglesMetier._();

  static const double _toleranceMontant = 0.000001;

  // ---------------------------------------------------------------------------
  // Budget
  // ---------------------------------------------------------------------------

  /// `Montant = Quantité × Nombre de jours × Taux unitaire`
  /// (REFERENTIEL_BUDGET!J : `G*I*H`). Si le nombre de jours est nul/absent,
  /// le montant vaut `Quantité × Taux` (comportement des lignes sans jours).
  static double montantAlloue({
    required double quantite,
    required double nombreJours,
    required double tauxUnitaire,
  }) {
    if (nombreJours <= 0) return quantite * tauxUnitaire;
    return quantite * nombreJours * tauxUnitaire;
  }

  /// `Montant = Nbr Jr/Mois × Quantité × Fréquence × P.U.` (J.Depenses!P).
  static double montantDepense({
    required double nbJrMois,
    required double quantite,
    required double frequence,
    required double pu,
  }) => nbJrMois * quantite * frequence * pu;

  /// Solde d'une ligne budgétaire : alloué − consommé.
  static double soldeBudget(double alloue, double consomme) =>
      alloue - consomme;

  /// Indemnité théorique = nombre de jours présents × taux journalier
  /// (PRESENCES_INDEMNITES!M : `COUNTIF(F:J,"Présent")*L`).
  static double indemniteTheorique({
    required int nombreJoursPresents,
    required double tauxJournalier,
  }) => nombreJoursPresents * tauxJournalier;

  // --- Règle d'or des indemnités ------------------------------------------
  //
  // `indemnité = participants × [ (délai de route × taux 100 %) +
  //   (jours d'activité × taux ajusté) ]`
  // où le taux des jours d'activité vaut 85 % lorsque le déjeuner est pris en
  // charge pendant l'activité, et 100 % sinon. Le délai de route (aller +
  // retour) est toujours payé à 100 % du taux.

  /// Part « délai de route » : payée à 100 % du taux.
  static double indemniteDelaiRoute({
    required double delaiRoute,
    required double taux,
  }) => delaiRoute * taux;

  /// Taux appliqué aux jours d'activité : 85 % si le déjeuner est pris en
  /// charge (repas fourni pendant l'activité), 100 % sinon.
  static double tauxJoursActivite({
    required double taux,
    required bool avecDejeuner,
  }) => avecDejeuner ? taux * 0.85 : taux;

  /// Indemnité d'**un** participant (règle d'or).
  ///
  /// [abattementRepas] permet de désactiver la réduction de 15 % : les
  /// chauffeurs, par exemple, perçoivent toujours 100 % du taux.
  static double indemniteParticipant({
    required double delaiRoute,
    required double joursActivite,
    required double taux,
    required bool avecDejeuner,
    bool abattementRepas = true,
  }) {
    final tauxActivite = abattementRepas
        ? tauxJoursActivite(taux: taux, avecDejeuner: avecDejeuner)
        : taux;
    return indemniteDelaiRoute(delaiRoute: delaiRoute, taux: taux) +
        joursActivite * tauxActivite;
  }

  /// Indemnité totale = nombre de participants × indemnité par participant.
  static double indemniteTotale({
    required int participants,
    required double delaiRoute,
    required double joursActivite,
    required double taux,
    required bool avecDejeuner,
    bool abattementRepas = true,
  }) =>
      participants *
      indemniteParticipant(
        delaiRoute: delaiRoute,
        joursActivite: joursActivite,
        taux: taux,
        avecDejeuner: avecDejeuner,
        abattementRepas: abattementRepas,
      );

  /// Carburant : distance aller-retour (km) × consommation (L/km) ×
  /// nombre de voitures × prix unitaire du litre.
  static double montantCarburant({
    required double distanceAllerRetourKm,
    required double consommation,
    required int voitures,
    required double prixUnitaire,
  }) => distanceAllerRetourKm * consommation * voitures * prixUnitaire;

  /// Écart indemnité = indemnité reçue − indemnité théorique
  /// (PRESENCES_INDEMNITES!O : `N-M`).
  static double ecartIndemnite(double recue, double theorique) =>
      recue - theorique;

  // ---------------------------------------------------------------------------
  // Présences / indemnités
  // ---------------------------------------------------------------------------

  /// `Date dans période ?` = OUI si la date est comprise entre le début et la
  /// fin de l'activité (bornes incluses).
  static bool dateDansPeriode(DateTime date, DateTime? debut, DateTime? fin) {
    if (debut == null || fin == null) return false;
    final d = DateTime(date.year, date.month, date.day);
    final a = DateTime(debut.year, debut.month, debut.day);
    final b = DateTime(fin.year, fin.month, fin.day);
    return !d.isBefore(a) && !d.isAfter(b);
  }

  /// `Présence justifie paiement ?` (PRESENCES_INDEMNITES!Q).
  /// - `Oui` si présent et preuve/signature renseignée,
  /// - `Non` si absent,
  /// - `À vérifier` sinon.
  static String presenceJustifiePaiement({
    required String statutPresence,
    required String? signaturePreuve,
  }) {
    final present = statutPresence == 'Présent';
    final aPreuve = (signaturePreuve ?? '').trim().isNotEmpty;
    if (present && aPreuve) return OuiNon.oui;
    if (statutPresence == 'Absent') return OuiNon.non;
    return OuiNon.aVerifier;
  }

  /// `Montant conforme ?` = OUI si écart nul (PRESENCES_INDEMNITES!R).
  static bool montantConforme(double ecart) => ecart.abs() < _toleranceMontant;

  /// `Résultat contrôle` (PRESENCES_INDEMNITES!S), par ordre de priorité.
  static String resultatControle({
    required bool dateDansPeriode,
    required String presenceJustifie,
    required bool montantConforme,
  }) {
    if (!dateDansPeriode) return ResultatPresence.dateHorsPeriode;
    if (presenceJustifie == OuiNon.non) {
      return ResultatPresence.paiementSansPresence;
    }
    if (presenceJustifie == OuiNon.aVerifier) {
      return ResultatPresence.presenceAVerifier;
    }
    if (!montantConforme) return ResultatPresence.montantNonConforme;
    return ResultatPresence.conforme;
  }

  // ---------------------------------------------------------------------------
  // Contrôle PJ
  // ---------------------------------------------------------------------------

  /// `Écart Budget = Montant payé − Montant alloué` (CONTROLE_PJ!M : `K-J`).
  static double ecartBudget(double montantPaye, double montantAlloue) =>
      montantPaye - montantAlloue;

  /// `Écart PJ = Montant PJ − Montant payé` (CONTROLE_PJ!N : `L-K`).
  static double ecartPJ(double montantPJ, double montantPaye) =>
      montantPJ - montantPaye;

  /// `Date PJ cohérente ?` (CONTROLE_PJ!Q) :
  /// OUI si `Date PJ ≥ Date début` **et** `Date fin ≤ Date PJ`.
  static bool datePJCoherente({
    required DateTime? dateDebut,
    required DateTime? dateFin,
    required DateTime? datePJ,
  }) {
    if (dateDebut == null || dateFin == null || datePJ == null) return false;
    final d = DateTime(datePJ.year, datePJ.month, datePJ.day);
    final debut = DateTime(dateDebut.year, dateDebut.month, dateDebut.day);
    final fin = DateTime(dateFin.year, dateFin.month, dateFin.day);
    return !d.isBefore(debut) && !fin.isAfter(d);
  }

  /// `Contrôle présence/indemnité` (CONTROLE_PJ!T).
  static String controlePresenceIndemnite({
    required bool aAnomaliePresence,
    required double montantControle,
    required double budgetIndemnitesDisponible,
  }) {
    if (aAnomaliePresence) return ControlePresenceIndemnite.anomalie;
    if (montantControle > budgetIndemnitesDisponible + _toleranceMontant) {
      return ControlePresenceIndemnite.depassement;
    }
    return ControlePresenceIndemnite.conforme;
  }

  /// `Statut final` (CONTROLE_PJ!V), par ordre de priorité.
  static String statutFinalPJ({
    required String? pjRecue,
    required bool datePJCoherente,
    required double ecartBudget,
    required double ecartPJ,
    required String? pjConforme,
    required String controlePresenceIndemnite,
  }) {
    if (pjRecue == OuiNon.non) return StatutFinalPJ.pjNonRecue;
    if (pjRecue == null || pjRecue.trim().isEmpty) return '';
    if (!datePJCoherente) return StatutFinalPJ.datePjNonConforme;
    final probleme =
        ecartBudget > _toleranceMontant ||
        ecartPJ.abs() > _toleranceMontant ||
        pjConforme == OuiNon.non ||
        controlePresenceIndemnite == ControlePresenceIndemnite.anomalie ||
        controlePresenceIndemnite == ControlePresenceIndemnite.depassement;
    if (probleme) return StatutFinalPJ.nonConforme;
    if (pjConforme == OuiNon.aVerifier) return StatutFinalPJ.aVerifier;
    return StatutFinalPJ.conforme;
  }

  // ---------------------------------------------------------------------------
  // Banque / rapprochement
  // ---------------------------------------------------------------------------

  /// Solde progressif du journal de banque : cumul recettes − cumul dépenses.
  static double soldeProgressif(
    double recettesCumulees,
    double depensesCumulees,
  ) => recettesCumulees - depensesCumulees;

  /// Solde rapproché côté journal (Rappr Banc!D33).
  static double soldeRapprocheJournal({
    required double soldeInitialDebit,
    required double soldeInitialCredit,
    required double totalCirculationDebit,
    required double totalCirculationCredit,
  }) =>
      soldeInitialDebit -
      soldeInitialCredit +
      totalCirculationDebit -
      totalCirculationCredit;

  /// Solde rapproché côté relevé (Rappr Banc!J33/L33).
  static double soldeRapprocheReleve({
    required double soldeInitialDebit,
    required double soldeInitialCredit,
    required double totalCirculationDebit,
    required double totalCirculationCredit,
  }) =>
      soldeInitialCredit -
      soldeInitialDebit +
      totalCirculationCredit -
      totalCirculationDebit;

  /// Écart de rapprochement = solde journal − solde relevé.
  static double ecartRapprochement(double soldeJournal, double soldeReleve) =>
      soldeJournal - soldeReleve;

  // ---------------------------------------------------------------------------
  // Districts
  // ---------------------------------------------------------------------------

  /// `EST CHEF-LIEU RÉGION` = OUI si district == chef-lieu (casse ignorée).
  static bool estChefLieuRegion(String district, String chefLieuRegion) {
    if (district.trim().isEmpty) return false;
    return district.trim().toUpperCase() == chefLieuRegion.trim().toUpperCase();
  }

  /// Distance carburant = distance aller × 2 (aller + retour).
  static double distanceCarburant(double distanceAller) => distanceAller * 2;

  /// Distance **aller-retour** reconstituée : on privilégie la valeur du
  /// référentiel, sinon `distance aller × 2`.
  static double distanceAllerRetour({
    required double distanceAllerKm,
    required double distanceCarburantKm,
  }) =>
      distanceCarburantKm > 0 ? distanceCarburantKm : distanceAllerKm * 2;

  /// Délai route total = délai aller + délai retour.
  static double delaiRouteTotal(double aller, double retour) => aller + retour;
}
