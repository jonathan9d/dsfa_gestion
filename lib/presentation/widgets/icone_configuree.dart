import 'dart:convert';

import 'package:flutter/material.dart';

import '../../domain/configuration/icones.dart';

/// Affiche l'icône d'un module, d'un statut ou d'un onglet : image importée
/// par l'utilisateur si elle existe, sinon icône du catalogue [IconesApp].
///
/// Une image importée est enregistrée dans la configuration (PNG encodé) :
/// elle s'affiche donc immédiatement, sans recompiler l'application.
class IconeConfiguree extends StatelessWidget {
  const IconeConfiguree({
    required this.cle,
    this.importee,
    this.taille = 20,
    this.couleur,
    super.key,
  });

  /// Clé du catalogue d'icônes (`dashboard`, `depense`…).
  final String cle;

  /// Image importée (base 64), prioritaire sur [cle].
  final String? importee;

  final double taille;
  final Color? couleur;

  @override
  Widget build(BuildContext context) {
    final donnees = importee;
    if (donnees != null && donnees.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(donnees),
          width: taille,
          height: taille,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          color: couleur,
          colorBlendMode: couleur == null ? null : BlendMode.srcIn,
          errorBuilder: (_, _, _) =>
              Icon(IconesApp.iconeOuDefaut(cle), size: taille, color: couleur),
        );
      } catch (_) {
        // Image illisible : on retombe sur l'icône du catalogue.
      }
    }
    return Icon(IconesApp.iconeOuDefaut(cle), size: taille, color: couleur);
  }
}
