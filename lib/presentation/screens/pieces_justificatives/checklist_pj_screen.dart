import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../domain/regles_parametres.dart';
import '../../../domain/rubriques.dart';
import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';

/// **Checklist des PJ requises** — tout ce qu'affiche l'onglet « Pièces
/// justificatives » du dossier PJ.
///
/// Rien d'autre : pas de bandeau de totaux, pas de synthèse de statuts, pas de
/// fiches de contrôle. La liste des pièces à fournir est déduite **mot pour
/// mot** de la matrice des PJ de `PARAMETRES`, regroupée par **rubrique
/// budgétaire**, et chaque pièce se coche (reçue / date conforme). L'état est
/// conservé par activité dans les paramètres de l'application.
class ChecklistPJScreen extends ConsumerStatefulWidget {
  const ChecklistPJScreen({this.imbrique = false, super.key});

  final bool imbrique;

  @override
  ConsumerState<ChecklistPJScreen> createState() => _ChecklistPJScreenState();
}

/// État d'une pièce : reçue ? sa date est-elle conforme ?
class EtatPiece {
  EtatPiece({this.recue = false, this.dateConforme = false});

  bool recue;
  bool dateConforme;

  Map<String, dynamic> toJson() => {
    'recue': recue,
    'dateConforme': dateConforme,
  };

  factory EtatPiece.fromJson(Map<String, dynamic> json) => EtatPiece(
    recue: json['recue'] == true,
    dateConforme: json['dateConforme'] == true,
  );
}

/// État d'une rubrique : date de la PJ retenue + état de chaque pièce.
class EtatRubrique {
  EtatRubrique({this.datePJ, Map<String, EtatPiece>? pieces})
    : pieces = pieces ?? <String, EtatPiece>{};

  DateTime? datePJ;
  final Map<String, EtatPiece> pieces;

  Map<String, dynamic> toJson() => {
    'datePJ': datePJ?.toIso8601String(),
    'pieces': pieces.map((k, v) => MapEntry(k, v.toJson())),
  };

  factory EtatRubrique.fromJson(Map<String, dynamic> json) {
    final date = json['datePJ'] == null
        ? null
        : DateTime.tryParse('${json['datePJ']}');
    final pieces = <String, EtatPiece>{};
    final brut = json['pieces'];
    if (brut is Map) {
      brut.forEach((k, v) {
        if (v is Map) {
          pieces['$k'] = EtatPiece.fromJson(v.cast<String, dynamic>());
        }
      });
    }
    return EtatRubrique(datePJ: date, pieces: pieces);
  }
}

class _ChecklistPJScreenState extends ConsumerState<ChecklistPJScreen> {
  final Map<String, EtatRubrique> _etats = {};
  String? _activiteChargee;
  bool _enregistrementEnCours = false;

  String _cle(String activite) => 'checklist_pj.$activite';

  Future<void> _charger(String activite) async {
    if (_activiteChargee == activite) return;
    _activiteChargee = activite;
    _etats.clear();
    try {
      final brut = await ref
          .read(parametresRepositoryProvider)
          .lire(_cle(activite));
      if (brut != null && brut.trim().isNotEmpty) {
        final json = (jsonDecode(brut) as Map).cast<String, dynamic>();
        json.forEach((rubrique, valeur) {
          if (valeur is Map) {
            _etats[rubrique] = EtatRubrique.fromJson(
              valeur.cast<String, dynamic>(),
            );
          }
        });
      }
    } catch (_) {
      // Données illisibles : on repart d'une checklist vierge.
    }
    if (mounted) setState(() {});
  }

  Future<void> _enregistrer() async {
    final activite = _activiteChargee;
    if (activite == null) return;
    setState(() => _enregistrementEnCours = true);
    try {
      await ref
          .read(parametresRepositoryProvider)
          .ecrire(
            _cle(activite),
            jsonEncode(_etats.map((k, v) => MapEntry(k, v.toJson()))),
          );
    } finally {
      if (mounted) setState(() => _enregistrementEnCours = false);
    }
  }

  EtatRubrique _etat(String rubrique) =>
      _etats.putIfAbsent(rubrique, EtatRubrique.new);

