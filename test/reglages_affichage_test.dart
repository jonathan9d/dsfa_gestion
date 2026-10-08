import 'package:dsfa_gestion/presentation/reglages/reglages_affichage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('les préférences de son et de motif survivent à une relecture', () {
    const reglages = ReglagesAffichage(sonActif: false, motifFond: true);

    final relus = ReglagesAffichage.depuisParametres(reglages.versParametres());

    expect(relus.sonActif, isFalse);
    expect(relus.motifFond, isTrue);
    expect(relus, reglages);
  });

  test(
    'les préférences ajoutées restent compatibles avec les anciennes bases',
    () {
      final anciens = ReglagesAffichage.depuisParametres(const {});

      expect(anciens.sonActif, isTrue);
      expect(anciens.motifFond, isFalse);
      expect(anciens.copyWith(motifFond: true).motifFond, isTrue);
    },
  );
}
