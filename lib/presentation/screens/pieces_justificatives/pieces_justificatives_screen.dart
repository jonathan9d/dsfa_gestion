import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../domain/models.dart';
import '../../../domain/services/regles_metier.dart';
import '../../../domain/regles_parametres.dart';
import '../../../domain/statuts.dart';
import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';

/// Contrôle des pièces justificatives avec calcul automatique du statut.
class PiecesJustificativesScreen extends ConsumerStatefulWidget {
  const PiecesJustificativesScreen({this.imbrique = false, super.key});

  /// Quand `true`, l'écran est affiché dans l'onglet « Dossier PJ » :
  /// pas de Scaffold ni d'en-tête propre.
  final bool imbrique;

  @override
  ConsumerState<PiecesJustificativesScreen> createState() =>
      _PiecesJustificativesScreenState();
}

class _PiecesJustificativesScreenState
    extends ConsumerState<PiecesJustificativesScreen> {
  final _recherche = TextEditingController();
  String? _filtreStatut;

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultats = ref.watch(resultatsControlePJProvider);
    final activite = ref.watch(activiteSelectionneeProvider);
    final activites = ref.watch(activitesProvider).value ?? const [];
    final corps = Column(
      children: [
        if (!widget.imbrique)
          const EnTetePage(
            titre: 'Pièces justificatives',
            module: 'dossier_pj',
            sousTitre:
                'Contrôle des PJ : écarts, cohérence des dates, budget et présence',
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 300,
                child: ChampRecherche(
                  controller: _recherche,
                  hint: 'Rechercher un bénéficiaire ou une activité',
                  onChanged: (v) =>
                      ref.read(filtreRechercheProvider.notifier).state = v,
                ),
              ),
              SizedBox(
                width: 230,
                child: DropdownButtonFormField<String?>(
                  key: ValueKey('pj-activite-$activite'),
                  initialValue: activite,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Activité',
                    prefixIcon: Icon(Icons.event_note_outlined),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Toutes les activités'),
                    ),
                    for (final a in activites)
                      DropdownMenuItem(
                        value: a.code,
                        child: Text(
                          a.code,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (v) =>
                      ref.read(activiteSelectionneeProvider.notifier).state = v,
                ),
              ),
              SizedBox(
                width: 210,
                child: DropdownButtonFormField<String?>(
                  initialValue: _filtreStatut,
                  // Sans `isExpanded`, le menu prend la largeur de son entrée
                  // la plus longue (« Date PJ non conforme ») et déborde.
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Statut'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Tous')),
                    DropdownMenuItem(
                      value: StatutFinalPJ.conforme,
                      child: Text('Conforme'),
                    ),
                    DropdownMenuItem(
                      value: StatutFinalPJ.aVerifier,
                      child: Text('À vérifier'),
                    ),
                    DropdownMenuItem(
                      value: StatutFinalPJ.nonConforme,
                      child: Text('Non conforme'),
                    ),
                    DropdownMenuItem(
                      value: StatutFinalPJ.pjNonRecue,
                      child: Text('PJ non reçue'),
                    ),
                    DropdownMenuItem(
                      value: StatutFinalPJ.datePjNonConforme,
                      child: Text('Date PJ non conforme'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _filtreStatut = v),
                ),
              ),
              FilledButton.icon(
                onPressed: () => _ouvrirFormulaire(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nouveau contrôle'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: resultats.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => EtatErreur(erreur: e),
            data: (liste) {
              if (liste.isEmpty) {
                return EtatVide(
                  message: 'Aucun contrôle PJ enregistré pour le moment.',
                  icone: Icons.attach_file_outlined,
                  action: FilledButton.icon(
                    onPressed: () => _ouvrirFormulaire(),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer un contrôle'),
                  ),
                );
              }
              // Les compteurs portent sur l'activité choisie, indépendamment
              // du filtre de statut (sinon les totaux s'effondrent dès qu'on
              // filtre).
              final parActivite = activite == null
                  ? liste
                  : liste.where((e) => e.$1.activiteCode == activite).toList();
              if (parActivite.isEmpty) {
                return EtatVide(
                  message:
                      'Aucun contrôle PJ pour l’activité « $activite ».\n'
                      'Choisissez « Toutes les activités » pour tout afficher.',
                  icone: Icons.event_busy_outlined,
                );
              }
              final filtree = _filtreStatut == null
                  ? parActivite
                  : parActivite
                        .where((e) => e.$2.statutFinal == _filtreStatut)
                        .toList();
              // **Une seule zone défilante** porte le bandeau, la synthèse et
              // les dossiers : plus rien ne peut être écrasé, et le bas de la
              // liste reste atteignable quelle que soit la hauteur de la
              // fenêtre (auparavant la colonne débordait et la liste était
              // réduite à néant).
              return ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _BandeauTotaux(resultats: parActivite),
                  const SizedBox(height: 12),
                  _SyntheseStatuts(
                    resultats: parActivite,
                    filtre: _filtreStatut,
                    onFiltrer: (v) => setState(() => _filtreStatut = v),
                  ),
                  const SizedBox(height: 12),
                  if (filtree.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: EtatVide(
                        message:
                            'Aucun contrôle avec le statut '
                            '« $_filtreStatut ».\n'
                            'Touchez à nouveau le compteur pour l’enlever.',
                        icone: Icons.filter_alt_off_outlined,
                      ),
                    )
                  else
                    for (final (controle, resultat) in filtree)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _CarteControle(
                          controle: controle,
                          resultat: resultat,
                        ),
                      ),
                ],
              );
            },
          ),
        ),
      ],
    );
    return widget.imbrique ? corps : Scaffold(body: corps);
  }

  Future<void> _ouvrirFormulaire({ControlePJ? controle}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ControlePJDialog(controle: controle),
    );
    if (ok == true && mounted) notifier(context, 'Contrôle PJ enregistré');
  }
}

