import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../reglages/reglages_affichage.dart';
import 'common.dart';

/// Description d'une colonne du [TableauGestion].
///
/// La largeur de chaque colonne est **calculée à partir du contenu réel**
/// (en-tête + cellules) : rien n'est tronqué tant que l'espace le permet.
class ColonneTableau<T> {
  const ColonneTableau({
    required this.label,
    required this.valeur,
    this.flex = 1,
    this.cellule,
    this.numerique = false,
    this.cleTri,
    this.triable = true,
    this.filtrable = true,
    this.ajusteLargeur = true,
    this.largeurMin,
  });

  /// Libellé affiché dans l'en-tête (et dans les cartes sur petit écran).
  final String label;

  /// Texte brut de la cellule : sert au filtrage, au tri par défaut, au
  /// calcul de la largeur et à l'affichage quand [cellule] n'est pas fourni.
  final String Function(T ligne) valeur;

  /// Poids relatif de la colonne (point de départ, conservé pour compatibilité).
  final int flex;

  /// Rendu personnalisé de la cellule (badge, icône…).
  final Widget Function(BuildContext context, T ligne)? cellule;

  /// Alignement à droite (colonnes de montants / quantités) et colonne
  /// éligible au **total** affiché en bas du tableau.
  final bool numerique;

  /// Clé de tri explicite (`num`, `DateTime`, `bool` ou texte), utile pour les
  /// dates et les nombres. `null` : le texte affiché sert de clé.
  final Object? Function(T ligne)? cleTri;

  final bool triable;
  final bool filtrable;

  /// Conserve la déclaration d'origine ; la largeur est désormais mesurée.
  final bool ajusteLargeur;

  /// Largeur plancher (px) de la colonne, à la place du plancher par défaut
  /// (110 px pour un rendu personnalisé, 72 px sinon).
  ///
  /// Baisser ce plancher permet à une colonne étroite (petite case de date,
  /// case à cocher…) de libérer de la place pour les autres colonnes.
  final double? largeurMin;
}

/// Action disponible sur une ligne (colonne « Actions »).
class ActionTableau<T> {
  const ActionTableau({
    required this.icone,
    required this.infobulle,
    required this.onTap,
    this.couleur,
    this.visible,
  });

  final IconData icone;
  final String infobulle;
  final void Function(T ligne) onTap;
  final Color? couleur;
  final bool Function(T ligne)? visible;
}

/// Répartition des largeurs décidée une fois pour toutes par colonne.
class _Disposition {
  const _Disposition({
    required this.largeurs,
    required this.largeurTotale,
    required this.defilable,
  });

  /// Largeur exacte de chaque colonne de données.
  final List<double> largeurs;

  /// Largeur totale de la zone de tableau (≥ largeur disponible).
  final double largeurTotale;

  /// Vrai quand le contenu dépasse : un défilement horizontal est alors
  /// proposé pour éviter toute troncature.
  final bool defilable;
}

/// Tableau de données complet et accessible.
///
/// * **largeurs calculées** : chaque colonne reçoit exactement l'espace
///   nécessaire pour son en-tête et son contenu → pas de « … » ;
/// * **défilement horizontal** uniquement quand le contenu dépasse vraiment
///   l'écran (les noms longs restent entièrement lisibles) ;
/// * **en-têtes fixes** : ils restent visibles pendant le défilement ;
/// * **filtres en haut, *hors* du tableau** : une barre dédiée au-dessus ;
/// * **tri** en cliquant sur l'en-tête ;
/// * **sélection multiple** : bouton « Sélectionner », cases à cocher,
///   totaux calculés en bas et suppression groupée ;
/// * **pagination** avec bouton « Tout afficher » (aucun découpage) ;
/// * **messages clairs** lorsqu'il n'y a rien à afficher.
class TableauGestion<T> extends StatefulWidget {
  const TableauGestion({
    required this.colonnes,
    required this.lignes,
    required this.cleLigne,
    this.actions = const [],
    this.messageVide = 'Aucune donnée à afficher pour le moment.',
    this.messageAucunResultat =
        'Aucun résultat ne correspond à votre recherche.\n'
        'Modifiez ou effacez les filtres pour voir plus de lignes.',
    this.resume,
    this.taillePage = 25,
    this.filtresVisibles = true,
    this.seuilCartes = 780,
    this.hauteur,
    this.onSupprimer,
    super.key,
  });

  final List<ColonneTableau<T>> colonnes;
  final List<T> lignes;
  final Object Function(T ligne) cleLigne;
  final List<ActionTableau<T>> actions;
  final String messageVide;
  final String messageAucunResultat;

  /// Widget résumé affiché au-dessus du tableau (nombre de lignes, total…).
  final Widget? resume;
  final int taillePage;

  /// Les filtres sont visibles d'emblée (ils restent masquables).
  final bool filtresVisibles;

  /// En dessous de cette largeur, chaque ligne devient une carte lisible.
  final double seuilCartes;

  /// Hauteur imposée du tableau. `null` : le tableau occupe toute la hauteur
  /// disponible (à placer dans un `Expanded`). Utile pour empiler plusieurs
  /// tableaux dans une page défilante.
  final double? hauteur;

  /// Suppression groupée des lignes sélectionnées. Quand elle est fournie,
  /// un bouton « Supprimer la sélection » apparaît sous le tableau.
  final Future<void> Function(List<T> lignes)? onSupprimer;

  @override
  State<TableauGestion<T>> createState() => _TableauGestionState<T>();
}

class _TableauGestionState<T> extends State<TableauGestion<T>> {
  static const double _largeurSelection = 44;
  static final _fmtNombre = NumberFormat('#,##0.##', 'fr_FR');

