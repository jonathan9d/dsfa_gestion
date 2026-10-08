import 'dart:convert';

import '../../domain/configuration/configuration_app.dart';
import 'referentiel_repository.dart';

/// Enregistrement de la **configuration de l'application** (modules, champs,
/// statuts, rubriques, onglets créés) dans la table `parametres`.
///
/// Le format est du JSON : une configuration enregistrée par une version
/// antérieure reste lisible, et les éléments livrés dans une version plus
/// récente sont **fusionnés** automatiquement ([ConfigurationApp.
/// fusionnerAvecDefauts]) sans perdre les personnalisations.
class ConfigurationRepository {
  ConfigurationRepository(this._parametres);

  /// Clé de la table `parametres` (comme `regles_parametres` pour la matrice
  /// des PJ).
  static const cle = 'configuration_app';

  final ParametresRepository _parametres;

  Future<ConfigurationApp> charger() async {
    final brut = await _parametres.lire(cle);
    if (brut == null || brut.trim().isEmpty) {
      return ConfigurationApp.parDefaut();
    }
    try {
      final json = (jsonDecode(brut) as Map).cast<String, dynamic>();
      return ConfigurationApp.fromJson(json).fusionnerAvecDefauts();
    } catch (_) {
      // Configuration illisible : on repart des valeurs livrées plutôt que de
      // bloquer l'application.
      return ConfigurationApp.parDefaut();
    }
  }

  Future<void> enregistrer(ConfigurationApp configuration) =>
      _parametres.ecrire(cle, jsonEncode(configuration.toJson()));

  /// Réinitialise la configuration livrée (les onglets et champs créés par
  /// l'utilisateur sont perdus — l'appel est confirmé par l'interface).
  Future<ConfigurationApp> reinitialiser() async {
    final defauts = ConfigurationApp.parDefaut();
    await enregistrer(defauts);
    return defauts;
  }
}