  @override
  Widget build(BuildContext context) {
    final activites = ref.watch(activitesProvider);
    final activiteCode = ref.watch(activiteSelectionneeProvider);

    if (activiteCode != null && activiteCode != _activiteChargee) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _charger(activiteCode);
      });
    }

    final corps = Column(
      children: [
        if (!widget.imbrique)
          const EnTetePage(
            titre: 'Pièces justificatives',
            sousTitre:
                'Checklist des pièces requises par rubrique (paramètres)',
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
                    key: ValueKey('checklist-$activiteCode'),
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
              const SizedBox(width: 12),
              if (_activiteChargee != null)
                FilledButton.tonalIcon(
                  onPressed: _enregistrementEnCours ? null : _enregistrer,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Enregistrer la checklist'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: activiteCode == null
              ? const EtatVide(
                  message:
                      'Sélectionnez une activité pour afficher la liste des '
                      'pièces justificatives requises.',
                  icone: Icons.checklist_outlined,
                )
              : _Liste(
                  activiteCode: activiteCode,
                  etats: _etats,
                  etatDe: _etat,
                  onChanger: (fn) {
                    setState(fn);
                    _enregistrer();
                  },
                ),
        ),
      ],
    );
    return widget.imbrique ? corps : Scaffold(body: corps);
  }
}

class _Liste extends ConsumerWidget {
  const _Liste({
    required this.activiteCode,
    required this.etats,
    required this.etatDe,
    required this.onChanger,
  });

  final String activiteCode;
  final Map<String, EtatRubrique> etats;
  final EtatRubrique Function(String rubrique) etatDe;
  final void Function(VoidCallback) onChanger;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regles = ref.watch(reglesParametresProvider).value;
    final activites = ref.watch(activitesProvider).value ?? const <Activite>[];
    Activite? activite;
    for (final a in activites) {
      if (a.code == activiteCode) activite = a;
    }
    final budgets =
        ref.watch(lignesBudgetActiviteProvider(activiteCode)).value ??
        const <LigneBudget>[];
    final tarifs =
        ref.watch(tousTarifsProvider).value ?? const <TarifReferentiel>[];

    if (regles == null || regles.matricePJ.isEmpty) {
      return const EtatVide(
        message:
            'La matrice des pièces justificatives n’est pas disponible.\n'
            'Importez « parametres.xlsx » depuis Paramètres pour la charger.',
        icone: Icons.rule_folder_outlined,
      );
    }

    final rubriquesReferentiel = RubriquesBudget.depuisTarifs(
      tarifs.map((t) => t.rubrique),
    );

    // Regroupement par rubrique : on n'affiche que les rubriques réellement
    // engagées par l'activité (lignes budgétaires) ; à défaut, toutes celles
    // de la matrice.
    final rubriques = <String>[];
    final montants = <String, double>{};
    final lignesParRubrique = <String, List<String>>{};
    for (final l in budgets) {
      final r = RubriquesBudget.resoudre(
        ligneBudgetaire: l.ligneBudgetaire,
        typeBudget: l.typeBudget,
        rubriques: rubriquesReferentiel.isEmpty
            ? regles.rubriques
            : rubriquesReferentiel,
      );
      if (!rubriques.contains(r)) rubriques.add(r);
      montants[r] = (montants[r] ?? 0) + l.montantAlloue;
      lignesParRubrique.putIfAbsent(r, () => <String>[]).add(l.ligneBudgetaire);
    }
    if (rubriques.isEmpty) rubriques.addAll(regles.rubriques);

    // Une rubrique du budget peut ne pas exister dans la matrice des PJ : on
    // la montre quand même pour que l'utilisateur voie l'écart.
    final rubriquesAffichees = <String>[
      for (final r in rubriques)
        regles.rubriques.any(
              (m) =>
                  RubriquesBudget.normaliser(m) ==
                  RubriquesBudget.normaliser(r),
            )
            ? regles.rubriques.firstWhere(
                (m) =>
                    RubriquesBudget.normaliser(m) ==
                    RubriquesBudget.normaliser(r),
              )
            : r,
    ];

