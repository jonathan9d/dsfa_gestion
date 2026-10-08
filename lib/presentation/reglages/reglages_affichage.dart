import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../theme/app_theme.dart';

/// Préférences d'affichage de l'application.
///
/// Elles sont **persistées** dans la table `parametres` (voir [versParametres])
/// et rechargées au démarrage par le bootstrap de la base, puis diffusées à
/// tout l'arbre via [ReglagesAffichageScope].
class ReglagesAffichage {
  const ReglagesAffichage({
    this.defilementHorizontal = true,
    this.couleurPrimaire = AppTheme.rose,
    this.couleurSecondaire = AppTheme.violet,
    this.echellePolice = 1.0,
    this.filtresOuverts = false,
    this.sauvegardeAutomatique = false,
    this.sonActif = true,
    this.motifFond = false,
  });

  /// Autorise le défilement horizontal des tableaux quand le contenu dépasse
  /// la largeur de l'écran. Désactivé : les colonnes sont comprimées.
  final bool defilementHorizontal;

  /// Couleur principale (boutons, en-têtes, accents).
  final Color couleurPrimaire;

  /// Couleur secondaire (sous-titres, éléments importants).
  final Color couleurSecondaire;

  /// Échelle de la police (1.0 = taille par défaut).
  final double echellePolice;

  /// Les filtres des tableaux sont-ils affichés d'emblée ?
  ///
  /// **Masqués par défaut** : les tableaux restent compacts et la barre de
  /// filtres ne s'ouvre que sur demande (« Filtrer ») ou via ce réglage.
  final bool filtresOuverts;

  /// Remplace la sauvegarde la plus récente à la fermeture de l'application.
  final bool sauvegardeAutomatique;

  /// Active les sons d'interaction et de notification.
  final bool sonActif;

  /// Affiche un motif géométrique discret au-dessus des écrans.
  final bool motifFond;

  ReglagesAffichage copyWith({
    bool? defilementHorizontal,
    Color? couleurPrimaire,
    Color? couleurSecondaire,
    double? echellePolice,
    bool? filtresOuverts,
    bool? sauvegardeAutomatique,
    bool? sonActif,
    bool? motifFond,
  }) => ReglagesAffichage(
    defilementHorizontal: defilementHorizontal ?? this.defilementHorizontal,
    couleurPrimaire: couleurPrimaire ?? this.couleurPrimaire,
    couleurSecondaire: couleurSecondaire ?? this.couleurSecondaire,
    echellePolice: echellePolice ?? this.echellePolice,
    filtresOuverts: filtresOuverts ?? this.filtresOuverts,
    sauvegardeAutomatique: sauvegardeAutomatique ?? this.sauvegardeAutomatique,
    sonActif: sonActif ?? this.sonActif,
    motifFond: motifFond ?? this.motifFond,
  );

  /// Réglages effectifs pour le contexte courant : valeur par défaut si
  /// l'application n'a pas posé de [ReglagesAffichageScope] (tests, widgets
  /// isolés).
  static ReglagesAffichage of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<ReglagesAffichageScope>()
          ?.reglages ??
      const ReglagesAffichage();

  // --- Persistance (clé / valeur de la table `parametres`) ---------------

  static const cleDefilement = 'affichage_defilement_horizontal';
  static const cleCouleurPrimaire = 'affichage_couleur_primaire';
  static const cleCouleurSecondaire = 'affichage_couleur_secondaire';
  static const clePolice = 'affichage_echelle_police';
  static const cleFiltres = 'affichage_filtres_ouverts';
  static const cleSauvegardeAuto = 'affichage_sauvegarde_automatique';
  static const cleSonActif = 'affichage_son_actif';
  static const cleMotifFond = 'affichage_motif_fond';

  /// Clé de persistance du thème choisi (clair / sombre / automatique).
  static const cleTheme = 'affichage_theme';

  /// Représentation persistable d'un [ThemeMode].
  static String themeVersTexte(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };

  /// Thème relu depuis `parametres` ; **automatique** par défaut.
  static ThemeMode themeDepuisTexte(String? valeur) => switch (valeur) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  /// Toutes les paires clé/valeur à écrire dans `parametres`.
  Map<String, String> versParametres() => {
    cleDefilement: defilementHorizontal ? '1' : '0',
    cleCouleurPrimaire:
        '0x${couleurPrimaire.toARGB32().toRadixString(16).padLeft(8, '0')}',
    cleCouleurSecondaire:
        '0x${couleurSecondaire.toARGB32().toRadixString(16).padLeft(8, '0')}',
    clePolice: echellePolice.toStringAsFixed(2),
    cleFiltres: filtresOuverts ? '1' : '0',
    cleSauvegardeAuto: sauvegardeAutomatique ? '1' : '0',
    cleSonActif: sonActif ? '1' : '0',
    cleMotifFond: motifFond ? '1' : '0',
  };

  /// Reconstructeur à partir de la table `parametres` (valeurs absentes =
  /// valeurs par défaut).
  factory ReglagesAffichage.depuisParametres(Map<String, String> p) {
    bool boole(String cle, bool defaut) {
      final v = p[cle];
      if (v == null) return defaut;
      return v == '1' || v.toLowerCase() == 'true';
    }

    Color couleur(String cle, Color defaut) {
      final v = p[cle];
      if (v == null) return defaut;
      final n = int.tryParse(v.replaceFirst('0x', ''), radix: 16);
      return n == null ? defaut : Color(n);
    }

    double echelle = double.tryParse(p[clePolice] ?? '') ?? 1.0;
    if (echelle < 0.8 || echelle > 1.4) echelle = 1.0;

    return ReglagesAffichage(
      defilementHorizontal: boole(cleDefilement, true),
      couleurPrimaire: couleur(cleCouleurPrimaire, AppTheme.rose),
      couleurSecondaire: couleur(cleCouleurSecondaire, AppTheme.violet),
      echellePolice: echelle,
      filtresOuverts: boole(cleFiltres, false),
      sauvegardeAutomatique: boole(cleSauvegardeAuto, false),
      sonActif: boole(cleSonActif, true),
      motifFond: boole(cleMotifFond, false),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReglagesAffichage &&
      other.defilementHorizontal == defilementHorizontal &&
      other.couleurPrimaire == couleurPrimaire &&
      other.couleurSecondaire == couleurSecondaire &&
      other.echellePolice == echellePolice &&
      other.filtresOuverts == filtresOuverts &&
      other.sauvegardeAutomatique == sauvegardeAutomatique &&
      other.sonActif == sonActif &&
      other.motifFond == motifFond;

  @override
  int get hashCode => Object.hash(
    defilementHorizontal,
    couleurPrimaire,
    couleurSecondaire,
    echellePolice,
    filtresOuverts,
    sauvegardeAutomatique,
    sonActif,
    motifFond,
  );
}

/// Réglages d'affichage courants (mutables, répercutés immédiatement).
final reglagesAffichageProvider = StateProvider<ReglagesAffichage>(
  (ref) => const ReglagesAffichage(),
);

/// Diffuse les réglages d'affichage dans l'arbre de widgets : les composants
/// qui ne sont pas des `Consumer` (tableau de données, dialogues…) peuvent
/// ainsi les lire via [ReglagesAffichage.of].
class ReglagesAffichageScope extends InheritedWidget {
  const ReglagesAffichageScope({
    required this.reglages,
    required super.child,
    super.key,
  });

  final ReglagesAffichage reglages;

  @override
  bool updateShouldNotify(ReglagesAffichageScope oldWidget) =>
      reglages != oldWidget.reglages;
}
