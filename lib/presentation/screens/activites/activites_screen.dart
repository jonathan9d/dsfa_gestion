import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../data/repositories/activite_repository.dart';
import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/tableau.dart';
import 'activite_form_dialog.dart';

/// Liste des activités avec recherche, filtres et CRUD.
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
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 320,
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
                _FiltreStatut(
                  valeur: filtre.statut,
                  onChanged: (v) => ref
                      .read(filtreActivitesProvider.notifier)
                      .state = FiltreActivite(
                    recherche: filtre.recherche,
                    annee: filtre.annee,
                    statut: v,
                    type: filtre.type,
                    district: filtre.district,
                  ),
                ),
                _FiltreType(
                  valeur: filtre.type,
                  onChanged: (v) => ref
                      .read(filtreActivitesProvider.notifier)
                      .state = FiltreActivite(
                    recherche: filtre.recherche,
                    annee: filtre.annee,
                    statut: filtre.statut,
                    type: v,
                    district: filtre.district,
                  ),
                ),
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

class _FiltreStatut extends StatelessWidget {
  const _FiltreStatut({required this.valeur, required this.onChanged});
  final String? valeur;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String?>(
        initialValue: valeur,
        decoration: const InputDecoration(labelText: 'Statut'),
        items: const [
          DropdownMenuItem(value: null, child: Text('Tous')),
          DropdownMenuItem(value: 'Planifiée', child: Text('Planifiée')),
          DropdownMenuItem(value: 'En cours', child: Text('En cours')),
          DropdownMenuItem(value: 'Terminée', child: Text('Terminée')),
          DropdownMenuItem(value: 'Annulée', child: Text('Annulée')),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _FiltreType extends StatelessWidget {
  const _FiltreType({required this.valeur, required this.onChanged});
  final String? valeur;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: DropdownButtonFormField<String?>(
        initialValue: valeur,
        decoration: const InputDecoration(labelText: 'Type'),
        items: const [
          DropdownMenuItem(value: null, child: Text('Tous')),
          DropdownMenuItem(value: 'Atelier/Réunion', child: Text('Atelier/Réunion')),
          DropdownMenuItem(value: 'Supervision', child: Text('Supervision')),
          DropdownMenuItem(value: 'Formation', child: Text('Formation')),
          DropdownMenuItem(value: 'Acquisition', child: Text('Acquisition')),
          DropdownMenuItem(
              value: 'Mission extérieur', child: Text('Mission extérieur')),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _TableauActivites extends ConsumerWidget {
  const _TableauActivites({required this.activites});
  final List<Activite> activites;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: TableauGestion<Activite>(
        lignes: activites,
        cleLigne: (a) => a.id,
        messageVide:
            'Aucune activité enregistrée pour le moment.\n'
            'Utilisez le bouton « Nouvelle activité » pour commencer.',
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
          ColonneTableau(
            label: 'Description',
            flex: 5,
            valeur: (a) => a.description,
          ),
          ColonneTableau(label: 'Type', flex: 3, valeur: (a) => a.type),
          ColonneTableau(
            label: 'Code budget',
            flex: 2,
            valeur: (a) => a.codeBudget ?? '',
            cellule: (_, a) => Text(
              a.codeBudget ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ColonneTableau(
            label: 'Source de financement',
            flex: 3,
            valeur: (a) => a.sourceFinancement ?? '',
          ),
          ColonneTableau(
            label: 'District',
            flex: 3,
            valeur: (a) => a.district ?? '',
          ),
          ColonneTableau(
            label: 'Jours',
            flex: 1,
            numerique: true,
            valeur: (a) => '${a.nombreJours}',
            cleTri: (a) => a.nombreJours,
          ),
          ColonneTableau(
            label: 'Début',
            flex: 2,
            valeur: (a) => formatDate(a.dateDebut),
            cleTri: (a) => a.dateDebut,
          ),
          ColonneTableau(
            label: 'Fin',
            flex: 2,
            valeur: (a) => formatDate(a.dateFin),
            cleTri: (a) => a.dateFin,
          ),
          ColonneTableau(
            label: 'Statut',
            flex: 3,
            valeur: (a) => a.statut,
            cellule: (_, a) => _BadgeStatut(statut: a.statut),
          ),
        ],
        actions: [
          ActionTableau<Activite>(
            icone: Icons.edit_outlined,
            infobulle: 'Modifier',
            onTap: (a) async {
              final ok = await ActiviteFormDialog.afficher(
                context,
                activite: a,
              );
              if (ok == true && context.mounted) {
                notifier(context, 'Activité modifiée');
              }
            },
          ),
          ActionTableau<Activite>(
            icone: Icons.delete_outline,
            infobulle: 'Supprimer',
            couleur: Theme.of(context).colorScheme.error,
            onTap: (a) async {
              final ok = await confirmer(
                context,
                titre: 'Supprimer l\'activité',
                message:
                    'Supprimer « ${a.code} » ?\n'
                    'Les lignes budgétaires, les affectations, les présences, '
                    'les indemnités et les contrôles PJ de cette activité seront '
                    'également supprimés. Cette action est irréversible.',
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
              if (context.mounted) {
                notifier(context, 'Activité supprimée');
              }
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

class _BadgeStatut extends StatelessWidget {
  const _BadgeStatut({required this.statut});
  final String statut;

  @override
  Widget build(BuildContext context) {
    final (couleur, icone) = switch (statut) {
      'Terminée' => (const Color(0xFF2E7D32), Icons.check_circle_outline),
      'En cours' => (const Color(0xFF1565C0), Icons.play_circle_outline),
      'Annulée' => (const Color(0xFFC62828), Icons.cancel_outlined),
      _ => (const Color(0xFFF9A825), Icons.schedule_outlined),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 13, color: couleur),
          const SizedBox(width: 4),
          Text(statut,
              style: TextStyle(
                  fontSize: 11.5, color: couleur, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
