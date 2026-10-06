import '../../data/database/database.dart';
import '../../data/repositories/activite_repository.dart';
import '../../data/repositories/participant_repository.dart';
import '../../data/repositories/presence_repository.dart';
import '../models.dart';
import '../statuts.dart';
import 'regles_metier.dart';

/// Service métier des présences et indemnités.
///
/// Reproduit les colonnes calculées de `PRESENCES_INDEMNITES`
/// (indemnité théorique, écart, contrôles, résultat).
class PresenceIndemniteService {
  PresenceIndemniteService({
    required PresencesRepository presences,
    required ParticipantsRepository participants,
    required ActivitesRepository activites,
  })  : _presences = presences,
        _participants = participants,
        _activites = activites;

  final PresencesRepository _presences;
  final ParticipantsRepository _participants;
  final ActivitesRepository _activites;

  /// Calcule le résultat de contrôle d'une ligne de présence.
  Future<ResultatPresenceIndemnite> evaluer(
    Presence presence,
    Activite? activite,
    Participant? participant,
  ) async {
    final dansPeriode = ReglesMetier.dateDansPeriode(
      presence.date,
      activite?.dateDebut,
      activite?.dateFin,
    );
    final justifie = ReglesMetier.presenceJustifiePaiement(
      statutPresence: presence.statut,
      signaturePreuve: presence.signaturePreuve,
    );
    final theorique = ReglesMetier.indemniteTheorique(
      nombreJoursPresents: presence.statut == 'Présent' ? 1 : 0,
      tauxJournalier: presence.tauxJournalier,
    );
    final ecart = ReglesMetier.ecartIndemnite(presence.indemniteRecue, theorique);
    final conforme = ReglesMetier.montantConforme(ecart);
    final resultat = ReglesMetier.resultatControle(
      dateDansPeriode: dansPeriode,
      presenceJustifie: justifie,
      montantConforme: conforme,
    );
    final p = participant;
    return ResultatPresenceIndemnite(
      presenceId: presence.id,
      activiteCode: presence.activiteCode,
      participantId: presence.participantId,
      participantNom: p == null ? '#${presence.participantId}' : _nomComplet(p),
      date: presence.date,
      statutPresence: presence.statut,
      tauxJournalier: presence.tauxJournalier,
      indemniteTheorique: theorique,
      indemniteRecue: presence.indemniteRecue,
      dateDansPeriode: dansPeriode,
      presenceJustifiePaiement: justifie,
      montantConforme: conforme,
      resultat: resultat,
    );
  }

  /// Évalue toutes les présences d'une activité.
  Future<List<ResultatPresenceIndemnite>> evaluerActivite(
      String activiteCode) async {
    final activite = await _activites.parCode(activiteCode);
    final presences = await _presences.parActivite(activiteCode);
    final participants = {
      for (final p in await _participants.getAll()) p.id: p,
    };
    final resultats = <ResultatPresenceIndemnite>[];
    for (final pres in presences) {
      resultats.add(await evaluer(
        pres,
        activite,
        participants[pres.participantId],
      ));
    }
    return resultats;
  }

  /// Synthèse par participant : nombre de jours présents, indemnité théorique
  /// (nombre de jours présents × taux), indemnité reçue et statut global.
  Future<List<SyntheseIndemniteParticipant>> syntheseParParticipant(
      String activiteCode) async {
    final activite = await _activites.parCode(activiteCode);
    final presences = await _presences.parActivite(activiteCode);
    final participants = {
      for (final p in await _participants.getAll()) p.id: p,
    };

    final parParticipant = <int, List<Presence>>{};
    for (final p in presences) {
      parParticipant.putIfAbsent(p.participantId, () => []).add(p);
    }

    final resultats = <SyntheseIndemniteParticipant>[];
    for (final entry in parParticipant.entries) {
      final lignes = entry.value;
      final taux = lignes.isNotEmpty ? lignes.first.tauxJournalier : 0.0;
      final joursPresents = lignes.where((l) => l.statut == 'Présent').length;
      final theorique = ReglesMetier.indemniteTheorique(
        nombreJoursPresents: joursPresents,
        tauxJournalier: taux,
      );
      final recue = lignes.fold<double>(0, (s, l) => s + l.indemniteRecue);
      final evaluations = <ResultatPresenceIndemnite>[];
      for (final l in lignes) {
        evaluations.add(await evaluer(l, activite, participants[entry.key]));
      }
      final statut = evaluations.any((e) => e.statut == StatutControle.nonConforme)
          ? StatutControle.nonConforme
          : evaluations.any((e) => e.statut == StatutControle.aVerifier)
              ? StatutControle.aVerifier
              : StatutControle.conforme;
      final p = participants[entry.key];
      resultats.add(SyntheseIndemniteParticipant(
        participantId: entry.key,
        participantNom: p == null ? '#${entry.key}' : _nomComplet(p),
        nombreJours: lignes.length,
        nombreJoursPresents: joursPresents,
        tauxJournalier: taux,
        indemniteTheorique: theorique,
        indemniteRecue: recue,
        statut: statut,
      ));
    }
    resultats.sort((a, b) => a.participantNom.compareTo(b.participantNom));
    return resultats;
  }

  /// Somme des indemnités théoriques conformes d'une activité
  /// (utilisée par le contrôle PJ : colonne `Montant contrôlées`).
  Future<double> montantIndemnitesConformes(String activiteCode) async {
    final resultats = await evaluerActivite(activiteCode);
    return resultats
        .where((r) => r.resultat == ResultatPresence.conforme)
        .fold<double>(0, (s, r) => s + r.indemniteTheorique);
  }

  /// Indique si l'activité possède des lignes de présence/indemnité non
  /// conformes (utilisé par `Contrôle présence/indemnité`).
  Future<bool> aAnomaliePresence(String activiteCode) async {
    final resultats = await evaluerActivite(activiteCode);
    return resultats.any((r) =>
        r.resultat != ResultatPresence.conforme &&
        r.resultat.isNotEmpty);
  }

  /// Totaux globaux des indemnités.
  Future<(double theorique, double recue)> totauxGlobaux() async {
    final presences = await _presences.getAll();
    double theorique = 0;
    double recue = 0;
    for (final p in presences) {
      theorique += ReglesMetier.indemniteTheorique(
        nombreJoursPresents: p.statut == 'Présent' ? 1 : 0,
        tauxJournalier: p.tauxJournalier,
      );
      recue += p.indemniteRecue;
    }
    return (theorique, recue);
  }

  static String _nomComplet(Participant p) =>
      '${p.nom} ${p.prenom}'.trim();
}