    var totalPieces = 0;
    var totalPretes = 0;
    for (final r in rubriquesAffichees) {
      final etat = etats[r];
      for (final p in regles.piecesPour(r)) {
        totalPieces++;
        final e = etat?.pieces[p.libelle];
        if (e != null && e.recue && e.dateConforme) totalPretes++;
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      children: [
        _Avancement(pretes: totalPretes, total: totalPieces),
        const SizedBox(height: 12),
        for (final rubrique in rubriquesAffichees)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _CarteRubrique(
              rubrique: rubrique,
              pieces: regles.piecesPour(rubrique),
              etat: etatDe(rubrique),
              montant: montants[rubrique] ?? 0,
              lignes: lignesParRubrique[rubrique] ?? const [],
              activite: activite,
              onChanger: onChanger,
            ),
          ),
      ],
    );
  }
}

/// Barre d'avancement globale de la checklist.
class _Avancement extends StatelessWidget {
  const _Avancement({required this.pretes, required this.total});
  final int pretes;
  final int total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fraction = total == 0 ? 0.0 : pretes / total;
    final complet = total > 0 && pretes == total;
    final couleur = complet ? vertValide(context) : scheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: couleur.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            complet ? Icons.verified_outlined : Icons.pending_actions_outlined,
            size: 20,
            color: couleur,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$pretes / $total pièce(s) prête(s)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: couleur,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 6,
                    backgroundColor: scheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(couleur),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Une rubrique : ses pièces requises, sa date de PJ et sa part de budget.
class _CarteRubrique extends StatelessWidget {
  const _CarteRubrique({
    required this.rubrique,
    required this.pieces,
    required this.etat,
    required this.montant,
    required this.lignes,
    required this.activite,
    required this.onChanger,
  });

  final String rubrique;
  final List<ReglePJRequise> pieces;
  final EtatRubrique etat;
  final double montant;
  final List<String> lignes;
  final Activite? activite;
  final void Function(VoidCallback) onChanger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    if (pieces.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: ambreAttention(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Rubrique « $rubrique » : aucune pièce définie dans les '
                  'paramètres pour cette rubrique (elle apparaît pourtant dans '
                  'le budget de l’activité).',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final pretes = pieces
        .where((p) => etat.pieces[p.libelle]?.recue == true)
        .length;
    final conformes = pieces
        .where((p) => etat.pieces[p.libelle]?.dateConforme == true)
        .length;
    final obligatoires = pieces.where((p) => p.obligatoire).length;
    final complet = pretes == pieces.length;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
            color: scheme.primaryContainer.withValues(alpha: 0.4),
            child: Row(
              children: [
                Icon(Icons.folder_outlined, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rubrique,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                if (montant > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Text(
                      'Budget : ${formatMontant(montant)}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                _Pastille(
                  texte: '$pretes / ${pieces.length} reçues',
                  couleur: complet ? vertValide(context) : scheme.primary,
                ),
                const SizedBox(width: 6),
                _Pastille(
                  texte: '$conformes / ${pieces.length} dates OK',
                  couleur: conformes == pieces.length
                      ? vertValide(context)
                      : ambreAttention(context),
                ),
              ],
            ),
          ),
          if (lignes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Text(
                'Lignes budgétaires rattachées : ${lignes.toSet().join(', ')}',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
            child: Row(
              children: [
                Text(
                  'Date de la PJ (contrôle automatique des délais)',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    final debut = activite?.dateDebut;
                    final date = await showDatePicker(
                      context: context,
                      initialDate: etat.datePJ ?? debut ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date == null) return;
                    onChanger(() => etat.datePJ = date);
                  },
                  icon: const Icon(Icons.event_outlined, size: 16),
                  label: Text(
                    etat.datePJ == null ? 'Choisir' : formatDate(etat.datePJ),
                  ),
                ),
                if (etat.datePJ != null)
                  IconButton(
                    tooltip: 'Effacer la date',
                    icon: const Icon(Icons.clear, size: 16),
                    onPressed: () => onChanger(() => etat.datePJ = null),
                  ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => onChanger(() {
                    for (final p in pieces) {
                      final evaluation = evaluerPiecePJ(
                        regle: p,
                        datePJ: etat.datePJ,
                        dateDebut: activite?.dateDebut,
                        dateFin: activite?.dateFin,
                      );
                      etat.pieces[p.libelle] = EtatPiece(
                        recue: etat.pieces[p.libelle]?.recue ?? false,
                        dateConforme:
                            evaluation.conformite == ConformitePiece.conforme,
                      );
                    }
                  }),
                  icon: const Icon(Icons.rule_outlined, size: 16),
                  label: const Text('Vérifier les dates selon les règles'),
                ),
              ],
            ),
          ),
          _LigneEntete(obligatoires: obligatoires, total: pieces.length),
          for (final piece in pieces)
            _LignePiece(
              piece: piece,
              evaluation: evaluerPiecePJ(
                regle: piece,
                datePJ: etat.datePJ,
                dateDebut: activite?.dateDebut,
                dateFin: activite?.dateFin,
              ),
              etat: etat.pieces[piece.libelle],
              onRecue: (v) => onChanger(
                () => (etat.pieces[piece.libelle] ??= EtatPiece()).recue = v,
              ),
              onDate: (v) => onChanger(
                () =>
                    (etat.pieces[piece.libelle] ??= EtatPiece()).dateConforme =
                        v,
              ),
            ),
        ],
      ),
    );
  }
}

