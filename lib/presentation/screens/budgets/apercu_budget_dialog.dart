import 'dart:convert';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/database/database.dart';
import '../../../domain/rubriques.dart';
import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';

/// **Pré-impression du budget, par rubrique.**
///
/// Le document n'est plus une simple liste : les lignes sont **regroupées par
/// rubrique budgétaire** (la rubrique vient toujours des paramètres), chaque
/// rubrique affiche **son total**, et les fournitures — qui se lisent comme une
/// liste de courses — sont présentées en **post-it**.
class ApercuBudgetDialog extends ConsumerStatefulWidget {
  const ApercuBudgetDialog({required this.lignes, super.key});

  final List<LigneBudget> lignes;

  @override
  ConsumerState<ApercuBudgetDialog> createState() => _ApercuBudgetDialogState();
}

/// Une rubrique et ses lignes, dans l'ordre d'affichage du document.
class _Bloc {
  _Bloc(this.rubrique, this.lignes);
  final String rubrique;
  final List<LigneBudget> lignes;

  double get totalPrevisionnel =>
      lignes.fold<double>(0, (s, l) => s + _previsionnelDe(l));
  double get totalAlloue =>
      lignes.fold<double>(0, (s, l) => s + l.montantAlloue);
  int get nonConfirmees => lignes.where((l) => l.montantAlloue <= 0).length;

  /// La rubrique se présente-t-elle comme une liste de courses ? (post-it)
  bool get enPostIt =>
      RubriquesBudget.normaliser(rubrique).contains('FOURNITURE');
}

Map<String, dynamic> _detailsDe(LigneBudget l) {
  final brut = l.details;
  if (brut == null || brut.trim().isEmpty) return <String, dynamic>{};
  try {
    return (jsonDecode(brut) as Map).cast<String, dynamic>();
  } catch (_) {
    return <String, dynamic>{};
  }
}

double _previsionnelDe(LigneBudget l) {
  final d = _detailsDe(l);
  final v = d['montantPrevisionnel'];
  if (v is num) return v.toDouble();
  return double.tryParse('$v'.replaceAll(',', '.')) ?? l.montantAlloue;
}

String _libelleDe(LigneBudget l) {
  final u = l.ligneBudgetaire.toUpperCase();
  if (u.contains('DEPLACEMENT PAR AVION') ||
      u.contains('DÉPLACEMENT PAR AVION')) {
    return 'Billet d’avion';
  }
  return l.ligneBudgetaire;
}

class _ApercuBudgetDialogState extends ConsumerState<ApercuBudgetDialog> {
  bool _enCours = false;

  /// Regroupe les lignes par rubrique, exactement comme l'export Excel.
  List<_Bloc> _blocs() {
    final rubriques = RubriquesBudget.depuisTarifs(
      (ref.read(tousTarifsProvider).value ?? const <TarifReferentiel>[]).map(
        (t) => t.rubrique,
      ),
    );
    final parRubrique = <String, List<LigneBudget>>{};
    for (final l in widget.lignes) {
      final r = RubriquesBudget.resoudre(
        ligneBudgetaire: l.ligneBudgetaire,
        typeBudget: l.typeBudget,
        rubriqueEnregistree: '${_detailsDe(l)['rubrique'] ?? ''}',
        rubriques: rubriques,
      );
      parRubrique.putIfAbsent(r, () => []).add(l);
    }
    final cles = parRubrique.keys.toList()
      ..sort(
        (a, b) => RubriquesBudget.normaliser(
          a,
        ).compareTo(RubriquesBudget.normaliser(b)),
      );
    return [
      for (final cle in cles)
        _Bloc(
          cle,
          parRubrique[cle]!..sort(
            (a, b) => a.ligneBudgetaire.toLowerCase().compareTo(
              b.ligneBudgetaire.toLowerCase(),
            ),
          ),
        ),
    ];
  }

