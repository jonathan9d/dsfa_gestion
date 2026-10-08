import 'dart:async';

import 'package:dsfa_gestion/presentation/providers/app_providers.dart';
import 'package:dsfa_gestion/presentation/router/app_router.dart';
import 'package:dsfa_gestion/presentation/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// La coquille (menu + zone de contenu) est testée seule : cela permet de
/// vérifier précisément que **toutes** les rubriques du menu sont affichées,
/// quelle que soit la taille de la fenêtre.
Widget _coquille({bool reduite = false}) {
  return ProviderScope(
    overrides: [
      sidebarReduiteProvider.overrideWith((ref) => reduite),
      auditCountProvider.overrideWith((ref) => Stream.value(0)),
    ],
    child: MaterialApp(
      home: AppShell(location: '/', child: const SizedBox.expand()),
    ),
  );
}

void _taille(WidgetTester tester, Size taille) {
  tester.view.physicalSize = taille;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

final _menu = find.byKey(const ValueKey('menu-lateral'));
final _pied = find.byKey(const ValueKey('pied-utilisateur'));

/// Vérifie qu'une rubrique est réellement visible : présente dans le menu,
/// entièrement au-dessus du pied utilisateur (donc non masquée) et dans
/// l'écran.
void _verifierVisible(WidgetTester tester, String label) {
  final zone = tester.getRect(_menu);
  final pied = tester.getRect(_pied);
  expect(
    pied.top >= zone.top,
    isTrue,
    reason: 'Le pied utilisateur est hors du menu (pied : $pied).',
  );
  final finder = find.descendant(of: _menu, matching: find.text(label));
  expect(
    finder,
    findsOneWidget,
    reason: 'Rubrique « $label » absente du menu.',
  );
  final rect = tester.getRect(finder);
  expect(
    rect.bottom <= pied.top + 1,
    isTrue,
    reason:
        'Rubrique « $label » masquée par le bas du menu '
        '(rubrique : $rect, pied : ${pied.top}).',
  );
  expect(
    rect.top >= zone.top - 1 && rect.right <= zone.right + 1,
    isTrue,
    reason: 'Rubrique « $label » hors du menu (rubrique : $rect).',
  );
}

void _verifierToutesLesRubriques(WidgetTester tester) {
  for (final entree in entreesNavigation) {
    _verifierVisible(tester, entree.label);
  }
}

void main() {
  testWidgets('Menu déployé (bureau) : toutes les rubriques sont visibles', (
    tester,
  ) async {
    _taille(tester, const Size(1400, 900));
    await tester.pumpWidget(_coquille());
    await tester.pumpAndSettle();

    _verifierToutesLesRubriques(tester);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Menu déployé : visible sur une fenêtre peu haute', (
    tester,
  ) async {
    _taille(tester, const Size(1100, 620));
    await tester.pumpWidget(_coquille());
    await tester.pumpAndSettle();

    _verifierToutesLesRubriques(tester);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'Menu déployé sur une fenêtre très peu haute : tout reste accessible',
    (tester) async {
      _taille(tester, const Size(1100, 520));
      await tester.pumpWidget(_coquille());
      await tester.pumpAndSettle();

      // Les premières rubriques sont visibles, et les suivantes restent
      // accessibles en faisant défiler le menu (jamais d'écran vide).
      for (final entree in entreesNavigation.take(5)) {
        _verifierVisible(tester, entree.label);
      }
      await tester.drag(
        find.descendant(of: _menu, matching: find.byType(ListView)),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();
      _verifierVisible(tester, entreesNavigation.last.label);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('Menu replié : toutes les rubriques restent accessibles', (
    tester,
  ) async {
    _taille(tester, const Size(1400, 900));
    await tester.pumpWidget(_coquille(reduite: true));
    await tester.pumpAndSettle();

    for (final entree in entreesNavigation) {
      expect(
        find.byTooltip(entree.label),
        findsOneWidget,
        reason: 'Icône manquante pour ${entree.label}',
      );
    }
    expect(_pied, findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Menu déployé par le bouton « hamburger » : tout est affiché', (
    tester,
  ) async {
    _taille(tester, const Size(900, 700));
    await tester.pumpWidget(_coquille());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    _verifierToutesLesRubriques(tester);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Menu déployé sur fenêtre peu haute : rien n\'est laissé vide', (
    tester,
  ) async {
    _taille(tester, const Size(900, 560));
    await tester.pumpWidget(_coquille());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    for (final entree in entreesNavigation.take(5)) {
      _verifierVisible(tester, entree.label);
    }
    // Les dernières rubriques du groupe « Administration » restent
    // accessibles en faisant défiler le menu.
    await tester.drag(
      find.descendant(of: _menu, matching: find.byType(ListView)),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    _verifierVisible(tester, entreesNavigation.last.label);

    await tester.pumpWidget(const SizedBox());
  });
}
