import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../../data/database/database.dart';
import '../../data/repositories/referentiel_repository.dart';
import '../../services/excel_import_service.dart';

/// **Modifications en cascade** de la configuration.
///
/// Quand une rubrique est renommée ou supprimée, tout ce qui la référence est
/// mis à jour dans la même opération :
///
/// * les **lignes du référentiel des tarifs** (`REFERENTIEL_TARIFS`) ;
/// * les **règles de la matrice des PJ** (`regles_parametres`), qui peuvent
///   être renommées (renommage de rubrique) ou désactivées (suppression) ;
/// * les **affectations** ligne budgétaire → rubrique de la configuration.
///
/// Aucune donnée n'est jamais supprimée silencieusement : le nombre d'éléments
/// touchés est renvoyé pour l'afficher dans la confirmation.
class CascadeConfiguration {
  CascadeConfiguration({required this.tarifs, required this.parametres});

  final TarifsRepository tarifs;
  final ParametresRepository parametres;

  /// Normalise un nom de rubrique pour comparer des libellés hétérogènes.
  static String normaliser(String valeur) {
    var texte = valeur.toUpperCase();
    const accents = {
      'À': 'A',
      'Â': 'A',
      'Ä': 'A',
      'Á': 'A',
      'Ç': 'C',
      'È': 'E',
      'É': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'Î': 'I',
      'Ï': 'I',
      'Ô': 'O',
      'Ö': 'O',
      'Ù': 'U',
      'Û': 'U',
      'Ü': 'U',
      "'": ' ',
      '’': ' ',
    };
    accents.forEach((a, b) => texte = texte.replaceAll(a, b));
    return texte.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Lignes du référentiel des tarifs rattachées à [rubrique].
  Future<int> compterLignes(String rubrique) async {
    final lignes = await tarifs.getAll();
    final n = normaliser(rubrique);
    return lignes.where((l) => normaliser(l.rubrique) == n).length;
  }

  /// Règles PJ rattachées à [rubrique].
  Future<int> compterReglesPJ(String rubrique) async {
    final matiere = await _matricePJ();
    final n = normaliser(rubrique);
    return matiere.where((r) => normaliser('${r['rubrique'] ?? ''}') == n).length;
  }

  /// Reclasse les lignes des tarifs de [de] vers [vers] (`null` : rubrique
  /// vidée, la ligne sera reclassée par la détection automatique).
  Future<int> reclasserLignes({required String de, String? vers}) async {
    final lignes = await tarifs.getAll();
    final cible = normaliser(de);
    var modifiees = 0;
    for (final ligne in lignes) {
      if (normaliser(ligne.rubrique) != cible) continue;
      await tarifs.update(
        ligne.id,
        ReferentielTarifsCompanion(rubrique: Value(vers ?? '')),
      );
      modifiees++;
    }
    return modifiees;
  }

  /// Classe une **ligne budgétaire** (par son libellé) dans une rubrique :
  /// toutes les entrées du référentiel portant ce libellé sont mises à jour,
  /// et les contrôles PJ continuent de s'appliquer selon la rubrique retenue.
  Future<int> classerLigneBudgetaire({
    required String ligneBudgetaire,
    required String rubrique,
  }) async {
    final lignes = await tarifs.getAll();
    final cible = normaliser(ligneBudgetaire);
    var modifiees = 0;
    for (final ligne in lignes) {
      if (normaliser(ligne.ligneBudgetaire) != cible) continue;
      await tarifs.update(
        ligne.id,
        ReferentielTarifsCompanion(rubrique: Value(rubrique)),
      );
      modifiees++;
    }
    return modifiees;
  }

  /// Reclasse ([vers] fourni) ou **désactive** les règles PJ d'une rubrique.
  Future<int> reclasserReglesPJ({
    required String rubrique,
    String? vers,
    bool desactiver = false,
  }) async {
    final brut = await parametres.lire(ExcelImportService.cleParametres);
    if (brut == null || brut.isEmpty) return 0;
    Map<String, dynamic> json;
    try {
      json = (jsonDecode(brut) as Map).cast<String, dynamic>();
    } catch (_) {
      return 0;
    }
    final matrice = (json['matricePJ'] as List?) ?? const [];
    final cible = normaliser(rubrique);
    var modifiees = 0;
    final nouvelle = <dynamic>[];
    for (final entree in matrice) {
      if (entree is! Map) {
        nouvelle.add(entree);
        continue;
      }
      final regle = entree.cast<String, dynamic>();
      if (normaliser('${regle['rubrique'] ?? ''}') != cible) {
        nouvelle.add(regle);
        continue;
      }
      final copie = Map<String, dynamic>.from(regle);
      if (vers != null) copie['rubrique'] = vers;
      if (desactiver) copie['actif'] = false;
      nouvelle.add(copie);
      modifiees++;
    }
    if (modifiees == 0) return 0;
    json['matricePJ'] = nouvelle;
    await parametres.ecrire(ExcelImportService.cleParametres, jsonEncode(json));
    return modifiees;
  }

  /// Duplique une règle PJ vers une rubrique nouvellement créée : la nouvelle
  /// rubrique hérite des mêmes pièces, sans que rien ne soit perdu.
  Future<int> dupliquerReglesPJ({
    required String modele,
    required String vers,
  }) async {
    final brut = await parametres.lire(ExcelImportService.cleParametres);
    if (brut == null || brut.isEmpty) return 0;
    Map<String, dynamic> json;
    try {
      json = (jsonDecode(brut) as Map).cast<String, dynamic>();
    } catch (_) {
      return 0;
    }
    final matrice = ((json['matricePJ'] as List?) ?? const []).toList();
    final cible = normaliser(modele);
    final copies = <Map<String, dynamic>>[];
    for (final entree in matrice) {
      if (entree is! Map) continue;
      final regle = entree.cast<String, dynamic>();
      if (normaliser('${regle['rubrique'] ?? ''}') != cible) continue;
      copies.add({...regle, 'rubrique': vers});
    }
    if (copies.isEmpty) return 0;
    json['matricePJ'] = [...matrice, ...copies];
    await parametres.ecrire(ExcelImportService.cleParametres, jsonEncode(json));
    return copies.length;
  }

  Future<List<Map<String, dynamic>>> _matricePJ() async {
    final brut = await parametres.lire(ExcelImportService.cleParametres);
    if (brut == null || brut.isEmpty) return const [];
    try {
      final json = (jsonDecode(brut) as Map).cast<String, dynamic>();
      return ((json['matricePJ'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
