import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/providers/app_providers.dart';
import 'presentation/providers/providers.dart';
import 'presentation/reglages/reglages_affichage.dart';
import 'presentation/router/app_router.dart';
import 'presentation/screens/demarrage/demarrage_screen.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/theme/comportement_defilement.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: DsfaGestionApp()));
}

class DsfaGestionApp extends ConsumerWidget {
  const DsfaGestionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final routeur = ref.watch(appRouterProvider);
    final reglages = ref.watch(reglagesAffichageProvider);
    final couleurs = (
      primaire: reglages.couleurPrimaire,
      secondaire: reglages.couleurSecondaire,
    );

    return MaterialApp.router(
      title: 'DSFA Gestion',
      debugShowCheckedModeBanner: false,
      // Interface entièrement en français : les composants Material
      // (sélecteur de date, menus de sélection, libellés standard) suivent.
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(
        primaire: couleurs.primaire,
        secondaire: couleurs.secondaire,
      ),
      darkTheme: AppTheme.dark(
        primaire: couleurs.primaire,
        secondaire: couleurs.secondaire,
      ),
      themeMode: mode,
      routerConfig: routeur,
      // Défilement adapté au poste de travail : glisser à la souris et pas
      // d'effet élastique (voir [ComportementDefilement]).
      scrollBehavior: const ComportementDefilement(),
      builder: (context, child) {
        // Écran de démarrage : affiché pendant la préparation des données de
        // référence, avec une durée minimale pour rester perceptible.
        final initialisation = ref.watch(databaseBootstrapProvider);
        final demarrageVu = ref.watch(demarrageTermineProvider);
        final Widget contenu;
        if (!demarrageVu || initialisation.isLoading || initialisation.hasError) {
          contenu = const DemarrageScreen();
        } else {
          contenu = child ?? const SizedBox.shrink();
        }

        // Taille de police personnalisée : on conserve l'échelle du système
        // (accessibilité) et on la multiplie par le réglage utilisateur.
        final media = MediaQuery.maybeOf(context);
        Widget result = ReglagesAffichageScope(
          reglages: reglages,
          child: contenu,
        );
        if (media != null) {
          final systeme = media.textScaler.scale(1.0);
          final cible = (systeme * reglages.echellePolice).clamp(0.7, 2.5);
          result = MediaQuery(
            data: media.copyWith(textScaler: TextScaler.linear(cible)),
            child: result,
          );
        }
        return result;
      },
    );
  }
}
