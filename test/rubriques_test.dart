import 'package:flutter_test/flutter_test.dart';

import 'package:dsfa_gestion/domain/rubriques.dart';
import 'package:dsfa_gestion/presentation/screens/budgets/ligne_budget_dialog.dart';

/// Les rubriques viennent **exclusivement** des paramètres (`REFERENTIEL_TARIFS`
/// de `parametres.xlsx`) : aucune ligne budgétaire ne peut avoir de rubrique
/// libre, et la location de salle doit tomber sur la restauration.
void main() {
  /// Rubriques telles qu'elles figurent dans le classeur de référence.
  const rubriques = <String>[
    'INDEMNITÉS DES MISSIONNAIRES',
    'DÉPLACEMENTS DES MISSIONNAIRES',
    'RESTAURATION / FRAIS D\'ORGANISATION',
    'FOURNITURES',
    'MULTIPLICATION DE DOCUMENT/VISUEL',
    'COUVERTURE MÉDIATIQUE',
    'ACHAT',
  ];

  test('la location des salles appartient à la restauration', () {
    expect(
      RubriquesBudget.pourLibelle('Location de salle équipée', rubriques),
      'RESTAURATION / FRAIS D\'ORGANISATION',
    );
    expect(
      RubriquesBudget.pourLibelle('Location salle', rubriques),
      'RESTAURATION / FRAIS D\'ORGANISATION',
    );
    // …et non aux déplacements, malgré le mot « location ».
    expect(
      RubriquesBudget.pourLibelle('Location de salle', rubriques),
      isNot('DÉPLACEMENTS DES MISSIONNAIRES'),
    );
  });

  test('les autres lignes tombent sur la bonne rubrique', () {
    expect(
      RubriquesBudget.pourLibelle('Indemnité Chauffeur', rubriques),
      'INDEMNITÉS DES MISSIONNAIRES',
    );
    expect(
      RubriquesBudget.pourLibelle('Location de voiture', rubriques),
      'DÉPLACEMENTS DES MISSIONNAIRES',
    );
    expect(
      RubriquesBudget.pourLibelle('Carburant', rubriques),
      'DÉPLACEMENTS DES MISSIONNAIRES',
    );
    expect(RubriquesBudget.pourLibelle('Post it', rubriques), 'FOURNITURES');
    expect(
      RubriquesBudget.pourLibelle('Rame Papier A4', rubriques),
      'FOURNITURES',
    );
  });

  test('aucune rubrique libre n’est jamais produite', () {
    final inconnus = [
      'Ligne libre',
      'Divers',
      '',
      'XYZ sans rapport',
      'Frais de mission',
    ];
    for (final libelle in inconnus) {
      final rubrique = RubriquesBudget.resoudre(
        ligneBudgetaire: libelle,
        rubriques: rubriques,
      );
      // Jamais la valeur libre historique « Libre » : soit une rubrique des
      // paramètres, soit le marqueur explicite « À préciser ».
      expect(
        rubrique.toUpperCase(),
        isNot('LIBRE'),
        reason: '« $libelle » ne doit pas rester en rubrique libre',
      );
      expect(
        rubriques.contains(rubrique) || rubrique == RubriquesBudget.aPreciser,
        isTrue,
        reason: '« $libelle » doit produire une rubrique des paramètres',
      );
    }
  });

  test('une rubrique inconnue des paramètres est signalée, pas inventée', () {
    // Aucun référentiel : l'application ne fabrique pas de rubrique.
    expect(
      RubriquesBudget.resoudre(
        ligneBudgetaire: 'Indemnité',
        rubriques: const [],
      ),
      RubriquesBudget.aPreciser,
    );
    // Une rubrique enregistrée autrefois et disparue du référentiel est
    // remplacée par la rubrique correspondante du référentiel courant.
    expect(
      RubriquesBudget.resoudre(
        ligneBudgetaire: 'Indemnité',
        rubriqueEnregistree: 'ANCIENNE RUBRIQUE',
        rubriques: rubriques,
      ),
      'INDEMNITÉS DES MISSIONNAIRES',
    );
  });

  test('le type de budget suit la rubrique, salle comprise', () {
    expect(TypeBudget.depuisLigne('Location de salle équipée').id,
        TypeBudget.restauration);
    expect(TypeBudget.depuisLigne('Salle équipée').id, TypeBudget.restauration);
    expect(
      TypeBudget.depuisLigne('Location de voiture').id,
      TypeBudget.location,
    );
    expect(TypeBudget.depuisLigne('Rame Papier A4').id, TypeBudget.fournitures);
    expect(
      TypeBudget.depuisLigne('Indemnité Chauffeur').id,
      TypeBudget.indemnitesChauffeurs,
    );
  });

  test('le regroupement par rubrique est cohérent et complet', () {
    final lignes = <String>[
      'Location de salle équipée',
      'Pause café',
      'Post it',
      'Stylo bleu',
      'Location de voiture',
      'Carburant',
    ];
    final compte = <String, int>{};
    for (final l in lignes) {
      final r = RubriquesBudget.pourLibelle(l, rubriques);
      compte[r] = (compte[r] ?? 0) + 1;
    }
    expect(compte['RESTAURATION / FRAIS D\'ORGANISATION'], 2);
    expect(compte['FOURNITURES'], 2);
    expect(compte['DÉPLACEMENTS DES MISSIONNAIRES'], 2);
    // Aucune ligne perdue dans une rubrique fourre-tout.
    expect(compte.values.fold<int>(0, (s, v) => s + v), lignes.length);
  });
}
