import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/database/database.dart';
import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../router/app_router.dart';
import '../../widgets/common.dart';
import '../../widgets/tableau.dart';

/// Gestion des présences : saisie rapide multi-participants par date.
class PresencesScreen extends ConsumerStatefulWidget {
  const PresencesScreen({this.imbrique = false, super.key});

  /// Quand `true`, l'écran est affiché dans l'onglet « Dossier PJ » :
  /// pas de Scaffold ni d'en-tête propre.
  final bool imbrique;

  @override
  ConsumerState<PresencesScreen> createState() => _PresencesScreenState();
}

class _PresencesScreenState extends ConsumerState<PresencesScreen> {
  @override
  Widget build(BuildContext context) {
    final activites = ref.watch(activitesProvider);
    // Activité partagée : la sélection reste la même dans « Présences »,
    // « Indemnités » et « Pièces justificatives ».
    final activiteCode = ref.watch(activiteSelectionneeProvider);
    final corps = Column(
      children: [
          if (!widget.imbrique)
            const EnTetePage(
              titre: 'Présences',
              sousTitre: 'Saisie rapide des présences par activité et par date',
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
                        'Sélectionnez une activité pour saisir les présences.',
                    icone: Icons.calendar_month_outlined,
                  )
                : _GrillePresences(activiteCode: activiteCode),
          ),
        ],
    );
    return widget.imbrique ? corps : Scaffold(body: corps);
  }
}

class _GrillePresences extends ConsumerWidget {
  const _GrillePresences({required this.activiteCode});
  final String activiteCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activiteAsync = ref.watch(activitesProvider);
    final presencesAsync = ref.watch(presencesActiviteProvider(activiteCode));
    final affectationsAsync = ref.watch(
      affectationsActiviteProvider(activiteCode),
    );

    return activiteAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EtatErreur(erreur: e),
      data: (activites) {
        final activite = activites
            .where((a) => a.code == activiteCode)
            .firstOrNull;
        if (activite == null) {
          return const EtatVide(message: 'Activité introuvable');
        }
        return presencesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EtatErreur(erreur: e),
          data: (presences) => affectationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => EtatErreur(erreur: e),
            data: (affectations) => _Contenu(
              activite: activite,
              presences: presences,
              affectations: affectations,
            ),
          ),
        );
      },
    );
  }
}

class _Contenu extends ConsumerStatefulWidget {
  const _Contenu({
    required this.activite,
    required this.presences,
    required this.affectations,
  });
  final Activite activite;
  final List<Presence> presences;
  final List<ActiviteParticipant> affectations;

  @override
  ConsumerState<_Contenu> createState() => _ContenuState();
}

class _ContenuState extends ConsumerState<_Contenu> {
  bool _enregistrement = false;

  /// Dates de l'activité (dateDebut → dateFin).
  List<DateTime> get _dates {
    final debut = widget.activite.dateDebut;
    final fin = widget.activite.dateFin;
    if (debut == null || fin == null) return const [];
    final jours = <DateTime>[];
    var courant = DateTime(debut.year, debut.month, debut.day);
    final finNorm = DateTime(fin.year, fin.month, fin.day);
    while (!courant.isAfter(finNorm) && jours.length < 90) {
      jours.add(courant);
      courant = courant.add(const Duration(days: 1));
    }
    return jours;
  }

  Map<int, Map<DateTime, Presence>> get _index {
    final map = <int, Map<DateTime, Presence>>{};
    for (final p in widget.presences) {
      final d = DateTime(p.date.year, p.date.month, p.date.day);
      map.putIfAbsent(p.participantId, () => {})[d] = p;
    }
    return map;
  }

  Future<void> _basculer(
    int participantId,
    DateTime date,
    Presence? existante,
  ) async {
    final nouveau = (existante?.statut == 'Présent') ? 'Absent' : 'Présent';
    final taux = existante?.tauxJournalier ?? _tauxPour(participantId);
    setState(() => _enregistrement = true);
    try {
      await ref
          .read(presencesRepositoryProvider)
          .upsert(
            PresencesCompanion(
              activiteCode: drift.Value(widget.activite.code),
              participantId: drift.Value(participantId),
              date: drift.Value(date),
              statut: drift.Value(nouveau),
              signaturePreuve: drift.Value(existante?.signaturePreuve),
              tauxJournalier: drift.Value(taux),
              indemniteRecue: drift.Value(existante?.indemniteRecue ?? 0),
            ),
          );
    } finally {
      if (mounted) setState(() => _enregistrement = false);
    }
  }

