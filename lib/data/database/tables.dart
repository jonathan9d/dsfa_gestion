import 'package:drift/drift.dart';

/// Référentiel géographique (feuille `DISTANCES_DISTRICTS`).
@DataClassName('District')
@TableIndex(name: 'idx_district_nom', columns: {#nom})
class Districts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get numero => integer().nullable()();
  TextColumn get chefLieuRegion => text().withLength(min: 0, max: 200)();
  TextColumn get region => text().withLength(min: 0, max: 200)();
  TextColumn get nom => text().withLength(min: 0, max: 200)();
  BoolColumn get estChefLieuRegion =>
      boolean().withDefault(const Constant(false))();
  RealColumn get distanceAllerKm => real().withDefault(const Constant(0))();
  RealColumn get distanceCarburantKm => real().withDefault(const Constant(0))();
  RealColumn get delaiRouteAller => real().withDefault(const Constant(0))();
  RealColumn get delaiRouteRetour => real().withDefault(const Constant(0))();
  RealColumn get delaiRouteTotal => real().withDefault(const Constant(0))();
}

/// Référentiel des tarifs (feuille `REFERENTIEL_TARIFS`).
@DataClassName('TarifReferentiel')
class ReferentielTarifs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rubrique => text()();
  TextColumn get ligneBudgetaire => text()();
  TextColumn get typeActivite => text().withDefault(const Constant('Tous'))();
  TextColumn get unite => text().withDefault(const Constant('personne'))();
  TextColumn get zone => text().withDefault(const Constant('Tous'))();
  RealColumn get tarif => real().withDefault(const Constant(0))();
  BoolColumn get actif => boolean().withDefault(const Constant(true))();
  TextColumn get observation => text().nullable()();
}

