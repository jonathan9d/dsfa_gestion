import 'package:flutter_test/flutter_test.dart';
import 'package:dsfa_gestion/domain/services/regles_metier.dart';
import 'package:dsfa_gestion/domain/statuts.dart';

void main() {
  group('règle d’or des indemnités', () {
    test('délai de route à 100 % + jours d’activité à 85 % avec déjeuner', () {
      // 2 j de route × 200 000 + 3 j d’activité × (200 000 × 85 %).
      final montant = ReglesMetier.indemniteParticipant(
        delaiRoute: 2,
        joursActivite: 3,
        taux: 200000,
        avecDejeuner: true,
      );
      expect(montant, 400000 + 3 * 170000);
    });

    test('sans déjeuner, les jours d’activité restent à 100 %', () {
      final montant = ReglesMetier.indemniteParticipant(
        delaiRoute: 2,
        joursActivite: 3,
        taux: 200000,
        avecDejeuner: false,
      );
      expect(montant, (2 + 3) * 200000);
    });

    test('les chauffeurs ne subissent jamais l’abattement repas', () {
      final montant = ReglesMetier.indemniteTotale(
        participants: 2,
        delaiRoute: 1,
        joursActivite: 4,
        taux: 150000,
        avecDejeuner: true,
        abattementRepas: false,
      );
      expect(montant, 2 * (1 + 4) * 150000);
    });

    test('la somme des parts recompose le total alloué', () {
      final partRoute = ReglesMetier.indemniteDelaiRoute(
        delaiRoute: 1.5,
        taux: 150000,
      );
      final tauxActivite = ReglesMetier.tauxJoursActivite(
        taux: 150000,
        avecDejeuner: true,
      );
      final total = ReglesMetier.indemniteParticipant(
        delaiRoute: 1.5,
        joursActivite: 5,
        taux: 150000,
        avecDejeuner: true,
      );
      expect(partRoute + 5 * tauxActivite, total);
    });
  });

  group('carburant', () {
    test('distance aller-retour = 2 × distance aller à défaut de référentiel',
        () {
      expect(
        ReglesMetier.distanceAllerRetour(
          distanceAllerKm: 120,
          distanceCarburantKm: 0,
        ),
        240,
      );
    });

    test('la distance carburant du référentiel est prioritaire', () {
      expect(
        ReglesMetier.distanceAllerRetour(
          distanceAllerKm: 120,
          distanceCarburantKm: 250,
        ),
        250,
      );
    });

    test('montant = distance A/R × consommation × voitures × PU', () {
      expect(
        ReglesMetier.montantCarburant(
          distanceAllerRetourKm: 240,
          consommation: 0.12,
          voitures: 2,
          prixUnitaire: 4860,
        ),
        240 * 0.12 * 2 * 4860,
      );
    });
  });

  group('contrôles métier stricts', () {
    test('une période incomplète n’est pas conforme', () {
      expect(
        ReglesMetier.dateDansPeriode(
          DateTime(2026, 10, 3),
          DateTime(2026, 10, 1),
          null,
        ),
        isFalse,
      );
    });

    test('tout écart monétaire significatif est non conforme', () {
      expect(ReglesMetier.montantConforme(0), isTrue);
      expect(ReglesMetier.montantConforme(0.25), isFalse);
    });

    test('un montant contrôlé dépasse un budget nul', () {
      expect(
        ReglesMetier.controlePresenceIndemnite(
          aAnomaliePresence: false,
          montantControle: 1,
          budgetIndemnitesDisponible: 0,
        ),
        ControlePresenceIndemnite.depassement,
      );
    });

    test('une date PJ absente ne peut pas être cohérente', () {
      expect(
        ReglesMetier.datePJCoherente(
          dateDebut: DateTime(2026, 10, 1),
          dateFin: DateTime(2026, 10, 2),
          datePJ: null,
        ),
        isFalse,
      );
    });

    test('un écart PJ non nul donne un statut non conforme', () {
      expect(
        ReglesMetier.statutFinalPJ(
          pjRecue: OuiNon.oui,
          datePJCoherente: true,
          ecartBudget: 0,
          ecartPJ: 0.25,
          pjConforme: OuiNon.oui,
          controlePresenceIndemnite: ControlePresenceIndemnite.conforme,
        ),
        StatutFinalPJ.nonConforme,
      );
    });
  });
}
