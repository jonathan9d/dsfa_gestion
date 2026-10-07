import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../domain/rubriques.dart';
import '../../../domain/services/regles_metier.dart';
import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/tableau.dart';

/// **Onglet unique « Présences & indemnités »** du dossier PJ.
///
/// Les deux tableaux d'origine (saisies d'indemnités, puis synthèse des
/// présences) sont fusionnés en **un seul tableau cohérent**, une ligne par
/// participant :
///
/// * plus aucune carte de synthèse (elles n'apportaient aucune action) ;
/// * le **nombre de jours d'activité** se modifie directement dans le tableau ;
/// * cette modification **pilote la présence** : les premiers jours de la
///   période d'activité sont marqués « Présent », les suivants « Absent » ;
/// * le montant alloué applique la règle d'or (délai de route à 100 %,
///   jours d'activité à 85 % si le déjeuner est pris en charge).
class PresencesIndemnitesScreen extends ConsumerStatefulWidget {
  const PresencesIndemnitesScreen({this.imbrique = false, super.key});

  /// Quand `true`, l'écran est affiché dans l'onglet « Dossier PJ » :
  /// pas de Scaffold ni d'en-tête propre.
  final bool imbrique;

  @override
  ConsumerState<PresencesIndemnitesScreen> createState() =>
      _PresencesIndemnitesScreenState();
}

