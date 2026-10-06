import 'package:meta/meta.dart';

import '../../data/database/database.dart';
import '../../data/repositories/activite_repository.dart';
import '../../data/repositories/finance_repository.dart';
import 'journal_depenses_service.dart';

/// Ligne du rapport financier (feuille `RAPPORT FINANCIER`).
///
/// `Dépenses réalisées` provient du journal des dépenses, lui-même alimenté
/// automatiquement par le dossier PJ (quantité × prix × fréquence).
@immutable
class LigneRapportFinancier {
  const LigneRapportFinancier({
    required this.codeActivite,
    required this.codeBudget,
    required this.descriptionActivite,
    required this.ligneBudgetaire,
    required this.montantAlloue,
    required this.depensesRealisees,
    required this.observation,
  });

  final String codeActivite;
  final String codeBudget;
  final String descriptionActivite;
  final String ligneBudgetaire;
  final double montantAlloue;
  final double depensesRealisees;
  final String observation;

  /// `Écart = Montant alloué − Dépenses réalisées`.
  double get ecart => montantAlloue - depensesRealisees;

  /// Dépassement du budget alloué.
  bool get depassement => ecart < -0.000001;

  String get observationFinale {
    if (observation.trim().isNotEmpty) return observation;
    if (depassement) return 'Dépassement du budget alloué';
    if (depensesRealisees == 0) return 'Aucune dépense enregistrée';
    return '';
  }
}

/// Récapitulatif chiffré de l'ensemble des lignes budgétaires.
@immutable
class ResumeRapportFinancier {
  const ResumeRapportFinancier({
    required this.lignes,
    required this.totalAlloue,
    required this.totalRealise,
  });

  final List<LigneRapportFinancier> lignes;
  final double totalAlloue;
  final double totalRealise;

  double get totalEcart => totalAlloue - totalRealise;

  double get tauxConsommation =>
      totalAlloue == 0 ? 0 : totalRealise / totalAlloue;
}

/// Service du rapport financier : rapproche le budget alloué des dépenses
/// réalisées, activité par activité et ligne budgétaire par ligne budgétaire.
class RapportFinancierService {
  RapportFinancierService({
    required LignesBudgetRepository lignesBudget,
    required ActivitesRepository activites,
    required DepensesRepository depenses,
  })  : _lignesBudget = lignesBudget,
        _activites = activites,
        _depenses = depenses;

  final LignesBudgetRepository _lignesBudget;
  final ActivitesRepository _activites;
  final DepensesRepository _depenses;

  /// Dépenses réalisées d'une ligne : journal des dépenses alimenté par le
  /// dossier PJ (désignation = ligne budgétaire [ — type de pièce]).
  Future<double> _depensesLigne(
    List<Depense> depenses,
    String codeActivite,
    String ligneBudgetaire,
  ) async {
    var total = 0.0;
    final ligne = ligneBudgetaire.trim().toLowerCase();
    for (final d in depenses) {
      if ((d.codeActivite ?? '') != codeActivite) continue;
      final designation = d.designation.trim().toLowerCase();
      if (designation == ligne || designation.startsWith('$ligne —')) {
        total += JournalDepensesService.montantDepense(d);
      }
    }
    return total;
  }

  Future<ResumeRapportFinancier> calculer() async {
    final lignes = await _lignesBudget.getAll();
    final activites = await _activites.getAll();
    final depenses = await _depenses.getAll();
    final parCode = {for (final a in activites) a.code: a};

    final resultats = <LigneRapportFinancier>[];
    var totalAlloue = 0.0;
    var totalRealise = 0.0;

    for (final l in lignes) {
      final activite = parCode[l.activiteCode];
      final realise = await _depensesLigne(
        depenses,
        l.activiteCode,
        l.ligneBudgetaire,
      );
      totalAlloue += l.montantAlloue;
      totalRealise += realise;
      resultats.add(
        LigneRapportFinancier(
          codeActivite: l.activiteCode,
          codeBudget: activite?.codeBudget ?? '',
          descriptionActivite: activite?.description ?? '',
          ligneBudgetaire: l.ligneBudgetaire,
          montantAlloue: l.montantAlloue,
          depensesRealisees: realise,
          observation: l.observation ?? '',
        ),
      );
    }

    return ResumeRapportFinancier(
      lignes: resultats,
      totalAlloue: totalAlloue,
      totalRealise: totalRealise,
    );
  }
}