  final _defilement = ScrollController();
  final _defilementHorizontal = ScrollController();
  final _filtres = <int, String>{};
  final _controleurs = <int, TextEditingController>{};

  /// Cache des mesures de texte (évite de re-mesurer à chaque rebuild).
  final _mesures = <String, double>{};

  int? _triColonne;
  bool _triAscendant = true;
  int _page = 0;
  late int _taillePage = widget.taillePage;
  late bool _afficherFiltres = widget.filtresVisibles;
  bool _filtresInitialises = false;
  bool? _dernierReglageFiltres;
  bool _enHaut = true;
  bool _enBas = false;
  bool _aGauche = true;
  bool _aDroite = true;
  List<double>? _largeurs;
  double _echelleMesuree = 1.0;

  /// Mode sélection (cases à cocher visibles).
  bool _modeSelection = false;
  final Set<Object> _selection = {};

  /// Affichage sans pagination (toutes les lignes d'un coup).
  bool _tout = false;

  /// Index de la ligne survolée par la souris (repère visuel sur bureau).
  int? _indexSurvole;

  bool _defilable = false;

  @override
  void initState() {
    super.initState();
    _defilement.addListener(_surDefilement);
    _defilementHorizontal.addListener(_surDefilementHorizontal);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Les filtres sont ouverts/fermés d'après le réglage global, appliqué
    // immédiatement à tous les tableaux ouverts.
    final ouverts = ReglagesAffichage.of(context).filtresOuverts;
    if (!_filtresInitialises) {
      _filtresInitialises = true;
      _afficherFiltres = widget.filtresVisibles && ouverts;
    } else if (ouverts != _dernierReglageFiltres) {
      _afficherFiltres = widget.filtresVisibles && ouverts;
    }
    _dernierReglageFiltres = ouverts;
  }

  @override
  void didUpdateWidget(covariant TableauGestion<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Les colonnes sont dimensionnées d'après le contenu : on recalcule
    // quand les données ou les colonnes changent.
    if (oldWidget.lignes != widget.lignes ||
        oldWidget.colonnes != widget.colonnes) {
      _largeurs = null;
      _mesures.clear();
      if (_selection.isNotEmpty) {
        final presents = <Object>{
          for (final l in widget.lignes) widget.cleLigne(l),
        };
        _selection.removeWhere((cle) => !presents.contains(cle));
      }
    }
  }

