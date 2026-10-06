import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../domain/models.dart';
import '../../../domain/services/regles_metier.dart';
import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/tableau.dart';

/// Indemnités : total théorique (présences), indemnités de délai de route,
/// total reçu et saisie détaillée (état de paiement, provenance, taux,
/// montant alloué / payé).
///
/// Tous les champs sont pré-remplis automatiquement à partir des règles
/// (district, référentiel tarifaire, restauration de l'activité).
class IndemnitesScreen extends ConsumerStatefulWidget {
  const IndemnitesScreen({this.imbrique = false, super.key});

  /// Quand `true`, l'écran est affiché dans l'onglet « Dossier PJ » :
  /// pas de Scaffold ni d'en-tête propre.
  final bool imbrique;

  @override
  ConsumerState<IndemnitesScreen> createState() => _IndemnitesScreenState();
}

class _IndemnitesScreenState extends ConsumerState<IndemnitesScreen> {
  @override
  Widget build(BuildContext context) {
    final activites = ref.watch(activitesProvider);
    // Même activité que dans « Présences » : le choix est mémorisé et partagé.
    final activiteCode = ref.watch(activiteSelectionneeProvider);
    final corps = Column(
      children: [
        if (!widget.imbrique)
          const EnTetePage(
            titre: 'Indemnités',
            sousTitre:
                'Jours = délai de route + jours d’activité, taux selon le '
                'district (chef-lieu de région / district)',
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              SizedBox(
                width: 340,
                child: activites.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Erreur : $e'),
                  data: (liste) => DropdownButtonFormField<String>(
                    key: ValueKey('activite-$activiteCode'),
                    initialValue: activiteCode,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Activité',
                      prefixIcon: Icon(Icons.event_note_outlined),
                    ),
                    hint: const Text('Sélectionner une activité'),
                    items: [
                      for (final a in liste)
                        DropdownMenuItem(
                          value: a.code,
                          child: Text(
                            '${a.code} — ${a.description}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (v) =>
                        ref.read(activiteSelectionneeProvider.notifier).state =
                            v,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: activiteCode == null
              ? const EtatVide(
                  message:
                      'Sélectionnez une activité pour consulter les indemnités.',
                  icone: Icons.payments_outlined,
                )
              : _VueIndemnites(activiteCode: activiteCode),
        ),
      ],
    );
    return widget.imbrique ? corps : Scaffold(body: corps);
  }
}

class _VueIndemnites extends ConsumerWidget {
  const _VueIndemnites({required this.activiteCode});
  final String activiteCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syntheses = ref.watch(syntheseIndemnitesProvider(activiteCode));
    final saisies = ref.watch(indemnitesSaisiesActiviteProvider(activiteCode));

    return syntheses.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EtatErreur(
        erreur: e,
        onReessayer: () =>
            ref.invalidate(syntheseIndemnitesProvider(activiteCode)),
      ),
      data: (liste) => saisies.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EtatErreur(erreur: e),
        data: (lignes) => _Contenu(
          activiteCode: activiteCode,
          syntheses: liste,
          saisies: lignes,
        ),
      ),
    );
  }
}

class _Contenu extends ConsumerWidget {
  const _Contenu({
    required this.activiteCode,
    required this.syntheses,
    required this.saisies,
  });

  final String activiteCode;
  final List<SyntheseIndemniteParticipant> syntheses;
  final List<IndemniteSaisie> saisies;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalTheoriquePresences =
        syntheses.fold<double>(0, (s, e) => s + e.indemniteTheorique);

    // Décomposition des saisies selon la règle d'or : la part « délai de
    // route » est payée à 100 % ; la part « jours d'activité » applique
    // 85 % ou 100 % selon la prise en charge du déjeuner. Les deux parts
    // recomposent exactement le montant alloué enregistré.
    final totalRoute = saisies.fold<double>(
      0,
      (s, e) => s + ReglesMetier.indemniteDelaiRoute(
            delaiRoute: e.delaiRoute,
            taux: e.taux,
          ),
    );
    final totalAlloue = saisies.fold<double>(0, (s, e) => s + e.montantAlloue);
    final totalActivite = totalAlloue - totalRoute;
    final totalPaye = saisies.fold<double>(0, (s, e) => s + e.montantPaye);
    final solde = totalAlloue - totalPaye;
    final conformes =
        syntheses.where((e) => e.statut.code == 'CONFORME').length;

