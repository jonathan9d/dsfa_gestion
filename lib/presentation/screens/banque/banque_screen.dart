import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/tableau.dart';

/// Journal de banque (feuille J.Banque) avec solde progressif.
class BanqueScreen extends ConsumerStatefulWidget {
  const BanqueScreen({super.key});

  @override
  ConsumerState<BanqueScreen> createState() => _BanqueScreenState();
}

class _BanqueScreenState extends ConsumerState<BanqueScreen> {
  final _recherche = TextEditingController();

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final operations = ref.watch(banqueProvider);
    final releve = ref.watch(releveBancaireProvider);

    return Scaffold(
      body: Column(
        children: [
          EnTetePage(
            titre: 'Banque',
            module: 'banque',
            sousTitre: 'Journal de banque et relevé bancaire',
            actions: [
              OutlinedButton.icon(
                onPressed: () => _ouvrirFormulaireReleve(),
                icon: const Icon(Icons.receipt_outlined),
                label: const Text('Ligne relevé'),
              ),
              FilledButton.icon(
                onPressed: () => _ouvrirFormulaire(),
                icon: const Icon(Icons.add),
                label: const Text('Nouvelle opération'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: 380,
              child: ChampRecherche(
                controller: _recherche,
                hint: 'Rechercher une opération',
                onChanged: (v) =>
                    ref.read(filtreRechercheProvider.notifier).state = v,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: operations.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EtatErreur(erreur: e),
              data: (liste) => liste.isEmpty
                  ? EtatVide(
                      message:
                          'Aucune opération bancaire enregistrée pour le moment.\n'
                          'Enregistrez les recettes et les dépenses du compte.',
                      icone: Icons.account_balance_outlined,
                      action: FilledButton.icon(
                        onPressed: () => _ouvrirFormulaire(),
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter une opération'),
                      ),
                    )
                  : _ContenuBanque(
                      operations: liste,
                      releve: releve.value ?? const [],
                      ref: ref,
                      onModifierReleve: (ligne) =>
                          _ouvrirFormulaireReleve(ligne: ligne),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _ouvrirFormulaire({BanqueOperation? operation}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _OperationDialog(operation: operation),
    );
    if (ok == true && mounted) notifier(context, 'Opération enregistrée');
  }

  Future<void> _ouvrirFormulaireReleve({ReleveBancaireLigne? ligne}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ReleveDialog(ligne: ligne),
    );
    if (ok == true && mounted) notifier(context, 'Ligne de relevé enregistrée');
  }
}

class _ContenuBanque extends StatelessWidget {
  const _ContenuBanque({
    required this.operations,
    required this.releve,
    required this.ref,
    required this.onModifierReleve,
  });

  final List<BanqueOperation> operations;
  final List<ReleveBancaireLigne> releve;
  final WidgetRef ref;
  final void Function(ReleveBancaireLigne ligne) onModifierReleve;

  @override
  Widget build(BuildContext context) {
    final recettes = operations.fold<double>(0, (s, o) => s + o.recettes);
    final depenses = operations.fold<double>(0, (s, o) => s + o.depenses);
    final solde = recettes - depenses;

    // Le solde progressif est calculé ligne par ligne, en suivant l'ordre du
    // journal (identique au tri par défaut du tableau).
    final soldes = <num>[0];
    var cumul = 0.0;
    for (final o in operations) {
      cumul += o.recettes - o.depenses;
      soldes.add(cumul);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final colonnes = c.maxWidth > 1000
                ? 3
                : c.maxWidth > 600
                ? 2
                : 1;
            const espace = 16.0;
            final largeur = colonnes == 1
                ? c.maxWidth
                : (c.maxWidth - espace * (colonnes - 1)) / colonnes;
            return Wrap(
              spacing: espace,
              runSpacing: espace,
              children: [
                SizedBox(
                  width: largeur,
                  child: CarteIndicateur(
                    titre: 'Total recettes',
                    valeur: formatMontant(recettes),
                    icone: Icons.south_west,
                    couleur: const Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(
                  width: largeur,
                  child: CarteIndicateur(
                    titre: 'Total dépenses',
                    valeur: formatMontant(depenses),
                    icone: Icons.north_east,
                    couleur: const Color(0xFFC62828),
                  ),
                ),
                SizedBox(
                  width: largeur,
                  child: CarteIndicateur(
                    titre: 'Solde',
                    valeur: formatMontant(solde),
                    icone: Icons.account_balance_wallet_outlined,
                    couleur: const Color(0xFF1F4E79),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          'Journal de banque',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TableauGestion<BanqueOperation>(
          cleModule: 'banque',
          lignes: operations,
          cleLigne: (o) => o.id,
          messageVide: 'Aucune opération bancaire enregistrée pour le moment.',
          colonnes: [
            ColonneTableau(
              label: 'Date',
              cle: 'date',
              flex: 2,
              valeur: (o) => formatDate(o.date),
              cleTri: (o) => o.date,
            ),
            ColonneTableau(
              label: 'Réf pièce',
              cle: 'reference',
              flex: 3,
              valeur: (o) => o.refPiece ?? '',
            ),
            ColonneTableau(
              label: 'Type',
              cle: 'type',
              flex: 3,
              valeur: (o) => o.type,
            ),
            ColonneTableau(
              label: 'Description',
              cle: 'description',
              flex: 5,
              valeur: (o) => o.description,
            ),
            ColonneTableau(
              label: 'Recettes',
              cle: 'recettes',
              flex: 3,
              numerique: true,
              valeur: (o) => o.recettes == 0 ? '' : formatMontant(o.recettes),
              cleTri: (o) => o.recettes,
              cellule: (_, o) => Text(
                o.recettes == 0 ? '—' : formatMontant(o.recettes),
                style: const TextStyle(color: Color(0xFF2E7D32)),
              ),
            ),
            ColonneTableau(
              label: 'Dépenses',
              cle: 'depenses',
              flex: 3,
              numerique: true,
              valeur: (o) => o.depenses == 0 ? '' : formatMontant(o.depenses),
              cleTri: (o) => o.depenses,
              cellule: (_, o) => Text(
                o.depenses == 0 ? '—' : formatMontant(o.depenses),
                style: const TextStyle(color: Color(0xFFC62828)),
              ),
            ),
            ColonneTableau(
              label: 'Solde',
              cle: 'solde',
              flex: 3,
              numerique: true,
              valeur: (o) => formatMontant(soldes[operations.indexOf(o) + 1]),
              cellule: (_, o) => Text(
                formatMontant(soldes[operations.indexOf(o) + 1]),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
          actions: [
            ActionTableau<BanqueOperation>(
              icone: Icons.edit_outlined,
              infobulle: 'Modifier',
              onTap: (o) async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => _OperationDialog(operation: o),
                );
                if (ok == true && context.mounted) {
                  notifier(context, 'Opération modifiée');
                }
              },
            ),
            ActionTableau<BanqueOperation>(
              icone: Icons.delete_outline,
              infobulle: 'Supprimer',
              couleur: Theme.of(context).colorScheme.error,
              onTap: (o) async {
                final ok = await confirmer(
                  context,
                  titre: 'Supprimer l\'opération',
                  message: 'Supprimer cette opération bancaire ?',
                );
                if (!ok) return;
                await ref.read(banqueRepositoryProvider).delete(o.id);
                if (context.mounted) notifier(context, 'Opération supprimée');
              },
            ),
          ],
          onSupprimer: (lignes) async {
            final repo = ref.read(banqueRepositoryProvider);
            for (final o in lignes) {
              await repo.delete(o.id);
            }
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Relevé bancaire',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TableauGestion<ReleveBancaireLigne>(
          lignes: releve,
          cleLigne: (r) => r.id,
          cleModule: 'banque_releve',
          messageVide:
              'Aucune ligne de relevé bancaire.\n'
              'Ajoutez les lignes du relevé pour pouvoir le rapprocher du journal.',
          colonnes: [
            ColonneTableau(
              label: 'Date',
              flex: 2,
              valeur: (r) => formatDate(r.date),
              cleTri: (r) => r.date,
            ),
            ColonneTableau(
              label: 'Référence',
              flex: 3,
              valeur: (r) => r.reference ?? '',
            ),
            ColonneTableau(
              label: 'Libellé',
              flex: 5,
              valeur: (r) => r.libelle ?? '',
            ),
            ColonneTableau(
              label: 'Débit',
              flex: 3,
              numerique: true,
              valeur: (r) => r.debit == 0 ? '' : formatMontant(r.debit),
              cleTri: (r) => r.debit,
            ),
            ColonneTableau(
              label: 'Crédit',
              flex: 3,
              numerique: true,
              valeur: (r) => r.credit == 0 ? '' : formatMontant(r.credit),
              cleTri: (r) => r.credit,
            ),
          ],
          actions: [
            ActionTableau<ReleveBancaireLigne>(
              icone: Icons.edit_outlined,
              infobulle: 'Modifier',
              onTap: onModifierReleve,
            ),
            ActionTableau<ReleveBancaireLigne>(
              icone: Icons.delete_outline,
              infobulle: 'Supprimer',
              couleur: Theme.of(context).colorScheme.error,
              onTap: (r) async {
                final ok = await confirmer(
                  context,
                  titre: 'Supprimer la ligne de relevé',
                  message: 'Supprimer cette ligne du relevé bancaire ?',
                );
                if (!ok) return;
                await ref.read(releveRepositoryProvider).delete(r.id);
                if (context.mounted) {
                  notifier(context, 'Ligne de relevé supprimée');
                }
              },
            ),
          ],
          onSupprimer: (lignes) async {
            final repo = ref.read(releveRepositoryProvider);
            for (final r in lignes) {
              await repo.delete(r.id);
            }
          },
        ),
      ],
    );
  }
}

class _OperationDialog extends ConsumerStatefulWidget {
  const _OperationDialog({this.operation});
  final BanqueOperation? operation;

  @override
  ConsumerState<_OperationDialog> createState() => _OperationDialogState();
}

class _OperationDialogState extends ConsumerState<_OperationDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ref;
  late final TextEditingController _refCheque;
  late final TextEditingController _description;
  late final TextEditingController _recettes;
  late final TextEditingController _depenses;
  late final TextEditingController _bailleur;
  late final TextEditingController _beneficiaire;
  DateTime? _date;
  String _type = 'Opération';

  static const _types = [
    'Opération',
    'SOLDE',
    'Recette',
    'Dépense',
    'Virement',
  ];

  @override
  void initState() {
    super.initState();
    final o = widget.operation;
    _ref = TextEditingController(text: o?.refPiece ?? '');
    _refCheque = TextEditingController(text: o?.refCheque ?? '');
    _description = TextEditingController(text: o?.description ?? '');
    _recettes = TextEditingController(text: (o?.recettes ?? 0).toString());
    _depenses = TextEditingController(text: (o?.depenses ?? 0).toString());
    _bailleur = TextEditingController(text: o?.bailleur ?? '');
    _beneficiaire = TextEditingController(text: o?.beneficiaire ?? '');
    _date = o?.date ?? DateTime.now();
    _type = o?.type ?? 'Opération';
  }

  @override
  void dispose() {
    for (final c in [
      _ref,
      _refCheque,
      _description,
      _recettes,
      _depenses,
      _bailleur,
      _beneficiaire,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null) {
      notifier(context, 'La date est obligatoire', erreur: true);
      return;
    }
    // Une opération bancaire doit mouvoir un montant : sans recette ni
    // dépense, elle n'a aucun effet sur le journal.
    final recettes = double.tryParse(_recettes.text.replaceAll(',', '.')) ?? 0;
    final depenses = double.tryParse(_depenses.text.replaceAll(',', '.')) ?? 0;
    if (recettes == 0 && depenses == 0) {
      notifier(
        context,
        'Renseignez un montant en recette ou en dépense.',
        erreur: true,
      );
      return;
    }
    if (_description.text.trim().isEmpty) {
      notifier(context, 'La description est obligatoire.', erreur: true);
      return;
    }
    final repo = ref.read(banqueRepositoryProvider);
    final companion = BanqueOperationsCompanion(
      date: drift.Value(_date!),
      refPiece: drift.Value(_ref.text.trim()),
      type: drift.Value(_type),
      refCheque: drift.Value(_refCheque.text.trim()),
      description: drift.Value(_description.text.trim()),
      recettes: drift.Value(
        double.tryParse(_recettes.text.replaceAll(',', '.')) ?? 0,
      ),
      depenses: drift.Value(
        double.tryParse(_depenses.text.replaceAll(',', '.')) ?? 0,
      ),
      bailleur: drift.Value(_bailleur.text.trim()),
      beneficiaire: drift.Value(_beneficiaire.text.trim()),
    );
    if (widget.operation == null) {
      await repo.insert(companion);
    } else {
      await repo.update(widget.operation!.id, companion);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final operations =
        ref.watch(banqueProvider).value ?? const <BanqueOperation>[];
    // La liste des bailleurs vient en priorité de la liste FINANCEMENT du
    // classeur de référence (parametres.xlsx), complétée par les valeurs déjà
    // saisies et les bailleurs institutionnels connus.
    final bailleursListe =
        ref.watch(valeursListeProvider('FINANCEMENT')).value ?? const [];
    final bailleurs = <String>{
      ...bailleursListe,
      'UNICEF',
      'UNFPA',
      'WISH2',
      'UPNNC',
      'AUTRES',
      ...operations
          .map((o) => o.bailleur ?? '')
          .where((b) => b.trim().isNotEmpty),
    }.toList();
    final beneficiaires = operations
        .map((o) => o.beneficiaire ?? '')
        .where((b) => b.trim().isNotEmpty)
        .toSet()
        .toList();
    List<String> distinctes(String Function(BanqueOperation) f) =>
        operations.map(f).where((v) => v.trim().isNotEmpty).toSet().toList();
    final refs = distinctes((o) => o.refPiece ?? '');
    final refsCheque = distinctes((o) => o.refCheque ?? '');
    final descriptions = distinctes((o) => o.description);
    return AlertDialog(
      title: TitreDialogue(
        widget.operation == null
            ? 'Nouvelle opération'
            : 'Modifier l\'opération',
        icone: Icons.account_balance_outlined,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 640),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final choix = await showDatePicker(
                            context: context,
                            initialDate: _date ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (choix != null) setState(() => _date = choix);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date *',
                            suffixIcon: Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                            ),
                          ),
                          child: Text(formatDate(_date)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _type,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: [
                          for (final t in _types)
                            DropdownMenuItem(value: t, child: Text(t)),
                        ],
                        onChanged: (v) => setState(() => _type = v ?? _type),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChampListe(
                        controller: _ref,
                        label: 'Réf pièce',
                        valeurs: refs,
                        prefixIcon: Icons.receipt_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChampListe(
                        controller: _refCheque,
                        label: 'Réf chq/OV',
                        valeurs: refsCheque,
                        prefixIcon: Icons.numbers_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ChampListe(
                  controller: _description,
                  label: 'Description *',
                  valeurs: descriptions,
                  prefixIcon: Icons.notes_outlined,
                  validator: (v) =>
                      validateurObligatoire(v, champ: 'La description'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChampNombre(
                        controller: _recettes,
                        label: 'Recettes (Ar)',
                        step: 1000,
                        validator: (v) => validateurMontant(v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChampNombre(
                        controller: _depenses,
                        label: 'Dépenses (Ar)',
                        step: 1000,
                        validator: (v) => validateurMontant(v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChampListe(
                        controller: _bailleur,
                        label: 'Bailleur',
                        valeurs: bailleurs,
                        prefixIcon: Icons.account_balance_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChampListe(
                        controller: _beneficiaire,
                        label: 'Bénéficiaire',
                        valeurs: beneficiaires,
                        prefixIcon: Icons.person_outline,
                      ),
                    ),
                  ],
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

class _ReleveDialog extends ConsumerStatefulWidget {
  const _ReleveDialog({this.ligne});
  final ReleveBancaireLigne? ligne;

  @override
  ConsumerState<_ReleveDialog> createState() => _ReleveDialogState();
}

class _ReleveDialogState extends ConsumerState<_ReleveDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reference;
  late final TextEditingController _libelle;
  late final TextEditingController _debit;
  late final TextEditingController _credit;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    final l = widget.ligne;
    _reference = TextEditingController(text: l?.reference ?? '');
    _libelle = TextEditingController(text: l?.libelle ?? '');
    _debit = TextEditingController(text: (l?.debit ?? 0).toString());
    _credit = TextEditingController(text: (l?.credit ?? 0).toString());
    _date = l?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    for (final c in [_reference, _libelle, _debit, _credit]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(releveRepositoryProvider);
    final companion = ReleveBancaireCompanion(
      date: drift.Value(_date),
      reference: drift.Value(_reference.text.trim()),
      libelle: drift.Value(_libelle.text.trim()),
      debit: drift.Value(
        double.tryParse(_debit.text.replaceAll(',', '.')) ?? 0,
      ),
      credit: drift.Value(
        double.tryParse(_credit.text.replaceAll(',', '.')) ?? 0,
      ),
    );
    if (widget.ligne == null) {
      await repo.insert(companion);
    } else {
      await repo.update(widget.ligne!.id, companion);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final releve =
        ref.watch(releveBancaireProvider).value ??
        const <ReleveBancaireLigne>[];
    final references = releve
        .map((r) => r.reference ?? '')
        .where((v) => v.trim().isNotEmpty)
        .toSet()
        .toList();
    final libelles = releve
        .map((r) => r.libelle ?? '')
        .where((v) => v.trim().isNotEmpty)
        .toSet()
        .toList();
    return AlertDialog(
      title: const TitreDialogue(
        'Ligne du relevé bancaire',
        icone: Icons.receipt_long_outlined,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 600),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () async {
                    final choix = await showDatePicker(
                      context: context,
                      initialDate: _date ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (choix != null) setState(() => _date = choix);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                    ),
                    child: Text(formatDate(_date)),
                  ),
                ),
                const SizedBox(height: 12),
                ChampListe(
                  controller: _reference,
                  label: 'Référence *',
                  hint: 'Doit correspondre à la réf du journal',
                  valeurs: references,
                  prefixIcon: Icons.receipt_outlined,
                  validator: (v) =>
                      validateurObligatoire(v, champ: 'La référence'),
                ),
                const SizedBox(height: 12),
                ChampListe(
                  controller: _libelle,
                  label: 'Libellé',
                  valeurs: libelles,
                  prefixIcon: Icons.notes_outlined,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChampNombre(
                        controller: _debit,
                        label: 'Débit (Ar)',
                        step: 1000,
                        validator: (v) => validateurMontant(v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChampNombre(
                        controller: _credit,
                        label: 'Crédit (Ar)',
                        step: 1000,
                        validator: (v) => validateurMontant(v),
                      ),
                    ),
                  ],
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
