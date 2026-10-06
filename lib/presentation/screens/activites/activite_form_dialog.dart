import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';

/// Formulaire de création/modification d'une activité.
class ActiviteFormDialog extends ConsumerStatefulWidget {
  const ActiviteFormDialog({this.activite, super.key});

  final Activite? activite;

  static Future<bool?> afficher(BuildContext context, {Activite? activite}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ActiviteFormDialog(activite: activite),
    );
  }

  @override
  ConsumerState<ActiviteFormDialog> createState() =>
      _ActiviteFormDialogState();
}

class _ActiviteFormDialogState extends ConsumerState<ActiviteFormDialog> {
  static const _types = [
    'Atelier/Réunion',
    'Supervision',
    'Formation',
    'Acquisition',
    'Mission extérieur',
  ];
  static const _statuts = ['Planifiée', 'En cours', 'Terminée', 'Annulée'];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _code;
  late final TextEditingController _description;
  late final TextEditingController _codeBudget;
  late final TextEditingController _sourceFinancement;
  late final TextEditingController _annee;
  late final TextEditingController _district;
  late final TextEditingController _responsable;
  late final TextEditingController _participants;
  late final TextEditingController _missionnaires;
  late final TextEditingController _distance;
  late final TextEditingController _observation;

  /// Génère un code d'activité unique et lisible, attribué automatiquement
  /// à la création (modifiable si besoin).
  static String _genererCode() {
    final maintenant = DateTime.now();
    String deux(int v) => v.toString().padLeft(2, '0');
    return 'ACT-${maintenant.year}${deux(maintenant.month)}'
        '${deux(maintenant.day)}-${deux(maintenant.hour)}'
        '${deux(maintenant.minute)}${deux(maintenant.second)}';
  }

  String _type = _types.first;
  String _statut = 'En cours';
  DateTime? _debut;
  DateTime? _fin;
  bool _restauration = false;
  bool _enregistrement = false;

  /// Génère le code budget suivant : `bud_1`, `bud_2`, … (auto-incrémenté).
  static String prochainCodeBudget(Iterable<String?> existants) {
    var max = 0;
    for (final brut in existants) {
      final m = RegExp(r'^bud_(\d+)$')
          .firstMatch((brut ?? '').trim().toLowerCase());
      if (m == null) continue;
      final n = int.tryParse(m.group(1)!) ?? 0;
      if (n > max) max = n;
    }
    return 'bud_${max + 1}';
  }

  /// Nombre de jours d'une activité : du début à la fin inclus.
  static int nombreJoursEntre(DateTime? debut, DateTime? fin) {
    if (debut == null || fin == null) return 0;
    final a = DateTime(debut.year, debut.month, debut.day);
    final b = DateTime(fin.year, fin.month, fin.day);
    return b.difference(a).inDays + 1;
  }

