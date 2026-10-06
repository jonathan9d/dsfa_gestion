import 'package:drift/drift.dart' as drift;

import '../../data/database/database.dart';
import '../../data/repositories/activite_repository.dart';
import '../../data/repositories/finance_repository.dart';
import 'regles_metier.dart';

/// Synchronisation automatique du **journal des dépenses** avec les autres
/// écrans :
///
///  * enregistrement d'un dossier PJ → ligne de dépense créée ou mise à jour
///    (dépense réalisée = montant de la pièce) ;
///  * mise à jour des indemnités d'une activité → ligne « indemnités »
///    mise à jour dans le journal.
///
/// Une ligne synchronisée est reconnaissable à son lien [Depense.controlePJId]
/// (dossier PJ) ou à sa désignation d'origine (indemnités) : aucune donnée
/// saisie à la main n'est écrasée.
class JournalDepensesService {
  JournalDepensesService({
    required DepensesRepository depenses,
    required ActivitesRepository activites,
  })  : _depenses = depenses,
        _activites = activites;

  final DepensesRepository _depenses;
  final ActivitesRepository _activites;

  /// Préfixe des lignes d'indemnités créées automatiquement.
  static const prefixeIndemnite = 'INDEMNITÉS';
  static const marqueurIndemnite = 'AUTO-INDEMNITES';

  /// Crée ou met à jour la ligne de dépense liée à un contrôle PJ.
  Future<void> synchroniserControlePJ(ControlePJ c) async {
    if (c.id <= 0) return;
    final montant = c.montantPJ;
    final existantes = await _depenses.getAll();
    Depense? liee;
    for (final d in existantes) {
      if (d.controlePJId == c.id) {
        liee = d;
        break;
      }
    }

    final activite = (c.activiteCode ?? '').isEmpty
        ? null
        : await _activites.parCode(c.activiteCode!);
    final descriptionPJ = (c.typePJ ?? '').trim();
    final designation = (c.ligneBudgetaire ?? '').trim().isEmpty
        ? (descriptionPJ.isEmpty ? 'Pièce justificative' : descriptionPJ)
        : (descriptionPJ.isEmpty
            ? c.ligneBudgetaire!.trim()
            : '${c.ligneBudgetaire!.trim()} — $descriptionPJ');

    final companion = DepensesCompanion(
      dateEnregistrement: drift.Value(c.datePJ ?? liee?.dateEnregistrement),
      datePieceComptable: drift.Value(c.datePJ),
      codeActivite: drift.Value(c.activiteCode),
      codeBudget: drift.Value(
        activite?.codeBudget ?? liee?.codeBudget ?? '',
      ),
      designation: drift.Value(designation),
      // Description des pièces justificatives : facture ou état de paiement.
      dctNumero: drift.Value(descriptionPJ.isEmpty ? liee?.dctNumero : descriptionPJ),
      refPieceDepense: drift.Value(liee?.refPieceDepense ?? ''),
      controlePJId: const drift.Value.absent(),
      nbJrMois: const drift.Value(1),
      quantite: const drift.Value(1),
      frequence: const drift.Value(1),
      pu: drift.Value(montant),
      observation: drift.Value(
        (c.observation ?? '').isEmpty ? liee?.observation : c.observation,
      ),
    );

    if (liee == null) {
      await _depenses.insert(
        DepensesCompanion.insert(
          designation: drift.Value(designation),
          nbJrMois: const drift.Value(1),
          quantite: const drift.Value(1),
          frequence: const drift.Value(1),
          pu: drift.Value(montant),
          controlePJId: drift.Value(c.id),
          dateEnregistrement: drift.Value(c.datePJ ?? DateTime.now()),
          datePieceComptable: drift.Value(c.datePJ),
          codeActivite: drift.Value(c.activiteCode),
          codeBudget: drift.Value(activite?.codeBudget ?? ''),
          dctNumero: drift.Value(descriptionPJ),
          observation: drift.Value(c.observation ?? ''),
        ),
      );
    } else {
      await _depenses.update(liee.id, companion);
    }
  }

  /// Supprime la ligne de dépense liée à un contrôle PJ supprimé.
  Future<void> retirerControlePJ(int controleId) async {
    final existantes = await _depenses.getAll();
    for (final d in existantes) {
      if (d.controlePJId == controleId) {
        await _depenses.delete(d.id);
      }
    }
  }

  /// Crée ou met à jour la ligne d'indemnités d'une activité.
  Future<void> synchroniserIndemnites({
    required String activiteCode,
    required double montant,
    String? observation,
  }) async {
    if (activiteCode.trim().isEmpty) return;
    final existantes = await _depenses.parActivite(activiteCode);
    Depense? liee;
    for (final d in existantes) {
      if ((d.refDecaissement ?? '') == marqueurIndemnite) {
        liee = d;
        break;
      }
    }
    // Plus aucune indemnité payée (saisies supprimées ou toutes « à payer ») :
    // la ligne automatique est retirée, sinon le journal continuerait
    // d'afficher un montant périmé.
    if (montant <= 0) {
      if (liee != null) await _depenses.delete(liee.id);
      return;
    }
    final activite = await _activites.parCode(activiteCode);
    final designation = '$prefixeIndemnite — $activiteCode';
    final companion = DepensesCompanion(
      designation: drift.Value(designation),
      codeActivite: drift.Value(activiteCode),
      codeBudget: drift.Value(activite?.codeBudget ?? liee?.codeBudget ?? ''),
      nbJrMois: const drift.Value(1),
      quantite: const drift.Value(1),
      frequence: const drift.Value(1),
      pu: drift.Value(montant),
      observation: drift.Value(observation ?? liee?.observation ?? ''),
    );
    if (liee == null) {
      await _depenses.insert(
        DepensesCompanion.insert(
          designation: drift.Value(designation),
          nbJrMois: const drift.Value(1),
          quantite: const drift.Value(1),
          frequence: const drift.Value(1),
          pu: drift.Value(montant),
          refDecaissement: const drift.Value(marqueurIndemnite),
          codeActivite: drift.Value(activiteCode),
          codeBudget: drift.Value(activite?.codeBudget ?? ''),
          dateEnregistrement: const drift.Value.absent(),
          observation: drift.Value(observation ?? ''),
        ),
      );
    } else {
      await _depenses.update(liee.id, companion);
    }
  }

  /// Montant total des dépenses réalisées pour une ligne budgétaire.
  static double montantDepense(Depense d) => ReglesMetier.montantDepense(
        nbJrMois: d.nbJrMois,
        quantite: d.quantite,
        frequence: d.frequence,
        pu: d.pu,
      );
}