/// Bandeau financier du dossier PJ : les totaux que suit un gestionnaire
/// (montants alloués, payés, montants des pièces et écarts), sur le périmètre
/// affiché.
class _BandeauTotaux extends StatelessWidget {
  const _BandeauTotaux({required this.resultats});
  final List<(ControlePJ, ResultatControlePJ)> resultats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alloue = resultats.fold<double>(0, (s, e) => s + e.$1.montantAlloue);
    final paye = resultats.fold<double>(0, (s, e) => s + e.$1.montantPaye);
    final pj = resultats.fold<double>(0, (s, e) => s + e.$1.montantPJ);
    final ecartBudget = resultats.fold<double>(
      0,
      (s, e) => s + e.$2.ecartBudget,
    );
    final ecartPJ = resultats.fold<double>(0, (s, e) => s + e.$2.ecartPJ);
    Color equilibre(double v) =>
        v.abs() <= 0.000001 ? vertValide(context) : rougeAlerte(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Wrap(
        spacing: 30,
        runSpacing: 12,
        children: [
          _Tuile(
            label: 'Dossiers contrôlés',
            valeur: '${resultats.length}',
            icone: Icons.folder_copy_outlined,
          ),
          _Tuile(
            label: 'Total alloué',
            valeur: formatMontant(alloue),
            icone: Icons.savings_outlined,
          ),
          _Tuile(
            label: 'Total payé',
            valeur: formatMontant(paye),
            icone: Icons.payments_outlined,
          ),
          _Tuile(
            label: 'Total des pièces (PJ)',
            valeur: formatMontant(pj),
            icone: Icons.receipt_outlined,
          ),
          _Tuile(
            label: 'Écart budget (payé − alloué)',
            valeur: formatMontant(ecartBudget),
            icone: Icons.compare_arrows_outlined,
            couleur: equilibre(ecartBudget),
          ),
          _Tuile(
            label: 'Écart PJ (PJ − payé)',
            valeur: formatMontant(ecartPJ),
            icone: Icons.compare_arrows_outlined,
            couleur: equilibre(ecartPJ),
          ),
        ],
      ),
    );
  }
}

/// Tuile compacte du bandeau financier.
class _Tuile extends StatelessWidget {
  const _Tuile({
    required this.label,
    required this.valeur,
    required this.icone,
    this.couleur,
  });

  final String label;
  final String valeur;
  final IconData icone;
  final Color? couleur;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = couleur ?? theme.colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icone, size: 14, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          valeur,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: c,
          ),
        ),
      ],
    );
  }
}

/// Bandeau de synthèse : nombre de contrôles par **statut final** — les cinq
/// statuts du contrôle PJ, exactement ceux du filtre de statut. Toucher un
/// compteur filtre la liste (toucher à nouveau l'enlève).
class _SyntheseStatuts extends StatelessWidget {
  const _SyntheseStatuts({
    required this.resultats,
    required this.filtre,
    required this.onFiltrer,
  });

  final List<(ControlePJ, ResultatControlePJ)> resultats;
  final String? filtre;
  final ValueChanged<String?> onFiltrer;

