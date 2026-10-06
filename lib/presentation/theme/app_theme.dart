import 'package:flutter/material.dart';

/// Thème Material 3 de DSFA Gestion aux couleurs institutionnelles DSFa/UNICEF.
///
/// Rose DSFa (#B14493) : couleur principale du logo.
/// Violet DSFa (#662583) : violet plus foncé (sous-titres / éléments importants).
/// Vert DSFa (#9BC55F) : feuilles du logo (validation / éléments positifs).
/// Blanc : texte/logo sur fond coloré.
class AppTheme {
  const AppTheme._();

  /// Couleur principale institutionnelle (Rose DSFa).
  static const rose = Color(0xFFB14493);

  /// Violet plus foncé (sous-titres, éléments importants).
  static const violet = Color(0xFF662583);

  /// Vert des feuilles du logo (validation, éléments positifs).
  static const vert = Color(0xFF9BC55F);

  /// Teinte par défaut des conteneurs principaux (rose DSFa très clair).
  static const roseConteneur = Color(0xFFF8E3F1);

  /// Mélange [couleur] sur [fond] (transparence contrôlée).
  static Color _surFond(Color couleur, Color fond, double opacite) =>
      Color.alphaBlend(couleur.withValues(alpha: opacite), fond);

  static Color _plusClair(Color c, double t) => Color.lerp(c, Colors.white, t)!;

  static Color _plusFonce(Color c, double t) => Color.lerp(c, Colors.black, t)!;

  /// Contraste : texte sombre sur fond clair, blanc sur fond sombre.
  static Color _texteSur(Color fond) {
    final luminance = 0.2126 * fond.r + 0.7152 * fond.g + 0.0722 * fond.b;
    return luminance > 0.5 ? const Color(0xFF1D1B20) : Colors.white;
  }

  /// Thème clair. [primaire] et [secondaire] sont personnalisables depuis
  /// Paramètres ▸ Général ; les valeurs par défaut sont les couleurs DSFa.
  static ThemeData light({Color primaire = rose, Color secondaire = violet}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: primaire,
      brightness: Brightness.light,
    ).copyWith(
      primary: primaire,
      onPrimary: _texteSur(primaire),
      primaryContainer: _surFond(primaire, const Color(0xFFFFFFFF), 0.16),
      onPrimaryContainer: _plusFonce(primaire, 0.3),
      secondary: secondaire,
      onSecondary: _texteSur(secondaire),
      secondaryContainer: _surFond(
        secondaire,
        const Color(0xFFFFFFFF),
        0.14,
      ),
      onSecondaryContainer: _plusFonce(secondaire, 0.3),
      tertiary: vert,
      onTertiary: const Color(0xFF1B2A00),
      surface: Colors.white,
      onSurface: const Color(0xFF1D1B20),
    );
    return _base(scheme);
  }

  /// Thème sombre, avec les mêmes couleurs personnalisables.
  static ThemeData dark({Color primaire = rose, Color secondaire = violet}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: primaire,
      brightness: Brightness.dark,
    ).copyWith(
      primary: _plusClair(primaire, 0.38),
      onPrimary: _texteSur(_plusClair(primaire, 0.38)),
      primaryContainer: _plusFonce(secondaire, 0.12),
      onPrimaryContainer: Colors.white,
      secondary: _plusClair(secondaire, 0.38),
      onSecondary: _texteSur(_plusClair(secondaire, 0.38)),
      secondaryContainer: _plusFonce(secondaire, 0.05),
      onSecondaryContainer: Colors.white,
      tertiary: vert,
      onTertiary: const Color(0xFF1B2A00),
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    final isLight = scheme.brightness == Brightness.light;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isLight ? const Color(0xFFF7F5F9) : scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? Colors.white : scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: isLight ? Colors.white : scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        iconColor: scheme.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        minVerticalPadding: 8,
      ),
      // Toutes les saisies de l'application partagent la même apparence :
      // même hauteur, même rayon, mêmes couleurs de libellé, d'aide, d'erreur
      // et d'icônes — y compris les listes déroulantes et les zones de texte.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? Colors.white : scheme.surfaceContainerLow,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        floatingLabelStyle: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        helperStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 11.5,
        ),
        helperMaxLines: 2,
        errorStyle: TextStyle(color: scheme.error, fontSize: 11.5),
        errorMaxLines: 2,
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        iconColor: scheme.onSurfaceVariant,
      ),
      // Hauteur de bouton commune : les barres d'actions restent alignées
      // sans surcharge visuelle.
      buttonTheme: const ButtonThemeData(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          minimumSize: const Size(0, 40),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
          elevation: 0,
          animationDuration: const Duration(milliseconds: 180),
        ).copyWith(
          // Légère animation au survol : la teinte s'intensifie.
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return scheme.onPrimary.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.pressed)) {
              return scheme.onPrimary.withValues(alpha: 0.22);
            }
            return null;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          minimumSize: const Size(0, 40),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
          side: BorderSide(color: scheme.outlineVariant),
          animationDuration: const Duration(milliseconds: 180),
        ).copyWith(
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return BorderSide(color: scheme.primary, width: 1.4);
            }
            return null;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) return scheme.primary;
            return null;
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 38),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          foregroundColor: scheme.primary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          animationDuration: const Duration(milliseconds: 180),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          iconSize: 20,
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: isLight ? Colors.white : scheme.surfaceContainerHigh,
        headerBackgroundColor: scheme.primary,
        headerForegroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: scheme.outline),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.onPrimary;
          }
          return scheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return scheme.surfaceContainerHighest;
        }),
      ),
      // Effet de remplissage de l'onglet actif (pill coloré).
      tabBarTheme: TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        dividerColor: Colors.transparent,
        labelColor: scheme.onPrimary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        splashBorderRadius: BorderRadius.circular(10),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return scheme.primary.withValues(alpha: 0.10);
          }
          return null;
        }),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        space: 1,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isLight ? Colors.white : scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
        selectedLabelTextStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        labelType: NavigationRailLabelType.all,
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(
          scheme.primaryContainer.withValues(alpha: 0.35),
        ),
        headingTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
          fontSize: 13,
        ),
        dataTextStyle: TextStyle(fontSize: 13, color: scheme.onSurface),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isLight ? Colors.white : scheme.surfaceContainerHigh,
        elevation: 6,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        titleTextStyle: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        contentTextStyle: TextStyle(fontSize: 13.5, color: scheme.onSurface),
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.all(8),
        radius: const Radius.circular(8),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return scheme.primary;
          return scheme.outlineVariant;
        }),
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(color: scheme.onInverseSurface, fontSize: 12.5),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
