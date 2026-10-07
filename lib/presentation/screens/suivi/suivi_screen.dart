import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../domain/services/regles_metier.dart';
import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/tableau.dart';

class SuiviScreen extends ConsumerStatefulWidget {
  const SuiviScreen({super.key});

  @override
  ConsumerState<SuiviScreen> createState() => _SuiviScreenState();
}

class _SuiviScreenState extends ConsumerState<SuiviScreen> {
  final Map<int, DateTime?> _receptionFonds = {};
  final Map<int, DateTime?> _rapportage = {};
  final Map<int, DateTime?> _receptionPJ = {};
  bool _charge = false;

  String _cle(int id, String champ) => 'suivi.activite.$id.$champ';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _chargerDates());
  }

  Future<void> _chargerDates() async {
    final activites = ref.read(activitesProvider).value ?? const <Activite>[];
    final toutes = await ref.read(parametresRepositoryProvider).tous();
    for (final a in activites) {
      final reception = toutes[_cle(a.id, 'dateReceptionFonds')];
      final rapportage = toutes[_cle(a.id, 'dateRapportage')];
      final receptionPJ = toutes[_cle(a.id, 'dateReceptionPJ')];
      if (reception != null && reception.isNotEmpty) {
        _receptionFonds[a.id] = DateTime.tryParse(reception);
      }
      if (rapportage != null && rapportage.isNotEmpty) {
        _rapportage[a.id] = DateTime.tryParse(rapportage);
      }
      if (receptionPJ != null && receptionPJ.isNotEmpty) {
        _receptionPJ[a.id] = DateTime.tryParse(receptionPJ);
      }
    }
    if (mounted) setState(() => _charge = true);
  }

  Future<void> _choisirDate({required int id, required bool reception}) async {
    final actuelle = reception ? _receptionFonds[id] : _rapportage[id];
    final date = await showDatePicker(
      context: context,
      initialDate: actuelle ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    await ref
        .read(parametresRepositoryProvider)
        .ecrire(
          _cle(id, reception ? 'dateReceptionFonds' : 'dateRapportage'),
          date.toIso8601String(),
        );
    if (!mounted) return;
    setState(() {
      if (reception) {
        _receptionFonds[id] = date;
      } else {
        _rapportage[id] = date;
      }
    });
  }

  Future<void> _choisirReceptionPJ(int id) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _receptionPJ[id] ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    await ref
        .read(parametresRepositoryProvider)
        .ecrire(_cle(id, 'dateReceptionPJ'), date.toIso8601String());
    if (!mounted) return;
    setState(() => _receptionPJ[id] = date);
  }

  Future<void> _effacerReceptionPJ(int id) async {
    await ref
        .read(parametresRepositoryProvider)
        .ecrire(_cle(id, 'dateReceptionPJ'), '');
    if (!mounted) return;
    setState(() => _receptionPJ.remove(id));
  }

  Future<void> _effacerDate({required int id, required bool reception}) async {
    await ref
        .read(parametresRepositoryProvider)
        .ecrire(
          _cle(id, reception ? 'dateReceptionFonds' : 'dateRapportage'),
          '',
        );
    if (!mounted) return;
    setState(() {
      if (reception) {
        _receptionFonds.remove(id);
      } else {
        _rapportage.remove(id);
      }
    });
  }

  String _statut({
    required String bailleur,
    required DateTime? reception,
    required DateTime? rapportage,
  }) {
    if (rapportage != null) return 'Rapporté';
    if (reception == null) return 'En attente';
    final debut = DateTime(reception.year, reception.month, reception.day);
    final jours = DateTime.now().difference(debut).inDays;
    final seuil = bailleur.trim().toUpperCase() == 'UNICEF' ? 90 : 15;
    if (jours > 120) return 'Bloqué';
    if (jours > seuil) return 'En retard';
    return 'En cours';
  }

  Color _couleur(BuildContext context, String statut) {
    switch (statut) {
      case 'Rapporté':
      case 'En cours':
        return vertValide(context);
      case 'En retard':
        return const Color(0xFFF9A825);
      case 'Bloqué':
        return rougeAlerte(context);
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activites = ref.watch(activitesProvider);
    final budgets = ref.watch(toutesLignesBudgetProvider);
    final depenses = ref.watch(depensesProvider);
    final pjs = ref.watch(controlesPJProvider);

    if (!_charge && activites.hasValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_charge) _chargerDates();
      });
    }

    return Scaffold(
      body: Column(
        children: [
          EnTetePage(
            titre: 'Suivi',
            sousTitre:
                'Fonds reçus, budget, dépenses, pièces justificatives et rapportage',
            actions: [
              OutlinedButton.icon(
                onPressed: _chargerDates,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Actualiser'),
              ),
            ],
          ),
          Expanded(
            child: activites.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EtatErreur(erreur: e),
              data: (a) => budgets.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => EtatErreur(erreur: e),
                data: (b) => depenses.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => EtatErreur(erreur: e),
                  data: (d) => pjs.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => EtatErreur(erreur: e),
                    data: (p) => _tableau(a, b, d, p),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableau(
    List<Activite> activites,
    List<LigneBudget> budgets,
    List<Depense> depenses,
    List<ControlePJ> pjs,
  ) {
    final alloue = <String, double>{};
    for (final l in budgets) {
      alloue[l.activiteCode] = (alloue[l.activiteCode] ?? 0) + l.montantAlloue;
    }
    final depense = <String, double>{};
    for (final d in depenses) {
      final code = d.codeActivite ?? '';
      if (code.isEmpty) continue;
      depense[code] =
          (depense[code] ?? 0) +
          ReglesMetier.montantDepense(
            nbJrMois: d.nbJrMois,
            quantite: d.quantite,
            frequence: d.frequence,
            pu: d.pu,
          );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: TableauGestion<Activite>(
        lignes: activites,
        cleLigne: (a) => a.id,
        taillePage: 15,
        messageVide: 'Aucune activité à suivre.',
        colonnes: [
          ColonneTableau(
            label: 'Date',
            valeur: (a) => formatDate(a.dateDebut),
            cleTri: (a) => a.dateDebut ?? DateTime(1900),
          ),
          ColonneTableau(label: 'Code activité', valeur: (a) => a.code),
          ColonneTableau(
            label: 'Code budget',
            valeur: (a) => a.codeBudget ?? '',
          ),
          ColonneTableau(
            label: 'Description activité',
            flex: 3,
            valeur: (a) => a.description,
          ),
          ColonneTableau(
            label: 'Date réception fonds',
            largeurMin: 190,
            valeur: (a) => formatDate(_receptionFonds[a.id]),
            cellule: (context, a) => _dateCell(context, a.id, true),
          ),
          ColonneTableau(
            label: 'Source de financement',
            flex: 2,
            valeur: (a) => a.sourceFinancement ?? '',
          ),
          ColonneTableau(
            label: 'Montant alloué',
            flex: 2,
            numerique: true,
            valeur: (a) => formatMontant(alloue[a.code] ?? 0),
            cleTri: (a) => alloue[a.code] ?? 0,
          ),
          ColonneTableau(
            label: 'Dépenses réalisées',
            flex: 2,
            numerique: true,
            valeur: (a) => formatMontant(depense[a.code] ?? 0),
            cleTri: (a) => depense[a.code] ?? 0,
          ),
          ColonneTableau(
            label: 'Écart',
            flex: 2,
            numerique: true,
            valeur: (a) =>
                formatMontant((alloue[a.code] ?? 0) - (depense[a.code] ?? 0)),
            cleTri: (a) => (alloue[a.code] ?? 0) - (depense[a.code] ?? 0),
          ),
          ColonneTableau(
            label: 'Date réception PJ',
            largeurMin: 190,
            valeur: (a) => formatDate(_receptionPJ[a.id]),
            cellule: (context, a) => _celluleDate(
              context,
              date: _receptionPJ[a.id],
              onChoisir: () => _choisirReceptionPJ(a.id),
              onEffacer: () => _effacerReceptionPJ(a.id),
            ),
          ),
          ColonneTableau(
            label: 'Date de rapportage',
            largeurMin: 190,
            valeur: (a) => formatDate(_rapportage[a.id]),
            cellule: (context, a) => _dateCell(context, a.id, false),
          ),
          ColonneTableau(
            label: 'Statut',
            flex: 2,
            valeur: (a) => _statut(
              bailleur: a.sourceFinancement ?? '',
              reception: _receptionFonds[a.id],
              rapportage: _rapportage[a.id],
            ),
            cellule: (context, a) {
              final statut = _statut(
                bailleur: a.sourceFinancement ?? '',
                reception: _receptionFonds[a.id],
                rapportage: _rapportage[a.id],
              );
              return Chip(
                label: Text(statut, style: const TextStyle(fontSize: 11)),
                visualDensity: VisualDensity.compact,
                backgroundColor: _couleur(
                  context,
                  statut,
                ).withValues(alpha: 0.12),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _dateCell(BuildContext context, int id, bool reception) =>
      _celluleDate(
        context,
        date: reception ? _receptionFonds[id] : _rapportage[id],
        onChoisir: () => _choisirDate(id: id, reception: reception),
        onEffacer: () => _effacerDate(id: id, reception: reception),
      );

  /// Cellule de date compacte : la date entière (jamais coupée) et **un seul**
  /// bouton qui ouvre le menu « Choisir / Effacer ». Deux boutons côte à côte
  /// élargissaient la colonne et finissaient par écraser la ligne.
  Widget _celluleDate(
    BuildContext context, {
    required DateTime? date,
    required VoidCallback onChoisir,
    required VoidCallback onEffacer,
  }) {
    final texte = formatDate(date);
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(texte, maxLines: 1, softWrap: false),
        const SizedBox(width: 2),
        PopupMenuButton<String>(
          tooltip: 'Date',
          padding: EdgeInsets.zero,
          iconSize: 18,
          icon: Icon(Icons.edit_calendar_outlined, color: scheme.primary),
          onSelected: (v) => v == 'effacer' ? onEffacer() : onChoisir(),
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'choisir',
              height: 38,
              child: Text('Choisir la date', style: TextStyle(fontSize: 13)),
            ),
            if (date != null)
              const PopupMenuItem(
                value: 'effacer',
                height: 38,
                child: Text('Effacer la date', style: TextStyle(fontSize: 13)),
              ),
          ],
        ),
      ],
    );
  }
}