/// Listes de valeurs de référence (feuille `LISTES`).
@DataClassName('ReferenceValeur')
@TableIndex(name: 'idx_ref_categorie', columns: {#categorie})
class ReferenceValeurs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get categorie => text()();
  TextColumn get valeur => text()();
  IntColumn get ordre => integer().withDefault(const Constant(0))();
  BoolColumn get actif => boolean().withDefault(const Constant(true))();
}

/// Activités (feuille `LISTES ACTIVITES` enrichie du générateur `BUDGET`).
@DataClassName('Activite')
@TableIndex(name: 'idx_activite_code', columns: {#code}, unique: true)
class Activites extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get type =>
      text().withDefault(const Constant('Atelier/Réunion'))();
  TextColumn get codeBudget => text().nullable()();

  /// Source de financement (UNICEF, UNFPA, …) — liste `FINANCEMENT`.
  TextColumn get sourceFinancement => text().nullable()();
  IntColumn get annee => integer().nullable()();
  TextColumn get periode => text().nullable()();
  DateTimeColumn get dateDebut => dateTime().nullable()();
  DateTimeColumn get dateFin => dateTime().nullable()();
  TextColumn get lieu => text().nullable()();
  TextColumn get district => text().nullable()();
  TextColumn get zoneIndemnite => text().nullable()();
  TextColumn get responsable => text().nullable()();
  IntColumn get nombreJours => integer().withDefault(const Constant(0))();
  IntColumn get nombreParticipants =>
      integer().withDefault(const Constant(0))();
  IntColumn get nombreMissionnaires =>
      integer().withDefault(const Constant(0))();
  RealColumn get distanceAllerKm => real().withDefault(const Constant(0))();
  BoolColumn get restauration => boolean().withDefault(const Constant(false))();
  TextColumn get statut => text().withDefault(const Constant('En cours'))();
  TextColumn get observation => text().nullable()();
  DateTimeColumn get creeLe => dateTime().withDefault(currentDateAndTime)();
}

/// Lignes budgétaires allouées (feuille `REFERENTIEL_BUDGET`).
@DataClassName('LigneBudget')
@TableIndex(name: 'idx_lignebudget_activite', columns: {#activiteCode})
class LignesBudget extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get activiteCode => text()();
  TextColumn get activiteLibelle => text().nullable()();
  DateTimeColumn get dateDebutPrevue => dateTime().nullable()();
  DateTimeColumn get dateFinPrevue => dateTime().nullable()();
  TextColumn get ligneBudgetaire => text()();

  /// Type de la ligne (indemnités, carburant, location, restauration…).
  TextColumn get typeBudget => text().withDefault(const Constant('Libre'))();
  TextColumn get unite => text().withDefault(const Constant('jour-personne'))();
  RealColumn get quantitePrevue => real().withDefault(const Constant(0))();
  RealColumn get nombreJours => real().withDefault(const Constant(0))();
  RealColumn get tauxUnitaire => real().withDefault(const Constant(0))();
  RealColumn get montantAlloue => real().withDefault(const Constant(0))();

  /// Paramètres saisis par le générateur (JSON) : personnes, délai de route,
  /// provenance/destination, nombre de véhicules, PU, fréquence…
  TextColumn get details => text().nullable()();
  TextColumn get observation => text().nullable()();
}

/// Participants / bénéficiaires.
@DataClassName('Participant')
@TableIndex(name: 'idx_participant_nom', columns: {#nom})
class Participants extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nom => text().withLength(min: 1, max: 200)();
  TextColumn get prenom => text().withDefault(const Constant(''))();
  TextColumn get fonction => text().nullable()();
  TextColumn get structure => text().nullable()();
  TextColumn get telephone => text().nullable()();
  TextColumn get email => text().nullable()();
  BoolColumn get actif => boolean().withDefault(const Constant(true))();
  TextColumn get observation => text().nullable()();
}

/// Affectation d'un participant à une activité.
@DataClassName('ActiviteParticipant')
@TableIndex(name: 'idx_actpart_activite', columns: {#activiteCode})
class ActiviteParticipants extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get activiteCode => text()();
  IntColumn get participantId => integer().references(Participants, #id)();
  TextColumn get role => text().withDefault(const Constant('Participant'))();
  TextColumn get zone => text().nullable()();
  RealColumn get tauxJournalier => real().withDefault(const Constant(0))();
}

/// Présences (une ligne par participant et par date).
@DataClassName('Presence')
@TableIndex(name: 'idx_presence_activite', columns: {#activiteCode})
@TableIndex(name: 'idx_presence_participant', columns: {#participantId})
class Presences extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get activiteCode => text()();
  IntColumn get participantId => integer().references(Participants, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get statut => text().withDefault(const Constant('Présent'))();
  TextColumn get signaturePreuve => text().nullable()();
  RealColumn get tauxJournalier => real().withDefault(const Constant(0))();
  RealColumn get indemniteRecue => real().withDefault(const Constant(0))();
  TextColumn get observation => text().nullable()();
}

/// Saisie des indemnités par participant (dossier PJ ▸ indemnités).
@DataClassName('IndemniteSaisie')
@TableIndex(name: 'idx_indemnite_activite', columns: {#activiteCode})
class IndemnitesSaisies extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get activiteCode => text()();
  TextColumn get ligneBudgetaire => text().withDefault(const Constant(''))();
  IntColumn get participantId => integer().nullable()();
  TextColumn get participantNom => text().withDefault(const Constant(''))();

  /// État de paiement : Payé, Partiel, À payer, Non payé.
  TextColumn get etatPaiement =>
      text().withDefault(const Constant('À payer'))();

  /// Provenance (district de l'activité) : détermine le taux applicable.
  TextColumn get provenance => text().nullable()();

  /// Délai de route (jours) et jours d'activité retenus.
  RealColumn get delaiRoute => real().withDefault(const Constant(0))();
  RealColumn get nombreJoursActivite => real().withDefault(const Constant(0))();
  BoolColumn get restauration => boolean().withDefault(const Constant(false))();

  /// Taux journalier appliqué (règle chef-lieu de région / district).
  RealColumn get taux => real().withDefault(const Constant(0))();
  RealColumn get montantAlloue => real().withDefault(const Constant(0))();
  RealColumn get montantPaye => real().withDefault(const Constant(0))();
  DateTimeColumn get creeLe => dateTime().withDefault(currentDateAndTime)();
}

/// Contrôle des pièces justificatives (feuille `CONTROLE_PJ`).
@DataClassName('ControlePJ')
@TableIndex(name: 'idx_pj_activite', columns: {#activiteCode})
class ControlesPJ extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get activiteCode => text().nullable()();
  DateTimeColumn get dateDebutActivite => dateTime().nullable()();
  DateTimeColumn get dateFinActivite => dateTime().nullable()();
  DateTimeColumn get datePJ => dateTime().nullable()();
  TextColumn get ligneBudgetaire => text().nullable()();
  TextColumn get beneficiaire => text().nullable()();
  TextColumn get typePJ => text().nullable()();
  RealColumn get montantAlloue => real().withDefault(const Constant(0))();
  RealColumn get montantPaye => real().withDefault(const Constant(0))();
  RealColumn get montantPJ => real().withDefault(const Constant(0))();
  TextColumn get pjRecue => text().withDefault(const Constant(''))();
  TextColumn get pjConforme => text().withDefault(const Constant(''))();

  /// Checklist des PJ requises (JSON) : pièce → « reçue » / « date conforme ».
  TextColumn get checklistPJ => text().nullable()();
  TextColumn get observation => text().nullable()();
}

/// Journal des dépenses (feuille `J.Depenses`).
@DataClassName('Depense')
@TableIndex(name: 'idx_depense_activite', columns: {#codeActivite})
class Depenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get dateEnregistrement => dateTime().nullable()();
  DateTimeColumn get datePieceComptable => dateTime().nullable()();
  TextColumn get periodeAutorisee => text().nullable()();
  TextColumn get fonds => text().withDefault(const Constant('Banque'))();
  TextColumn get refDecaissement => text().nullable()();
  TextColumn get refPieceDepense => text().nullable()();
  TextColumn get dctNumero => text().nullable()();
  TextColumn get codeActivite => text().nullable()();
  TextColumn get codeBudget => text().nullable()();
  TextColumn get designation => text().withDefault(const Constant(''))();
  TextColumn get beneficiaire => text().nullable()();

  /// Contrôle PJ d'origine quand la ligne est créée/mise à jour par le
  /// dossier PJ (permet d'afficher le statut de conformité de la pièce).
  IntColumn get controlePJId => integer().nullable()();
  TextColumn get unite => text().nullable()();
  RealColumn get nbJrMois => real().withDefault(const Constant(0))();
  RealColumn get quantite => real().withDefault(const Constant(0))();
  RealColumn get frequence => real().withDefault(const Constant(1))();
  RealColumn get pu => real().withDefault(const Constant(0))();
  TextColumn get observation => text().nullable()();
}

/// Journal de banque (feuille `J.Banque`).
@DataClassName('BanqueOperation')
@TableIndex(name: 'idx_banque_date', columns: {#date})
class BanqueOperations extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get refPiece => text().nullable()();
  TextColumn get type => text().withDefault(const Constant('Opération'))();
  TextColumn get refCheque => text().nullable()();
  TextColumn get description => text().withDefault(const Constant(''))();
  RealColumn get recettes => real().withDefault(const Constant(0))();
  RealColumn get depenses => real().withDefault(const Constant(0))();
  TextColumn get bailleur => text().nullable()();
  TextColumn get beneficiaire => text().nullable()();
  TextColumn get observation => text().nullable()();
}

/// Relevé bancaire (partie droite de `Rappr Banc`).
@DataClassName('ReleveBancaireLigne')
class ReleveBancaire extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime().nullable()();
  TextColumn get reference => text().nullable()();
  TextColumn get libelle => text().nullable()();
  RealColumn get debit => real().withDefault(const Constant(0))();
  RealColumn get credit => real().withDefault(const Constant(0))();
}

/// Utilisateurs : identité, profil et rôle.
@DataClassName('Utilisateur')
class Utilisateurs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get identifiant => text().unique()();
  TextColumn get nom => text()();
  TextColumn get role => text().withDefault(const Constant('GESTIONNAIRE'))();
  BoolColumn get actif => boolean().withDefault(const Constant(true))();
  TextColumn get motDePasseHash => text().nullable()();

  // --- Profil utilisateur (certains champs obligatoires, d'autres facultatifs)
  TextColumn get prenomUtilisateur => text().nullable()();
  TextColumn get fonction => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get telephone => text().nullable()();

  /// Photo de profil encodée en base64 (data URI), facultative.
  TextColumn get photo => text().nullable()();
  DateTimeColumn get dateCreation => dateTime().nullable()();
  DateTimeColumn get derniereConnexion => dateTime().nullable()();
}

/// Journal d'audit (historique des modifications).
@DataClassName('JournalAuditEntry')
@TableIndex(name: 'idx_audit_entite', columns: {#entite})
class JournalAudit extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get dateHeure => dateTime().withDefault(currentDateAndTime)();
  TextColumn get utilisateur => text().withDefault(const Constant('systeme'))();
  TextColumn get action => text()();
  TextColumn get entite => text()();
  TextColumn get entiteId => text().nullable()();
  TextColumn get champ => text().nullable()();
  TextColumn get ancienneValeur => text().nullable()();
  TextColumn get nouvelleValeur => text().nullable()();
}

/// Paramètres clé/valeur (banque, compte, devise, exercice…).
@DataClassName('Parametre')
class Parametres extends Table {
  TextColumn get cle => text()();
  TextColumn get valeur => text().withDefault(const Constant(''))();
  @override
  Set<Column> get primaryKey => {cle};
}
