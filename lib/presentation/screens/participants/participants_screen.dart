import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/tableau.dart';

/// Gestion des participants / bénéficiaires.
class ParticipantsScreen extends ConsumerStatefulWidget {
  const ParticipantsScreen({super.key});

  @override
  ConsumerState<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends ConsumerState<ParticipantsScreen> {
  final _recherche = TextEditingController();

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final participants = ref.watch(participantsProvider);
    return Scaffold(
      body: Column(
        children: [
          EnTetePage(
            titre: 'Participants',
            module: 'participants',
            sousTitre: 'Répertoire des participants et bénéficiaires',
            actions: [
              FilledButton.icon(
                onPressed: () => _ouvrirFormulaire(),
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Nouveau participant'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: 380,
              child: ChampRecherche(
                controller: _recherche,
                hint: 'Rechercher un participant',
                onChanged: (v) =>
                    ref.read(filtreRechercheProvider.notifier).state = v,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: participants.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EtatErreur(erreur: e),
              data: (liste) => liste.isEmpty
                  ? EtatVide(
                      message:
                          'Aucun participant enregistré pour le moment.\n'
                          'Ajoutez les personnes qui prennent part à vos activités.',
                      icone: Icons.groups_outlined,
                      action: FilledButton.icon(
                        onPressed: () => _ouvrirFormulaire(),
                        icon: const Icon(Icons.person_add_alt),
                        label: const Text('Ajouter un participant'),
                      ),
                    )
                  : _TableauParticipants(participants: liste, ref: ref),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _ouvrirFormulaire({Participant? participant}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ParticipantDialog(participant: participant),
    );
    if (ok == true && mounted) notifier(context, 'Participant enregistré');
  }
}

class _TableauParticipants extends StatelessWidget {
  const _TableauParticipants({required this.participants, required this.ref});
  final List<Participant> participants;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: TableauGestion<Participant>(
        cleModule: 'participants',
        lignes: participants,
        cleLigne: (p) => p.id,
        messageVide:
            'Aucun participant enregistré pour le moment.\n'
            'Utilisez le bouton « Nouveau participant » pour en ajouter.',
        colonnes: [
          ColonneTableau(
            label: 'Nom',
            cle: 'nom',
            flex: 4,
            valeur: (p) => p.nom,
            cellule: (_, p) => Text(
              p.nom,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          ColonneTableau(
            label: 'Prénom',
            cle: 'prenom',
            flex: 3,
            valeur: (p) => p.prenom,
          ),
          ColonneTableau(
            label: 'Statut',
            cle: 'statut',
            flex: 3,
            valeur: (p) => p.actif ? 'Actif' : 'Inactif',
            cellule: (_, p) => Chip(
              label: Text(
                p.actif ? 'Actif' : 'Inactif',
                style: const TextStyle(fontSize: 11),
              ),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: p.actif
                  ? const Color(0xFF2E7D32).withValues(alpha: 0.12)
                  : null,
            ),
          ),
          ColonneTableau(
            label: 'Observation',
            cle: 'observation',
            flex: 4,
            valeur: (p) => p.observation ?? '',
          ),
        ],
        actions: [
          ActionTableau<Participant>(
            icone: Icons.edit_outlined,
            infobulle: 'Modifier',
            onTap: (p) async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => _ParticipantDialog(participant: p),
              );
              if (ok == true && context.mounted) {
                notifier(context, 'Participant modifié');
              }
            },
          ),
          ActionTableau<Participant>(
            icone: Icons.delete_outline,
            infobulle: 'Supprimer',
            couleur: Theme.of(context).colorScheme.error,
            onTap: (p) async {
              final ok = await confirmer(
                context,
                titre: 'Supprimer le participant',
                message:
                    'Supprimer « ${p.nom} ${p.prenom} » ? Les présences liées resteront enregistrées.',
              );
              if (!ok) return;
              try {
                await ref.read(participantsRepositoryProvider).delete(p.id);
                if (context.mounted) {
                  notifier(context, 'Participant supprimé');
                }
              } catch (e) {
                if (context.mounted) {
                  notifier(
                    context,
                    'Suppression impossible : ce participant est utilisé dans des '
                    'présences ou des activités. Désactivez-le plutôt que de le supprimer.',
                    erreur: true,
                  );
                }
              }
            },
          ),
        ],
        onSupprimer: (lignes) async {
          final repo = ref.read(participantsRepositoryProvider);
          for (final p in lignes) {
            try {
              await repo.delete(p.id);
            } catch (_) {
              // Ligne liée à des présences : on passe à la suivante.
            }
          }
        },
      ),
    );
  }
}

class _ParticipantDialog extends ConsumerStatefulWidget {
  const _ParticipantDialog({this.participant});
  final Participant? participant;

  @override
  ConsumerState<_ParticipantDialog> createState() => _ParticipantDialogState();
}

class _ParticipantDialogState extends ConsumerState<_ParticipantDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nom;
  late final TextEditingController _prenom;
  late final TextEditingController _observation;
  bool _actif = true;

  @override
  void initState() {
    super.initState();
    final p = widget.participant;
    _nom = TextEditingController(text: p?.nom ?? '');
    _prenom = TextEditingController(text: p?.prenom ?? '');
    _observation = TextEditingController(text: p?.observation ?? '');
    _actif = p?.actif ?? true;
  }

  @override
  void dispose() {
    for (final c in [_nom, _prenom, _observation]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Valeurs déjà saisies, proposées pour éviter les répétitions.
  List<String> _valeurs(String Function(Participant) f) {
    final liste =
        ref.watch(tousParticipantsProvider).value ?? const <Participant>[];
    return liste.map(f).where((v) => v.trim().isNotEmpty).toSet().toList();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(participantsRepositoryProvider);
    // Un participant n'a plus que son nom et son prénom : fonction,
    // structure, téléphone et email ne sont plus gérés.
    final companion = ParticipantsCompanion(
      nom: drift.Value(_nom.text.trim()),
      prenom: drift.Value(_prenom.text.trim()),
      fonction: const drift.Value(null),
      structure: const drift.Value(null),
      telephone: const drift.Value(null),
      email: const drift.Value(null),
      actif: drift.Value(_actif),
      observation: drift.Value(_observation.text.trim()),
    );
    if (widget.participant == null) {
      await repo.insert(companion);
    } else {
      await repo.update(widget.participant!.id, companion);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final largeur = MediaQuery.sizeOf(context).width;
    final deux = largeur > 640;
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

    return AlertDialog(
      title: TitreDialogue(
        widget.participant == null
            ? 'Nouveau participant'
            : 'Modifier le participant',
        icone: Icons.person_outline,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 620),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                paire(
                  ChampListe(
                    controller: _nom,
                    label: 'Nom *',
                    valeurs: _valeurs((p) => p.nom),
                    prefixIcon: Icons.person_outline,
                    validator: (v) => validateurObligatoire(v, champ: 'Le nom'),
                  ),
                  ChampListe(
                    controller: _prenom,
                    label: 'Prénom *',
                    valeurs: _valeurs((p) => p.prenom),
                    prefixIcon: Icons.badge_outlined,
                    validator: (v) =>
                        validateurObligatoire(v, champ: 'Le prénom'),
                  ),
                ),
                const SizedBox(height: 12),
                LigneBascule(
                  label: 'Participant actif',
                  sousTitre:
                      'Un participant inactif reste dans l\'historique mais '
                      'n\'est plus proposé.',
                  value: _actif,
                  onChanged: (v) => setState(() => _actif = v),
                ),
                ChampListe(
                  controller: _observation,
                  label: 'Observation',
                  valeurs: _valeurs((p) => p.observation ?? ''),
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
