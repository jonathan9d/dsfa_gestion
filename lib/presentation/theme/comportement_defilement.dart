import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Comportement de défilement de l'application (bureau Windows).
///
/// Deux ajustements par rapport au comportement Material par défaut, tous les
/// deux destinés au confort à la souris :
///
/// 1. **glisser à la souris** : sur un poste de travail, on peut saisir une
///    zone vide d'une page (en-tête, marge, pied de liste) et la tirer pour la
///    faire défiler. C'est le filet de sécurité quand la molette est captée par
///    l'élément survolé — un tableau ou une carte qui possède son propre
///    défilement ;
/// 2. **aucun indicateur d'étirement** en butée : l'effet élastique se traduit
///    mal à la souris et donne l'impression que la vue est bloquée.
///
/// La molette continue par ailleurs de remonter naturellement vers la page
/// parente dès qu'un défilement imbriqué atteint son extrémité.
class ComportementDefilement extends MaterialScrollBehavior {
  const ComportementDefilement();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.unknown,
  };

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}