  double _tauxPour(int participantId) {
    for (final affectation in widget.affectations) {
      if (affectation.participantId == participantId) {
        return affectation.tauxJournalier;
      }
    }
    final map = _index;
    final p = map[participantId]?.values.firstOrNull;
    return p?.tauxJournalier ?? 0;
  }

  static String _chiffreTaux(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(2);

  /// Taux journalier pré-rempli selon la **zone du district de l'activité**
  /// (référentiel des tarifs), exactement comme le dossier d'indemnités.
  double _tauxParDefaut() {
    final nom = (widget.activite.district ?? '').trim();
    final districts = ref.read(tousDistrictsProvider).value ?? const <District>[];
    District? trouve;
    for (final d in districts) {
      if (d.nom.toLowerCase() == nom.toLowerCase()) {
        trouve = d;
        break;
      }
    }
    final zone = trouve == null
        ? 'Région'
        : (trouve.estChefLieuRegion ? 'Région' : 'District');
    final tarifs =
        ref.read(tousTarifsProvider).value ?? const <TarifReferentiel>[];
    for (final t in tarifs) {
      if (!t.actif) continue;
      if (!t.ligneBudgetaire.toUpperCase().contains('INDEMNIT')) continue;
      if (t.zone.trim().toLowerCase() == zone.toLowerCase()) return t.tarif;
    }
    return zone == 'Région' ? 200000 : 150000;
  }

  /// Création rapide d'un participant : uniquement nom et prénom.
  Future<void> _ajouterNouveauParticipant() async {
    final formKey = GlobalKey<FormState>();
    final nom = TextEditingController();
    final prenom = TextEditingController();
    final candidats = ref.read(tousParticipantsProvider).value ?? const <Participant>[];
    final noms = candidats
        .map((p) => p.nom)
        .where((v) => v.trim().isNotEmpty)
        .toSet()
        .toList();
    final prenoms = candidats
        .map((p) => p.prenom)
        .where((v) => v.trim().isNotEmpty)
        .toSet()
        .toList();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const TitreDialogue(
            'Nouveau participant',
            icone: Icons.person_add_alt_outlined,
          ),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ChampListe(
                    controller: nom,
                    label: 'Nom *',
                    valeurs: noms,
                    prefixIcon: Icons.person_outline,
                    validator: (v) =>
                        validateurObligatoire(v, champ: 'Le nom'),
                  ),
                  const SizedBox(height: 12),
                  ChampListe(
                    controller: prenom,
                    label: 'Prénom',
                    valeurs: prenoms,
                    prefixIcon: Icons.badge_outlined,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      );
      if (ok != true) return;
      await ref
          .read(participantsRepositoryProvider)
          .insert(
            ParticipantsCompanion(
              nom: drift.Value(nom.text.trim()),
              prenom: drift.Value(prenom.text.trim()),
              fonction: const drift.Value(null),
              structure: const drift.Value(null),
              telephone: const drift.Value(null),
              email: const drift.Value(null),
            ),
          );
      if (mounted) notifier(context, 'Participant ajouté');
    } finally {
      nom.dispose();
      prenom.dispose();
    }
  }

