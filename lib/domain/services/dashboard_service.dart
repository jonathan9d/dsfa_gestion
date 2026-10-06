import '../../data/repositories/activite_repository.dart';
import '../../data/repositories/controle_pj_repository.dart';
import '../../data/repositories/finance_repository.dart';
import '../../data/repositories/participant_repository.dart';
import '../../data/repositories/presence_repository.dart';
import '../models.dart';
import '../statuts.dart';
import 'controle_pj_service.dart';
import 'presence_indemnite_service.dart';
import 'regles_metier.dart';

/// Service du tableau de bord (feuille `TABLEAU_DE_BORD`).
///
/// Tous les indicateurs proviennent de SQLite et des services métier :
/// aucune donnée n'est calculée dans les widgets.
class DashboardService {
  DashboardService({
    required ControlePJService controlePJ,
    required PresenceIndemniteService presenceService,
    required ControlesPJRepository controles,
    required ActivitesRepository activites,
    required ParticipantsRepository participants,
    required PresencesRepository presences,
    required DepensesRepository depenses,
    required BanqueRepository banque,
  })  : _controlePJ = controlePJ,
        _presenceService = presenceService,
        _controles = controles,
        _activites = activites,
        _participants = participants,
        _presences = presences,
        _depenses = depenses,
        _banque = banque;

  final ControlePJService _controlePJ;
  final PresenceIndemniteService _presenceService;
  final ControlesPJRepository _controles;
  final ActivitesRepository _activites;
  final ParticipantsRepository _participants;
  final PresencesRepository _presences;
  final DepensesRepository _depenses;
  final BanqueRepository _banque;

  Future<IndicateursDashboard> calculer() async {
    final controles = await _controles.getAll();
    final lignes = await _activites.getAll();
    final participants = await _participants.getAll();
    final presences = await _presences.getAll();
    final depenses = await _depenses.getAll();
    final banque = await _banque.getAll();

    double alloue = 0, paye = 0, pj = 0;
    for (final c in controles) {
      alloue += c.montantAlloue;
      paye += c.montantPaye;
      pj += c.montantPJ;
    }
    final ecartBudget = ReglesMetier.ecartBudget(paye, alloue);
    final ecartPJ = ReglesMetier.ecartPJ(pj, paye);

    final (theorique, recue) = await _presenceService.totauxGlobaux();

    final totalDepenses = depenses.fold<double>(
        0,
        (s, d) => s +
            ReglesMetier.montantDepense(
              nbJrMois: d.nbJrMois,
              quantite: d.quantite,
              frequence: d.frequence,
              pu: d.pu,
            ));

    final recettes = banque.fold<double>(0, (s, o) => s + o.recettes);
    final sorties = banque.fold<double>(0, (s, o) => s + o.depenses);

    final compteurs = await _controlePJ.compteursStatuts();

    return IndicateursDashboard(
      montantTotalAlloue: alloue,
      montantTotalPaye: paye,
      montantTotalPJ: pj,
      ecartBudgetTotal: ecartBudget,
      ecartPJTotal: ecartPJ,
      nombreActivites: lignes.length,
      nombreParticipants: participants.length,
      nombrePresences: presences.length,
      totalIndemnitesTheoriques: theorique,
      totalIndemnitesRecues: recue,
      totalDepenses: totalDepenses,
      soldeBancaire: ReglesMetier.soldeProgressif(recettes, sorties),
      dossiersConformes: compteurs[StatutFinalPJ.conforme] ?? 0,
      dossiersNonConformes: compteurs[StatutFinalPJ.nonConforme] ?? 0,
      pjNonRecues: compteurs[StatutFinalPJ.pjNonRecue] ?? 0,
      datesPJNonConformes: compteurs[StatutFinalPJ.datePjNonConforme] ?? 0,
      anomaliesPresence:
          compteurs[StatutFinalPJ.nonConforme] ?? 0,
      pjAverifier: compteurs[StatutFinalPJ.aVerifier] ?? 0,
    );
  }

  /// Répartition des dépenses par rubrique/ligne (graphique).
  Future<List<SeriePoint>> depensesParRubrique() async {
    final controles = await _controles.getAll();
    final map = <String, double>{};
    for (final c in controles) {
      final cle = (c.ligneBudgetaire ?? 'Non défini').trim();
      map[cle] = (map[cle] ?? 0) + c.montantPaye;
    }
    final points = map.entries
        .where((e) => e.value > 0)
        .map((e) => SeriePoint(e.key, e.value))
        .toList()
      ..sort((a, b) => b.valeur.compareTo(a.valeur));
    return points;
  }

  /// Évolution mensuelle des dépenses (graphique).
  Future<List<SeriePoint>> evolutionDepenses() async {
    final depenses = await _depenses.getAll();
    final map = <String, double>{};
    for (final d in depenses) {
      final date = d.dateEnregistrement;
      if (date == null) continue;
      final cle = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      map[cle] = (map[cle] ?? 0) +
          ReglesMetier.montantDepense(
            nbJrMois: d.nbJrMois,
            quantite: d.quantite,
            frequence: d.frequence,
            pu: d.pu,
          );
    }
    final cles = map.keys.toList()..sort();
    return cles.map((k) => SeriePoint(k, map[k]!)).toList();
  }

  /// Répartition des activités par statut (graphique).
  Future<List<SeriePoint>> repartitionActivites() async {
    final activites = await _activites.getAll();
    final map = <String, double>{};
    for (final a in activites) {
      map[a.statut] = (map[a.statut] ?? 0) + 1;
    }
    return map.entries.map((e) => SeriePoint(e.key, e.value)).toList();
  }
}
