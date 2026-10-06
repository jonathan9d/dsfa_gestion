import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsfa_gestion/presentation/theme/app_theme.dart';
import 'package:dsfa_gestion/presentation/theme/comportement_defilement.dart';
import 'package:dsfa_gestion/presentation/widgets/tableau.dart';

class _Ligne {
  const _Ligne(this.id, this.nom, this.montant);
  final int id;
  final String nom;
  final String montant;
}

const _lignes = <_Ligne>[
  _Ligne(1, 'Frais de mission', '1 000 Ar'),
  _Ligne(2, 'Carburant', '2 000 Ar'),
  _Ligne(3, 'Restauration', '3 000 Ar'),
];

/// Page défilante contenant un tableau **imbriqué** : le cas qui, à la souris,
/// donne l'impression que « ça ne veut pas défiler ».
Widget _page(ScrollController externe) => MaterialApp(
  theme: AppTheme.light(),
  scrollBehavior: const ComportementDefilement(),
  home: Scaffold(
    body: ListView(
      controller: externe,
      children: [
        const SizedBox(height: 700, child: ColoredBox(color: Color(0xFFEFEFEF))),
        TableauGestion<_Ligne>(
          hauteur: 260,
          lignes: _lignes,
          cleLigne: (l) => l.id,
          colonnes: [
            ColonneTableau(label: 'Libellé', valeur: (l) => l.nom),
            ColonneTableau(
              label: 'Montant',
              numerique: true,
              valeur: (l) => l.montant,
            ),
          ],
        ),
        const SizedBox(height: 900, child: ColoredBox(color: Color(0xFFDDDDDD))),
      ],
    ),
  ),
);

void _taille(WidgetTester tester, double largeur, double hauteur) {
  tester.view.physicalSize = Size(largeur, hauteur);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('la molette franchit un tableau sans défilement propre', (
    tester,
  ) async {
    _taille(tester, 900, 900);
    final externe = ScrollController();
    addTearDown(externe.dispose);
    await tester.pumpWidget(_page(externe));
    await tester.pump();
    expect(externe.offset, 0);

    // La souris est posée sur le tableau (y ≈ 830), pas sur la page.
    final cible = tester.getCenter(find.byType(TableauGestion<_Ligne>));
    final souris = TestPointer(1, PointerDeviceKind.mouse);
    souris.hover(cible);
    // Trois lignes seulement : le tableau n'a rien à faire défiler, la page
    // doit donc recevoir la molette.
    await tester.sendEventToBinding(souris.scroll(const Offset(0, 150)));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 80));
    }

    expect(
      externe.offset,
      greaterThan(0),
      reason: 'la page doit défiler malgré le tableau sous le curseur',
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('on peut faire glisser la page à la souris par-dessus le tableau', (
    tester,
  ) async {
    _taille(tester, 900, 900);
    final externe = ScrollController();
    addTearDown(externe.dispose);
    await tester.pumpWidget(_page(externe));
    await tester.pump();
    expect(externe.offset, 0);

    final cible = tester.getCenter(find.byType(TableauGestion<_Ligne>));
    await tester.dragFrom(
      cible,
      const Offset(0, -180),
      kind: PointerDeviceKind.mouse,
    );
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 80));
    }

    expect(
      externe.offset,
      greaterThan(0),
      reason: 'le glisser à la souris doit faire défiler la page',
    );
    await tester.pumpWidget(const SizedBox());
  });

  test('le comportement autorise le glisser à la souris', () {
    const comportement = ComportementDefilement();
    expect(comportement.dragDevices, contains(PointerDeviceKind.mouse));
    expect(comportement.dragDevices, contains(PointerDeviceKind.touch));
    expect(comportement.dragDevices, contains(PointerDeviceKind.trackpad));
  });
}
