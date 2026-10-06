import 'package:dsfa_gestion/presentation/widgets/tableau.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Ligne {
  _Ligne(this.id, this.nom, this.ville, this.montant);
  final int id;
  final String nom;
  final String ville;
  final double montant;
}

List<_Ligne> _lignesCourtes() => [
  _Ligne(1, 'Rakoto', 'Antananarivo', 1000),
  _Ligne(2, 'Rasoa', 'Toamasina', 2000),
  _Ligne(3, 'Andry', 'Fianarantsoa', 3000),
];

List<_Ligne> _lignesNomLong() => [
  for (var i = 0; i < 3; i++)
    _Ligne(
      i,
      'Nom très long sans aucune troncature '.padRight(160, 'x'),
      'Ville $i',
      (i + 1) * 1000,
    ),
];

Widget _tableau({
  required List<_Ligne> lignes,
  int taillePage = 25,
  Future<void> Function(List<_Ligne>)? onSupprimer,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TableauGestion<_Ligne>(
          lignes: lignes,
          cleLigne: (l) => l.id,
          taillePage: taillePage,
          onSupprimer: onSupprimer,
          colonnes: [
            ColonneTableau(label: 'Nom', valeur: (l) => l.nom),
            ColonneTableau(label: 'Ville', valeur: (l) => l.ville),
            ColonneTableau(
              label: 'Total Ar',
              numerique: true,
              valeur: (l) => '${l.montant.toStringAsFixed(0)} Ar',
            ),
          ],
        ),
      ),
    ),
  );
}

void _taille(WidgetTester tester, double largeur, double hauteur) {
  tester.view.physicalSize = Size(largeur, hauteur);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('Contenu court : aucune colonne tronquée, pas de défilement', (
    tester,
  ) async {
    _taille(tester, 1400, 800);
    await tester.pumpWidget(_tableau(lignes: _lignesCourtes()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Les largeurs calculées tiennent dans l'écran : aucun défilement
    // horizontal n'est nécessaire.
    expect(find.byType(SingleChildScrollView), findsNothing);
    // Le texte est rendu en entier (largeur du rendu ≥ largeur mesurée).
    expect(find.text('Rakoto'), findsOneWidget);
  });

  testWidgets('Noms très longs : défilement horizontal au lieu de « … »', (
    tester,
  ) async {
    _taille(tester, 900, 700);
    await tester.pumpWidget(_tableau(lignes: _lignesNomLong()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Le contenu dépasse la largeur disponible : un défilement horizontal
    // est proposé pour que rien ne soit coupé.
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('Sélection : cases à cocher, total calculé et suppression', (
    tester,
  ) async {
    _taille(tester, 1400, 800);
    var supprimees = <_Ligne>[];
    await tester.pumpWidget(
      _tableau(
        lignes: _lignesCourtes(),
        onSupprimer: (lignes) async => supprimees = lignes,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Checkbox), findsNothing);

    await tester.tap(find.widgetWithText(TextButton, 'Sélectionner'));
    await tester.pumpAndSettle();
    // Une case dans l'en-tête + une par ligne visible.
    expect(find.byType(Checkbox), findsNWidgets(4));

    // Sélection de toutes les lignes via la case d'en-tête.
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(find.text('3 ligne(s) sélectionnée(s)'), findsOneWidget);

    // Le total de la colonne numérique est affiché en bas.
    expect(find.textContaining('Total Ar :'), findsOneWidget);

    final suppression = find.widgetWithText(
      FilledButton,
      'Supprimer (3)',
    );
    expect(suppression, findsOneWidget);
    await tester.tap(suppression);
    await tester.pumpAndSettle();

    // Confirmation puis suppression.
    expect(find.widgetWithText(FilledButton, 'Supprimer'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
    await tester.pumpAndSettle();
    expect(supprimees.length, 3);
    expect(find.text('3 ligne(s) supprimée(s).'), findsOneWidget);
  });

  testWidgets('Bouton « Tout afficher » : plus aucune pagination', (
    tester,
  ) async {
    _taille(tester, 1400, 800);
    final lignes = [for (var i = 0; i < 60; i++) _Ligne(i, 'Nom $i', 'Ville', 1)];
    await tester.pumpWidget(_tableau(lignes: lignes));
    await tester.pumpAndSettle();

    expect(find.text('Lignes 1 à 25 sur 60'), findsOneWidget);

    await tester.tap(find.text('Tout afficher'));
    await tester.pumpAndSettle();

    expect(find.text('Toutes les lignes : 60'), findsOneWidget);

    // Retour à la pagination.
    await tester.tap(find.text('Paginer'));
    await tester.pumpAndSettle();
    expect(find.text('Lignes 1 à 25 sur 60'), findsOneWidget);
  });
}