  Future<void> _ajouterParticipant(List<Participant> participants) async {
    final idsAffectes = widget.affectations
        .map((affectation) => affectation.participantId)
        .toSet();
    final candidats = participants
        .where(
          (participant) =>
              participant.actif && !idsAffectes.contains(participant.id),
        )
        .toList();
    if (candidats.isEmpty) {
      notifier(context, 'Aucun participant actif à affecter.', erreur: true);
      return;
    }

    final formKey = GlobalKey<FormState>();
    final tauxController = TextEditingController(
      text: _chiffreTaux(_tauxParDefaut()),
    );
    var participantId = candidats.first.id;
    try {
      final choix = await showDialog<({int participantId, double taux})>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const TitreDialogue(
              'Affecter un participant',
              icone: Icons.group_add_outlined,
            ),
            content: Form(
              key: formKey,
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: participantId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Participant',
                      ),
                      items: [
                        for (final participant in candidats)
                          DropdownMenuItem(
                            value: participant.id,
                            child: Text(
                              '${participant.nom} ${participant.prenom}'.trim(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (value) => setDialogState(
                        () => participantId = value ?? participantId,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ChampNombre(
                      controller: tauxController,
                      label: 'Taux journalier (Ar)',
                      decimales: true,
                      step: 1000,
                      validator: (value) {
                        final taux = double.tryParse(
                          (value ?? '').replaceAll(',', '.'),
                        );
                        return taux == null || taux < 0
                            ? 'Saisissez un taux valide ou zéro.'
                            : null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.pop(dialogContext, (
                    participantId: participantId,
                    taux: double.parse(
                      tauxController.text.replaceAll(',', '.'),
                    ),
                  ));
                },
                child: const Text('Affecter'),
              ),
            ],
          ),
        ),
      );
      if (choix == null) return;
      await ref
          .read(activiteParticipantsRepositoryProvider)
          .insert(
            ActiviteParticipantsCompanion.insert(
              activiteCode: widget.activite.code,
              participantId: choix.participantId,
              tauxJournalier: drift.Value(choix.taux),
            ),
          );
    } finally {
      tauxController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dates = _dates;
    if (dates.isEmpty) {
      return const EtatVide(
        message:
            'Renseignez la date de début et la date de fin de l\'activité pour saisir les présences.',
        icone: Icons.event_busy_outlined,
      );
    }
    final participants = ref.watch(tousParticipantsProvider);
    final compact = MediaQuery.sizeOf(context).width < 800;

    return participants.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EtatErreur(erreur: e),
      data: (liste) {
        final participantsActifs = liste.where((p) => p.actif).toList();
        final idsAffectes =
            widget.affectations
                .map((affectation) => affectation.participantId)
                .toSet()
              ..addAll(
                widget.presences.map((presence) => presence.participantId),
              );
        final participantsAffectes = participantsActifs
            .where((participant) => idsAffectes.contains(participant.id))
            .toList();
        if (participantsActifs.isEmpty) {
          return const EtatVide(
            message:
                'Aucun participant. Ajoutez des participants avant de saisir les présences.',
            icone: Icons.groups_outlined,
          );
        }
        final index = _index;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Chip(
                    avatar: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text('${dates.length} jour(s)'),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    avatar: const Icon(Icons.groups_outlined, size: 16),
                    label: Text(
                      '${participantsAffectes.length} participant(s)',
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Gérer les participants (nom, prénom)',
                    onPressed: () => context.go(AppRoutes.participants),
                    icon: const Icon(Icons.manage_accounts_outlined),
                  ),
                  IconButton(
                    tooltip: 'Ajouter un participant (nom, prénom)',
                    onPressed: () => _ajouterNouveauParticipant(),
                    icon: const Icon(Icons.person_add_alt_outlined),
                  ),
                  IconButton(
                    tooltip: 'Affecter un participant à cette activité',
                    onPressed: () => _ajouterParticipant(participantsActifs),
                    icon: const Icon(Icons.person_add_outlined),
                  ),
                  if (_enregistrement)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  const Text(
                    'Cliquez une case pour basculer Présent / Absent',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: participantsAffectes.isEmpty
                  ? const EtatVide(
                      message: 'Aucun participant affecté à cette activité.',
                      icone: Icons.person_add_alt_1_outlined,
                    )
                  : compact
                  ? _VueMobile(
                      participants: participantsAffectes,
                      dates: dates,
                      index: index,
                      onBasculer: _basculer,
                    )
                  : _VueDesktop(
                      participants: participantsAffectes,
                      dates: dates,
                      index: index,
                      onBasculer: _basculer,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _VueDesktop extends StatelessWidget {
  const _VueDesktop({
    required this.participants,
    required this.dates,
    required this.index,
    required this.onBasculer,
  });

  final List<Participant> participants;
  final List<DateTime> dates;
  final Map<int, Map<DateTime, Presence>> index;
  final Future<void> Function(int, DateTime, Presence?) onBasculer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: TableauGestion<Participant>(
        lignes: participants,
        cleLigne: (p) => p.id,
        taillePage: 25,
        messageVide:
            'Aucun participant affecté à cette activité.\n'
            'Utilisez le bouton « Affecter un participant » pour commencer.',
        colonnes: [
          ColonneTableau(
            label: 'Participant',
            flex: 5,
            valeur: (p) => '${p.nom} ${p.prenom}'.trim(),
          ),
          for (final d in dates)
            ColonneTableau(
              label: '${d.day}/${d.month}',
              flex: 1,
              triable: false,
              filtrable: false,
              // Colonne étroite : la case occupe un petit carré, tout le
              // reste de la largeur va au nom du participant.
              largeurMin: 44,
              valeur: (_) => '',
              cellule: (context, p) => _CasePresence(
                presence: index[p.id]?[DateTime(d.year, d.month, d.day)],
                onTap: () => onBasculer(
                  p.id,
                  d,
                  index[p.id]?[DateTime(d.year, d.month, d.day)],
                ),
              ),
            ),
          ColonneTableau(
            label: 'Présents',
            flex: 1,
            numerique: true,
            filtrable: false,
            valeur: (p) =>
                '${index[p.id]?.values.where((e) => e.statut == 'Présent').length ?? 0}',
            cleTri: (p) =>
                index[p.id]?.values.where((e) => e.statut == 'Présent').length ??
                0,
          ),
        ],
      ),
    );
  }
}

class _VueMobile extends StatelessWidget {
  const _VueMobile({
    required this.participants,
    required this.dates,
    required this.index,
    required this.onBasculer,
  });

  final List<Participant> participants;
  final List<DateTime> dates;
  final Map<int, Map<DateTime, Presence>> index;
  final Future<void> Function(int, DateTime, Presence?) onBasculer;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: participants.length,
      itemBuilder: (context, i) {
        final p = participants[i];
        final presences = index[p.id] ?? {};
        final nbPresents = presences.values
            .where((e) => e.statut == 'Présent')
            .length;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text('${p.nom} ${p.prenom}'.trim()),
            subtitle: Text(
              '$nbPresents jour(s) présent(s) sur ${dates.length}',
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final d in dates)
                      _CaseMobile(
                        date: d,
                        presence: presences[DateTime(d.year, d.month, d.day)],
                        onTap: () => onBasculer(
                          p.id,
                          d,
                          presences[DateTime(d.year, d.month, d.day)],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CasePresence extends StatelessWidget {
  const _CasePresence({required this.presence, required this.onTap});
  final Presence? presence;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final present = presence?.statut == 'Présent';
    final absent = presence?.statut == 'Absent';
    final couleur = present
        ? const Color(0xFF2E7D32)
        : absent
        ? const Color(0xFFC62828)
        : Theme.of(context).colorScheme.onSurfaceVariant;
    // Petit carré centré : la colonne reste mince et le nom du participant
    // profite de toute la largeur restante.
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: present
                  ? const Color(0xFF2E7D32).withValues(alpha: 0.15)
                  : absent
                  ? const Color(0xFFC62828).withValues(alpha: 0.12)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              present ? Icons.check : absent ? Icons.close : Icons.remove,
              size: 14,
              color: couleur,
            ),
          ),
        ),
      ),
    );
  }
}

class _CaseMobile extends StatelessWidget {
  const _CaseMobile({
    required this.date,
    required this.presence,
    required this.onTap,
  });

  final DateTime date;
  final Presence? presence;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final present = presence?.statut == 'Présent';
    final absent = presence?.statut == 'Absent';
    final couleur = present
        ? const Color(0xFF2E7D32)
        : absent
        ? const Color(0xFFC62828)
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 58,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: couleur.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(8),
          color: couleur.withValues(alpha: 0.08),
        ),
        child: Column(
          children: [
            Text(
              '${date.day}/${date.month}',
              style: const TextStyle(fontSize: 11),
            ),
            const SizedBox(height: 2),
            Icon(
              present
                  ? Icons.check_circle
                  : absent
                  ? Icons.cancel
                  : Icons.radio_button_unchecked,
              size: 16,
              color: couleur,
            ),
          ],
        ),
      ),
    );
  }
}