  @override
  void initState() {
    super.initState();
    final a = widget.activite;
    _code = TextEditingController(text: a?.code ?? _genererCode());
    _description = TextEditingController(text: a?.description ?? '');
    _codeBudget = TextEditingController(text: a?.codeBudget ?? '');
    _sourceFinancement = TextEditingController(
      text: a?.sourceFinancement ?? '',
    );
    _annee = TextEditingController(text: a?.annee?.toString() ?? '');
    _district = TextEditingController(text: a?.district ?? '');
    _responsable = TextEditingController(text: a?.responsable ?? '');
    _participants =
        TextEditingController(text: (a?.nombreParticipants ?? 0).toString());
    _missionnaires =
        TextEditingController(text: (a?.nombreMissionnaires ?? 0).toString());
    _distance =
        TextEditingController(text: (a?.distanceAllerKm ?? 0).toString());
    _observation = TextEditingController(text: a?.observation ?? '');
    _type = a?.type ?? _types.first;
    _statut = a?.statut ?? 'En cours';
    _debut = a?.dateDebut;
    _fin = a?.dateFin;
    _restauration = a?.restauration ?? false;
    // Code budget attribué automatiquement à la création.
    if (a?.codeBudget == null || a!.codeBudget!.trim().isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _codeBudget.text.trim().isNotEmpty) return;
        _codeBudget.text = prochainCodeBudget([
          for (final act in
              ref.read(activitesProvider).value ?? const <Activite>[])
            act.codeBudget,
        ]);
      });
    }
  }

  @override
  void dispose() {
    for (final c in [
      _code,
      _description,
      _codeBudget,
      _sourceFinancement,
      _annee,
      _district,
      _responsable,
      _participants,
      _missionnaires,
      _distance,
      _observation,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Pré-remplissage automatique depuis le district choisi : distance aller
  /// et zone d'indemnité viennent du référentiel DISTANCES_DISTRICTS.
  void _appliquerDistrict(String nom) {
    final districts = ref.read(tousDistrictsProvider).value ?? const <District>[];
    District? trouve;
    for (final d in districts) {
      if (d.nom.toLowerCase() == nom.trim().toLowerCase()) {
        trouve = d;
        break;
      }
    }
    if (trouve == null) return;
    setState(() {
      if (trouve!.distanceAllerKm > 0) {
        _distance.text = trouve.distanceAllerKm
            .toStringAsFixed(trouve.distanceAllerKm.truncateToDouble() ==
                    trouve.distanceAllerKm
                ? 0
                : 2);
      }
    });
  }

  Future<void> _choisirDate({required bool debut}) async {
    final choix = await showDatePicker(
      context: context,
      initialDate: (debut ? _debut : _fin) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (choix == null) return;
    setState(() {
      if (debut) {
        _debut = choix;
      } else {
        _fin = choix;
      }
    });
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_debut != null && _fin != null && _fin!.isBefore(_debut!)) {
      notifier(context, 'La date de fin doit être postérieure à la date de début.',
          erreur: true);
      return;
    }
    setState(() => _enregistrement = true);
    try {
      final repo = ref.read(activitesRepositoryProvider);
      final audit = ref.read(auditRepositoryProvider);
      final joursCalcules = nombreJoursEntre(_debut, _fin);
      final companion = ActivitesCompanion(
        code: drift.Value(_code.text.trim()),
        description: drift.Value(_description.text.trim()),
        type: drift.Value(_type),
        codeBudget: drift.Value(_codeBudget.text.trim()),
        sourceFinancement: drift.Value(_sourceFinancement.text.trim()),
        annee: drift.Value(int.tryParse(_annee.text)),
        district: drift.Value(_district.text.trim()),
        responsable: drift.Value(_responsable.text.trim()),
        // Nombre de jours recalculé automatiquement depuis les dates.
        nombreJours: drift.Value(
          joursCalcules > 0
              ? joursCalcules
              : (widget.activite?.nombreJours ?? 0),
        ),
        nombreParticipants: drift.Value(int.tryParse(_participants.text) ?? 0),
        nombreMissionnaires:
            drift.Value(int.tryParse(_missionnaires.text) ?? 0),
        distanceAllerKm: drift.Value(
            double.tryParse(_distance.text.replaceAll(',', '.')) ?? 0),
        restauration: drift.Value(_restauration),
        statut: drift.Value(_statut),
        dateDebut: drift.Value(_debut),
        dateFin: drift.Value(_fin),
        observation: drift.Value(_observation.text.trim()),
      );

      final existante = widget.activite;
      if (existante == null) {
        final id = await repo.insert(companion);
        await audit.log(
          action: 'CREATION',
          entite: 'activite',
          entiteId: id.toString(),
          nouvelleValeur: _code.text.trim(),
        );
      } else {
        await repo.update(existante.id, companion);
        await audit.log(
          action: 'MODIFICATION',
          entite: 'activite',
          entiteId: existante.id.toString(),
          champ: 'code',
          ancienneValeur: existante.code,
          nouvelleValeur: _code.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        notifier(context, 'Enregistrement impossible : $e', erreur: true);
      }
    } finally {
      if (mounted) setState(() => _enregistrement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final largeur = MediaQuery.sizeOf(context).width;
    final deuxColonnes = largeur > 640;
    final largeurContenu = largeur > 720
        ? 640.0
        : (largeur - 64).clamp(240.0, 640.0);
    final districts = ref.watch(tousDistrictsProvider).value ?? const <District>[];
    final activitesExistantes =
        ref.watch(activitesProvider).value ?? const <Activite>[];
    final responsables = activitesExistantes
        .map((a) => a.responsable ?? '')
        .where((v) => v.trim().isNotEmpty)
        .toSet()
        .toList();
    final codes = activitesExistantes.map((a) => a.code).toList();
    final descriptions = activitesExistantes
        .map((a) => a.description)
        .where((v) => v.trim().isNotEmpty)
        .toSet()
        .toList();
    final observations = activitesExistantes
        .map((a) => a.observation ?? '')
        .where((v) => v.trim().isNotEmpty)
        .toSet()
        .toList();
    final codeBudgets = activitesExistantes
        .map((a) => a.codeBudget ?? '')
        .where((v) => v.trim().isNotEmpty)
        .toSet()
        .toList();
    final sourcesExistantes = activitesExistantes
        .map((a) => a.sourceFinancement ?? '')
        .where((v) => v.trim().isNotEmpty)
        .toSet()
        .toList();
    final sourcesFinancement = {
      ...sourcesExistantes,
      ...ref.watch(reglesParametresProvider).value?.sourcesFinancement ??
          const <String>[],
      ...ref.watch(valeursListeProvider('FINANCEMENT')).value ?? const <String>[],
    }.toList();
    return AlertDialog(
      title: TitreDialogue(
        widget.activite == null ? 'Nouvelle activité' : 'Modifier l\'activité',
        icone: Icons.event_available_outlined,
      ),
      content: SizedBox(
        width: largeurContenu,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _paire(
                  deuxColonnes,
                  ChampListe(
                    controller: _code,
                    label: 'Code activité *',
                    hint: 'PSN N°1',
                    valeurs: codes,
                    prefixIcon: Icons.confirmation_number_outlined,
                    onSaisieAuto: () => setState(
                      () => _code.text = _genererCode(),
                    ),
                    saisieAutoLabel: 'Générer un nouveau code',
                    validator: (v) =>
                        validateurObligatoire(v, champ: 'Le code'),
                  ),
                  ChampListe(
                    controller: _description,
                    label: 'Description',
                    valeurs: descriptions,
                    prefixIcon: Icons.description_outlined,
                  ),
                ),
                const SizedBox(height: 12),
                _paire(
                  deuxColonnes,
                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: [
                      for (final t in _types)
                        DropdownMenuItem(value: t, child: Text(t)),
                    ],
                    onChanged: (v) => setState(() => _type = v ?? _type),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _statut,
                    decoration: const InputDecoration(labelText: 'Statut'),
                    items: [
                      for (final s in _statuts)
                        DropdownMenuItem(value: s, child: Text(s)),
                    ],
                    onChanged: (v) => setState(() => _statut = v ?? _statut),
                  ),
                ),
                const SizedBox(height: 12),
                _paire(
                  deuxColonnes,
                  ChampListe(
                    controller: _codeBudget,
                    label: 'Code budget',
                    valeurs: codeBudgets,
                    prefixIcon: Icons.savings_outlined,
                    helperText: 'Généré automatiquement (bud_1, bud_2, …)',
                    onChanged: (_) => setState(() {}),
                    onSaisieAuto: () => setState(
                      () => _codeBudget.text = prochainCodeBudget(
                        activitesExistantes.map((a) => a.codeBudget),
                      ),
                    ),
                    saisieAutoLabel: 'Générer le code budget suivant',
                  ),
                  ChampNombre(
                    controller: _annee,
                    label: 'Année',
                    step: 1,
                  ),
                ),
                const SizedBox(height: 12),
                _paire(
                  deuxColonnes,
                  _champDate(
                    label: 'Date début',
                    valeur: _debut,
                    onTap: () => _choisirDate(debut: true),
                  ),
                  _champDate(
                    label: 'Date fin',
                    valeur: _fin,
                    onTap: () => _choisirDate(debut: false),
                  ),
                ),
                const SizedBox(height: 12),
                _paire(
                  deuxColonnes,
                  ChampListe(
                    controller: _sourceFinancement,
                    label: 'Source de financement',
                    valeurs: sourcesFinancement,
                    prefixIcon: Icons.account_balance_wallet_outlined,
                    hint: 'UNICEF, UNFPA, …',
                  ),
                  ChampListe(
                    controller: _district,
                    label: 'District',
                    valeurs: [for (final d in districts) d.nom],
                    prefixIcon: Icons.map_outlined,
                    // Distance et zone d'indemnité pré-remplies selon le
                    // district sélectionné (référentiel DISTANCES_DISTRICTS).
                    onChanged: _appliquerDistrict,
                  ),
                ),
                const SizedBox(height: 12),
                _paire(
                  deuxColonnes,
                  ChampListe(
                    controller: _responsable,
                    label: 'Responsable',
                    valeurs: responsables,
                    prefixIcon: Icons.person_outline,
                  ),
                  ChampNombre(
                    controller: _distance,
                    label: 'Distance aller (km) — selon district',
                    decimales: true,
                    validator: (v) => validateurMontant(v),
                  ),
                ),
                const SizedBox(height: 12),
                _paire(
                  deuxColonnes,
                  ChampNombre(
                    controller: _participants,
                    label: 'Nombre de participants',
                  ),
                  ChampNombre(
                    controller: _missionnaires,
                    label: 'Nombre de missionnaires',
                  ),
                ),
                const SizedBox(height: 12),
                LigneBascule(
                  label: 'Restauration prise en charge',
                  sousTitre:
                      'Applique automatiquement le taux réduit de 15 % sur '
                      'les indemnités pendant l\'activité.',
                  value: _restauration,
                  onChanged: (v) => setState(() => _restauration = v),
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
          onPressed:
              _enregistrement ? null : () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: _enregistrement ? null : _enregistrer,
          icon: _enregistrement
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.save_outlined),
          label: const Text('Enregistrer'),
        ),
      ],
    );
  }

  Widget _paire(bool deuxColonnes, Widget a, Widget b) {
    if (!deuxColonnes) {
      return Column(children: [a, const SizedBox(height: 12), b]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: 12),
        Expanded(child: b),
      ],
    );
  }

  Widget _champDate({
    required String label,
    required DateTime? valeur,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(valeur == null ? 'Non définie' : formatDate(valeur)),
      ),
    );
  }
}