class _PresencesIndemnitesScreenState
    extends ConsumerState<PresencesIndemnitesScreen> {
  @override
  Widget build(BuildContext context) {
    final activites = ref.watch(activitesProvider);
    final activiteCode = ref.watch(activiteSelectionneeProvider);
    final corps = Column(
      children: [
        if (!widget.imbrique)
          const EnTetePage(
            titre: 'Présences et indemnités',
            sousTitre:
                'Une ligne par participant — le nombre de jours d’activité '
                'met à jour la présence',
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              SizedBox(
                width: 380,
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
        const SizedBox(height: 14),
        Expanded(
          child: activiteCode == null
              ? const EtatVide(
                  message:
                      'Sélectionnez une activité pour saisir les présences et '
                      'les indemnités.',
                  icone: Icons.payments_outlined,
                )
              : _Vue(activiteCode: activiteCode),
        ),
      ],
    );
    return widget.imbrique ? corps : Scaffold(body: corps);
  }
}

/// Ligne « fiche participant » du tableau fusionné.
class FicheParticipant {
  FicheParticipant({
    required this.participantId,
    required this.nom,
    required this.role,
    required this.provenance,
    required this.tauxJournalier,
    required this.delaiRoute,
    required this.joursActivite,
    required this.joursPresents,
    required this.joursPeriode,
    required this.montantPaye,
    required this.etatPaiement,
    required this.restauration,
    required this.conforme,
    required this.ligneBudgetaire,
    this.saisieId,
  });

  final int participantId;
  final String nom;
  final String role;

  /// District de provenance : détermine la zone et donc le taux.
  final String provenance;
  final double tauxJournalier;
  final double delaiRoute;

  /// Jours d'activité retenus (pilote la présence).
  final double joursActivite;
  final int joursPresents;
  final int joursPeriode;
  final double montantPaye;
  final String etatPaiement;
  final bool restauration;
  final bool conforme;
  final String ligneBudgetaire;
  final int? saisieId;

  /// Le participant est-il un chauffeur ? (100 % du taux, sans abattement).
  bool get estChauffeur =>
      RubriquesBudget.normaliser(role).contains('CHAUFFEUR') ||
      RubriquesBudget.normaliser(nom).contains('CHAUFFEUR');

  double get montantAlloue => ReglesMetier.indemniteParticipant(
    delaiRoute: delaiRoute,
    joursActivite: joursActivite,
    taux: tauxJournalier,
    avecDejeuner: restauration,
    abattementRepas: !estChauffeur,
  );

  double get solde => montantAlloue - montantPaye;

  double get totalJours => delaiRoute + joursActivite;
}

class _Vue extends ConsumerWidget {
  const _Vue({required this.activiteCode});

  final String activiteCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activites = ref.watch(activitesProvider).value ?? const <Activite>[];
    Activite? activite;
    for (final a in activites) {
      if (a.code == activiteCode) activite = a;
    }
    final participants =
        ref.watch(tousParticipantsProvider).value ?? const <Participant>[];
    final affectations =
        ref.watch(affectationsActiviteProvider(activiteCode)).value ??
        const <ActiviteParticipant>[];
    final presences =
        ref.watch(presencesActiviteProvider(activiteCode)).value ??
        const <Presence>[];
    final saisies =
        ref.watch(indemnitesSaisiesActiviteProvider(activiteCode)).value ??
        const <IndemniteSaisie>[];
    final districts =
        ref.watch(tousDistrictsProvider).value ?? const <District>[];
    final tarifs =
        ref.watch(tousTarifsProvider).value ?? const <TarifReferentiel>[];
    final budgets =
        ref.watch(lignesBudgetActiviteProvider(activiteCode)).value ??
        const <LigneBudget>[];

    final parId = {for (final p in participants) p.id: p};
    final saisieParParticipant = <int, IndemniteSaisie>{};
    for (final s in saisies) {
      final id = s.participantId;
      if (id != null) saisieParParticipant[id] = s;
    }

    final joursPeriode = _joursPeriode(activite);
    final lignesPresents = <int, int>{};
    for (final p in presences) {
      if (p.statut == 'Présent') {
        lignesPresents[p.participantId] =
            (lignesPresents[p.participantId] ?? 0) + 1;
      }
    }

    // Ligne budgétaire d'indemnités de l'activité (celle du journal).
    final rubriques = RubriquesBudget.depuisTarifs(
      tarifs.map((t) => t.rubrique),
    );
    String ligneIndemnite = '';
    for (final l in budgets) {
      final r = RubriquesBudget.pourLibelle(l.ligneBudgetaire, rubriques);
      if (RubriquesBudget.normaliser(r).contains('INDEMNIT')) {
        ligneIndemnite = l.ligneBudgetaire;
        break;
      }
    }

    // Une ligne par participant affecté à l'activité ; à défaut d'affectation,
    // les participants déjà présents ou saisis restent visibles.
    final ids = <int>{
      for (final a in affectations) a.participantId,
      ...lignesPresents.keys,
      ...saisieParParticipant.keys,
    }.toList()..sort();

    final fiches = <FicheParticipant>[];
    for (final id in ids) {
      final p = parId[id];
      if (p == null) continue;
      ActiviteParticipant? affectation;
      for (final a in affectations) {
        if (a.participantId == id) {
          affectation = a;
          break;
        }
      }
      final saisie = saisieParParticipant[id];
      final provenance =
          (saisie?.provenance ?? affectation?.zone ?? activite?.district ?? '')
              .trim();
      final district = _district(districts, provenance);
      final zone = district == null
          ? 'Région'
          : (district.estChefLieuRegion ? 'Région' : 'District');
      final taux = (saisie?.taux ?? 0) > 0
          ? saisie!.taux
          : _tauxIndemnite(tarifs, ligneIndemnite, zone);
      final delai = (saisie?.delaiRoute ?? 0) > 0
          ? saisie!.delaiRoute
          : (district?.delaiRouteTotal ?? 0);
      final jours = (saisie?.nombreJoursActivite ?? 0) > 0
          ? saisie!.nombreJoursActivite
          : (lignesPresents[id] ?? 0).toDouble();
      final presents = lignesPresents[id] ?? 0;
      fiches.add(
        FicheParticipant(
          participantId: id,
          nom: '${p.nom} ${p.prenom}'.trim(),
          role: affectation?.role ?? 'Participant',
          provenance: provenance,
          tauxJournalier: taux,
          delaiRoute: delai,
          joursActivite: jours,
          joursPresents: presents,
          joursPeriode: joursPeriode,
          montantPaye: saisie?.montantPaye ?? 0,
          etatPaiement: saisie?.etatPaiement ?? 'À payer',
          restauration:
              saisie?.restauration ?? (activite?.restauration ?? false),
          conforme: joursPeriode == 0 || presents == jours,
          ligneBudgetaire: (saisie?.ligneBudgetaire ?? '').isNotEmpty
              ? saisie!.ligneBudgetaire
              : ligneIndemnite,
          saisieId: saisie?.id,
        ),
      );
    }

    final totalAlloue = fiches.fold<double>(0, (s, f) => s + f.montantAlloue);
    final totalPaye = fiches.fold<double>(0, (s, f) => s + f.montantPaye);
    final solde = totalAlloue - totalPaye;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          // Bandeau unique et compact (remplace les 7 cartes).
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Wrap(
              spacing: 18,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _Stat(
                  icone: Icons.functions,
                  texte:
                      'Indemnité = délai de route × 100 % + jours d’activité '
                      '× ${'85 %/100 %'}',
                ),
                _Stat(
                  icone: Icons.groups_outlined,
                  texte: '${fiches.length} participant(s)',
                ),
                _Stat(
                  icone: Icons.calculate_outlined,
                  texte: 'Alloué : ${formatMontant(totalAlloue)}',
                ),
                _Stat(
                  icone: Icons.payments_outlined,
                  texte: 'Payé : ${formatMontant(totalPaye)}',
                ),
                _Stat(
                  icone: Icons.balance_outlined,
                  texte: 'Solde : ${formatMontant(solde)}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TableauGestion<FicheParticipant>(
              lignes: fiches,
              cleLigne: (f) => f.participantId,
              messageVide:
                  'Aucun participant affecté à cette activité.\n'
                  'Affectez des participants depuis l’écran « Activités », '
                  'puis revenez saisir les présences.',
              resume: Text(
                'Jours d’activité modifiables directement dans le tableau : '
                'la présence du participant est mise à jour.',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              colonnes: [
                ColonneTableau(
                  label: 'Participant',
                  valeur: (f) => f.nom,
                  cellule: (context, f) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        f.nom,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        f.role,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                ColonneTableau(
                  label: 'Provenance',
                  valeur: (f) => f.provenance,
                ),
                ColonneTableau(
                  label: 'Délai route (j)',
                  numerique: true,
                  valeur: (f) => f.delaiRoute.toStringAsFixed(0),
                  cleTri: (f) => f.delaiRoute,
                ),
                ColonneTableau(
                  label: 'Jours d’activité',
                  numerique: true,
                  valeur: (f) => f.joursActivite.toStringAsFixed(0),
                  cleTri: (f) => f.joursActivite,
                  cellule: (context, f) => _CelluleJours(
                    fiche: f,
                    activiteCode: activiteCode,
                    activite: activite,
                  ),
                ),
                ColonneTableau(
                  label: 'Jours présents',
                  numerique: true,
                  valeur: (f) => '${f.joursPresents}',
                  cleTri: (f) => f.joursPresents,
                ),
                ColonneTableau(
                  label: 'Total jours',
                  numerique: true,
                  valeur: (f) => f.totalJours.toStringAsFixed(0),
                  cleTri: (f) => f.totalJours,
                ),
                ColonneTableau(
                  label: 'Taux',
                  numerique: true,
                  valeur: (f) => formatMontant(f.tauxJournalier),
                  cleTri: (f) => f.tauxJournalier,
                ),
                ColonneTableau(
                  label: 'Montant alloué',
                  numerique: true,
                  valeur: (f) => formatMontant(f.montantAlloue),
                  cleTri: (f) => f.montantAlloue,
                ),
                ColonneTableau(
                  label: 'Payé',
                  numerique: true,
                  valeur: (f) => formatMontant(f.montantPaye),
                  cleTri: (f) => f.montantPaye,
                ),
                ColonneTableau(
                  label: 'Solde',
                  numerique: true,
                  valeur: (f) => formatMontant(f.solde),
                  cleTri: (f) => f.solde,
                ),
                ColonneTableau(
                  label: 'État',
                  valeur: (f) => f.etatPaiement,
                  cellule: (context, f) => _EtatChip(etat: f.etatPaiement),
                ),
              ],
              actions: [
                ActionTableau<FicheParticipant>(
                  icone: Icons.edit_outlined,
                  infobulle: 'Modifier la ligne du participant',
                  onTap: (f) => showDialog<bool>(
                    context: context,
                    builder: (_) => _FicheDialog(
                      activiteCode: activiteCode,
                      activite: activite,
                      fiche: f,
                    ),
                  ),
                ),
                ActionTableau<FicheParticipant>(
                  icone: Icons.delete_outline,
                  infobulle: 'Supprimer la saisie d’indemnité',
                  couleur: Theme.of(context).colorScheme.error,
                  visible: (f) => f.saisieId != null,
                  onTap: (f) async {
                    final ok = await confirmer(
                      context,
                      titre: 'Supprimer la saisie',
                      message:
                          'Supprimer l’indemnité de ${f.nom} pour cette '
                          'activité ? Les présences ne sont pas modifiées.',
                    );
                    if (!ok) return;
                    await ref
                        .read(indemnitesSaisiesRepositoryProvider)
                        .delete(f.saisieId!);
                    ref.invalidate(
                      indemnitesSaisiesActiviteProvider(activiteCode),
                    );
                  },
                ),
              ],
              onSupprimer: (lignes) async {
                final repo = ref.read(indemnitesSaisiesRepositoryProvider);
                for (final f in lignes) {
                  if (f.saisieId != null) await repo.delete(f.saisieId!);
                }
                ref.invalidate(indemnitesSaisiesActiviteProvider(activiteCode));
              },
            ),
          ),
        ],
      ),
    );
  }

  static District? _district(List<District> districts, String nom) {
    for (final d in districts) {
      if (d.nom.trim().toLowerCase() == nom.trim().toLowerCase()) return d;
    }
    return null;
  }

  /// Taux journalier du référentiel pour la zone du participant.
  static double _tauxIndemnite(
    List<TarifReferentiel> tarifs,
    String ligne,
    String zone,
  ) {
    for (final t in tarifs) {
      final estIndemnite = RubriquesBudget.normaliser(
        t.rubrique,
      ).contains('INDEMNIT');
      if (!estIndemnite) continue;
      final zoneOk =
          t.zone.trim().isEmpty ||
          t.zone.trim().toLowerCase() == 'tous' ||
          t.zone.trim().toLowerCase() == zone.toLowerCase();
      if (!zoneOk) continue;
      if (ligne.isNotEmpty &&
          t.ligneBudgetaire.trim().toLowerCase() ==
              ligne.trim().toLowerCase() &&
          t.tarif > 0) {
        return t.tarif;
      }
    }
    for (final t in tarifs) {
      if (!RubriquesBudget.normaliser(t.rubrique).contains('INDEMNIT'))
        continue;
      final zoneOk =
          t.zone.trim().isEmpty ||
          t.zone.trim().toLowerCase() == 'tous' ||
          t.zone.trim().toLowerCase() == zone.toLowerCase();
      if (zoneOk && t.tarif > 0) return t.tarif;
    }
    return zone.toLowerCase() == 'region' || zone.toLowerCase() == 'région'
        ? 200000
        : 150000;
  }

  static int _joursPeriode(Activite? a) => joursPeriodeDe(a);
}