  @override
  void dispose() {
    _defilement
      ..removeListener(_surDefilement)
      ..dispose();
    _defilementHorizontal
      ..removeListener(_surDefilementHorizontal)
      ..dispose();
    for (final c in _controleurs.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _surDefilement() {
    if (!_defilement.hasClients) return;
    final position = _defilement.position;
    final enHaut = position.pixels <= 2;
    final enBas = position.pixels >= position.maxScrollExtent - 2;
    if (enHaut != _enHaut || enBas != _enBas) {
      setState(() {
        _enHaut = enHaut;
        _enBas = enBas;
      });
    }
  }

  void _surDefilementHorizontal() {
    if (!_defilementHorizontal.hasClients) return;
    final position = _defilementHorizontal.position;
    final aGauche = position.pixels <= 2;
    final aDroite = position.pixels >= position.maxScrollExtent - 2;
    if (aGauche != _aGauche || aDroite != _aDroite) {
      setState(() {
        _aGauche = aGauche;
        _aDroite = aDroite;
      });
    }
  }

  TextEditingController _controleur(int index) => _controleurs.putIfAbsent(
    index,
    () => TextEditingController(text: _filtres[index] ?? '')
      ..addListener(() {
        final valeur = _controleurs[index]!.text;
        if ((_filtres[index] ?? '') == valeur) return;
        setState(() {
          if (valeur.trim().isEmpty) {
            _filtres.remove(index);
          } else {
            _filtres[index] = valeur;
          }
          _page = 0;
        });
      }),
  );

  bool get _aDesFiltres => _filtres.isNotEmpty;

  // --- Mesure des largeurs ------------------------------------------------

  /// Largeur nécessaire pour afficher [texte] sans aucune troncature,
  /// à l'échelle de police courante.
  double _mesurer(String texte, TextStyle style, TextScaler scaler) {
    if (texte.isEmpty) return 0;
    final cle =
        '${style.fontSize}|${style.fontWeight?.value}|${style.letterSpacing}'
        '|${scaler.scale(1.0)}|$texte';
    final connu = _mesures[cle];
    if (connu != null) return connu;
    final peintre = TextPainter(
      text: TextSpan(text: texte, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final largeur = peintre.width;
    peintre.dispose();
    if (_mesures.length > 4000) _mesures.clear();
    _mesures[cle] = largeur;
    return largeur;
  }

  /// Largeur *souhaitée* (px) de chaque colonne, calculée à l'avance :
  /// en-tête + valeur la plus large + marges internes.
  List<double> _largeursSouhaitees(TextScaler scaler) {
    final echelle = scaler.scale(1.0);
    if (_largeurs == null || echelle != _echelleMesuree) {
      _echelleMesuree = echelle;
      _mesures.clear();
      _largeurs = _calculerLargeurs(scaler);
    }
    return _largeurs!;
  }

  /// Largeur exacte nécessaire à chaque colonne : la mesure porte sur **toutes**
  /// les valeurs affichées (mise en cache), afin qu'aucun mot, nombre ni date
  /// ne soit coupé, même lorsque la valeur la plus large est aussi la plus
  /// courte en caractères (chiffres larges, majuscules…).
  List<double> _calculerLargeurs(TextScaler scaler) {
    const styleEntete = TextStyle(fontSize: 12, fontWeight: FontWeight.w700);
    const styleCellule = TextStyle(fontSize: 13);
    const marge = 12.0;
    final resultat = <double>[];
    for (final colonne in widget.colonnes) {
      var largeur = _mesurer(colonne.label, styleEntete, scaler) + marge;
      var compteur = 0;
      for (final ligne in widget.lignes) {
        final texte = colonne.valeur(ligne).trim();
        if (texte.isNotEmpty) {
          final mesuree = _mesurer(texte, styleCellule, scaler) + marge;
          if (mesuree > largeur) largeur = mesuree;
        }
        if (++compteur >= 3000) break;
      }
      // Un rendu personnalisé (badge, bouton…) peut être plus large que son
      // texte : plancher plus généreux, sauf plancher déclaré `largeurMin`.
      final plancher =
          colonne.largeurMin ?? (colonne.cellule != null ? 150.0 : 58.0);
      resultat.add(math.max(largeur, plancher));
    }
    return resultat;
  }

  double get _largeurActions => widget.actions.length * 34 + 6;

  double get _largeurMarge =>
      (_modeSelection ? _largeurSelection : 0.0) + _largeurActions;

  /// Répartit l'espace disponible : chaque colonne reçoit au moins la
  /// largeur dont elle a besoin. Si le total dépasse la largeur de l'écran :
  ///  * défilement horizontal **autorisé** → les colonnes gardent leur
  ///    largeur exacte, rien n'est coupé ;
  ///  * défilement **interdit** (réglage utilisateur) → les colonnes sont
  ///    comprimées proportionnellement.
  _Disposition _disposer(
    double dispo,
    ReglagesAffichage reglages,
    TextScaler scaler,
  ) {
    final souhait = _largeursSouhaitees(scaler);
    double somme(List<double> liste) => liste.fold(0.0, (s, v) => s + v);
    final besoin = somme(souhait);
    final dispoColonnes = math.max(dispo - _largeurMarge, 1.0);

    if (!dispo.isFinite) {
      return _Disposition(
        largeurs: souhait,
        largeurTotale: besoin + _largeurMarge,
        defilable: false,
      );
    }

    if (besoin + _largeurMarge <= dispo) {
      final facteur = besoin <= 0 ? 1.0 : dispoColonnes / besoin;
      return _Disposition(
        largeurs: [for (final v in souhait) v * facteur],
        largeurTotale: dispo,
        defilable: false,
      );
    }

    if (!reglages.defilementHorizontal) {
      // Défilement horizontal désactivé dans les réglages : on resserre les
      // colonnes pour tenir dans l'écran.
      final facteur = besoin <= 0 ? 1.0 : dispoColonnes / besoin;
      return _Disposition(
        largeurs: [for (final v in souhait) v * facteur],
        largeurTotale: dispo,
        defilable: false,
      );
    }

    final bornees = [for (final v in souhait) math.min(v, dispo)];
    return _Disposition(
      largeurs: bornees,
      largeurTotale: somme(bornees) + _largeurMarge,
      defilable: true,
    );
  }

  // --- Tri, filtres, pagination ------------------------------------------

  /// Applique les filtres par colonne puis le tri.
  List<T> get _lignesAffichees {
    var liste = widget.lignes;
    if (_aDesFiltres) {
      liste = liste.where((ligne) {
        for (final entree in _filtres.entries) {
          final colonne = widget.colonnes[entree.key];
          final texte = colonne.valeur(ligne).toLowerCase();
          final recherche = entree.value.trim().toLowerCase();
          if (!texte.contains(recherche)) return false;
        }
        return true;
      }).toList();
    }
    final colonneTri = _triColonne;
    if (colonneTri != null) {
      final colonne = widget.colonnes[colonneTri];
      final triees = [...liste];
      triees.sort((a, b) {
        final comparaison = _comparer(colonne, a, b);
        return _triAscendant ? comparaison : -comparaison;
      });
      liste = triees;
    }
    return liste;
  }

  int _comparer(ColonneTableau<T> colonne, T a, T b) {
    final cleA = colonne.cleTri?.call(a);
    final cleB = colonne.cleTri?.call(b);
    if (colonne.cleTri != null) {
      // Les valeurs absentes sont regroupées en fin de tri.
      if (cleA == null && cleB == null) return 0;
      if (cleA == null) return 1;
      if (cleB == null) return -1;
      if (cleA is num && cleB is num) return cleA.compareTo(cleB);
      if (cleA is DateTime && cleB is DateTime) return cleA.compareTo(cleB);
      return cleA.toString().toLowerCase().compareTo(
        cleB.toString().toLowerCase(),
      );
    }
    final texteA = colonne.valeur(a).trim();
    final texteB = colonne.valeur(b).trim();
    final nombreA = _nombre(texteA);
    final nombreB = _nombre(texteB);
    if (nombreA != null && nombreB != null) return nombreA.compareTo(nombreB);
    return texteA.toLowerCase().compareTo(texteB.toLowerCase());
  }

  static double? _nombre(String texte) {
    if (texte.isEmpty || texte == '—') return null;
    final nettoye = texte
        .replaceAll(RegExp(r'[^0-9,.\-]'), '')
        .replaceAll(',', '.');
    return double.tryParse(nettoye);
  }

  void _basculerTri(int index) {
    setState(() {
      if (_triColonne != index) {
        _triColonne = index;
        _triAscendant = true;
      } else if (_triAscendant) {
        _triAscendant = false;
      } else {
        _triColonne = null;
      }
      _page = 0;
    });
    _remonter();
  }

  void _reinitialiserFiltres() {
    setState(() {
      for (final c in _controleurs.values) {
        c.clear();
      }
      _filtres.clear();
      _triColonne = null;
      _page = 0;
    });
    _remonter();
  }

  void _remonter() {
    if (_defilement.hasClients) _defilement.jumpTo(0);
    if (_defilementHorizontal.hasClients) _defilementHorizontal.jumpTo(0);
  }

  void _allerA(int page) {
    setState(() {
      _tout = false;
      _page = page;
    });
    _remonter();
  }

  // --- Sélection ---------------------------------------------------------

  List<T> _lignesSelectionnees(List<T> filtrees) => [
    for (final ligne in filtrees)
      if (_selection.contains(widget.cleLigne(ligne))) ligne,
  ];

  void _basculerSelection(T ligne) {
    final cle = widget.cleLigne(ligne);
    setState(() {
      if (!_selection.remove(cle)) _selection.add(cle);
    });
  }

  void _toutSelectionner(List<T> filtrees, bool cocher) {
    setState(() {
      if (cocher) {
        for (final ligne in filtrees) {
          _selection.add(widget.cleLigne(ligne));
        }
      } else {
        for (final ligne in filtrees) {
          _selection.remove(widget.cleLigne(ligne));
        }
      }
    });
  }

  /// Totaux des colonnes numériques : sur la sélection si elle est non vide,
  /// sinon sur toutes les lignes affichées (filtres compris).
  List<({String label, double somme})> _totaux(List<T> lignes) {
    if (lignes.isEmpty) return const [];
    final resultat = <({String label, double somme})>[];
    for (var i = 0; i < widget.colonnes.length; i++) {
      final colonne = widget.colonnes[i];
      if (!colonne.numerique) continue;
      var somme = 0.0;
      var trouve = false;
      for (final ligne in lignes) {
        final valeur = _nombre(colonne.valeur(ligne).trim());
        if (valeur == null) continue;
        somme += valeur;
        trouve = true;
      }
      if (trouve) resultat.add((label: colonne.label, somme: somme));
    }
    return resultat;
  }

  Future<void> _supprimerSelection(List<T> selectionnees) async {
    final onSupprimer = widget.onSupprimer;
    if (onSupprimer == null || selectionnees.isEmpty) return;
    final ok = await confirmer(
      context,
      titre: 'Supprimer la sélection',
      message:
          'Supprimer définitivement ${selectionnees.length} ligne(s) ? '
          'Cette action est irréversible.',
      confirmerLabel: 'Supprimer',
    );
    if (!ok || !mounted) return;
    await onSupprimer(selectionnees);
    if (!mounted) return;
    setState(_selection.clear);
    notifier(context, '${selectionnees.length} ligne(s) supprimée(s).');
  }

  // --- Construction ------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final tableau = _corps(context);
    if (widget.hauteur == null) return tableau;
    return SizedBox(height: widget.hauteur, child: tableau);
  }

  Widget _corps(BuildContext context) {
    final filtrees = _lignesAffichees;
    final total = filtrees.length;
    final pages = total == 0 ? 1 : (total / _taillePage).ceil();
    final pageCourante = _tout ? 0 : _page.clamp(0, pages - 1);
    final debut = pageCourante * _taillePage;
    final lignesPage = _tout
        ? filtrees
        : filtrees.skip(debut).take(_taillePage).toList();
    final aDesLignes = widget.lignes.isNotEmpty && total > 0;

    return LayoutBuilder(
      builder: (context, contraintes) {
        final modeCartes = contraintes.maxWidth < widget.seuilCartes;
        final reglages = ReglagesAffichage.of(context);
        final scaler =
            MediaQuery.maybeTextScalerOf(context) ?? TextScaler.noScaling;
        final disposition = modeCartes
            ? null
            : _disposer(contraintes.maxWidth, reglages, scaler);
        _defilable = disposition?.defilable ?? false;

        // Hauteur auto : le tableau s'arrête *exactement* à la dernière
        // ligne (aucun vide en dessous) et grandit avec le contenu. Il ne
        // remplit l'espace disponible que s'il déborde vraiment ou s'il n'y
        // a rien à afficher — auquel cas le défilement interne reprend.
        final estimation = _hauteurEstimee(
          lignes: lignesPage.length,
          modeCartes: modeCartes,
          filtres: _afficherFiltres && widget.lignes.isNotEmpty,
          aDesLignes: aDesLignes,
        );
        final modeRemplissage =
            contraintes.maxHeight.isFinite &&
            (modeCartes ||
                widget.lignes.isEmpty ||
                estimation + 48 > contraintes.maxHeight);
        final auto = !modeRemplissage;

        Widget contenu = widget.lignes.isEmpty
            ? EtatVide(
                message: widget.messageVide,
                icone: Icons.table_rows_outlined,
              )
            : total == 0
            ? EtatVide(
                message: widget.messageAucunResultat,
                icone: Icons.search_off,
                action: OutlinedButton.icon(
                  onPressed: _reinitialiserFiltres,
                  icon: const Icon(Icons.filter_alt_off_outlined),
                  label: const Text('Effacer les filtres'),
                ),
              )
            : modeCartes
            ? DecoratedBox(
                decoration: _cadre(context),
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 4),
                  shrinkWrap: auto,
                  physics: auto ? const NeverScrollableScrollPhysics() : null,
                  children: [
                    for (var i = 0; i < lignesPage.length; i++)
                      _carte(context, lignesPage[i], i),
                  ],
                ),
              )
            : _tableau(context, disposition!, lignesPage, filtrees, auto: auto);

        if (!modeCartes &&
            widget.lignes.isNotEmpty &&
            total > 0 &&
            disposition!.defilable) {
          contenu = SizedBox(
            width: disposition.largeurTotale,
            child: Scrollbar(
              controller: _defilementHorizontal,
              thumbVisibility: false,
              interactive: true,
              child: SingleChildScrollView(
                controller: _defilementHorizontal,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: disposition.largeurTotale,
                  child: contenu,
                ),
              ),
            ),
          );
        }

        return Column(
          mainAxisSize: modeRemplissage ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: contraintes.maxWidth.isFinite
              ? CrossAxisAlignment.stretch
              : CrossAxisAlignment.start,
          children: [
            _barreOutils(total),
            const SizedBox(height: 8),
            if (modeRemplissage) Expanded(child: contenu) else contenu,
            // Pied (sélection + pagination) : *en dehors* du tableau, en bas.
            if (aDesLignes) ...[
              if (_modeSelection) ...[
                const SizedBox(height: 6),
                _barreSelection(context, filtrees),
              ],
              const SizedBox(height: 6),
              _pied(context, total, pages, pageCourante, lignesPage),
            ],
          ],
        );
      },
    );
  }

