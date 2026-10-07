import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../data/repositories/activite_repository.dart';
import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/tableau.dart';
import 'activite_form_dialog.dart';

class ActivitesScreen extends ConsumerStatefulWidget {
  const ActivitesScreen({super.key});

  @override
  ConsumerState<ActivitesScreen> createState() => _ActivitesScreenState();
}

class _ActivitesScreenState extends ConsumerState<ActivitesScreen> {
  final _recherche = TextEditingController();

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activites = ref.watch(activitesProvider);
    final filtre = ref.watch(filtreActivitesProvider);

    return Scaffold(
      body: Column(
        children: [
          EnTetePage(
            titre: 'Activités',
            sousTitre: 'Planification, suivi et pilotage des activités',
            actions: [
              FilledButton.icon(
                onPressed: () async {
                  final ok = await ActiviteFormDialog.afficher(context);
                  if (ok == true && context.mounted) {
                    notifier(context, 'Activité enregistrée');
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Nouvelle activité'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                SizedBox(
                  width: 360,
                  child: ChampRecherche(
                    controller: _recherche,
                    hint: 'Rechercher par code ou description',
                    onChanged: (v) => ref
                        .read(filtreActivitesProvider.notifier)
                        .state = FiltreActivite(
                      recherche: v,
                      annee: filtre.annee,
                      statut: filtre.statut,
                      type: filtre.type,
                      district: filtre.district,
                    ),
                  ),
                ),
                const Spacer(),
                if (!filtre.estVide)
                  TextButton.icon(
                    onPressed: () {
                      _recherche.clear();
                      ref.read(filtreActivitesProvider.notifier).state =
                          const FiltreActivite();
                    },
                    icon: const Icon(Icons.filter_alt_off_outlined),
                    label: const Text('Réinitialiser'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: activites.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EtatErreur(erreur: e),
              data: (liste) {
                if (liste.isEmpty) {
                  return const EtatVide(
                    message: 'Aucune activité.\nCréez votre première activité.',
                    icone: Icons.event_note_outlined,
                  );
                }
                return _TableauActivites(activites: liste);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TableauActivites extends ConsumerWidget {
  const _TableauActivites({required this.activites});
  final List<Activite> activites;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(toutesLignesBudgetProvider).value ?? const <LigneBudget>[];
    final montants = <String, double>{};
    for (final l in budgets) {
      montants[l.activiteCode] = (montants[l.activiteCode] ?? 0) + l.montantAlloue;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: TableauGestion<Activite>(
        lignes: activites,
        cleLigne: (a) => a.id,
        messageVide: 'Aucune activité enregistrée.',
        colonnes: [
          ColonneTableau(
            label: 'Code',
            flex: 2,
            valeur: (a) => a.code,
            cellule: (_, a) => Text(
              a.code,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          ColonneTableau(label: 'Description', flex: 5, valeur: (a) => a.description),
          ColonneTableau(label: 'Code budget', flex: 2, valeur: (a) => a.codeBudget ?? ''),
          ColonneTableau(label: 'Source de financement', flex: 3, valeur: (a) => a.sourceFinancement ?? ''),
          ColonneTableau(label: 'Lieu d’activité', flex: 3, valeur: (a) => a.district ?? ''),
          ColonneTableau(label: 'Jours', flex: 1, numerique: true, valeur: (a) => '${a.nombreJours}', cleTri: (a) => a.nombreJours),
          ColonneTableau(label: 'Début', flex: 2, valeur: (a) => formatDate(a.dateDebut), cleTri: (a) => a.dateDebut),
          ColonneTableau(label: 'Fin', flex: 2, valeur: (a) => formatDate(a.dateFin), cleTri: (a) => a.dateFin),
          ColonneTableau(
            label: 'Montant alloué',
            flex: 3,
            numerique: true,
            valeur: (a) => formatMontant(montants[a.code] ?? 0),
            cleTri: (a) => montants[a.code] ?? 0,
          ),
        ],
        actions: [
          ActionTableau<Activite>(
            icone: Icons.edit_outlined,
            infobulle: 'Modifier',
            onTap: (a) async {
              final ok = await ActiviteFormDialog.afficher(context, activite: a);
              if (ok == true && context.mounted) notifier(context, 'Activité modifiée');
            },
          ),
          ActionTableau<Activite>(
            icone: Icons.delete_outline,
            infobulle: 'Supprimer',
            couleur: Theme.of(context).colorScheme.error,
            onTap: (a) async {
              final ok = await confirmer(
                context,
                titre: 'Supprimer l’activité',
                message: 'Supprimer « ${a.code} » et toutes ses données liées ?',
                confirmerLabel: 'Supprimer',
              );
              if (!ok) return;
              await ref.read(activitesRepositoryProvider).delete(a.id);
              await ref.read(auditRepositoryProvider).log(
                    action: 'SUPPRESSION',
                    entite: 'activite',
                    entiteId: a.id.toString(),
                    ancienneValeur: a.code,
                  );
              if (context.mounted) notifier(context, 'Activité supprimée');
            },
          ),
        ],
        onSupprimer: (lignes) async {
          final repo = ref.read(activitesRepositoryProvider);
          final audit = ref.read(auditRepositoryProvider);
          for (final a in lignes) {
            await repo.delete(a.id);
            await audit.log(
              action: 'SUPPRESSION',
              entite: 'activite',
              entiteId: a.id.toString(),
              ancienneValeur: a.code,
            );
          }
        },
      ),
    );
  }
}
