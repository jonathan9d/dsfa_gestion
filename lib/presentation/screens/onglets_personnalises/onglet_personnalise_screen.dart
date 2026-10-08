import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/configuration/configuration_app.dart';
import '../../../domain/rubriques.dart';
import '../../providers/app_providers.dart';
import '../../providers/configuration_providers.dart';
import '../../providers/providers.dart';
import '../../router/app_router.dart';
import '../../widgets/common.dart';
import '../../widgets/tableau.dart';

/// Une ligne affichée dans un onglet créé : un identifiant, les valeurs de
/// ses champs et, si l'action est autorisée, la suppression de la ligne.
class LigneSource {
  const LigneSource({required this.id, required this.valeurs, this.supprimer});

  final String id;
  final Map<String, String> valeurs;
  final Future<void> Function()? supprimer;

  String champ(String cle) => valeurs[cle] ?? '';
}

/// **Onglet créé depuis la configuration** : son contenu (source de données),
/// ses colonnes (champs de la configuration) et ses actions sont entièrement
/// définis par l'utilisateur. Le tableau reste celui de l'application : tri,
/// filtres, largeurs calculées et sélection multiple fonctionnent d'office.
class OngletPersonnaliseScreen extends ConsumerStatefulWidget {
  const OngletPersonnaliseScreen({required this.cle, super.key});

  /// Clé du module créé dans la configuration.
  final String cle;

  @override
  ConsumerState<OngletPersonnaliseScreen> createState() =>
      _OngletPersonnaliseScreenState();
}