  BoxDecoration _cadre(BuildContext context) => BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
  );

  /// Estimation (volontairement pessimiste) de la hauteur du tableau :
  /// elle décide s'il peut se limiter à la hauteur de son contenu ou s'il
  /// doit remplir l'espace disponible (défilement interne).
  double _hauteurEstimee({
    required int lignes,
    required bool modeCartes,
    required bool filtres,
    required bool aDesLignes,
  }) {
    // Barre d'outils + écart.
    var hauteur = 48.0 + 8;
    if (modeCartes) {
      // Fiches : hauteur très variable, estimation volontairement large.
      hauteur += lignes * 140;
    } else {
      if (filtres) hauteur += 56 + 6;
      hauteur += 38 /* en-tête */ + lignes * 38 + 2;
    }
    if (aDesLignes) {
      hauteur += 6 + 44; // pied (pagination)
      if (_modeSelection) hauteur += 6 + 46; // barre de sélection
    }
    return hauteur;
  }

  /// Zone de tableau (filtres + en-tête + lignes), déjà dimensionnée.
  Widget _tableau(
    BuildContext context,
    _Disposition disposition,
    List<T> lignesPage,
    List<T> filtrees, {
    required bool auto,
  }) {
    final cadre = DecoratedBox(
      decoration: _cadre(context),
      child: Column(
        mainAxisSize: auto ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-têtes statiques : hors de la zone défilante.
          _entete(context, disposition),
          if (auto)
            _lignesTableau(context, lignesPage, disposition, auto: true)
          else
            Expanded(
              child: _lignesTableau(
                context,
                lignesPage,
                disposition,
                auto: false,
              ),
            ),
        ],
      ),
    );
    return Column(
      mainAxisSize: auto ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_afficherFiltres && widget.lignes.isNotEmpty) ...[
          _barreFiltres(context, disposition),
          const SizedBox(height: 8),
        ],
        if (auto) cadre else Expanded(child: cadre),
      ],
    );
  }

  /// Les lignes du tableau : défilantes quand le tableau occupe l'espace
  /// disponible, dimensionnées au contenu (hauteur auto) sinon.
  Widget _lignesTableau(
    BuildContext context,
    List<T> lignesPage,
    _Disposition disposition, {
    required bool auto,
  }) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      child: ListView.builder(
        controller: _defilement,
        primary: false,
        shrinkWrap: auto,
        physics: auto ? const NeverScrollableScrollPhysics() : null,
        // Pas d'`itemExtent` : la hauteur de chaque ligne s'adapte à son
        // contenu (une cellule sur deux lignes ne peut donc pas déborder),
        // tout en restant compacte grâce au plancher de [_ligne].
        padding: const EdgeInsets.only(bottom: 2),
        itemCount: lignesPage.length,
        itemBuilder: (context, index) {
          final ligne = lignesPage[index];
          final cle = widget.cleLigne(ligne);
          final selectionne = _selection.contains(cle);
          final survole = _indexSurvole == index;
          final scheme = Theme.of(context).colorScheme;
          final Color fond;
          if (selectionne) {
            fond = scheme.primary.withValues(alpha: 0.12);
          } else if (survole) {
            // Survol discret : la ligne se détache sans masquer
            // les valeurs (confort de lecture au bureau).
            fond = scheme.primary.withValues(alpha: 0.055);
          } else if (index.isEven) {
            fond = Colors.transparent;
          } else {
            fond = scheme.surfaceContainerHighest.withValues(alpha: 0.28);
          }
          return MouseRegion(
            onEnter: (_) {
              if (_indexSurvole != index) {
                setState(() => _indexSurvole = index);
              }
            },
            onExit: (_) {
              if (_indexSurvole == index) {
                setState(() => _indexSurvole = null);
              }
            },
            child: Container(
              key: ValueKey(cle),
              color: fond,
              child: _ligne(context, ligne, disposition),
            ),
          );
        },
      ),
    );
  }

  // --- Barre d'outils -----------------------------------------------------

  Widget _barreOutils(int total) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (widget.resume != null) widget.resume!,
        Text(
          total == widget.lignes.length
              ? '${widget.lignes.length} ligne(s)'
              : '$total sur ${widget.lignes.length} ligne(s)',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton.icon(
          onPressed: widget.lignes.isEmpty
              ? null
              : () => setState(() {
                  _modeSelection = !_modeSelection;
                  if (!_modeSelection) _selection.clear();
                }),
          icon: Icon(_modeSelection ? Icons.close : Icons.checklist, size: 16),
          label: Text(
            _modeSelection ? 'Quitter la sélection' : 'Sélectionner',
            style: const TextStyle(fontSize: 12.5),
          ),
          style: TextButton.styleFrom(
            backgroundColor: _modeSelection
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            textStyle: const TextStyle(fontSize: 12.5),
          ),
        ),
        if (_aDesFiltres || _triColonne != null)
          TextButton.icon(
            onPressed: _reinitialiserFiltres,
            icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
            label: const Text('Effacer filtres et tri'),
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 12.5),
            ),
          ),
        TextButton.icon(
          onPressed: () => setState(() => _afficherFiltres = !_afficherFiltres),
          icon: Icon(
            _afficherFiltres ? Icons.filter_alt : Icons.filter_alt_outlined,
            size: 16,
          ),
          label: Text(
            _afficherFiltres ? 'Masquer les filtres' : 'Filtrer',
            style: const TextStyle(fontSize: 12.5),
          ),
        ),
      ],
    );
  }

  // --- En-tête et filtres -------------------------------------------------

  Widget _entete(BuildContext context, _Disposition d) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.8),
          ),
        ),
      ),
      height: 38,
      child: Row(
        children: [
          if (_modeSelection)
            SizedBox(
              width: _largeurSelection,
              child: _caseToutSelectionner(context, _lignesAffichees),
            ),
          for (var i = 0; i < widget.colonnes.length; i++)
            SizedBox(width: d.largeurs[i], child: _enteteColonne(context, i)),
          if (widget.actions.isNotEmpty)
            SizedBox(
              width: _largeurActions,
              child: Text(
                'Actions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _caseToutSelectionner(BuildContext context, List<T> filtrees) {
    final selectionnees = _lignesSelectionnees(filtrees);
    final tous = filtrees.isNotEmpty && selectionnees.length == filtrees.length;
    final aucun = selectionnees.isEmpty;
    return Align(
      alignment: Alignment.centerLeft,
      child: Tooltip(
        message: tous
            ? 'Tout désélectionner'
            : 'Sélectionner toutes les lignes affichées',
        child: Checkbox(
          tristate: true,
          visualDensity: VisualDensity.compact,
          value: tous ? true : (aucun ? false : null),
          onChanged: (v) => _toutSelectionner(filtrees, v ?? false),
        ),
      ),
    );
  }

  Widget _enteteColonne(BuildContext context, int index) {
    final colonne = widget.colonnes[index];
    final scheme = Theme.of(context).colorScheme;
    final actif = _triColonne == index;
    final contenu = Row(
      mainAxisAlignment: colonne.numerique
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            colonne.label,
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: actif ? scheme.primary : scheme.onSurface,
            ),
          ),
        ),
        // Aucun chevron ni flèche : le tri actif se signale uniquement par
        // la couleur de l'en-tête (les « ^ / v » encombraient la ligne et
        // étaient jugés inesthétiques). Le sens du tri reste indiqué dans
        // l'infobulle de l'en-tête.
      ],
    );
    final alignement = Align(
      alignment: colonne.numerique
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: contenu,
    );
    if (!colonne.triable) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: alignement,
      );
    }
    return InkWell(
      onTap: () => _basculerTri(index),
      child: Tooltip(
        message:
            'Trier par ${colonne.label.toLowerCase()}'
            '${actif ? (_triAscendant ? ' (décroissant)' : ' (aucun)') : ' (croissant)'}',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
          child: alignement,
        ),
      ),
    );
  }

  /// Barre de filtres, placée **au-dessus** du tableau et alignée sur les
  /// colonnes grâce aux mêmes largeurs calculées.
  Widget _barreFiltres(BuildContext context, _Disposition d) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: d.largeurTotale,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          if (_modeSelection) const SizedBox(width: _largeurSelection),
          for (var i = 0; i < widget.colonnes.length; i++)
            SizedBox(
              width: d.largeurs[i],
              child: Padding(
                padding: const EdgeInsets.only(left: 6, right: 6),
                child: widget.colonnes[i].filtrable
                    ? _filtreColonne(context, i)
                    : const SizedBox.shrink(),
              ),
            ),
          if (widget.actions.isNotEmpty) SizedBox(width: _largeurActions),
        ],
      ),
    );
  }

  Widget _filtreColonne(BuildContext context, int index) {
    final colonne = widget.colonnes[index];
    final controleur = _controleur(index);
    final valeurs = <String>{
      for (final l in widget.lignes)
        if (colonne.valeur(l).trim().isNotEmpty &&
            colonne.valeur(l).trim().length <= 40)
          colonne.valeur(l).trim(),
    }.toList()..sort();
    final proposeListe = valeurs.isNotEmpty && valeurs.length <= 25;
    return TextField(
      controller: controleur,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Filtrer…',
        hintStyle: const TextStyle(fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        suffixIconConstraints: const BoxConstraints(minWidth: 26),
        suffixIcon: proposeListe
            ? PopupMenuButton<String>(
                tooltip: 'Choisir une valeur',
                padding: EdgeInsets.zero,
                iconSize: 18,
                icon: const Icon(Icons.arrow_drop_down),
                onSelected: (v) {
                  controleur.text = v;
                  controleur.selection = TextSelection.collapsed(
                    offset: v.length,
                  );
                },
                itemBuilder: (_) => [
                  for (final v in valeurs)
                    PopupMenuItem(
                      value: v,
                      height: 38,
                      child: Text(
                        v,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                ],
              )
            : null,
      ),
    );
  }

  // --- Lignes -------------------------------------------------------------

  Widget _ligne(BuildContext context, T ligne, _Disposition d) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 36),
        child: Row(
          children: [
            if (_modeSelection)
              SizedBox(
                width: _largeurSelection,
                child: Center(
                  child: Checkbox(
                    visualDensity: VisualDensity.compact,
                    value: _selection.contains(widget.cleLigne(ligne)),
                    onChanged: (_) => _basculerSelection(ligne),
                  ),
                ),
              ),
            for (var i = 0; i < widget.colonnes.length; i++)
              SizedBox(
                width: d.largeurs[i],
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 4,
                  ),
                  child: Align(
                    alignment: widget.colonnes[i].numerique
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: _contenuCellule(context, widget.colonnes[i], ligne),
                  ),
                ),
              ),
            if (widget.actions.isNotEmpty)
              SizedBox(
                width: _largeurActions,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final action in widget.actions)
                      if (action.visible?.call(ligne) ?? true)
                        SizedBox(
                          width: 34,
                          height: 34,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 18,
                            tooltip: action.infobulle,
                            color: action.couleur,
                            icon: Icon(action.icone),
                            onPressed: () => action.onTap(ligne),
                          ),
                        ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _contenuCellule(
    BuildContext context,
    ColonneTableau<T> colonne,
    T ligne,
  ) {
    final personnalise = colonne.cellule?.call(context, ligne);
    if (personnalise != null) {
      return Align(
        alignment: colonne.numerique
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: personnalise,
      );
    }
    final texte = colonne.valeur(ligne);
    if (texte.isEmpty) {
      return Text(
        '—',
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }
    return Tooltip(
      message: texte,
      waitDuration: const Duration(milliseconds: 700),
      child: Text(
        texte,
        maxLines: 1,
        softWrap: false,
        // Les largeurs sont mesurées sur le contenu réel : le « … » ne peut
        // apparaître que si l'utilisateur a explicitement désactivé le
        // défilement horizontal dans les paramètres.
        overflow: TextOverflow.ellipsis,
        textAlign: colonne.numerique ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          fontSize: 13,
          fontWeight: colonne.numerique ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  /// Version « cartes » : sur un écran étroit, chaque ligne devient une fiche
  /// lisible (aucun glissement horizontal, aucune colonne tronquée).
  Widget _carte(BuildContext context, T ligne, int index) {
    final scheme = Theme.of(context).colorScheme;
    final pertinentes = [
      for (var i = 0; i < widget.colonnes.length; i++)
        if (widget.colonnes[i].valeur(ligne).trim().isNotEmpty ||
            widget.colonnes[i].cellule != null)
          i,
    ];
    final titre = pertinentes.isEmpty
        ? 'Ligne ${index + 1}'
        : widget.colonnes[pertinentes.first].valeur(ligne);
    return Card(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_modeSelection)
                  Checkbox(
                    visualDensity: VisualDensity.compact,
                    value: _selection.contains(widget.cleLigne(ligne)),
                    onChanged: (_) => _basculerSelection(ligne),
                  ),
                Expanded(
                  child: Text(
                    titre.isEmpty ? 'Ligne ${index + 1}' : titre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                for (final action in widget.actions)
                  if (action.visible?.call(ligne) ?? true)
                    IconButton(
                      iconSize: 18,
                      tooltip: action.infobulle,
                      color: action.couleur,
                      icon: Icon(action.icone),
                      onPressed: () => action.onTap(ligne),
                    ),
              ],
            ),
            const SizedBox(height: 4),
            for (final i in pertinentes.skip(1))
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(
                        widget.colonnes[i].label,
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _contenuCellule(
                        context,
                        widget.colonnes[i],
                        ligne,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- Barre de sélection (totaux + suppression) -------------------------

  Widget _barreSelection(BuildContext context, List<T> filtrees) {
    final scheme = Theme.of(context).colorScheme;
    final selectionnees = _lignesSelectionnees(filtrees);
    final base = selectionnees.isNotEmpty ? selectionnees : filtrees;
    final totaux = _totaux(base);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_box_outlined, size: 16, color: scheme.primary),
              const SizedBox(width: 6),
              Text(
                selectionnees.isEmpty
                    ? 'Aucune ligne sélectionnée — total affiché sur les '
                          '${filtrees.length} ligne(s) affichée(s)'
                    : '${selectionnees.length} ligne(s) sélectionnée(s)',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              if (_selection.isNotEmpty) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => setState(_selection.clear),
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: const Text('Tout désélectionner'),
                ),
              ],
              if (widget.onSupprimer != null && selectionnees.isNotEmpty) ...[
                const SizedBox(width: 4),
                FilledButton.icon(
                  onPressed: () => _supprimerSelection(selectionnees),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: Text(
                    'Supprimer (${selectionnees.length})',
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  ),
                ),
              ],
            ],
          ),
          if (totaux.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final total in totaux) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Text(
                      '${total.label} : ${_fmtNombre.format(total.somme)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
        ],
      ),
    );
  }

  // --- Défilement ---------------------------------------------------------

  /// Petits boutons haut / bas (et gauche / droite quand le tableau défile).
  Widget _boutonsDefilement() {
    final scheme = Theme.of(context).colorScheme;
    final vertical = _defilement.hasClients
        ? _defilement.position.maxScrollExtent > 4
        : widget.lignes.length > _taillePage;
    final horizontal = _defilable;
    if (!vertical && !horizontal) return const SizedBox.shrink();

    Widget bouton(
      IconData icone,
      bool actif,
      String infobulle,
      VoidCallback onTap,
    ) {
      return Tooltip(
        message: infobulle,
        child: Material(
          elevation: actif ? 1 : 0,
          borderRadius: BorderRadius.circular(7),
          color: scheme.surfaceContainerHighest.withValues(
            alpha: actif ? 0.95 : 0.5,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(7),
            onTap: actif ? onTap : null,
            child: SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                icone,
                size: 16,
                color: actif ? scheme.primary : scheme.outline,
              ),
            ),
          ),
        ),
      );
    }

    void allerHaut() => _defilement.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    void allerBas() => _defilement.animateTo(
      _defilement.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    void gauche() => _defilementHorizontal.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    void droite() => _defilementHorizontal.animateTo(
      _defilementHorizontal.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (vertical) ...[
          bouton(
            Icons.keyboard_arrow_up,
            !_enHaut,
            'Revenir en haut',
            allerHaut,
          ),
          const SizedBox(width: 4),
          bouton(
            Icons.keyboard_arrow_down,
            !_enBas,
            'Aller à la fin',
            allerBas,
          ),
        ],
        if (horizontal) ...[
          if (vertical) const SizedBox(width: 8),
          bouton(
            Icons.keyboard_arrow_left,
            !_aGauche,
            'Faire défiler vers la gauche',
            gauche,
          ),
          const SizedBox(width: 4),
          bouton(
            Icons.keyboard_arrow_right,
            !_aDroite,
            'Faire défiler vers la droite',
            droite,
          ),
        ],
      ],
    );
  }

  // --- Pagination ---------------------------------------------------------

  Widget _pied(
    BuildContext context,
    int total,
    int pages,
    int pageCourante,
    List<T> lignesPage,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final bornes = [
      for (var i = 0; i < pages; i++)
        if (i == 0 ||
            i == pages - 1 ||
            (i >= pageCourante - 1 && i <= pageCourante + 1))
          i,
    ];
    final puces = <int?>[];
    for (var i = 0; i < bornes.length; i++) {
      if (i > 0 && bornes[i] - bornes[i - 1] > 1) puces.add(null);
      puces.add(bornes[i]);
    }
    final debut = total == 0 ? 0 : pageCourante * _taillePage + 1;
    final fin = debut == 0 ? 0 : debut + lignesPage.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 2),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Bas-gauche : petits boutons de défilement, hors du tableau.
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _boutonsDefilement(),
              const SizedBox(width: 10),
              Text(
                _tout
                    ? 'Toutes les lignes : $total'
                    : 'Lignes $debut à $fin sur $total',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_tout)
                Text(
                  'Affichage complet, sans pagination',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: scheme.onSurfaceVariant,
                  ),
                )
              else ...[
                _carre(
                  icone: Icons.first_page,
                  infobulle: 'Première page',
                  actif: pageCourante > 0,
                  onTap: () => _allerA(0),
                ),
                const SizedBox(width: 4),
                _carre(
                  icone: Icons.chevron_left,
                  infobulle: 'Page précédente',
                  actif: pageCourante > 0,
                  onTap: () => _allerA(pageCourante - 1),
                ),
                const SizedBox(width: 6),
                for (final puce in puces) ...[
                  if (puce == null)
                    const SizedBox(
                      width: 22,
                      child: Center(
                        child: Text('…', style: TextStyle(fontSize: 13)),
                      ),
                    )
                  else
                    _carre(
                      texte: '${puce + 1}',
                      infobulle: 'Page ${puce + 1}',
                      actif: true,
                      selectionne: puce == pageCourante,
                      onTap: () => _allerA(puce),
                    ),
                  const SizedBox(width: 4),
                ],
                const SizedBox(width: 2),
                _carre(
                  icone: Icons.chevron_right,
                  infobulle: 'Page suivante',
                  actif: pageCourante < pages - 1,
                  onTap: () => _allerA(pageCourante + 1),
                ),
                const SizedBox(width: 4),
                _carre(
                  icone: Icons.last_page,
                  infobulle: 'Dernière page',
                  actif: pageCourante < pages - 1,
                  onTap: () => _allerA(pages - 1),
                ),
              ],
              const SizedBox(width: 12),
              _boutonToutAfficher(),
              const SizedBox(width: 8),
              _selecteurTaille(),
            ],
          ),
        ],
      ),
    );
  }

  /// Bascule « toutes les lignes d'un coup » / pagination.
  Widget _boutonToutAfficher() {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: _tout
          ? 'Revenir à la pagination'
          : 'Afficher toutes les lignes en une seule fois, sans les découper '
                'en plusieurs pages',
      child: Material(
        color: _tout
            ? scheme.primary
            : scheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: widget.lignes.isEmpty
              ? null
              : () => setState(() {
                  _tout = !_tout;
                  _page = 0;
                }),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _tout ? Icons.view_list_outlined : Icons.unfold_more,
                  size: 15,
                  color: _tout ? scheme.onPrimary : scheme.onSurface,
                ),
                const SizedBox(width: 6),
                Text(
                  _tout ? 'Paginer' : 'Tout afficher',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _tout ? scheme.onPrimary : scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _carre({
    IconData? icone,
    String? texte,
    required String infobulle,
    required bool actif,
    bool selectionne = false,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final fond = selectionne
        ? scheme.primary
        : actif
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.7)
        : scheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final couleur = selectionne
        ? scheme.onPrimary
        : actif
        ? scheme.onSurface
        : scheme.outline;
    return Tooltip(
      message: infobulle,
      child: Material(
        color: fond,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: actif ? onTap : null,
          child: SizedBox(
            width: 30,
            height: 30,
            child: Center(
              child: icone != null
                  ? Icon(icone, size: 17, color: couleur)
                  : Text(
                      texte ?? '',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: selectionne
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: couleur,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _selecteurTaille() {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'Nombre de lignes par page',
      child: PopupMenuButton<int>(
        initialValue: _tout ? null : _taillePage,
        onSelected: (v) {
          setState(() {
            if (v >= 1000000000) {
              _tout = true;
            } else {
              _taillePage = v;
              _tout = false;
            }
            _page = 0;
          });
          _remonter();
        },
        itemBuilder: (_) => [
          for (final taille in const [10, 25, 50, 100])
            PopupMenuItem(
              value: taille,
              height: 38,
              child: Text(
                '$taille lignes par page',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          const PopupMenuItem(
            value: 1000000000,
            height: 38,
            child: Text('Toutes les lignes', style: TextStyle(fontSize: 13)),
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _tout ? 'Tout / page' : '$_taillePage / page',
                style: const TextStyle(fontSize: 12),
              ),
              const Icon(Icons.arrow_drop_down, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
