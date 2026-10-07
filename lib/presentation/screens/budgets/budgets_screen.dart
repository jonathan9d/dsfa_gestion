import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../domain/rubriques.dart';
import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/tableau.dart';
import 'apercu_budget_dialog.dart';
import 'ligne_budget_dialog.dart';

/// Gestion des lignes budgétaires allouées (REFERENTIEL_BUDGET).
///
/// Le montant alloué est **toujours calculé automatiquement** (aucun champ de
/// saisie, aucun bouton « Appliquer ») : quantité × jours × taux, ou formule
/// du type de budget sélectionné.
class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  final _recherche = TextEditingController();

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lignes = ref.watch(lignesBudgetProvider);

    return Scaffold(
      body: Column(
        children: [
          EnTetePage(
            titre: 'Budgets',
            sousTitre:
                'Lignes budgétaires allouées — montant calculé automatiquement '
                'selon les règles',
            actions: [
              // Une seule action principale par écran : « Voir » reste une
              // action secondaire, « Nouvelle ligne » porte l'accent.
              OutlinedButton.icon(
                onPressed: lignes.value == null
                    ? null
                    : () => _ouvrirApercu(lignes.value!),
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('Voir'),
              ),
              FilledButton.icon(
                onPressed: () => _ouvrirFormulaire(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nouvelle ligne'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: 380,
              child: ChampRecherche(
                controller: _recherche,
                hint: 'Rechercher une ligne budgétaire',
                onChanged: (v) =>
                    ref.read(filtreRechercheProvider.notifier).state = v,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: lignes.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EtatErreur(erreur: e),
              data: (liste) {
                if (liste.isEmpty) {
                  return EtatVide(
                    message:
                        'Aucune ligne budgétaire enregistrée pour le moment.\n'
                        'Créez une ligne pour suivre les montants alloués.',
                    icone: Icons.savings_outlined,
                    action: FilledButton.icon(
                      onPressed: () => _ouvrirFormulaire(),
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter une ligne'),
                    ),
                  );
                }
                return _TableauBudgets(lignes: liste, ref: ref);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _ouvrirFormulaire({LigneBudget? ligne}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => LigneBudgetDialog(ligne: ligne),
    );
    if (ok == true && mounted) {
      notifier(context, 'Ligne budgétaire enregistrée');
    }
  }

  /// Pré-impression du budget : récapitulatif automatique + exports.
  Future<void> _ouvrirApercu(List<LigneBudget> lignes) async {
    await showDialog<void>(
      context: context,
      builder: (_) => ApercuBudgetDialog(lignes: lignes),
    );
  }
}

class _TableauBudgets extends StatelessWidget {
  const _TableauBudgets({required this.lignes, required this.ref});

  final List<LigneBudget> lignes;
  final WidgetRef ref;

  static String _rubriqueDe(LigneBudget l, List<String> rubriques) {
    final details = _detailsLigne(l);
    return RubriquesBudget.resoudre(
      ligneBudgetaire: l.ligneBudgetaire,
      typeBudget: l.typeBudget,
      rubriqueEnregistree: '${details['rubrique'] ?? ''}',
      rubriques: rubriques,
    );
  }

  static Map<String, dynamic> _detailsLigne(LigneBudget l) {
    final brut = l.details;
    if (brut == null || brut.trim().isEmpty) return <String, dynamic>{};
    try {
      return (jsonDecode(brut) as Map).cast<String, dynamic>();
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrevisionnel = lignes.fold<double>(
      0,
      (s, l) => s + montantPrevisionnelLigneBudget(l),
    );
    final totalAlloue = lignes.fold<double>(0, (s, l) => s + l.montantAlloue);
    final confirmees = lignes.where((l) => l.montantAlloue > 0).length;
    final rubriques = RubriquesBudget.depuisTarifs(
      (ref.watch(tousTarifsProvider).value ?? const <TarifReferentiel>[]).map(
        (t) => t.rubrique,
      ),
    );

    // Récapitulatif par **rubrique** (regroupement cohérent avec la
    // pré-impression et l'export), les totaux les plus importants d'abord.
    final parRubrique = <String, double>{};
    for (final l in lignes) {
      final r = _rubriqueDe(l, rubriques);
      parRubrique[r] = (parRubrique[r] ?? 0) + l.montantAlloue;
    }
    final entrees = parRubrique.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: TableauGestion<LigneBudget>(
        lignes: lignes,
        cleLigne: (l) => l.id,
        messageVide:
            'Aucune ligne budgétaire enregistrée pour le moment.\n'
            'Utilisez le bouton « Nouvelle ligne » pour en créer une.',
        resume: Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _ResumeChip(
              label:
                  'Budget prévisionnel : ${formatMontant(totalPrevisionnel)}',
              icone: Icons.account_balance_wallet_outlined,
            ),
            for (final e in entrees.take(6))
              _ResumeChip(
                label: '${e.key} : ${formatMontant(e.value)}',
                icone: Icons.donut_small_outlined,
              ),
            _ResumeChip(
              label:
                  'Montant alloué confirmé : ${formatMontant(totalAlloue)} '
                  '($confirmees/${lignes.length})',
              icone: Icons.verified_outlined,
            ),
          ],
        ),
        colonnes: [
          ColonneTableau(
            label: 'Activité',
            flex: 2,
            valeur: (l) => l.activiteCode,
            cellule: (_, l) => Text(
              l.activiteCode,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          ColonneTableau(
            label: 'Rubrique',
            flex: 3,
            valeur: (l) => _rubriqueDe(l, rubriques),
            cellule: (context, l) {
              final r = _rubriqueDe(l, rubriques);
              final inconnue = RubriquesBudget.estLibre(r);
              return Tooltip(
                message: inconnue
                    ? 'Rubrique absente des paramètres : complétez '
                          'REFERENTIEL_TARIFS.'
                    : 'Rubrique trouvée dans les paramètres·',
                child: Text(
                  r,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: inconnue ? FontWeight.w400 : FontWeight.w600,
                    color: inconnue
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            },
          ),
          ColonneTableau(
            label: 'Ligne budgétaire',
            flex: 4,
            valeur: (l) => l.ligneBudgetaire,
          ),
          ColonneTableau(label: 'Unité', flex: 2, valeur: (l) => l.unite),
          ColonneTableau(
            label: 'Quantité / Base',
            flex: 2,
            numerique: true,
            valeur: (l) => l.quantitePrevue.toStringAsFixed(0),
            cleTri: (l) => l.quantitePrevue,
          ),
          ColonneTableau(
            label: 'Jours / Multiplicateur',
            flex: 2,
            numerique: true,
            valeur: (l) => l.nombreJours.toStringAsFixed(0),
            cleTri: (l) => l.nombreJours,
          ),
          ColonneTableau(
            label: 'Taux / PU',
            flex: 3,
            numerique: true,
            valeur: (l) => formatMontant(l.tauxUnitaire),
            cleTri: (l) => l.tauxUnitaire,
          ),
          ColonneTableau(
            label: 'Budget prévisionnel',
            flex: 3,
            numerique: true,
            valeur: (l) => formatMontant(montantPrevisionnelLigneBudget(l)),
            cleTri: (l) => montantPrevisionnelLigneBudget(l),
          ),
          ColonneTableau(
            label: 'Montant alloué',
            flex: 3,
            numerique: true,
            valeur: (l) => formatMontant(l.montantAlloue),
            cleTri: (l) => l.montantAlloue,
            // Un montant **déjà confirmé** se distingue au premier coup d'œil
            // (vert + pastille ✓) d'un montant encore à confirmer (neutre).
            cellule: (context, l) {
              final confirme = l.montantAlloue > 0;
              final scheme = Theme.of(context).colorScheme;
              return Tooltip(
                message: confirme
                    ? 'Montant alloué confirmé'
                    : 'Montant non confirmé : ouvrez la ligne pour le confirmer',
                child: Chip(
                  avatar: Icon(
                    confirme ? Icons.check_circle_outline : Icons.help_outline,
                    size: 15,
                  ),
                  label: Text(
                    confirme ? formatMontant(l.montantAlloue) : 'Non confirmé',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: confirme
                      ? vertValide(context).withValues(alpha: 0.16)
                      : scheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  labelStyle: TextStyle(
                    color: confirme
                        ? vertValide(context)
                        : scheme.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
          ColonneTableau(
            label: 'Observation',
            flex: 3,
            valeur: (l) => l.observation ?? '',
          ),
        ],
        actions: [
          ActionTableau<LigneBudget>(
            icone: Icons.visibility_outlined,
            infobulle: 'Voir (pré-impression)',
            onTap: (l) => showDialog<void>(
              context: context,
              builder: (_) => ApercuBudgetDialog(lignes: [l]),
            ),
          ),
          ActionTableau<LigneBudget>(
            icone: Icons.edit_outlined,
            infobulle: 'Modifier',
            onTap: (l) async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => LigneBudgetDialog(ligne: l),
              );
              if (ok == true && context.mounted) {
                notifier(context, 'Ligne budgétaire modifiée');
              }
            },
          ),
          ActionTableau<LigneBudget>(
            icone: Icons.delete_outline,
            infobulle: 'Supprimer',
            couleur: Theme.of(context).colorScheme.error,
            onTap: (l) async {
              final ok = await confirmer(
                context,
                titre: 'Supprimer la ligne',
                message:
                    'Supprimer « ${l.ligneBudgetaire} » de ${l.activiteCode} ?',
              );
              if (!ok) return;
              await ref.read(lignesBudgetRepositoryProvider).delete(l.id);
              await ref
                  .read(auditRepositoryProvider)
                  .log(
                    action: 'SUPPRESSION',
                    entite: 'ligne_budget',
                    entiteId: l.id.toString(),
                    ancienneValeur: l.ligneBudgetaire,
                  );
            },
          ),
        ],
        onSupprimer: (lignes) async {
          final repo = ref.read(lignesBudgetRepositoryProvider);
          final audit = ref.read(auditRepositoryProvider);
          for (final l in lignes) {
            await repo.delete(l.id);
            await audit.log(
              action: 'SUPPRESSION',
              entite: 'ligne_budget',
              entiteId: l.id.toString(),
              ancienneValeur: l.ligneBudgetaire,
            );
          }
        },
      ),
    );
  }
}

class _ResumeChip extends StatelessWidget {
  const _ResumeChip({required this.label, required this.icone});
  final String label;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icone, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12.5)),
    );
  }
}