  Future<void> _exporter() async {
    setState(() => _enCours = true);
    try {
      final octets = await ref
          .read(excelExportServiceProvider)
          .exporterBudget();
      if (!mounted) return;
      final horodatage = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final uri = await FilePicker.saveFile(
        dialogTitle: 'Enregistrer le budget Excel',
        fileName: 'DSFA_budget_$horodatage.xlsx',
        bytes: Uint8List.fromList(octets),
        type: FileType.custom,
        allowedExtensions: const ['xlsx'],
      );
      if (uri == null) return;
      await ref
          .read(excelExportServiceProvider)
          .sauvegarder(octets, uri.toFilePath());
      if (mounted) {
        notifier(context, 'Fichier enregistré : ${uri.toFilePath()}');
      }
    } catch (e) {
      if (mounted) notifier(context, 'Export impossible : $e', erreur: true);
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final blocs = _blocs();
    final totalPrevisionnel = blocs.fold<double>(
      0,
      (s, b) => s + b.totalPrevisionnel,
    );
    final totalAlloue = blocs.fold<double>(0, (s, b) => s + b.totalAlloue);
    final nonConfirmees = blocs.fold<int>(0, (s, b) => s + b.nonConfirmees);

    return AlertDialog(
      title: const TitreDialogue(
        'Pré-impression du budget',
        sousTitre:
            'Regroupement par rubrique, total pour chaque rubrique — '
            'identique à l’export Excel.',
        icone: Icons.visibility_outlined,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 1240),
        height: math.min(640, MediaQuery.sizeOf(context).height - 190),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _Pastille(label: 'Rubriques', value: '${blocs.length}'),
                _Pastille(label: 'Lignes', value: '${widget.lignes.length}'),
                _Pastille(
                  label: 'Budget prévisionnel',
                  value: formatMontant(totalPrevisionnel),
                ),
                _Pastille(
                  label: 'Montant alloué confirmé',
                  value: formatMontant(totalAlloue),
                  accent: vertValide(context),
                ),
                if (nonConfirmees > 0)
                  _Pastille(
                    label: 'À confirmer',
                    value: '$nonConfirmees ligne(s)',
                    accent: ambreAttention(context),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: blocs.isEmpty
                  ? const EtatVide(
                      message: 'Aucune ligne budgétaire à imprimer.',
                      icone: Icons.savings_outlined,
                    )
                  : ListView(
                      padding: const EdgeInsets.only(right: 6, bottom: 8),
                      children: [
                        for (final bloc in blocs)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _BlocRubrique(bloc: bloc),
                          ),
                        _Recapitulatif(
                          blocs: blocs,
                          totalPrevisionnel: totalPrevisionnel,
                          totalAlloue: totalAlloue,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
        OutlinedButton.icon(
          onPressed: _enCours ? null : _exporter,
          icon: const Icon(Icons.table_view_outlined),
          label: const Text('Exporter Excel'),
        ),
      ],
    );
  }
}

/// Un bloc « rubrique » : son en-tête, son total, puis ses lignes — en post-it
/// pour les fournitures, en tableau sinon.
class _BlocRubrique extends StatelessWidget {
  const _BlocRubrique({required this.bloc});

  final _Bloc bloc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final complet = bloc.nonConfirmees == 0;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
        color: scheme.surface,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
            color: scheme.primaryContainer.withValues(alpha: 0.45),
            child: Row(
              children: [
                Icon(Icons.folder_outlined, size: 17, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bloc.rubrique,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  '${bloc.lignes.length} ligne(s)',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Total : ${formatMontant(bloc.totalAlloue)}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (!complet) ...[
                  const SizedBox(width: 8),
                  _Etiquette(
                    texte: '${bloc.nonConfirmees} à confirmer',
                    couleur: ambreAttention(context),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: bloc.enPostIt
                ? _PostIts(lignes: bloc.lignes)
                : _TableauLignes(lignes: bloc.lignes),
          ),
        ],
      ),
    );
  }
}

/// Fournitures : chaque ligne devient un **post-it** (l'équivalent d'une liste
/// de courses affichée sur le mur).
class _PostIts extends StatelessWidget {
  const _PostIts({required this.lignes});

  final List<LigneBudget> lignes;

  static const _couleurs = <Color>[
    Color(0xFFFFF3B0),
    Color(0xFFFFD9E2),
    Color(0xFFD7F2DA),
    Color(0xFFD9E8FF),
    Color(0xFFF0DCFF),
    Color(0xFFFFE7C2),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, contraintes) {
        const largeur = 186.0;
        final colonnes = math.max(
          1,
          (contraintes.maxWidth / (largeur + 12)).floor(),
        );
        final largeurCarte = math.max(
          140.0,
          (contraintes.maxWidth - 12 * (colonnes - 1)) / colonnes,
        );
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var i = 0; i < lignes.length; i++)
              SizedBox(
                width: largeurCarte,
                child: _PostIt(
                  ligne: lignes[i],
                  couleur: _couleurs[i % _couleurs.length],
                  delie: i.isEven,
                ),
              ),
            SizedBox(
              width: largeurCarte,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TOTAL FOURNITURES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatMontant(
                        lignes.fold<double>(0, (s, l) => s + l.montantAlloue),
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PostIt extends StatelessWidget {
  const _PostIt({
    required this.ligne,
    required this.couleur,
    required this.delie,
  });

  final LigneBudget ligne;
  final Color couleur;

  /// Alterne une légère inclinaison : l'effet « punaisé au mur ».
  final bool delie;

  @override
  Widget build(BuildContext context) {
    final previsionnel = _previsionnelDe(ligne);
    final confirme = ligne.montantAlloue > 0;
    return Transform.rotate(
      angle: delie ? -0.012 : 0.012,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        decoration: BoxDecoration(
          color: couleur,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Ruban adhésif en haut au centre.
            Positioned(
              top: -14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 54,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.55),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _libelleDe(ligne),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF3A2E00),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_nombre(ligne.quantitePrevue)} '
                  '${ligne.unite} × ${formatMontant(ligne.tauxUnitaire)}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF5A4A10),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Prévu : ${formatMontant(previsionnel)}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF5A4A10),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    confirme
                        ? 'Confirmé : ${formatMontant(ligne.montantAlloue)}'
                        : 'Montant non confirmé',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: confirme
                          ? const Color(0xFF1B5E20)
                          : const Color(0xFF8D4004),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Toutes les autres rubriques : un tableau sans aucune troncature.
class _TableauLignes extends StatelessWidget {
  const _TableauLignes({required this.lignes});

  final List<LigneBudget> lignes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const entete = TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    );
    final cellules = <TableRow>[
      TableRow(
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
        children: [
          for (final label in const [
            'Ligne budgétaire',
            'Unité',
            'Quantité',
            'Jours / fréq.',
            'Taux / PU',
            'Budget prévisionnel',
            'Montant alloué',
          ])
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              child: Text(label, style: entete),
            ),
        ],
      ),
      for (var i = 0; i < lignes.length; i++)
        TableRow(
          decoration: BoxDecoration(
            color: i.isEven
                ? null
                : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
          ),
          children: [
            _Cellule(texte: _libelleDe(lignes[i]), gras: true),
            _Cellule(texte: lignes[i].unite),
            _Cellule(texte: _nombre(lignes[i].quantitePrevue), droite: true),
            _Cellule(texte: _nombre(lignes[i].nombreJours), droite: true),
            _Cellule(
              texte: formatMontant(lignes[i].tauxUnitaire),
              droite: true,
            ),
            _Cellule(
              texte: formatMontant(_previsionnelDe(lignes[i])),
              droite: true,
            ),
            _Cellule(
              texte: lignes[i].montantAlloue > 0
                  ? formatMontant(lignes[i].montantAlloue)
                  : 'Non confirmé',
              droite: true,
              gras: true,
              couleur: lignes[i].montantAlloue > 0
                  ? vertValide(context)
                  : ambreAttention(context),
            ),
          ],
        ),
    ];
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: IntrinsicColumnWidth(),
        2: IntrinsicColumnWidth(),
        3: IntrinsicColumnWidth(),
        4: IntrinsicColumnWidth(),
        5: IntrinsicColumnWidth(),
        6: IntrinsicColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(color: scheme.outlineVariant, width: 0.6),
      children: cellules,
    );
  }
}

class _Cellule extends StatelessWidget {
  const _Cellule({
    required this.texte,
    this.droite = false,
    this.gras = false,
    this.couleur,
  });

  final String texte;
  final bool droite;
  final bool gras;
  final Color? couleur;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    child: Text(
      texte,
      textAlign: droite ? TextAlign.right : TextAlign.left,
      style: TextStyle(
        fontSize: 12,
        fontWeight: gras ? FontWeight.w700 : FontWeight.w400,
        color: couleur,
      ),
    ),
  );
}

/// Récapitulatif final : un total par rubrique, puis le total général.
class _Recapitulatif extends StatelessWidget {
  const _Recapitulatif({
    required this.blocs,
    required this.totalPrevisionnel,
    required this.totalAlloue,
  });

  final List<_Bloc> blocs;
  final double totalPrevisionnel;
  final double totalAlloue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.45)),
        color: scheme.primaryContainer.withValues(alpha: 0.25),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total par rubrique',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
          ),
          const SizedBox(height: 8),
          for (final bloc in blocs)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${bloc.rubrique}  '
                      '(${bloc.lignes.length} ligne(s))',
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  ),
                  Text(
                    formatMontant(bloc.totalAlloue),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'TOTAL GÉNÉRAL',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
              ),
              Text(
                'prévu ${formatMontant(totalPrevisionnel)}   ·   '
                'alloué ${formatMontant(totalAlloue)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Etiquette extends StatelessWidget {
  const _Etiquette({required this.texte, required this.couleur});
  final String texte;
  final Color couleur;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: couleur.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      texte,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: couleur,
      ),
    ),
  );
}

class _Pastille extends StatelessWidget {
  const _Pastille({required this.label, required this.value, this.accent});
  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final couleur = accent ?? scheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label : $value',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
          color: couleur,
        ),
      ),
    );
  }
}

String _nombre(num v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(2);
