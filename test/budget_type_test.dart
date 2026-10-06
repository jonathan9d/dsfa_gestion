import 'package:dsfa_gestion/data/database/database.dart';
import 'package:dsfa_gestion/presentation/screens/budgets/ligne_budget_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

LigneBudget _ligne({
  required String ligne,
  required String type,
  String? details,
  double quantite = 0,
  double jours = 0,
  double taux = 0,
  double montant = 0,
}) => LigneBudget(
  id: 1,
  activiteCode: 'PSN N°1',
  ligneBudgetaire: ligne,
  typeBudget: type,
  unite: 'unité',
  quantitePrevue: quantite,
  nombreJours: jours,
  tauxUnitaire: taux,
  montantAlloue: montant,
  details: details,
);

void main() {
  group('type de budget déduit automatiquement du libellé', () {
    test('les libellés d’indemnité donnent le type indemnités', () {
      expect(
        TypeBudget.depuisLigne('Indemnité des équipes centraux et régionaux').id,
        TypeBudget.indemnitesEquipes,
      );
      expect(
        TypeBudget.depuisLigne('Indemnité des chauffeurs').id,
        TypeBudget.indemnitesChauffeurs,
      );
      // Les accents ne doivent pas empêcher la détection.
      expect(
        TypeBudget.depuisLigne('INDEMNITE DES EQUIPES').id,
        TypeBudget.indemnitesEquipes,
      );
    });

    test('les autres rubriques sont reconnues', () {
      expect(TypeBudget.depuisLigne('Carburant').id, TypeBudget.carburant);
      expect(
        TypeBudget.depuisLigne('Location de voitures').id,
        TypeBudget.location,
      );
      expect(
        TypeBudget.depuisLigne('Restauration — pause-café').id,
        TypeBudget.restauration,
      );
      expect(
        TypeBudget.depuisLigne('Fourniture : papier A4').id,
        TypeBudget.fournitures,
      );
    });

    test('un libellé inconnu laisse le type libre', () {
      expect(TypeBudget.depuisLigne('Autre dépense diverse').id,
          TypeBudget.libres);
      expect(TypeBudget.estAutomatique('Autre dépense diverse'), isFalse);
    });

    test('une ligne existante non reconnue garde son type enregistré', () {
      expect(
        TypeBudget.typePourLigne(
          'Rubrique personnalisée',
          typeStocke: TypeBudget.carburant,
        ),
        TypeBudget.carburant,
      );
    });
  });

  group('résumé du calcul des lignes enregistrées', () {
    test('une indemnité montre la part route et la part activité', () {
      final resume = resumeLigneBudget(
        _ligne(
          ligne: 'Indemnité des équipes',
          type: TypeBudget.indemnitesEquipes,
          details:
              '{"personnes":2,"delaiRoute":2,"joursActivite":3,'
              '"taux":200000,"restauration":true}',
          montant: 2 * (2 * 200000 + 3 * 170000),
        ),
      );
      expect(resume, contains('2 pers.'));
      expect(resume, contains('route 2 j'));
      expect(resume, contains('3 j'));
    });

    test('le carburant affiche la distance aller-retour', () {
      final resume = resumeLigneBudget(
        _ligne(
          ligne: 'Carburant',
          type: TypeBudget.carburant,
          details:
              '{"distanceAller":120,"distanceRetour":120,"consommation":0.12,'
              '"voitures":2,"pu":4860}',
        ),
      );
      expect(resume, contains('240 km A/R'));
      expect(resume, contains('0.12 L/km'));
    });
  });
}