    // Une seule rangée de cartes compactes : toutes de même largeur et de
    // même hauteur, alignées horizontalement.
    final cartes = <Widget>[
      CarteIndicateur(
        titre: 'Délai de route (100 %)',
        valeur: formatMontant(totalRoute),
        icone: Icons.route_outlined,
        couleur: const Color(0xFF662583),
        sousTitre: 'Délai de route × taux',
        compact: true,
      ),
      CarteIndicateur(
        titre: 'Jours d’activité (85 % / 100 %)',
        valeur: formatMontant(totalActivite),
        icone: Icons.event_available_outlined,
        couleur: const Color(0xFF00838F),
        sousTitre: 'Jours d’activité × taux ajusté',
        compact: true,
      ),
      CarteIndicateur(
        titre: 'Total indemnités allouées',
        valeur: formatMontant(totalAlloue),
        icone: Icons.calculate_outlined,
        couleur: const Color(0xFF1F4E79),
        sousTitre: 'Délai de route + jours d’activité',
        compact: true,
      ),
      CarteIndicateur(
        titre: 'Total payé',
        valeur: formatMontant(totalPaye),
        icone: Icons.payments_outlined,
        couleur: const Color(0xFF2E7D32),
        sousTitre: 'Montants versés',
        compact: true,
      ),
      CarteIndicateur(
        titre: 'Solde à payer',
        valeur: formatMontant(solde),
        icone: Icons.balance_outlined,
        couleur: solde.abs() <= 0.000001
            ? const Color(0xFF2E7D32)
            : const Color(0xFFF9A825),
        sousTitre: 'Alloué − payé',
        compact: true,
      ),
      CarteIndicateur(
        titre: 'Présences : indemnité théorique',
        valeur: formatMontant(totalTheoriquePresences),
        icone: Icons.checklist_outlined,
        couleur: const Color(0xFF283593),
        sousTitre: 'Jours présents × taux journalier',
        compact: true,
      ),
      CarteIndicateur(
        titre: 'Participants conformes',
        valeur: '$conformes / ${syntheses.length}',
        icone: Icons.verified_outlined,
        couleur: const Color(0xFF2E7D32),
        sousTitre: 'Sur ${syntheses.length} participant(s)',
        compact: true,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      children: [
        _BandeauRegleOr(),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, contraintes) {
            // Largeur égale pour les 7 cartes : une seule ligne quand la
            // fenêtre le permet, deux rangées alignées sinon.
            const espace = 10.0;
            final largeurCarte =
                ((contraintes.maxWidth - espace * 6) / 7).clamp(118.0, 230.0);
            return Wrap(
              spacing: espace,
              runSpacing: espace,
              children: [
                for (final carte in cartes)
                  SizedBox(width: largeurCarte, child: carte),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                'Saisie des indemnités',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            FilledButton.icon(
              onPressed: () => _ouvrirSaisie(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nouvelle saisie'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (saisies.isEmpty)
          const EtatVide(
            message:
                'Aucune indemnité saisie pour cette activité.\n'
                'Les champs sont pré-remplis automatiquement selon les règles '
                '(district, taux, délai de route).',
            icone: Icons.payments_outlined,
          )
        else ...[
          const SizedBox(height: 4),
          TableauGestion<IndemniteSaisie>(
              lignes: saisies,
              cleLigne: (s) => s.id,
              taillePage: 10,
              messageVide: 'Aucune saisie d’indemnité.',
              colonnes: [
                ColonneTableau(
                  label: 'Ligne budgetaire',
                  flex: 4,
                  valeur: (s) => s.ligneBudgetaire,
                ),
                ColonneTableau(
                  label: 'Participant',
                  flex: 4,
                  valeur: (s) => s.participantNom,
                ),
                ColonneTableau(
                  label: 'État de paiement',
                  flex: 3,
                  valeur: (s) => s.etatPaiement,
                  cellule: (_, s) => Chip(
                    label: Text(
                      s.etatPaiement,
                      style: const TextStyle(fontSize: 11),
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: s.etatPaiement == 'Payé'
                        ? const Color(0xFF2E7D32).withValues(alpha: 0.12)
                        : s.etatPaiement == 'Non payé'
                            ? const Color(0xFFC62828).withValues(alpha: 0.10)
                            : null,
                  ),
                ),
                ColonneTableau(
                  label: 'Provenance',
                  flex: 3,
                  valeur: (s) => s.provenance ?? '',
                ),
                ColonneTableau(
                  label: 'Délai route (j)',
                  flex: 2,
                  numerique: true,
                  valeur: (s) => s.delaiRoute.toStringAsFixed(1),
                  cleTri: (s) => s.delaiRoute,
                ),
                ColonneTableau(
                  label: 'Jours activité',
                  flex: 2,
                  numerique: true,
                  valeur: (s) => s.nombreJoursActivite.toStringAsFixed(0),
                  cleTri: (s) => s.nombreJoursActivite,
                ),
                ColonneTableau(
                  label: 'Taux',
                  flex: 3,
                  numerique: true,
                  valeur: (s) => formatMontant(s.taux),
                  cleTri: (s) => s.taux,
                ),
                ColonneTableau(
                  label: 'Montant alloué',
                  flex: 3,
                  numerique: true,
                  valeur: (s) => formatMontant(s.montantAlloue),
                  cleTri: (s) => s.montantAlloue,
                ),
                ColonneTableau(
                  label: 'Montant payé',
                  flex: 3,
                  numerique: true,
                  valeur: (s) => formatMontant(s.montantPaye),
                  cleTri: (s) => s.montantPaye,
                ),
              ],
              actions: [
                ActionTableau<IndemniteSaisie>(
                  icone: Icons.edit_outlined,
                  infobulle: 'Modifier',
                  onTap: (s) => _ouvrirSaisie(context, ref, saisie: s),
                ),
                ActionTableau<IndemniteSaisie>(
                  icone: Icons.delete_outline,
                  infobulle: 'Supprimer',
                  couleur: Theme.of(context).colorScheme.error,
                  onTap: (s) async {
                    final ok = await confirmer(
                      context,
                      titre: 'Supprimer la saisie',
                      message:
                          'Supprimer l’indemnité de ${s.participantNom} ?',
                    );
                    if (!ok) return;
                    await ref
                        .read(indemnitesSaisiesRepositoryProvider)
                        .delete(s.id);
                    await _synchroniserJournal(ref, activiteCode);
                  },
                ),
              ],
              onSupprimer: (lignes) async {
                final repo = ref.read(indemnitesSaisiesRepositoryProvider);
                for (final s in lignes) {
                  await repo.delete(s.id);
                }
                await _synchroniserJournal(ref, activiteCode);
              },
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'Présences et indemnités par participant',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        if (syntheses.isEmpty)
          const EtatVide(
            message: 'Aucune présence saisie pour cette activité.',
            icone: Icons.calendar_month_outlined,
          )
        else
          TableauGestion<SyntheseIndemniteParticipant>(
              lignes: syntheses,
              cleLigne: (s) => s.participantId,
              taillePage: 10,
              messageVide: 'Aucune indemnité à afficher pour cette activité.',
              colonnes: [
                ColonneTableau(
                  label: 'Participant',
                  flex: 4,
                  valeur: (s) => s.participantNom,
                ),
                ColonneTableau(
                  label: 'Présents',
                  flex: 1,
                  numerique: true,
                  valeur: (s) => '${s.nombreJoursPresents}',
                  cleTri: (s) => s.nombreJoursPresents,
                ),
                ColonneTableau(
                  label: 'Taux journalier',
                  flex: 3,
                  numerique: true,
                  valeur: (s) => formatMontant(s.tauxJournalier),
                  cleTri: (s) => s.tauxJournalier,
                ),
                ColonneTableau(
                  label: 'Indemnité théorique',
                  flex: 3,
                  numerique: true,
                  valeur: (s) => formatMontant(s.indemniteTheorique),
                  cleTri: (s) => s.indemniteTheorique,
                ),
                ColonneTableau(
                  label: 'Indemnité reçue',
                  flex: 3,
                  numerique: true,
                  valeur: (s) => formatMontant(s.indemniteRecue),
                  cleTri: (s) => s.indemniteRecue,
                ),
                ColonneTableau(
                  label: 'Statut',
                  flex: 3,
                  valeur: (s) => s.statut.libelle,
                  cellule: (_, s) =>
                      PastilleStatut(statut: s.statut, compact: true),
                ),
              ],
          ),
      ],
    );
  }

  Future<void> _ouvrirSaisie(
    BuildContext context,
    WidgetRef ref, {
    IndemniteSaisie? saisie,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => IndemniteSaisieDialog(
        activiteCode: activiteCode,
        saisie: saisie,
      ),
    );
    if (ok != true) return;
    await _synchroniserJournal(ref, activiteCode);
    if (context.mounted) notifier(context, 'Indemnité enregistrée');
  }

  /// Mise à jour automatique des dépenses dans le journal des dépenses.
  Future<void> _synchroniserJournal(WidgetRef ref, String code) async {
    try {
      final saisies =
          await ref.read(indemnitesSaisiesRepositoryProvider).parActivite(code);
      final paye = saisies.fold<double>(0, (s, e) => s + e.montantPaye);
      await ref.read(journalDepensesServiceProvider).synchroniserIndemnites(
            activiteCode: code,
            montant: paye,
            observation: 'Indemnités encaissées (dossier PJ)',
          );
      ref.invalidate(depensesProvider);
    } catch (_) {
      // Le journal ne doit jamais bloquer la saisie.
    }
  }
}

/// Rappel de la règle d'or appliquée à toutes les indemnités.
class _BandeauRegleOr extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.functions, size: 20, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Règle appliquée (par participant)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Indemnité = participants × [ délai de route × taux 100 % '
                  '+ jours d’activité × taux (85 % si déjeuner pris en charge, '
                  '100 % sinon) ]',
                  style: const TextStyle(fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialogue de saisie d'une indemnité, entièrement pré-rempli à partir des
/// règles : district (taux, délai de route), jours d'activité, restauration.
class IndemniteSaisieDialog extends ConsumerStatefulWidget {
  const IndemniteSaisieDialog({
    required this.activiteCode,
    this.saisie,
    super.key,
  });

  final String activiteCode;
  final IndemniteSaisie? saisie;

  @override
  ConsumerState<IndemniteSaisieDialog> createState() =>
      _IndemniteSaisieDialogState();
}

class _IndemniteSaisieDialogState extends ConsumerState<IndemniteSaisieDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _ligneBudgetaire;
  int? _participantId;
  String _etatPaiement = 'À payer';
  String? _provenance;
  double _delaiRoute = 0;
  double _taux = 0;
  bool _restauration = false;
  final _montantPaye = TextEditingController();

  static const _etatsPaiement = ['Payé', 'Partiel', 'À payer', 'Non payé'];

  @override
  void initState() {
    super.initState();
    final s = widget.saisie;
    _ligneBudgetaire = s?.ligneBudgetaire.isEmpty == true
        ? null
        : s?.ligneBudgetaire;
    _participantId = s?.participantId;
    _etatPaiement = s?.etatPaiement ?? 'À payer';
    _provenance = s?.provenance;
    _delaiRoute = s?.delaiRoute ?? 0;
    _taux = s?.taux ?? 0;
    _restauration = s?.restauration ?? false;
    _montantPaye.text = s == null ? '' : _chiffre(s.montantPaye);
    // Pré-remplissage automatique au premier affichage.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _preRemplir();
    });
  }

  @override
  void dispose() {
    _montantPaye.dispose();
    super.dispose();
  }

  static String _chiffre(num v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(2);

  Activite? get _activite {
    for (final a in ref.read(activitesProvider).value ?? const <Activite>[]) {
      if (a.code == widget.activiteCode) return a;
    }
    return null;
  }

  District? _districtParNom(String nom) {
    for (final d in ref.read(tousDistrictsProvider).value ?? const <District>[]) {
      if (d.nom.toLowerCase() == nom.trim().toLowerCase()) return d;
    }
    return null;
  }

  /// Jours d'activité (date début → date fin inclus).
  int get _joursActivite {
    final a = _activite;
    if (a == null || a.dateDebut == null || a.dateFin == null) return 0;
    final d = DateTime(a.dateDebut!.year, a.dateDebut!.month, a.dateDebut!.day);
    final f = DateTime(a.dateFin!.year, a.dateFin!.month, a.dateFin!.day);
    return f.difference(d).inDays + 1;
  }

  /// Zone d'indemnité selon le district (chef-lieu de région ou district).
  String get _zone {
    final d = (_provenance ?? '').isEmpty ? null : _districtParNom(_provenance!);
    if (d == null) return 'Région';
    return d.estChefLieuRegion ? 'Région' : 'District';
  }

  /// Taux d'indemnité appliqué automatiquement (règles `REFERENTIEL_TARIFS`).
  double _tauxSelonRegle() {
    final tarifs = ref.read(tousTarifsProvider).value ?? const <TarifReferentiel>[];
    final ligne = _ligneBudgetaire ?? '';
    for (final t in tarifs) {
      if (ligne.isNotEmpty &&
          t.ligneBudgetaire.trim().toLowerCase() == ligne.trim().toLowerCase() &&
          t.zone.trim().toLowerCase() == _zone.toLowerCase()) {
        return t.tarif;
      }
    }
    for (final t in tarifs) {
      if (t.ligneBudgetaire.toUpperCase().contains('INDEMNIT') &&
          t.zone.trim().toLowerCase() == _zone.toLowerCase()) {
        return t.tarif;
      }
    }
    return _zone.toLowerCase() == 'région' ? 200000 : 150000;
  }

  /// Taux réellement appliqué (saisi ou déduit du référentiel).
  double get _tauxApplique => _taux > 0 ? _taux : _tauxSelonRegle();

  /// Montant alloué — **règle d'or** (par participant) :
  /// délai de route × taux 100 % + jours d'activité × taux (85 % si le
  /// déjeuner est pris en charge, 100 % sinon).
  double get _montantAlloue => ReglesMetier.indemniteParticipant(
        delaiRoute: _delaiRoute,
        joursActivite: _joursActivite.toDouble(),
        taux: _tauxApplique,
        avecDejeuner: _restauration,
      );

  /// Pré-remplissage automatique depuis l'activité et ses règles.
  void _preRemplir() {
    final a = _activite;
    final districts =
        ref.read(tousDistrictsProvider).value ?? const <District>[];
    setState(() {
      if (a != null) {
        _restauration = a.restauration || _restauration;
        if (_provenance == null || _provenance!.trim().isEmpty) {
          _provenance = (a.district ?? '').isEmpty ? null : a.district;
        }
      }
      District? trouve;
      for (final d in districts) {
        if ((_provenance ?? '').toLowerCase() == d.nom.toLowerCase()) {
          trouve = d;
          break;
        }
      }
      if (widget.saisie == null && trouve != null) {
        _delaiRoute = trouve.delaiRouteTotal;
      }
      if (_ligneBudgetaire == null || _ligneBudgetaire!.isEmpty) {
        final lignes =
            ref.read(valeursListeProvider('LIGNE_BUDGETAIRE')).value ?? [];
        for (final l in lignes) {
          if (l.toUpperCase().contains('INDEMNIT')) {
            _ligneBudgetaire = l;
            break;
          }
        }
      }
      if (widget.saisie == null || _taux == 0) _taux = _tauxSelonRegle();
    });
  }

  double _nombre(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.')) ?? 0;

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    final participants =
        ref.read(tousParticipantsProvider).value ?? const <Participant>[];
    String nomParticipant = '';
    for (final p in participants) {
      if (p.id == _participantId) {
        nomParticipant = '${p.nom} ${p.prenom}'.trim();
        break;
      }
    }
    final montantPaye = _montantPaye.text.trim().isEmpty
        ? (_etatPaiement == 'Payé' ? _montantAlloue : 0.0)
        : _nombre(_montantPaye);

    final repo = ref.read(indemnitesSaisiesRepositoryProvider);
    final companion = IndemnitesSaisiesCompanion(
      activiteCode: drift.Value(widget.activiteCode),
      ligneBudgetaire: drift.Value(_ligneBudgetaire ?? ''),
      participantId: drift.Value(_participantId),
      participantNom: drift.Value(nomParticipant),
      etatPaiement: drift.Value(_etatPaiement),
      provenance: drift.Value(_provenance),
      delaiRoute: drift.Value(_delaiRoute),
      nombreJoursActivite: drift.Value(_joursActivite.toDouble()),
      restauration: drift.Value(_restauration),
      taux: drift.Value(_taux > 0 ? _taux : _tauxSelonRegle()),
      montantAlloue: drift.Value(_montantAlloue),
      montantPaye: drift.Value(montantPaye),
    );
    if (widget.saisie == null) {
      await repo.insert(companion);
    } else {
      await repo.update(widget.saisie!.id, companion);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final participants =
        ref.watch(tousParticipantsProvider).value ?? const <Participant>[];
    final lignes =
        ref.watch(valeursListeProvider('LIGNE_BUDGETAIRE')).value ?? const [];
    final indemnitesLignes = lignes
        .where((l) => l.toUpperCase().contains('INDEMNIT'))
        .toSet()
        .toList();
    final districts =
        ref.watch(tousDistrictsProvider).value ?? const <District>[];
    final a = _activite;

    return AlertDialog(
      title: TitreDialogue(
        widget.saisie == null
            ? 'Nouvelle saisie d’indemnité'
            : 'Modifier l’indemnité',
        icone: Icons.payments_outlined,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 720),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activité : ${widget.activiteCode}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nombre de jours = délai de route '
                        '${_delaiRoute.toStringAsFixed(1)} + jours d’activité '
                        '$_joursActivite',
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _ligneBudgetaire,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Ligne budgetaire',
                          prefixIcon: Icon(Icons.receipt_outlined),
                        ),
                        items: [
                          for (final l in indemnitesLignes)
                            DropdownMenuItem(
                              value: l,
                              child: Text(l,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                        ],
                        onChanged: (v) => setState(() {
                          _ligneBudgetaire = v;
                          _taux = _tauxSelonRegle();
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _participantId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Participant',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        items: [
                          for (final p in participants)
                            DropdownMenuItem(
                              value: p.id,
                              child: Text(
                                '${p.nom} ${p.prenom}'.trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (v) =>
                            setState(() => _participantId = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _etatPaiement,
                        decoration: const InputDecoration(
                          labelText: 'État de paiement',
                          prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                        ),
                        items: [
                          for (final e in _etatsPaiement)
                            DropdownMenuItem(value: e, child: Text(e)),
                        ],
                        onChanged: (v) => setState(() {
                          _etatPaiement = v ?? 'À payer';
                          if (_etatPaiement == 'Payé' &&
                              _montantPaye.text.trim().isEmpty) {
                            _montantPaye.text = _chiffre(_montantAlloue);
                          }
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _provenance,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Provenance (district)',
                          prefixIcon: Icon(Icons.map_outlined),
                        ),
                        items: [
                          for (final d in districts)
                            DropdownMenuItem(
                              value: d.nom,
                              child: Text(d.nom,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                        ],
                        onChanged: (v) => setState(() {
                          _provenance = v;
                          final d = _districtParNom(v ?? '');
                          if (d != null) _delaiRoute = d.delaiRouteTotal;
                          _taux = _tauxSelonRegle();
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ChampLecture(
                        label: 'Délai de route (jours)',
                        valeur: _delaiRoute.toStringAsFixed(1),
                        icone: Icons.route_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ChampLecture(
                        label: 'Jours d’activité',
                        valeur: '$_joursActivite',
                        icone: Icons.event_available_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ChampLecture(
                        label: 'Taux ($_zone)',
                        valeur: formatMontant(_taux > 0 ? _taux : _tauxSelonRegle()),
                        icone: Icons.attach_money_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ChampLecture(
                        label: 'Montant alloué (calculé)',
                        valeur: formatMontant(_montantAlloue),
                        icone: Icons.calculate_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LigneBascule(
                  label: 'Déjeuner pris en charge pendant l’activité',
                  sousTitre: 'Applique 85 % du taux sur les jours d’activité '
                      '(100 % sinon). Le délai de route reste à 100 %.',
                  value: _restauration,
                  onChanged: (v) => setState(() => _restauration = v),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _montantPaye,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Montant payé (Ar)',
                    prefixIcon: Icon(Icons.payments_outlined),
                    suffixText: 'Ar',
                  ),
                  validator: (v) => validateurMontant(v),
                ),
                const SizedBox(height: 6),
                if (a != null && (a.district ?? '').isNotEmpty)
                  Text(
                    'Taux appliqué automatiquement selon le district '
                    '« ${a.district} » ($_zone).',
                    style: Theme.of(context).textTheme.bodySmall,
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

/// Champ en lecture seule (valeur calculée automatiquement).
class _ChampLecture extends StatelessWidget {
  const _ChampLecture({
    required this.label,
    required this.valeur,
    required this.icone,
  });

  final String label;
  final String valeur;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icone, size: 15, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            valeur,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