  /// Statuts finaux affichés, dans l'ordre de lecture du contrôle.
  static const _statuts = <String>[
    StatutFinalPJ.conforme,
    StatutFinalPJ.aVerifier,
    StatutFinalPJ.nonConforme,
    StatutFinalPJ.pjNonRecue,
    StatutFinalPJ.datePjNonConforme,
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _compteur(
            context,
            scheme,
            'Tous',
            resultats.length,
            null,
            StatutControle.aVerifier,
          ),
          for (final statut in _statuts)
            _compteur(
              context,
              scheme,
              statut,
              resultats.where((e) => e.$2.statutFinal == statut).length,
              statut,
              StatutFinalPJ.versStatut(statut),
            ),
        ],
      ),
    );
  }

  Widget _compteur(
    BuildContext context,
    ColorScheme scheme,
    String label,
    int nombre,
    String? valeurFiltre,
    StatutControle statut,
  ) {
    final actif = filtre == valeurFiltre;
    final couleur = statut.color(scheme);
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Tooltip(
        message: valeurFiltre == null
            ? 'Afficher tous les statuts'
            : 'Filtrer sur « $label »',
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onFiltrer(actif ? null : valeurFiltre),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: couleur.withValues(alpha: actif ? 0.22 : 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: couleur.withValues(alpha: actif ? 0.9 : 0.35),
                width: actif ? 1.6 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statut.icon, size: 16, color: couleur),
                const SizedBox(width: 6),
                Text(
                  '$label : $nombre',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: couleur,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CarteControle extends ConsumerWidget {
  const _CarteControle({required this.controle, required this.resultat});
  final ControlePJ controle;
  final ResultatControlePJ resultat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statut = resultat.statut;
    final couleur = statut.color(theme.colorScheme);
    final ecartBudget = resultat.ecartBudget;
    final ecartPJ = resultat.ecartPJ;
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      // Contour à la couleur du statut : le dossier se lit au premier coup
      // d'œil dans la liste.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: couleur.withValues(alpha: 0.45), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${controle.activiteCode ?? '—'} · '
                        '${(controle.beneficiaire ?? '').trim().isEmpty ? 'Bénéficiaire non renseigné' : controle.beneficiaire}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if ((controle.ligneBudgetaire ?? '').isNotEmpty)
                            controle.ligneBudgetaire!,
                          if ((controle.typePJ ?? '').isNotEmpty)
                            controle.typePJ!,
                          if (controle.datePJ != null)
                            'PJ du ${formatDate(controle.datePJ)}',
                        ].join(' · '),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PastilleStatut(statut: statut),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Modifier',
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => _ControlePJDialog(controle: controle),
                    );
                    if (ok == true && context.mounted) {
                      notifier(context, 'Contrôle modifié');
                    }
                  },
                ),
                IconButton(
                  tooltip: 'Supprimer',
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () async {
                    final ok = await confirmer(
                      context,
                      titre: 'Supprimer le contrôle',
                      message:
                          'Supprimer ce contrôle PJ ?\n'
                          'La ligne de dépense créée automatiquement dans le '
                          'journal sera aussi retirée.',
                    );
                    if (!ok) return;
                    // Le journal des dépenses est nettoyé pour ne pas laisser
                    // une dépense orpheline après la suppression.
                    try {
                      await ref
                          .read(journalDepensesServiceProvider)
                          .retirerControlePJ(controle.id);
                    } catch (_) {
                      // La suppression du contrôle reste prioritaire.
                    }
                    await ref
                        .read(controlesPJRepositoryProvider)
                        .delete(controle.id);
                    ref.invalidate(depensesProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Vérifications',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 28,
              runSpacing: 14,
              children: [
                _Verif(
                  ok: controle.pjRecue == OuiNon.oui,
                  label: 'PJ reçue',
                  valeur: _libelleOuiNon(controle.pjRecue),
                ),
                _Verif(
                  ok: controle.pjConforme == OuiNon.oui,
                  label: 'PJ conforme',
                  valeur: _libelleOuiNon(controle.pjConforme),
                ),
                _Verif(
                  ok: resultat.datePJCoherente,
                  label: 'Date PJ cohérente',
                  valeur: resultat.datePJCoherente ? 'Oui' : 'Non',
                ),
                _Verif(
                  ok: ecartBudget.abs() <= 0.000001,
                  label: 'Écart budget (payé − alloué)',
                  valeur: formatMontant(ecartBudget),
                ),
                _Verif(
                  ok: ecartPJ.abs() <= 0.000001,
                  label: 'Écart PJ (PJ − payé)',
                  valeur: formatMontant(ecartPJ),
                ),
                _Verif(
                  ok:
                      resultat.controlePresenceIndemnite ==
                      ControlePresenceIndemnite.conforme,
                  label: 'Présence / indemnité',
                  valeur: resultat.controlePresenceIndemnite,
                ),
              ],
            ),
            const Divider(height: 28),
            Text(
              'Montants (Ar)',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 32,
              runSpacing: 14,
              children: [
                _Montant(
                  label: 'Budget alloué',
                  valeur: controle.montantAlloue,
                ),
                _Montant(label: 'Montant payé', valeur: controle.montantPaye),
                _Montant(label: 'Montant PJ', valeur: controle.montantPJ),
                _Montant(
                  label: 'Budget indemnités disponible',
                  valeur: resultat.budgetIndemnitesDisponible,
                ),
                _Montant(
                  label: 'Montant contrôlé',
                  valeur: resultat.montantControle,
                ),
              ],
            ),
            if ((controle.observation ?? '').isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Observation : ${controle.observation}',
                style: theme.textTheme.bodySmall,
              ),
            ],
            Container(
              margin: const EdgeInsets.only(top: 18),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(statut.icon, size: 16, color: couleur),
                  const SizedBox(width: 8),
                  Text(
                    'STATUT : '
                    '${resultat.statutFinal.isEmpty ? 'Non évalué' : resultat.statutFinal}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: couleur,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Libellé lisible d'une valeur Oui/Non/À compléter/À vérifier.
String _libelleOuiNon(String valeur) {
  final v = valeur.trim();
  return v.isEmpty ? 'Non renseigné' : v;
}

class _Verif extends StatelessWidget {
  const _Verif({required this.ok, required this.label, this.valeur});
  final bool ok;
  final String label;
  final String? valeur;

  @override
  Widget build(BuildContext context) {
    final couleur = ok ? vertValide(context) : rougeAlerte(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(ok ? Icons.check_circle : Icons.cancel, size: 15, color: couleur),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12.5)),
        if (valeur != null && valeur!.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text('($valeur)', style: TextStyle(fontSize: 12, color: couleur)),
        ],
      ],
    );
  }
}