class _Pastille extends StatelessWidget {
  const _Pastille({required this.texte, required this.couleur});
  final String texte;
  final Color couleur;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: couleur.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      texte,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: couleur,
      ),
    ),
  );
}

class _LigneEntete extends StatelessWidget {
  const _LigneEntete({required this.obligatoires, required this.total});
  final int obligatoires;
  final int total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Row(
        children: [
          const Expanded(
            flex: 5,
            child: Text(
              'Pièce justificative requise',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
          ),
          const Expanded(
            flex: 3,
            child: Text(
              'Règle de date',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            width: 96,
            child: Text(
              'Reçue',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(
            width: 116,
            child: Text(
              'Date conforme',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _LignePiece extends StatelessWidget {
  const _LignePiece({
    required this.piece,
    required this.evaluation,
    required this.etat,
    required this.onRecue,
    required this.onDate,
  });

  final ReglePJRequise piece;
  final EvaluationPiecePJ evaluation;
  final EtatPiece? etat;
  final ValueChanged<bool> onRecue;
  final ValueChanged<bool> onDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final recue = etat?.recue ?? false;
    final dateOk = etat?.dateConforme ?? false;
    final regleDate = piece.regleDate.replaceAll(';', ' · ');
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Icon(
                  piece.obligatoire
                      ? Icons.check_box_outlined
                      : Icons.check_box_outline_blank,
                  size: 15,
                  color: piece.obligatoire
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
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
                ),
                if (!piece.obligatoire)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      'facultative',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              regleDate.isEmpty ? '—' : regleDate,
              style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
            ),
          ),
          SizedBox(
            width: 96,
            child: Center(
              child: _Case(
                valeur: recue,
                libelle: 'PJ reçue',
                couleur: vertValide(context),
                onChanged: onRecue,
              ),
            ),
          ),
          SizedBox(
            width: 116,
            child: Center(
              child: _Case(
                valeur: dateOk,
                libelle: 'Date PJ conforme',
                couleur: dateOk
                    ? vertValide(context)
                    : (evaluation.conformite == ConformitePiece.nonConforme
                          ? rougeAlerte(context)
                          : ambreAttention(context)),
                onChanged: onDate,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Case à cocher compacte (✓ / ✗), utilisable dans un tableau.
class _Case extends StatelessWidget {
  const _Case({
    required this.valeur,
    required this.libelle,
    required this.couleur,
    required this.onChanged,
  });

  final bool valeur;
  final String libelle;
  final Color couleur;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final actif = valeur ? vertValide(context) : couleur;
    return Tooltip(
      message: '$libelle : ${valeur ? 'oui' : 'non'}',
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => onChanged(!valeur),
        child: Container(
          width: 34,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: actif.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: actif.withValues(alpha: 0.55)),
          ),
          child: Icon(
            valeur ? Icons.check : Icons.close,
            size: 16,
            color: actif,
          ),
        ),
      ),
    );
  }
}
