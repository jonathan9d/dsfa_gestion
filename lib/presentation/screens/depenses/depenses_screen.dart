import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../domain/services/regles_metier.dart';
import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/tableau.dart';

/// Journal des dépenses (feuille J.Depenses).
class DepensesScreen extends ConsumerStatefulWidget {
  const DepensesScreen({super.key});

  @override
  ConsumerState<DepensesScreen> createState() => _DepensesScreenState();
}

class _DepensesScreenState extends ConsumerState<DepensesScreen> {
  final _recherche = TextEditingController();

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final depenses = ref.watch(depensesProvider);
    return Scaffold(
      body: Column(
        children: [
          EnTetePage(
            titre: 'Dépenses',
            sousTitre:
                'Journal des dépenses — montant = nbr jr/mois × quantité × fréquence × P.U.',
            actions: [
              FilledButton.icon(
                onPressed: () => _ouvrirFormulaire(),
                icon: const Icon(Icons.add),
                label: const Text('Nouvelle dépense'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: 380,
              child: ChampRecherche(
                controller: _recherche,
                hint: 'Rechercher une dépense',
                onChanged: (v) =>
                    ref.read(filtreRechercheProvider.notifier).state = v,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: depenses.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EtatErreur(erreur: e),
              data: (liste) => liste.isEmpty
                  ? EtatVide(
                      message:
                          'Aucune dépense enregistrée pour le moment.\n'
                          'Utilisez le bouton « Nouvelle dépense » pour saisir la première.',
                      icone: Icons.receipt_long_outlined,
                      action: FilledButton.icon(
                        onPressed: () => _ouvrirFormulaire(),
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter une dépense'),
                      ),
                    )
                  : _TableauDepenses(depenses: liste, ref: ref),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _ouvrirFormulaire({Depense? depense}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _DepenseDialog(depense: depense),
    );
    if (ok == true && mounted) notifier(context, 'Dépense enregistrée');
  }
}

class _TableauDepenses extends StatelessWidget {
  const _TableauDepenses({required this.depenses, required this.ref});
  final List<Depense> depenses;
  final WidgetRef ref;

  double _montant(Depense d) => ReglesMetier.montantDepense(
        nbJrMois: d.nbJrMois,
        quantite: d.quantite,
        frequence: d.frequence,
        pu: d.pu,
      );

  /// Statut de conformité de la pièce justificative liée à cette dépense
  /// (mise à jour automatique à l'enregistrement du dossier PJ).
  String _statutPJ(Depense d) {
    final id = d.controlePJId;
    if (id == null) return '—';
    final resultats =
        ref.watch(resultatsControlePJProvider).value ?? const [];
    for (final (c, r) in resultats) {
      if (c.id == id) {
        return r.statutFinal.isEmpty ? 'À vérifier' : r.statutFinal;
      }
    }
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    final total = depenses.fold<double>(0, (s, d) => s + _montant(d));
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: TableauGestion<Depense>(
        lignes: depenses,
        cleLigne: (d) => d.id,
        messageVide:
            'Aucune dépense enregistrée pour le moment.\n'
            'Utilisez le bouton « Nouvelle dépense » pour saisir la première.',
        resume: Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            Chip(
              avatar:
                  const Icon(Icons.account_balance_wallet_outlined, size: 16),
              visualDensity: VisualDensity.compact,
              label: Text('Total : ${formatMontant(total)}',
                  style: const TextStyle(fontSize: 12.5)),
            ),
          ],
        ),
        colonnes: [
          ColonneTableau(
            label: 'Date',
            flex: 2,
            valeur: (d) => formatDate(d.dateEnregistrement),
            cleTri: (d) => d.dateEnregistrement,
          ),
          ColonneTableau(
            label: 'Code activité',
            flex: 2,
            valeur: (d) => d.codeActivite ?? '',
            cellule: (_, d) => Text(
              d.codeActivite ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          ColonneTableau(
            label: 'Désignation',
            flex: 5,
            valeur: (d) => d.designation,
          ),
          ColonneTableau(label: 'Mode de paiement', flex: 3, valeur: (d) => d.fonds),
          ColonneTableau(
            label: 'Statut PJ',
            flex: 3,
            valeur: (d) => _statutPJ(d),
            cellule: (_, d) {
              final statut = _statutPJ(d);
              final couleur = switch (statut) {
                'Conforme' => const Color(0xFF2E7D32),
                'Non conforme' || 'PJ non reçue' || 'Date PJ non conforme' =>
                  const Color(0xFFC62828),
                'À vérifier' => const Color(0xFFF9A825),
                _ => Theme.of(context).colorScheme.onSurfaceVariant,
              };
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    statut == 'Conforme'
                        ? Icons.verified_outlined
                        : statut == '—'
                            ? Icons.remove
                            : Icons.rule_outlined,
                    size: 15,
                    color: couleur,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      statut,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: couleur,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          ColonneTableau(
            label: 'Qté',
            flex: 2,
            numerique: true,
            valeur: (d) => d.quantite.toStringAsFixed(0),
            cleTri: (d) => d.quantite,
          ),
          ColonneTableau(
            label: 'P.U.',
            flex: 3,
            numerique: true,
            valeur: (d) => formatMontant(d.pu),
            cleTri: (d) => d.pu,
          ),
          ColonneTableau(
            label: 'Montant',
            flex: 3,
            numerique: true,
            valeur: (d) => formatMontant(_montant(d)),
            cleTri: (d) => _montant(d),
            cellule: (_, d) => Text(
              formatMontant(_montant(d)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
        actions: [
          ActionTableau<Depense>(
            icone: Icons.edit_outlined,
            infobulle: 'Modifier',
            onTap: (d) async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => _DepenseDialog(depense: d),
              );
              if (ok == true && context.mounted) {
                notifier(context, 'Dépense modifiée');
              }
            },
          ),
          ActionTableau<Depense>(
            icone: Icons.delete_outline,
            infobulle: 'Supprimer',
            couleur: Theme.of(context).colorScheme.error,
            onTap: (d) async {
              final ok = await confirmer(
                context,
                titre: 'Supprimer la dépense',
                message: 'Supprimer « ${d.designation} » ?',
              );
              if (!ok) return;
              await ref.read(depensesRepositoryProvider).delete(d.id);
              if (context.mounted) notifier(context, 'Dépense supprimée');
            },
          ),
        ],
        onSupprimer: (lignes) async {
          final repo = ref.read(depensesRepositoryProvider);
          for (final d in lignes) {
            await repo.delete(d.id);
          }
        },
      ),
    );
  }
}


class _DepenseDialog extends ConsumerStatefulWidget {
  const _DepenseDialog({this.depense});
  final Depense? depense;

  @override
  ConsumerState<_DepenseDialog> createState() => _DepenseDialogState();
}

class _DepenseDialogState extends ConsumerState<_DepenseDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _designation;
  late final TextEditingController _codeActivite;
  late final TextEditingController _codeBudget;
  late final TextEditingController _unite;
  late final TextEditingController _nbJrMois;
  late final TextEditingController _quantite;
  late final TextEditingController _frequence;
  late final TextEditingController _pu;
  late final TextEditingController _refDecaissement;
  late final TextEditingController _refPiece;
  late final TextEditingController _dct;
  late final TextEditingController _observation;
  DateTime? _dateEnregistrement;
  DateTime? _datePiece;
  String _fonds = 'Banque';

  @override
  void initState() {
    super.initState();
    final d = widget.depense;
    _designation = TextEditingController(text: d?.designation ?? '');
    _codeActivite = TextEditingController(text: d?.codeActivite ?? '');
    _codeBudget = TextEditingController(text: d?.codeBudget ?? '');
    _unite = TextEditingController(text: d?.unite ?? '');
    _nbJrMois = TextEditingController(text: (d?.nbJrMois ?? 0).toString());
    _quantite = TextEditingController(text: (d?.quantite ?? 0).toString());
    _frequence = TextEditingController(text: (d?.frequence ?? 1).toString());
    _pu = TextEditingController(text: (d?.pu ?? 0).toString());
    _refDecaissement = TextEditingController(text: d?.refDecaissement ?? '');
    _refPiece = TextEditingController(text: d?.refPieceDepense ?? '');
    _dct = TextEditingController(text: d?.dctNumero ?? '');
    _observation = TextEditingController(text: d?.observation ?? '');
    _dateEnregistrement = d?.dateEnregistrement;
    _datePiece = d?.datePieceComptable;
    _fonds = d?.fonds ?? 'Espèce';
    if (widget.depense == null) _suggereCode();
  }

  /// Propose le prochain code d'activité (auto-incrémenté).
  Future<void> _suggereCode() async {
    final codes = await ref.read(activitesRepositoryProvider).codes();
    if (!mounted || _codeActivite.text.trim().isNotEmpty) return;
    setState(() => _codeActivite.text = _prochainCode(codes));
    await _remplirCodeBudget(_codeActivite.text);
  }

  /// Pré-remplit le code budget et la source de financement depuis l'activité.
  Future<void> _remplirCodeBudget(String code) async {
    final activite =
        await ref.read(activitesRepositoryProvider).parCode(code.trim());
    if (!mounted || activite == null) return;
    setState(() {
      if ((activite.codeBudget ?? '').trim().isNotEmpty) {
        _codeBudget.text = activite.codeBudget!;
      }
    });
  }

  static String _chiffre(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(2);

  /// Pré-remplit l'unité et le prix unitaire depuis le référentiel des tarifs
  /// (correspondance exacte puis partielle sur la ligne budgétaire).
  void _surDesignation(String designation) {
    final libelle = designation.trim().toLowerCase();
    if (libelle.isEmpty) return;
    final tarifs =
        ref.read(tousTarifsProvider).value ?? const <TarifReferentiel>[];
    TarifReferentiel? exact;
    TarifReferentiel? partiel;
    for (final t in tarifs) {
      if (!t.actif) continue;
      final l = t.ligneBudgetaire.trim().toLowerCase();
      if (l.isEmpty) continue;
      if (l == libelle) {
        exact = t;
        break;
      }
      if (partiel == null && (l.contains(libelle) || libelle.contains(l))) {
        partiel = t;
      }
    }
    final trouve = exact ?? partiel;
    if (trouve == null) return;
    setState(() {
      if (_unite.text.trim().isEmpty && trouve.unite.trim().isNotEmpty) {
        _unite.text = trouve.unite;
      }
      final pu = double.tryParse(_pu.text.replaceAll(',', '.')) ?? 0;
      if (pu <= 0 && trouve.tarif > 0) _pu.text = _chiffre(trouve.tarif);
    });
  }

  /// Déduit le code suivant à partir de la numérotation existante.
  static String _prochainCode(List<String> codes) {
    final motif = RegExp(r'^(.*?)(\d+)\s*$');
    String? prefixe;
    var max = 0;
    var largeur = 1;
    for (final c in codes) {
      final m = motif.firstMatch(c.trim());
      if (m == null) continue;
      final chiffres = m.group(2)!;
      final n = int.tryParse(chiffres) ?? 0;
      if (n >= max) {
        max = n;
        prefixe = m.group(1);
        largeur = chiffres.length;
      }
    }
    if (prefixe == null) {
      return 'ACT-${(codes.length + 1).toString().padLeft(4, '0')}';
    }
    return '$prefixe${(max + 1).toString().padLeft(largeur, '0')}';
  }

  @override
  void dispose() {
    for (final c in [
      _designation,
      _codeActivite,
      _codeBudget,
      _unite,
      _nbJrMois,
      _quantite,
      _frequence,
      _pu,
      _refDecaissement,
      _refPiece,
      _dct,
      _observation,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double get _montant => ReglesMetier.montantDepense(
        nbJrMois: double.tryParse(_nbJrMois.text.replaceAll(',', '.')) ?? 0,
        quantite: double.tryParse(_quantite.text.replaceAll(',', '.')) ?? 0,
        frequence: double.tryParse(_frequence.text.replaceAll(',', '.')) ?? 1,
        pu: double.tryParse(_pu.text.replaceAll(',', '.')) ?? 0,
      );

  Future<void> _choisirDate({required bool piece}) async {
    final choix = await showDatePicker(
      context: context,
      initialDate: (piece ? _datePiece : _dateEnregistrement) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (choix == null) return;
    setState(() {
      if (piece) {
        _datePiece = choix;
      } else {
        _dateEnregistrement = choix;
      }
    });
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(depensesRepositoryProvider);
    final companion = DepensesCompanion(
      dateEnregistrement: drift.Value(_dateEnregistrement),
      datePieceComptable: drift.Value(_datePiece),
      fonds: drift.Value(_fonds),
      refDecaissement: drift.Value(_refDecaissement.text.trim()),
      refPieceDepense: drift.Value(_refPiece.text.trim()),
      dctNumero: drift.Value(_dct.text.trim()),
      codeActivite: drift.Value(_codeActivite.text.trim()),
      codeBudget: drift.Value(_codeBudget.text.trim()),
      designation: drift.Value(_designation.text.trim()),
      unite: drift.Value(_unite.text.trim()),
      nbJrMois:
          drift.Value(double.tryParse(_nbJrMois.text.replaceAll(',', '.')) ?? 0),
      quantite:
          drift.Value(double.tryParse(_quantite.text.replaceAll(',', '.')) ?? 0),
      frequence:
          drift.Value(double.tryParse(_frequence.text.replaceAll(',', '.')) ?? 1),
      pu: drift.Value(double.tryParse(_pu.text.replaceAll(',', '.')) ?? 0),
      observation: drift.Value(_observation.text.trim()),
    );
    if (widget.depense == null) {
      await repo.insert(companion);
    } else {
      await repo.update(widget.depense!.id, companion);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final largeur = MediaQuery.sizeOf(context).width;
    final deux = largeur > 700;
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
    final lignesReference =
        ref.watch(valeursListeProvider('LIGNE_BUDGETAIRE')).value ??
            const <String>[];
    final tarifsReference =
        ref.watch(tousTarifsProvider).value ?? const <TarifReferentiel>[];
    final designations = <String>{
      ...lignesReference,
      ...tarifsReference
          .where((t) => t.actif && t.ligneBudgetaire.trim().isNotEmpty)
          .map((t) => t.ligneBudgetaire.trim()),
    }.toList()
      ..sort();
    final unites = <String>{
      'personne',
      'jour',
      'unité',
      'forfait',
      'km',
      'litre',
      'mois',
      ...tarifsReference.map((t) => t.unite.trim()),
    }.where((v) => v.isNotEmpty).toList()
      ..sort();
    final codesActivite =
        ref.watch(activitesCodesProvider).value ?? const [];
    final existantes =
        ref.watch(depensesProvider).value ?? const <Depense>[];
    List<String> distinctes(String Function(Depense) f) => existantes
        .map(f)
        .where((v) => v.trim().isNotEmpty)
        .toSet()
        .toList();
    final refPieces = distinctes((d) => d.refPieceDepense ?? '');
    final dcts = distinctes((d) => d.dctNumero ?? '');
    final observations = distinctes((d) => d.observation ?? '');

    return AlertDialog(
      title: TitreDialogue(
        widget.depense == null ? 'Nouvelle dépense' : 'Modifier la dépense',
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
                paire(
                  InkWell(
                    onTap: () => _choisirDate(piece: false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date d\'enregistrement',
                        suffixIcon:
                            Icon(Icons.calendar_today_outlined, size: 18),
                      ),
                      child: Text(formatDate(_dateEnregistrement)),
                    ),
                  ),
                  InkWell(
                    onTap: () => _choisirDate(piece: true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date pièce comptable',
                        suffixIcon:
                            Icon(Icons.calendar_today_outlined, size: 18),
                      ),
                      child: Text(formatDate(_datePiece)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                paire(
                  ChampListe(
                    controller: _codeActivite,
                    label: 'Code activité *',
                    valeurs: codesActivite,
                    prefixIcon: Icons.confirmation_number_outlined,
                    helperText: 'Auto-incrémenté, modifiable — le code budget '
                        'est pré-rempli automatiquement',
                    onChanged: _remplirCodeBudget,
                    validator: (v) =>
                        validateurObligatoire(v, champ: 'Le code activité'),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _fonds,
                    decoration: const InputDecoration(
                      labelText: 'Mode de paiement',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Espèce', child: Text('Espèce')),
                      DropdownMenuItem(value: 'Chèque', child: Text('Chèque')),
                      DropdownMenuItem(value: 'Virement', child: Text('Virement')),
                      DropdownMenuItem(
                          value: 'Mobile Money', child: Text('Mobile Money')),
                      DropdownMenuItem(value: 'Banque', child: Text('Banque')),
                      DropdownMenuItem(value: 'Caisse', child: Text('Caisse')),
                    ],
                    onChanged: (v) => setState(() => _fonds = v ?? 'Espèce'),
                  ),
                ),
                const SizedBox(height: 12),
                paire(
                  ChampListe(
                    controller: _designation,
                    label: 'Désignation *',
                    valeurs: designations,
                    prefixIcon: Icons.label_outline,
                    helperText:
                        'Choisir dans la liste ou saisir une nouvelle valeur',
                    onChanged: _surDesignation,
                    validator: (v) =>
                        validateurObligatoire(v, champ: 'La désignation'),
                  ),
                  ChampListe(
                    controller: _unite,
                    label: 'Unité',
                    valeurs: unites,
                    prefixIcon: Icons.straighten_outlined,
                    helperText: 'Pré-remplie depuis le référentiel',
                  ),
                ),
                const SizedBox(height: 12),
                paire(
                  ChampListe(
                    controller: _refPiece,
                    label: 'Référence PJ',
                    valeurs: refPieces,
                    prefixIcon: Icons.receipt_outlined,
                  ),
                  ChampListe(
                    controller: _dct,
                    label: 'Description des pj',
                    valeurs: dcts,
                    hint: 'Facture ou état de paiement',
                    prefixIcon: Icons.description_outlined,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChampNombre(
                        controller: _nbJrMois,
                        label: 'Nbr jr/mois',
                        onChanged: () => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChampNombre(
                        controller: _quantite,
                        label: 'Quantité',
                        onChanged: () => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChampNombre(
                        controller: _frequence,
                        label: 'Fréquence',
                        onChanged: () => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChampNombre(
                        controller: _pu,
                        label: 'P.U. (Ar)',
                        onChanged: () => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
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
                  child: Row(
                    children: [
                      const Icon(Icons.calculate_outlined, size: 20),
                      const SizedBox(width: 10),
                      Text('Montant calculé : ${formatMontant(_montant)}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
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
