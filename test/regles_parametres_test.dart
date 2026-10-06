import 'package:flutter_test/flutter_test.dart';

import 'package:dsfa_gestion/domain/regles_parametres.dart';

ReglePJRequise regle(String regleDate, {String type = 'DATE'}) => ReglePJRequise(
  rubrique: 'RESTAURATION',
  sousRubrique: '',
  piece: 'PIECE',
  obligatoire: true,
  regleDate: regleDate,
  typeControle: type,
);

void main() {
  final debut = DateTime(2026, 5, 11);
  final fin = DateTime(2026, 5, 15);

  group('évaluation des règles de date des PJ', () {
    test('« Avant activité » conforme si la PJ précède le début', () {
      final e = evaluerPiecePJ(
        regle: regle('Avant activité'),
        datePJ: DateTime(2026, 5, 1),
        dateDebut: debut,
        dateFin: fin,
      );
      expect(e.conformite, ConformitePiece.conforme);
    });

    test('« Avant activité » non conforme si la PJ suit le début', () {
      final e = evaluerPiecePJ(
        regle: regle('Avant activité'),
        datePJ: DateTime(2026, 5, 20),
        dateDebut: debut,
        dateFin: fin,
      );
      expect(e.conformite, ConformitePiece.nonConforme);
    });

    test('« Après activité » conforme si la PJ suit la fin', () {
      final e = evaluerPiecePJ(
        regle: regle('Après activité'),
        datePJ: DateTime(2026, 6, 1),
        dateDebut: debut,
        dateFin: fin,
      );
      expect(e.conformite, ConformitePiece.conforme);
    });

    test('« Pendant activité » bornes incluses', () {
      final e = evaluerPiecePJ(
        regle: regle('Pendant activité'),
        datePJ: DateTime(2026, 5, 13),
        dateDebut: debut,
        dateFin: fin,
      );
      expect(e.conformite, ConformitePiece.conforme);
    });

    test('jalon référençant une autre pièce reste à vérifier', () {
      final e = evaluerPiecePJ(
        regle: regle('Après date PV;Avant activité'),
        datePJ: DateTime(2026, 5, 1),
        dateDebut: debut,
        dateFin: fin,
      );
      expect(e.conformite, ConformitePiece.aVerifier);
      expect(e.jalons['Après date PV'], isNull);
      expect(e.jalons['Avant activité'], isTrue);
    });

    test('date PJ absente : indéterminé', () {
      final e = evaluerPiecePJ(
        regle: regle('Avant activité'),
        datePJ: null,
        dateDebut: debut,
        dateFin: fin,
      );
      expect(e.conformite, ConformitePiece.aVerifier);
    });

    test('règle MANUEL sans jalon : à vérifier', () {
      final e = evaluerPiecePJ(
        regle: regle('Selon nature de dépense', type: 'MANUEL'),
        datePJ: DateTime(2026, 5, 1),
        dateDebut: debut,
        dateFin: fin,
      );
      expect(e.conformite, ConformitePiece.aVerifier);
    });
  });

  group('rattachement d\'un libellé à une rubrique', () {
    const rubriques = [
      'RESTAURATION',
      'FOURNITURE',
      'ACHAT',
      'COUVERTURE MÉDIATIQUE',
      'MULTIPLICATION DE DOCUMENT/VISUEL',
      'INDEMNITE',
      'CARBURANT',
      'DEPLACEMENT',
      'AUTRES',
    ];

    test('ligne budgétaire d\'indemnité', () {
      expect(
        rubriquePourLibelle('INDEMNITÉS DES MISSIONNAIRES', rubriques),
        'INDEMNITE',
      );
    });

    test('ligne de restauration', () {
      expect(rubriquePourLibelle('Pause café', rubriques), 'RESTAURATION');
      expect(rubriquePourLibelle('Déjeuner', rubriques), 'RESTAURATION');
    });

    test('ligne de fourniture', () {
      expect(rubriquePourLibelle('Rame Papier A4', rubriques), 'FOURNITURE');
    });

    test('transfert aéroport rattaché aux déplacements', () {
      expect(
        rubriquePourLibelle('Frais de transfert aéroport Interieur', rubriques),
        'DEPLACEMENT',
      );
    });
  });
}