/// Nombre de jours couverts par l'activité (bornes incluses).
int joursPeriodeDe(Activite? a) {
  final debut = a?.dateDebut;
  final fin = a?.dateFin;
  if (debut == null || fin == null) return 0;
  final d = DateTime(debut.year, debut.month, debut.day);
  final f = DateTime(fin.year, fin.month, fin.day);
  return f.difference(d).inDays + 1;
}

/// Les jours d'activité d'un participant ne peuvent jamais dépasser la durée
/// de l'activité : la fiche de présence serait incohérente.
String? validateurJoursActivite(String? valeur, {required int joursPeriode}) {
  final manquant = validateurNombrePositif(
    valeur,
    champ: 'Les jours d’activité',
    zeroAutorise: true,
  );
  if (manquant != null) return manquant;
  final n = double.tryParse(
    valeur!.trim().replaceAll(' ', '').replaceAll(',', '.'),
  );
  if (n != null && joursPeriode > 0 && n > joursPeriode) {
    return 'Maximum $joursPeriode jour(s) pour cette activité';
  }
  return null;
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icone, required this.texte});
  final IconData icone;
  final String texte;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 15, color: scheme.primary),
        const SizedBox(width: 5),
        Text(
          texte,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _EtatChip extends StatelessWidget {
  const _EtatChip({required this.etat});
  final String etat;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final normalise = RubriquesBudget.normaliser(etat);
    final Color fond;
    final Color texte;
    if (normalise.contains('PAYE') && !normalise.contains('NON')) {
      fond = vertValide(context).withValues(alpha: 0.15);
      texte = vertValide(context);
    } else if (normalise.contains('PARTIEL')) {
      fond = ambreAttention(context).withValues(alpha: 0.16);
      texte = ambreAttention(context);
    } else if (normalise.contains('NON')) {
      fond = rougeAlerte(context).withValues(alpha: 0.12);
      texte = rougeAlerte(context);
    } else {
      fond = scheme.surfaceContainerHighest;
      texte = scheme.onSurfaceVariant;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        etat,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: texte,
        ),
      ),
    );
  }
}