class _Montant extends StatelessWidget {
  const _Montant({required this.label, required this.valeur});
  final String label;
  final double valeur;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          formatMontant(valeur),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Analyse en direct d'un contrôle PJ : écarts budget/PJ et cohérence des
/// dates, pour que le statut soit compréhensible **pendant** la saisie.
class _AnalyseControlePJ extends StatelessWidget {
  const _AnalyseControlePJ({
    required this.montantAlloue,
    required this.montantPaye,
    required this.montantPJ,
    required this.dateDebut,
    required this.dateFin,
    required this.datePJ,
  });

  final double montantAlloue;
  final double montantPaye;
  final double montantPJ;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final DateTime? datePJ;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ecartBudget = ReglesMetier.ecartBudget(montantPaye, montantAlloue);
    final ecartPJ = ReglesMetier.ecartPJ(montantPJ, montantPaye);
    final datePJOk = ReglesMetier.datePJCoherente(
      dateDebut: dateDebut,
      dateFin: dateFin,
      datePJ: datePJ,
    );
    final datesRenseignees =
        dateDebut != null && dateFin != null && datePJ != null;
    final periodeValide =
        dateDebut == null || dateFin == null || !dateFin!.isBefore(dateDebut!);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.rule_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Analyse automatique du dossier',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _Verif(
            ok: ecartBudget.abs() <= 0.000001,
            label: 'Budget payé = budget alloué',
            valeur: 'écart ${formatMontant(ecartBudget)}',
          ),
          const SizedBox(height: 4),
          _Verif(
            ok: ecartPJ.abs() <= 0.000001,
            label: 'Montant PJ = montant payé',
            valeur: 'écart ${formatMontant(ecartPJ)}',
          ),
          const SizedBox(height: 4),
          _Verif(
            ok: !datesRenseignees || datePJOk,
            label: 'Date PJ ≥ fin d’activité',
            valeur: datePJOk
                ? 'Oui'
                : (datesRenseignees ? 'Non' : 'À compléter'),
          ),
          const SizedBox(height: 4),
          _Verif(
            ok: periodeValide,
            label: 'Date de fin ≥ date de début',
            valeur: periodeValide ? 'Oui' : 'Non',
          ),
        ],
      ),
    );
  }
}

class _ControlePJDialog extends ConsumerStatefulWidget {
  const _ControlePJDialog({this.controle});
  final ControlePJ? controle;

  @override
  ConsumerState<_ControlePJDialog> createState() => _ControlePJDialogState();
}

