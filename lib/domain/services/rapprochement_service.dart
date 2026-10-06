import '../../data/database/database.dart';
import '../../data/repositories/finance_repository.dart';
import '../models.dart';
import '../statuts.dart';
import 'regles_metier.dart';

/// Service de rapprochement bancaire (feuille `Rappr Banc`).
///
/// Compare le journal de banque et le relevé bancaire, calcule les soldes
/// rapprochés et l'écart, et classe chaque ligne.
class RapprochementService {
  RapprochementService({
    required BanqueRepository banque,
    required ReleveBancaireRepository releve,
  }) : _banque = banque,
       _releve = releve;

  final BanqueRepository _banque;
  final ReleveBancaireRepository _releve;

  Future<ResultatRapprochement> calculer() async {
    final journal = await _banque.getAll();
    final releve = await _releve.getAll();

    // Solde initial du journal = première ligne de type SOLDE.
    final soldeInitial = journal
        .where((j) => j.type.toUpperCase() == 'SOLDE')
        .fold<double>(0, (s, j) => s + j.recettes - j.depenses);

    final operations = journal
        .where((j) => j.type.toUpperCase() != 'SOLDE')
        .toList();

    final relevesParRef = <String, List<ReleveBancaireLigne>>{};
    for (final ligne in releve) {
      final ref = (ligne.reference ?? '').trim().toUpperCase();
      if (ref.isEmpty) continue;
      relevesParRef.putIfAbsent(ref, () => []).add(ligne);
    }

    final lignes = <LigneRapprochement>[];
    final relevesTraites = <int>{};

    for (final op in operations) {
      final ref = (op.refPiece ?? '').trim().toUpperCase();
      final candidats = (relevesParRef[ref] ?? [])
          .where((r) => !relevesTraites.contains(r.id))
          .toList();
      if (candidats.isEmpty) {
        lignes.add(
          LigneRapprochement(
            date: op.date,
            reference: op.refPiece ?? '',
            libelle: op.description,
            montantJournal: op.recettes - op.depenses,
            montantReleve: 0,
            statut: StatutRapprochement.nonTrouve,
          ),
        );
      } else {
        final montantJournal = op.recettes - op.depenses;
        final correspondancesExactes = candidats
            .where(
              (r) => ((r.credit - r.debit) - montantJournal).abs() < 0.000001,
            )
            .toList();
        final correspondance = correspondancesExactes.isNotEmpty
            ? correspondancesExactes.first
            : candidats.first;
        relevesTraites.add(correspondance.id);
        final montantReleve = correspondance.credit - correspondance.debit;
        final ecart = montantJournal - montantReleve;
        lignes.add(
          LigneRapprochement(
            date: op.date,
            reference: op.refPiece ?? '',
            libelle: op.description,
            montantJournal: montantJournal,
            montantReleve: montantReleve,
            statut: ecart.abs() < 0.000001
                ? StatutRapprochement.rapproche
                : StatutRapprochement.difference,
          ),
        );
      }
    }

    // Lignes du relevé sans contrepartie dans le journal.
    for (final r in releve) {
      if (relevesTraites.contains(r.id)) continue;
      if ((r.reference ?? '').trim().isEmpty) continue;
      lignes.add(
        LigneRapprochement(
          date: r.date,
          reference: r.reference ?? '',
          libelle: r.libelle ?? '',
          montantJournal: 0,
          montantReleve: r.credit - r.debit,
          statut: StatutRapprochement.nonTrouve,
        ),
      );
    }

    // Soldes rapprochés : solde initial + crédits − débits.
    final totalDebitJournal = operations.fold<double>(
      0,
      (s, o) => s + o.depenses,
    );
    final totalCreditJournal = operations.fold<double>(
      0,
      (s, o) => s + o.recettes,
    );
    final totalDebitReleve = releve.fold<double>(0, (s, r) => s + r.debit);
    final totalCreditReleve = releve.fold<double>(0, (s, r) => s + r.credit);

    final soldeJournal = soldeInitial + totalCreditJournal - totalDebitJournal;
    final soldeReleve = totalCreditReleve - totalDebitReleve;

    return ResultatRapprochement(
      soldeJournal: soldeJournal,
      soldeReleve: soldeReleve,
      lignes: lignes,
    );
  }

  /// Solde bancaire courant (recettes − dépenses cumulées).
  Future<double> soldeCourant() async {
    final ops = await _banque.getAll();
    final recettes = ops.fold<double>(0, (s, o) => s + o.recettes);
    final depenses = ops.fold<double>(0, (s, o) => s + o.depenses);
    return ReglesMetier.soldeProgressif(recettes, depenses);
  }
}