/// Cellule « Jours d'activité » : modifiable d'un clic, et c'est **elle** qui
/// met à jour la présence du participant.
class _CelluleJours extends ConsumerWidget {
  const _CelluleJours({
    required this.fiche,
    required this.activiteCode,
    required this.activite,
  });

  final FicheParticipant fiche;
  final String activiteCode;
  final Activite? activite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message:
          'Modifier le nombre de jours d’activité\n'
          '(la présence du participant est mise à jour automatiquement)',
      child: InkWell(
        // Clé stable : la cellule est la cible d'un test de bout en bout
        // (« jours d'activité → fiche de présence »).
        key: ValueKey('jours-activite-${fiche.participantId}'),
        borderRadius: BorderRadius.circular(8),
        onTap: () => showDialog<bool>(
          context: context,
          builder: (_) => _FicheDialog(
            activiteCode: activiteCode,
            activite: activite,
            fiche: fiche,
            joursUniquement: true,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                fiche.joursActivite.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.edit_outlined, size: 13, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialogue de la fiche d'un participant : jours d'activité (et, si demandé,
/// provenance, délai de route, taux, paiement).
class _FicheDialog extends ConsumerStatefulWidget {
  const _FicheDialog({
    required this.activiteCode,
    required this.fiche,
    this.activite,
    this.joursUniquement = false,
  });

  final String activiteCode;
  final FicheParticipant fiche;
  final Activite? activite;
  final bool joursUniquement;

  @override
  ConsumerState<_FicheDialog> createState() => _FicheDialogState();
}

class _FicheDialogState extends ConsumerState<_FicheDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _jours;
  late final TextEditingController _delai;
  late final TextEditingController _taux;
  late final TextEditingController _paye;
  late final TextEditingController _provenance;
  String _etat = 'À payer';
  late bool _restauration;

  static String _chiffre(num v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(2);

  @override
  void initState() {
    super.initState();
    final f = widget.fiche;
    _jours = TextEditingController(text: _chiffre(f.joursActivite));
    _delai = TextEditingController(text: _chiffre(f.delaiRoute));
    _taux = TextEditingController(text: _chiffre(f.tauxJournalier));
    _paye = TextEditingController(text: _chiffre(f.montantPaye));
    _provenance = TextEditingController(text: f.provenance);
    _etat = f.etatPaiement;
    _restauration = f.restauration;
  }

  @override
  void dispose() {
    for (final c in [_jours, _delai, _taux, _paye, _provenance]) {
      c.dispose();
    }
    super.dispose();
  }

  double _nombre(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(' ', '').replaceAll(',', '.')) ??
      0;

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    final jours = _nombre(_jours);
    final delai = _nombre(_delai);
    final taux = _nombre(_taux);
    final f = widget.fiche;
    final repo = ref.read(indemnitesSaisiesRepositoryProvider);
    final montantAlloue = ReglesMetier.indemniteParticipant(
      delaiRoute: delai,
      joursActivite: jours,
      taux: taux,
      avecDejeuner: _restauration,
      abattementRepas: !f.estChauffeur,
    );

    // 1. La présence suit le nombre de jours d'activité.
    await _synchroniserPresence(
      participantId: f.participantId,
      jours: jours,
      taux: taux,
    );

    // 2. La saisie d'indemnité est créée ou mise à jour.
    final companion = IndemnitesSaisiesCompanion(
      activiteCode: drift.Value(widget.activiteCode),
      ligneBudgetaire: drift.Value(f.ligneBudgetaire),
      participantId: drift.Value(f.participantId),
      participantNom: drift.Value(f.nom),
      etatPaiement: drift.Value(_etat),
      provenance: drift.Value(_provenance.text.trim()),
      delaiRoute: drift.Value(delai),
      nombreJoursActivite: drift.Value(jours),
      restauration: drift.Value(_restauration),
      taux: drift.Value(taux),
      montantAlloue: drift.Value(montantAlloue),
      montantPaye: drift.Value(_nombre(_paye)),
    );
    if (f.saisieId == null) {
      await repo.insert(companion);
    } else {
      await repo.update(f.saisieId!, companion);
    }
    await _synchroniserJournal();
    if (!mounted) return;
    ref.invalidate(indemnitesSaisiesActiviteProvider(widget.activiteCode));
    ref.invalidate(presencesActiviteProvider(widget.activiteCode));
    ref.invalidate(syntheseIndemnitesProvider(widget.activiteCode));
    ref.invalidate(resultatsPresencesProvider(widget.activiteCode));
    notifier(context, 'Présence et indemnité enregistrées');
    Navigator.of(context).pop(true);
  }

  /// Écrit une ligne de présence par jour de la période : les [jours] premiers
  /// jours de l'activité sont « Présent », les suivants « Absent ». La ligne
  /// « Présent/Absent » est ainsi toujours cohérente avec le nombre de jours
  /// saisi pour le participant.
  Future<void> _synchroniserPresence({
    required int participantId,
    required double jours,
    required double taux,
  }) async {
    final debut = widget.activite?.dateDebut;
    final fin = widget.activite?.dateFin;
    if (debut == null || fin == null) return;
    final repo = ref.read(presencesRepositoryProvider);
    final d = DateTime(debut.year, debut.month, debut.day);
    final f = DateTime(fin.year, fin.month, fin.day);
    final total = f.difference(d).inDays + 1;
    for (var i = 0; i < total; i++) {
      final date = d.add(Duration(days: i));
      final present = i < jours;
      await repo.upsert(
        PresencesCompanion(
          activiteCode: drift.Value(widget.activiteCode),
          participantId: drift.Value(participantId),
          date: drift.Value(date),
          statut: drift.Value(present ? 'Présent' : 'Absent'),
          tauxJournalier: drift.Value(taux),
        ),
      );
    }
  }

  Future<void> _synchroniserJournal() async {
    try {
      final saisies = await ref
          .read(indemnitesSaisiesRepositoryProvider)
          .parActivite(widget.activiteCode);
      final paye = saisies.fold<double>(0, (s, e) => s + e.montantPaye);
      await ref
          .read(journalDepensesServiceProvider)
          .synchroniserIndemnites(
            activiteCode: widget.activiteCode,
            montant: paye,
            observation: 'Indemnités encaissées (dossier PJ)',
          );
      ref.invalidate(depensesProvider);
    } catch (_) {
      // Le journal des dépenses ne doit jamais bloquer la saisie.
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.fiche;
    final districts =
        ref.watch(tousDistrictsProvider).value ?? const <District>[];
    final joursPeriode = joursPeriodeDe(widget.activite);
    final apercu = ReglesMetier.indemniteParticipant(
      delaiRoute: _nombre(_delai),
      joursActivite: _nombre(_jours),
      taux: _nombre(_taux),
      avecDejeuner: _restauration,
      abattementRepas: !f.estChauffeur,
    );
    final titre = widget.joursUniquement
        ? 'Jours d’activité — ${f.nom}'
        : 'Indemnité — ${f.nom}';

    return AlertDialog(
      title: TitreDialogue(
        titre,
        sousTitre:
            'Le nombre de jours d’activité met à jour la présence du '
            'participant dans l’activité.',
        icone: Icons.event_available_outlined,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 620),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChampNombre(
                  controller: _jours,
                  label: 'Jours d’activité (présence) *',
                  step: 1,
                  onChanged: () => setState(() {}),
                  validator: (v) =>
                      validateurJoursActivite(v, joursPeriode: joursPeriode),
                ),
                const SizedBox(height: 4),
                Text(
                  joursPeriode > 0
                      ? 'Période de l’activité : $joursPeriode jour(s). Les N '
                            'premiers jours seront marqués « Présent ».'
                      : 'Renseignez les dates de l’activité pour générer la '
                            'fiche de présence.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                if (!widget.joursUniquement) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ChampListe(
                          controller: _provenance,
                          label: 'Provenance (district)',
                          valeurs: districts.map((d) => d.nom).toList(),
                          prefixIcon: Icons.place_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChampNombre(
                          controller: _delai,
                          label: 'Délai de route (j)',
                          step: 1,
                          onChanged: () => setState(() {}),
                          // Un délai de route nul est légitime (activité dans
                          // la même ville) : seul le format est vérifié.
                          validator: (v) => validateurNombrePositif(
                            v,
                            champ: 'Le délai de route',
                            zeroAutorise: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ChampNombre(
                    controller: _taux,
                    label: 'Taux journalier (Ar) *',
                    step: 1000,
                    onChanged: () => setState(() {}),
                    validator: (v) =>
                        validateurNombrePositif(v, champ: 'Le taux'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _etat,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'État de paiement',
                            prefixIcon: Icon(Icons.payments_outlined),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'À payer',
                              child: Text('À payer'),
                            ),
                            DropdownMenuItem(
                              value: 'Partiel',
                              child: Text('Partiel'),
                            ),
                            DropdownMenuItem(
                              value: 'Payé',
                              child: Text('Payé'),
                            ),
                            DropdownMenuItem(
                              value: 'Non payé',
                              child: Text('Non payé'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _etat = v ?? 'À payer'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChampNombre(
                          controller: _paye,
                          label: 'Montant payé (Ar)',
                          step: 1000,
                          validator: (v) => validateurMontant(v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  CheckboxListTile(
                    value: _restauration,
                    onChanged: (v) =>
                        setState(() => _restauration = v ?? false),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    title: const Text(
                      'Déjeuner pris en charge (jours d’activité à 85 %)',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Montant alloué calculé : ${formatMontant(apercu)}\n'
                    'Règle : délai de route × 100 % + jours d’activité '
                    '× ${_restauration && !f.estChauffeur ? '85 %' : '100 %'}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
          icon: const Icon(Icons.check),
          label: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