class _ControlePJDialogState extends ConsumerState<_ControlePJDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _activite;
  late final TextEditingController _ligne;
  late final TextEditingController _beneficiaire;
  late final TextEditingController _typePJ;
  late final TextEditingController _alloue;
  late final TextEditingController _paye;
  late final TextEditingController _montantPJ;
  late final TextEditingController _observation;
  DateTime? _dateDebut;
  DateTime? _dateFin;
  DateTime? _datePJ;
  String _pjRecue = OuiNon.oui;
  String _pjConforme = OuiNon.oui;
  String? _rubrique;
  String? _sousRubrique;

  /// Checklist des PJ requises : pièce → {"recue": bool, "date": bool}.
  final Map<String, Map<String, bool>> _checklist = {};

  static const _cleRecue = 'recue';
  static const _cleDate = 'date';

  void _lireChecklist(String? brut) {
    _checklist.clear();
    if (brut == null || brut.trim().isEmpty) return;
    try {
      final brutMap = (jsonDecode(brut) as Map).cast<String, dynamic>();
      for (final e in brutMap.entries) {
        final valeurs = (e.value as Map).cast<String, dynamic>();
        _checklist[e.key] = {
          _cleRecue: valeurs[_cleRecue] == true,
          _cleDate: valeurs[_cleDate] == true,
        };
      }
    } catch (_) {
      // JSON illisible : on repart d'une checklist vide.
    }
  }

  @override
  void initState() {
    super.initState();
    final c = widget.controle;
    _activite = TextEditingController(text: c?.activiteCode ?? '');
    _ligne = TextEditingController(text: c?.ligneBudgetaire ?? '');
    _beneficiaire = TextEditingController(text: c?.beneficiaire ?? '');
    _typePJ = TextEditingController(text: c?.typePJ ?? '');
    _alloue = TextEditingController(text: (c?.montantAlloue ?? 0).toString());
    _paye = TextEditingController(text: (c?.montantPaye ?? 0).toString());
    _montantPJ = TextEditingController(text: (c?.montantPJ ?? 0).toString());
    _observation = TextEditingController(text: c?.observation ?? '');
    _dateDebut = c?.dateDebutActivite;
    _dateFin = c?.dateFinActivite;
    _datePJ = c?.datePJ;
    _pjRecue = c?.pjRecue.isNotEmpty == true ? c!.pjRecue : OuiNon.oui;
    _pjConforme = c?.pjConforme.isNotEmpty == true ? c!.pjConforme : OuiNon.oui;
    _lireChecklist(c?.checklistPJ);
    // Pré-remplissage du budget alloué à partir des lignes budgétaires de
    // l'activité (uniquement à la création : une saisie existante est gardée).
    if (widget.controle == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _reprendreBudgetAlloue(silencieux: true);
      });
    }
  }

  double _val(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.')) ?? 0;

  static String _chiffre(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(2);

  /// Sélection d'une activité : reprend automatiquement ses dates et son
  /// montant alloué, pour éviter les ressaisies et les incohérences.
  void _surActivite(String code) {
    final activites = ref.read(activitesProvider).value ?? const <Activite>[];
    for (final a in activites) {
      if (a.code == code.trim()) {
        setState(() {
          _dateDebut ??= a.dateDebut;
          _dateFin ??= a.dateFin;
        });
        break;
      }
    }
    _reprendreBudgetAlloue(silencieux: true);
  }

  /// Coche la case « date PJ conforme » de chaque pièce selon la matrice de
  /// règles (contrôle automatique) ; la réception reste à confirmer à la main.
  void _verifierDatesSelonRegles() {
    final regles = ref.read(reglesParametresProvider).value;
    if (regles == null) return;
    final rubriques = regles.rubriques;
    final effective = _rubrique ?? rubriquePourLibelle(_ligne.text, rubriques);
    if (!rubriques.contains(effective)) return;
    final pieces = regles.piecesPour(effective, sousRubrique: _sousRubrique);
    if (pieces.isEmpty) return;
    setState(() {
      for (final p in pieces) {
        final evaluation = evaluerPiecePJ(
          regle: p,
          datePJ: _datePJ,
          dateDebut: _dateDebut,
          dateFin: _dateFin,
        );
        final etat = _checklist.putIfAbsent(
          p.libelle,
          () => {_cleRecue: false, _cleDate: false},
        );
        etat[_cleDate] = evaluation.conformite == ConformitePiece.conforme;
      }
    });
  }

  /// Reprend le montant alloué des lignes budgétaires correspondant à
  /// l'activité et à la ligne choisies (cohérence budget ↔ dossier PJ).
  void _reprendreBudgetAlloue({bool silencieux = false}) {
    // Référentiel **non filtré** : la reprise de budget ne doit pas dépendre
    // de la recherche saisie dans la liste des pièces justificatives.
    final lignes =
        ref.read(toutesLignesBudgetProvider).value ?? const <LigneBudget>[];
    final code = _activite.text.trim();
    final libelle = _ligne.text.trim();
    var total = 0.0;
    var trouve = false;
    for (final l in lignes) {
      if (code.isNotEmpty && l.activiteCode != code) continue;
      if (libelle.isNotEmpty && l.ligneBudgetaire != libelle) continue;
      total += l.montantAlloue;
      trouve = true;
    }
    if (!trouve) {
      if (!silencieux && mounted) {
        notifier(
          context,
          'Aucune ligne budgétaire ne correspond à cette activité et à cette '
          'ligne.',
          erreur: true,
        );
      }
      return;
    }
    setState(() => _alloue.text = _chiffre(total));
  }

  @override
  void dispose() {
    for (final c in [
      _activite,
      _ligne,
      _beneficiaire,
      _typePJ,
      _alloue,
      _paye,
      _montantPJ,
      _observation,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _choisirDate(String champ) async {
    // Le calendrier s'ouvre sur la date déjà saisie : on corrige une date
    // existante sans devoir y revenir depuis aujourd'hui.
    final actuelle = switch (champ) {
      'debut' => _dateDebut,
      'fin' => _dateFin,
      _ => _datePJ,
    };
    final choix = await showDatePicker(
      context: context,
      initialDate: actuelle ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: switch (champ) {
        'debut' => 'Date de début de l’activité',
        'fin' => 'Date de fin de l’activité',
        _ => 'Date de la pièce justificative',
      },
    );
    if (choix == null) return;
    setState(() {
      switch (champ) {
        case 'debut':
          _dateDebut = choix;
        case 'fin':
          _dateFin = choix;
        case 'pj':
          _datePJ = choix;
      }
    });
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    // « PJ reçue » est pilotée par la checklist quand elle est renseignée :
    // toutes les cases cochées → Oui, aucune → Non, sinon → À compléter.
    var pjRecue = _pjRecue;
    if (_checklist.isNotEmpty) {
      final recues = _checklist.values
          .where((e) => e[_cleRecue] == true)
          .length;
      pjRecue = recues == _checklist.length
          ? OuiNon.oui
          : recues == 0
          ? OuiNon.non
          : OuiNon.aCompleter;
    }
    final repo = ref.read(controlesPJRepositoryProvider);
    final companion = ControlesPJCompanion(
      activiteCode: drift.Value(
        _activite.text.trim().isEmpty ? null : _activite.text.trim(),
      ),
      dateDebutActivite: drift.Value(_dateDebut),
      dateFinActivite: drift.Value(_dateFin),
      datePJ: drift.Value(_datePJ),
      ligneBudgetaire: drift.Value(_ligne.text.trim()),
      beneficiaire: drift.Value(_beneficiaire.text.trim()),
      typePJ: drift.Value(_typePJ.text.trim()),
      montantAlloue: drift.Value(
        double.tryParse(_alloue.text.replaceAll(',', '.')) ?? 0,
      ),
      montantPaye: drift.Value(
        double.tryParse(_paye.text.replaceAll(',', '.')) ?? 0,
      ),
      montantPJ: drift.Value(
        double.tryParse(_montantPJ.text.replaceAll(',', '.')) ?? 0,
      ),
      pjRecue: drift.Value(pjRecue),
      pjConforme: drift.Value(_pjConforme),
      checklistPJ: drift.Value(
        _checklist.isEmpty ? null : jsonEncode(_checklist),
      ),
      observation: drift.Value(_observation.text.trim()),
    );
    int idEnregistre;
    if (widget.controle == null) {
      idEnregistre = await repo.insert(companion);
    } else {
      await repo.update(widget.controle!.id, companion);
      idEnregistre = widget.controle!.id;
    }
    // Mise à jour automatique du journal des dépenses après l'enregistrement
    // du dossier PJ.
    final controle = (await repo.getAll()).where((c) => c.id == idEnregistre);
    if (controle.isNotEmpty) {
      try {
        await ref
            .read(journalDepensesServiceProvider)
            .synchroniserControlePJ(controle.first);
        ref.invalidate(depensesProvider);
      } catch (_) {
        // Le journal ne doit pas bloquer l'enregistrement du dossier.
      }
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final largeur = MediaQuery.sizeOf(context).width;
    final deux = largeur > 700;
    final codesActivite =
        ref.watch(activitesCodesProvider).value ?? const <String>[];
    final lignes =
        ref.watch(valeursListeProvider('LIGNE_BUDGETAIRE')).value ?? const [];
    final typesPJ = <String>{
      'Facture',
      'État de paiement',
      ...ref.watch(valeursListeProvider('TYPE_PJ')).value ?? const <String>[],
    }.toList();
    final controles =
        ref.watch(controlesPJProvider).value ?? const <ControlePJ>[];
    final beneficiaires = controles
        .map((c) => c.beneficiaire ?? '')
        .where((b) => b.trim().isNotEmpty)
        .toSet()
        .toList();
    final observations = controles
        .map((c) => c.observation ?? '')
        .where((o) => o.trim().isNotEmpty)
        .toSet()
        .toList();
    Widget paire(Widget a, Widget b) => deux
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: a),
              const SizedBox(width: 12),
              Expanded(child: b),
            ],
          )
        : Column(children: [a, const SizedBox(height: 12), b]);

    Widget champDate(String label, DateTime? valeur, String champ) => InkWell(
      onTap: () => _choisirDate(champ),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(valeur == null ? 'Non définie' : formatDate(valeur)),
      ),
    );

    return AlertDialog(
      title: TitreDialogue(
        widget.controle == null
            ? 'Nouveau contrôle PJ'
            : 'Modifier le contrôle PJ',
        icone: Icons.attach_file_outlined,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 720),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                paire(
                  ChampListe(
                    controller: _activite,
                    label: 'Code activité *',
                    valeurs: codesActivite,
                    prefixIcon: Icons.confirmation_number_outlined,
                    onChanged: _surActivite,
                    validator: (v) =>
                        validateurObligatoire(v, champ: 'Le code activité'),
                  ),
                  ChampListe(
                    controller: _ligne,
                    label: 'Ligne budgétaire *',
                    valeurs: lignes,
                    prefixIcon: Icons.receipt_outlined,
                    onChanged: (_) => _reprendreBudgetAlloue(silencieux: true),
                    validator: (v) =>
                        validateurObligatoire(v, champ: 'La ligne budgétaire'),
                  ),
                ),
                const SizedBox(height: 12),
                paire(
                  ChampListe(
                    controller: _beneficiaire,
                    label: 'Bénéficiaire / fournisseur',
                    valeurs: beneficiaires,
                    prefixIcon: Icons.person_outline,
                  ),
                  ChampListe(
                    controller: _typePJ,
                    label: 'Type de pj avec montant',
                    valeurs: typesPJ,
                    hint: 'Soit Facture, soit État de paiement',
                    helperText:
                        'Le montant de la pièce est saisi dans « Montant PJ ».',
                    prefixIcon: Icons.attach_file_outlined,
                  ),
                ),
                const SizedBox(height: 12),
                paire(
                  champDate('Date début activité', _dateDebut, 'debut'),
                  champDate('Date fin activité', _dateFin, 'fin'),
                ),
                const SizedBox(height: 12),
                paire(
                  champDate('Date PJ', _datePJ, 'pj'),
                  DropdownButtonFormField<String>(
                    initialValue: _pjRecue,
                    decoration: InputDecoration(
                      labelText: 'PJ reçue',
                      helperText: _checklist.isEmpty
                          ? null
                          : 'Déterminée par la checklist ci-dessous',
                    ),
                    items: const [
                      DropdownMenuItem(value: OuiNon.oui, child: Text('Oui')),
                      DropdownMenuItem(value: OuiNon.non, child: Text('Non')),
                      DropdownMenuItem(
                        value: OuiNon.aCompleter,
                        child: Text('À compléter'),
                      ),
                    ],
                    onChanged: _checklist.isEmpty
                        ? (v) => setState(() => _pjRecue = v ?? OuiNon.oui)
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                paire(
                  DropdownButtonFormField<String>(
                    initialValue: _pjConforme,
                    decoration: const InputDecoration(labelText: 'PJ conforme'),
                    items: const [
                      DropdownMenuItem(value: OuiNon.oui, child: Text('Oui')),
                      DropdownMenuItem(value: OuiNon.non, child: Text('Non')),
                      DropdownMenuItem(
                        value: OuiNon.aVerifier,
                        child: Text('À vérifier'),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _pjConforme = v ?? OuiNon.oui),
                  ),
                  ChampNombre(
                    controller: _alloue,
                    label: 'Montant alloué (Ar)',
                    step: 1000,
                    onChanged: () => setState(() {}),
                    validator: (v) => validateurMontant(v, obligatoire: true),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _reprendreBudgetAlloue,
                    icon: const Icon(Icons.sync_outlined, size: 16),
                    label: const Text('Reprendre le budget alloué'),
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 12.5),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                paire(
                  ChampNombre(
                    controller: _paye,
                    label: 'Montant payé (Ar)',
                    step: 1000,
                    onChanged: () => setState(() {}),
                    validator: (v) => validateurMontant(v, obligatoire: true),
                  ),
                  ChampNombre(
                    controller: _montantPJ,
                    label: 'Montant PJ (Ar)',
                    step: 1000,
                    onChanged: () => setState(() {}),
                    validator: (v) => validateurMontant(v, obligatoire: true),
                  ),
                ),
                const SizedBox(height: 12),
                _AnalyseControlePJ(
                  montantAlloue: _val(_alloue),
                  montantPaye: _val(_paye),
                  montantPJ: _val(_montantPJ),
                  dateDebut: _dateDebut,
                  dateFin: _dateFin,
                  datePJ: _datePJ,
                ),
                const SizedBox(height: 16),
                _ChecklistPJRequises(
                  regles: ref.watch(reglesParametresProvider).value,
                  ligne: _ligne.text,
                  rubrique: _rubrique,
                  sousRubrique: _sousRubrique,
                  onRubrique: (v) => setState(() {
                    _rubrique = v;
                    _sousRubrique = null;
                  }),
                  onSousRubrique: (v) => setState(() => _sousRubrique = v),
                  dateDebut: _dateDebut,
                  dateFin: _dateFin,
                  datePJ: _datePJ,
                  checklist: _checklist,
                  onAutoRemplir: _verifierDatesSelonRegles,
                  onBasculer: (piece, champ) => setState(() {
                    final etat = _checklist.putIfAbsent(
                      piece,
                      () => {_cleRecue: false, _cleDate: false},
                    );
                    etat[champ] = !(etat[champ] ?? false);
                  }),
                ),
                const SizedBox(height: 12),
                ChampListe(
                  controller: _observation,
                  label: 'Observation',
                  valeurs: observations,
                  prefixIcon: Icons.notes_outlined,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: _enregistrer,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

/// Checklist des pièces requises déduite de la matrice de `PARAMETRES`
/// (`parametres.xlsx`), avec vérification de la règle de date de chaque pièce.
class _ChecklistPJRequises extends StatelessWidget {
  const _ChecklistPJRequises({
    required this.regles,
    required this.ligne,
    required this.rubrique,
    required this.sousRubrique,
    required this.onRubrique,
    required this.onSousRubrique,
    required this.dateDebut,
    required this.dateFin,
    required this.datePJ,
    this.checklist = const {},
    this.onBasculer,
    this.onAutoRemplir,
  });

  /// Pièce → état des deux cases : « PJ reçue » et « Date PJ conforme ».
  final Map<String, Map<String, bool>> checklist;

  /// Bascule d'une case de la checklist.
  final void Function(String piece, String champ)? onBasculer;

  /// Vérifie automatiquement les dates PJ d'après la matrice de règles.
  final VoidCallback? onAutoRemplir;

  final ReglesParametres? regles;
  final String ligne;
  final String? rubrique;
  final String? sousRubrique;
  final ValueChanged<String?> onRubrique;
  final ValueChanged<String?> onSousRubrique;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final DateTime? datePJ;

  @override
  Widget build(BuildContext context) {
    final r = regles;
    if (r == null || r.matricePJ.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final rubriques = r.rubriques;
    final effective = rubrique ?? rubriquePourLibelle(ligne, rubriques);
    final valeurRubrique = rubriques.contains(effective) ? effective : null;
    final sousRubriques = valeurRubrique == null
        ? <String>[]
        : r.sousRubriquesDe(valeurRubrique);
    final pieces = valeurRubrique == null
        ? <ReglePJRequise>[]
        : r.piecesPour(valeurRubrique, sousRubrique: sousRubrique);
    final evaluations = [
      for (final p in pieces)
        evaluerPiecePJ(
          regle: p,
          datePJ: datePJ,
          dateDebut: dateDebut,
          dateFin: dateFin,
        ),
    ];
    final conformes = evaluations
        .where((e) => e.conformite == ConformitePiece.conforme)
        .length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.rule_folder_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Checklist des PJ requises',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
              ),
              if (pieces.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (conformes == pieces.length
                                ? vertValide(context)
                                : ambreAttention(context))
                            .withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$conformes / ${pieces.length} prête(s)',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: conformes == pieces.length
                          ? vertValide(context)
                          : ambreAttention(context),
                    ),
                  ),
                ),
            ],
          ),
          if (pieces.isNotEmpty && onAutoRemplir != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onAutoRemplir,
                icon: const Icon(Icons.rule_outlined, size: 16),
                label: const Text('Vérifier les dates selon les règles'),
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 12.5),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: valeurRubrique,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Rubrique'),
                  items: [
                    for (final rb in rubriques)
                      DropdownMenuItem(
                        value: rb,
                        child: Text(rb, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: onRubrique,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: sousRubrique,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Sous-rubrique'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Toutes')),
                    for (final sr in sousRubriques)
                      DropdownMenuItem(
                        value: sr,
                        child: Text(
                          sr.isEmpty ? '(aucune)' : sr,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: onSousRubrique,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (pieces.isEmpty)
            Text(
              'Aucune pièce définie pour cette rubrique.',
              style: theme.textTheme.bodySmall,
            )
          else
            _TableauChecklist(
              evaluations: evaluations,
              checklist: checklist,
              onBasculer: onBasculer,
            ),
        ],
      ),
    );
  }
}

/// Tableau de la checklist des PJ requises : pour chaque pièce, deux cases à
/// cocher — « PJ reçue » et « Conformité date PJ » — dont la valeur est
/// affichée par des croix (✓ / ✗).
class _TableauChecklist extends StatelessWidget {
  const _TableauChecklist({
    required this.evaluations,
    required this.checklist,
    required this.onBasculer,
  });

  final List<EvaluationPiecePJ> evaluations;
  final Map<String, Map<String, bool>> checklist;
  final void Function(String piece, String champ)? onBasculer;

  static const _recue = 'recue';
  static const _date = 'date';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surface,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'PJ requise',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                SizedBox(
                  width: 96,
                  child: Text(
                    'PJ reçue',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Text(
                    'Date PJ conforme',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          for (final evaluation in evaluations)
            _LigneChecklist(
              evaluation: evaluation,
              recue: checklist[evaluation.piece.libelle]?[_recue] ?? false,
              dateConforme:
                  checklist[evaluation.piece.libelle]?[_date] ?? false,
              onBasculer: onBasculer == null
                  ? null
                  : (champ) => onBasculer!(evaluation.piece.libelle, champ),
            ),
        ],
      ),
    );
  }
}

/// Une ligne de la checklist : pièce + ses deux cases (✓ / ✗).
class _LigneChecklist extends StatelessWidget {
  const _LigneChecklist({
    required this.evaluation,
    required this.recue,
    required this.dateConforme,
    this.onBasculer,
  });

  final EvaluationPiecePJ evaluation;
  final bool recue;
  final bool dateConforme;
  final ValueChanged<String>? onBasculer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final piece = evaluation.piece;
    final regleDate = piece.regleDate.replaceAll(';', ' · ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  piece.sousRubrique.isEmpty
                      ? piece.piece
                      : '${piece.sousRubrique} — ${piece.piece}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: piece.obligatoire
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                if (regleDate.isNotEmpty)
                  Text(
                    regleDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 96,
            child: Center(
              child: _Croix(
                valeur: recue,
                libelle: 'PJ reçue',
                onTap: onBasculer == null
                    ? null
                    : () => onBasculer!(_TableauChecklist._recue),
              ),
            ),
          ),
          SizedBox(
            width: 110,
            child: Center(
              child: _Croix(
                valeur: dateConforme,
                libelle: 'Date PJ conforme',
                onTap: onBasculer == null
                    ? null
                    : () => onBasculer!(_TableauChecklist._date),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Case « oui / non » affichée par une croix verte (✓) ou rouge (✗).
class _Croix extends StatelessWidget {
  const _Croix({required this.valeur, required this.libelle, this.onTap});

  final bool valeur;
  final String libelle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final couleur = valeur ? vertValide(context) : rougeAlerte(context);
    return Tooltip(
      message: '$libelle : ${valeur ? 'Oui' : 'Non'}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 34,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: couleur.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: couleur.withValues(alpha: 0.5)),
          ),
          child: Icon(
            valeur ? Icons.check : Icons.close,
            size: 17,
            color: couleur,
          ),
        ),
      ),
    );
  }
}
