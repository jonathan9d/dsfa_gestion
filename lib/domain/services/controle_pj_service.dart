import '../../data/database/database.dart';
import '../../data/repositories/activite_repository.dart';
import '../../data/repositories/controle_pj_repository.dart';
import '../models.dart';
import '../statuts.dart';
import 'presence_indemnite_service.dart';
import 'regles_metier.dart';

/// Service métier du contrôle des pièces justificatives.
///
/// Reproduit les colonnes calculées de `CONTROLE_PJ` : écarts, cohérence de
/// date, montant contrôlé, budget indemnités disponible, contrôle
/// présence/indemnité et statut final.
class ControlePJService {
  ControlePJService({
    required ControlesPJRepository controles,
    required LignesBudgetRepository lignesBudget,
    required PresenceIndemniteService presenceService,
  })  : _controles = controles,
        _lignesBudget = lignesBudget,
        _presenceService = presenceService;

  final ControlesPJRepository _controles;
  final LignesBudgetRepository _lignesBudget;
  final PresenceIndemniteService _presenceService;

  /// Lignes budgétaires d'indemnités (détermine si le contrôle
  /// présence/indemnité s'applique).
  static bool estLigneIndemnite(String? ligne) {
    final l = (ligne ?? '').toUpperCase();
    return l.contains('INDEMNIT') || l.contains('INDEMNITÉ');
  }

  Future<ResultatControlePJ> evaluer(ControlePJ c) async {
    final ecartBudget =
        ReglesMetier.ecartBudget(c.montantPaye, c.montantAlloue);
    final ecartPJ = ReglesMetier.ecartPJ(c.montantPJ, c.montantPaye);
    final dateOk = ReglesMetier.datePJCoherente(
      dateDebut: c.dateDebutActivite,
      dateFin: c.dateFinActivite,
      datePJ: c.datePJ,
    );

    double montantControle = 0;
    double budgetIndemnites = 0;
    var controlePresence = ControlePresenceIndemnite.conforme;

    final code = c.activiteCode;
    if (code != null && code.isNotEmpty) {
      final lignes = await _lignesBudget.parActivite(code);
      budgetIndemnites = lignes
          .where((l) => l.ligneBudgetaire == c.ligneBudgetaire)
          .fold<double>(0, (s, l) => s + l.montantAlloue);

      if (estLigneIndemnite(c.ligneBudgetaire)) {
        montantControle =
            await _presenceService.montantIndemnitesConformes(code);
        final anomalie = await _presenceService.aAnomaliePresence(code);
        controlePresence = ReglesMetier.controlePresenceIndemnite(
          aAnomaliePresence: anomalie,
          montantControle: montantControle,
          budgetIndemnitesDisponible: budgetIndemnites,
        );
      }
    }

    final statut = ReglesMetier.statutFinalPJ(
      pjRecue: c.pjRecue,
      datePJCoherente: dateOk,
      ecartBudget: ecartBudget,
      ecartPJ: ecartPJ,
      pjConforme: c.pjConforme,
      controlePresenceIndemnite: controlePresence,
    );

    return ResultatControlePJ(
      controleId: c.id,
      ecartBudget: ecartBudget,
      ecartPJ: ecartPJ,
      datePJCoherente: dateOk,
      montantControle: montantControle,
      budgetIndemnitesDisponible: budgetIndemnites,
      controlePresenceIndemnite: controlePresence,
      statutFinal: statut,
    );
  }

  Future<List<(ControlePJ, ResultatControlePJ)>> evaluerTout() async {
    final controles = await _controles.getAll();
    final resultats = <(ControlePJ, ResultatControlePJ)>[];
    for (final c in controles) {
      resultats.add((c, await evaluer(c)));
    }
    return resultats;
  }

  /// Synthèse utilisée par le tableau de bord.
  Future<Map<String, int>> compteursStatuts() async {
    final resultats = await evaluerTout();
    final map = <String, int>{
      StatutFinalPJ.conforme: 0,
      StatutFinalPJ.nonConforme: 0,
      StatutFinalPJ.aVerifier: 0,
      StatutFinalPJ.pjNonRecue: 0,
      StatutFinalPJ.datePjNonConforme: 0,
    };
    for (final (_, r) in resultats) {
      if (r.statutFinal.isEmpty) continue;
      map[r.statutFinal] = (map[r.statutFinal] ?? 0) + 1;
    }
    return map;
  }
}