class _OngletPersonnaliseScreenState
    extends ConsumerState<OngletPersonnaliseScreen> {
  final _recherche = TextEditingController();
  String _filtre = '';

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configuration = ref.watch(configurationProvider);
    final module = configuration.module(widget.cle);
    if (module == null) {
      return Scaffold(
        body: EtatVide(
          icone: Icons.help_outline,
          titre: 'Onglet introuvable',
          message:
              'Cet onglet n\'existe plus dans la configuration.\n'
              'Ouvrez la configuration pour le recréer ou en choisir un autre.',
          action: FilledButton.icon(
            onPressed: () =>
                context.go('${AppRoutes.parametres}?onglet=configuration'),
            icon: const Icon(Icons.tune, size: 18),
            label: const Text('Ouvrir la configuration'),
          ),
        ),
      );
    }

    final lignes = _charger(module)
        .where(
          (l) =>
              _filtre.isEmpty ||
              l.valeurs.values.any(
                (v) => v.toLowerCase().contains(_filtre.toLowerCase()),
              ),
        )
        .toList();

    return Scaffold(
      body: Column(
        children: [
          EnTetePage(
            module: module.cle,
            titre: module.titre,
            sousTitre: module.sousTitre,
            actions: [
              FilledButton.icon(
                onPressed: () => context.go(
                  '${AppRoutes.parametres}?onglet=configuration'
                  '&module=${module.cle}',
                ),
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('Personnaliser cet onglet'),
              ),
            ],
          ),
          if (module.actionAutorisee(ActionsApp.rechercher))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: 380,
                child: ChampRecherche(
                  controller: _recherche,
                  hint: 'Rechercher dans ${module.titre.toLowerCase()}',
                  onChanged: (v) => setState(() => _filtre = v),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: TableauGestion<LigneSource>(
                cleModule: module.cle,
                lignes: lignes,
                cleLigne: (l) => l.id,
                messageVide:
                    'Aucune donnée à afficher pour le moment.\n'
                    'Les données saisies dans « ${module.titre} » apparaîtront '
                    'ici.',
                colonnes: _colonnes(module),
                actions: [
                  if (module.actionAutorisee(ActionsApp.supprimer))
                    ActionTableau<LigneSource>(
                      icone: Icons.delete_outline,
                      infobulle: 'Supprimer',
                      couleur: Theme.of(context).colorScheme.error,
                      visible: (l) => l.supprimer != null,
                      onTap: (l) async {
                        final supprimer = l.supprimer;
                        if (supprimer == null) return;
                        final ok = await confirmer(
                          context,
                          titre: 'Supprimer la ligne',
                          message:
                              'Supprimer cette ligne de « ${module.titre} » ? '
                              'Cette action est définitive.',
                        );
                        if (!ok) return;
                        await supprimer();
                        if (context.mounted) {
                          notifier(context, 'Ligne supprimée');
                        }
                      },
                    ),
                ],
                onSupprimer: module.actionAutorisee(ActionsApp.supprimer)
                    ? (selection) async {
                        for (final ligne in selection) {
                          await ligne.supprimer?.call();
                        }
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<ColonneTableau<LigneSource>> _colonnes(ModuleConfig module) => [
    for (final champ in champsDeSource(module.source))
      ColonneTableau<LigneSource>(
        cle: champ.cle,
        label: champ.libelle,
        flex: 2,
        numerique:
            champ.type == TypeChamp.montant || champ.type == TypeChamp.nombre,
        valeur: (l) => l.champ(champ.cle),
      ),
  ];

  List<LigneSource> _charger(ModuleConfig module) {
    switch (module.source) {
      case 'activites':
        final activites = ref.watch(activitesProvider).value ?? const [];
        return [
          for (final a in activites)
            LigneSource(
              id: 'activite-${a.id}',
              valeurs: {
                'code': a.code,
                'description': a.description,
                'code_budget': a.codeBudget ?? '',
                'source_financement': a.sourceFinancement ?? '',
                'lieu': a.district ?? '',
                'jours': '${a.nombreJours}',
                'date_debut': formatDate(a.dateDebut),
                'date_fin': formatDate(a.dateFin),
              },
              supprimer: module.actionAutorisee(ActionsApp.supprimer)
                  ? () => ref.read(activitesRepositoryProvider).delete(a.id)
                  : null,
            ),
        ];
      case 'budgets':
        final lignesBudget =
            ref.watch(toutesLignesBudgetProvider).value ?? const [];
        final rubriques = ref.watch(configurationProvider).nomsRubriques;
        return [
          for (final l in lignesBudget)
            LigneSource(
              id: 'budget-${l.id}',
              valeurs: {
                'activite': l.activiteCode,
                'rubrique': () {
                  final r = RubriquesBudget.resoudre(
                    ligneBudgetaire: l.ligneBudgetaire,
                    typeBudget: l.typeBudget,
                    rubriques: rubriques,
                  );
                  return r == RubriquesBudget.aPreciser ? '' : r;
                }(),
                'ligne_budgetaire': l.ligneBudgetaire,
                'unite': l.unite,
                'quantite': l.quantitePrevue.toStringAsFixed(0),
                'nombre_jours': l.nombreJours.toStringAsFixed(0),
                'taux_unitaire': formatMontant(l.tauxUnitaire),
                'budget_previsionnel': formatMontant(
                  l.quantitePrevue * l.nombreJours * l.tauxUnitaire,
                ),
                'montant_alloue': formatMontant(l.montantAlloue),
                'observation': l.observation ?? '',
              },
              supprimer: module.actionAutorisee(ActionsApp.supprimer)
                  ? () => ref.read(lignesBudgetRepositoryProvider).delete(l.id)
                  : null,
            ),
        ];
      case 'depenses':
        final depenses = ref.watch(depensesProvider).value ?? const [];
        return [
          for (final d in depenses)
            LigneSource(
              id: 'depense-${d.id}',
              valeurs: {
                'date': formatDate(d.dateEnregistrement),
                'code_activite': d.codeActivite ?? '',
                'designation': d.designation,
                'beneficiaire': d.beneficiaire ?? '',
                'mode_paiement': d.fonds,
                'quantite': d.quantite.toStringAsFixed(0),
                'pu': formatMontant(d.pu),
                'montant': formatMontant(
                  d.nbJrMois * d.quantite * d.frequence * d.pu,
                ),
                'reference_pj': d.refPieceDepense ?? '',
                'observation': d.observation ?? '',
              },
              supprimer: module.actionAutorisee(ActionsApp.supprimer)
                  ? () => ref.read(depensesRepositoryProvider).delete(d.id)
                  : null,
            ),
        ];
      case 'banque':
        final operations = ref.watch(banqueProvider).value ?? const [];
        return [
          for (final o in operations)
            LigneSource(
              id: 'banque-${o.id}',
              valeurs: {
                'date': formatDate(o.date),
                'reference': o.refPiece ?? '',
                'type': o.type,
                'description': o.description,
                'recettes': formatMontant(o.recettes),
                'depenses': formatMontant(o.depenses),
              },
              supprimer: module.actionAutorisee(ActionsApp.supprimer)
                  ? () => ref.read(banqueRepositoryProvider).delete(o.id)
                  : null,
            ),
        ];
      case 'participants':
        final participants = ref.watch(participantsProvider).value ?? const [];
        return [
          for (final p in participants)
            LigneSource(
              id: 'participant-${p.id}',
              valeurs: {
                'nom': p.nom,
                'prenom': p.prenom,
                'statut': p.actif ? 'Actif' : 'Inactif',
                'observation': p.observation ?? '',
              },
              supprimer: module.actionAutorisee(ActionsApp.supprimer)
                  ? () => ref.read(participantsRepositoryProvider).delete(p.id)
                  : null,
            ),
        ];
      default:
        return const [];
    }
  }
}

/// Champs (colonnes) proposés pour une source de données : ils alimentent la
/// configuration d'un onglet créé, où l'utilisateur choisit lesquels afficher,
/// dans quel ordre et avec quel titre.
List<ChampConfig> champsDeSource(String source) {
  switch (source) {
    case 'activites':
      return _champs(const {
        'code': ('Code', TypeChamp.texte, 120),
        'description': ('Description', TypeChamp.texte, 300),
        'code_budget': ('Code budget', TypeChamp.texte, 150),
        'source_financement': ('Source de financement', TypeChamp.liste, 200),
        'lieu': ('Lieu d\'activité', TypeChamp.texte, 170),
        'jours': ('Jours', TypeChamp.nombre, 90),
        'date_debut': ('Début', TypeChamp.date, 110),
        'date_fin': ('Fin', TypeChamp.date, 110),
      });
    case 'budgets':
      return _champs(const {
        'activite': ('Activité', TypeChamp.texte, 140),
        'rubrique': ('Rubrique', TypeChamp.liste, 230),
        'ligne_budgetaire': ('Ligne budgétaire', TypeChamp.liste, 260),
        'unite': ('Unité', TypeChamp.liste, 110),
        'quantite': ('Quantité', TypeChamp.nombre, 110),
        'nombre_jours': ('Jours', TypeChamp.nombre, 100),
        'taux_unitaire': ('Taux / PU', TypeChamp.montant, 120),
        'budget_previsionnel': ('Budget prévisionnel', TypeChamp.montant, 160),
        'montant_alloue': ('Montant alloué', TypeChamp.montant, 150),
        'observation': ('Observation', TypeChamp.texte, 200),
      });
    case 'depenses':
      return _champs(const {
        'date': ('Date', TypeChamp.date, 110),
        'code_activite': ('Code activité', TypeChamp.texte, 130),
        'designation': ('Désignation', TypeChamp.liste, 260),
        'beneficiaire': ('Bénéficiaire', TypeChamp.texte, 200),
        'mode_paiement': ('Mode de paiement', TypeChamp.liste, 160),
        'quantite': ('Qté', TypeChamp.nombre, 90),
        'pu': ('P.U.', TypeChamp.montant, 120),
        'montant': ('Montant', TypeChamp.montant, 150),
        'reference_pj': ('Référence PJ', TypeChamp.texte, 160),
        'observation': ('Observation', TypeChamp.texte, 200),
      });
    case 'banque':
      return _champs(const {
        'date': ('Date', TypeChamp.date, 110),
        'reference': ('Référence', TypeChamp.texte, 160),
        'type': ('Type', TypeChamp.liste, 150),
        'description': ('Description', TypeChamp.texte, 280),
        'recettes': ('Recettes', TypeChamp.montant, 140),
        'depenses': ('Dépenses', TypeChamp.montant, 140),
      });
    case 'participants':
      return _champs(const {
        'nom': ('Nom', TypeChamp.texte, 160),
        'prenom': ('Prénom', TypeChamp.texte, 160),
        'statut': ('Statut', TypeChamp.statut, 130),
        'observation': ('Observation', TypeChamp.texte, 200),
      });
    default:
      return const [];
  }
}

List<ChampConfig> _champs(
  Map<String, (String, TypeChamp, double)> descriptions,
) {
  final champs = <ChampConfig>[];
  var ordre = 1;
  for (final entree in descriptions.entries) {
    champs.add(
      ChampConfig(
        cle: entree.key,
        libelle: entree.value.$1,
        type: entree.value.$2,
        largeur: entree.value.$3,
        ordre: ordre,
      ),
    );
    ordre++;
  }
  return champs;
}
