import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'domain/configuration/configuration_app.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/providers/configuration_providers.dart';
import 'presentation/providers/providers.dart';
import 'presentation/reglages/reglages_affichage.dart';
import 'presentation/router/app_router.dart';
import 'presentation/screens/demarrage/demarrage_screen.dart';
import 'services/son_service.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/theme/comportement_defilement.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _demarrerApplication();
}

Future<void> _demarrerApplication() async {
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    await windowManager.setPreventClose(true);
  }
  runApp(const ProviderScope(child: DsfaGestionApp()));
}

class DsfaGestionApp extends ConsumerStatefulWidget {
  const DsfaGestionApp({super.key});

  @override
  ConsumerState<DsfaGestionApp> createState() => _DsfaGestionAppState();
}

class _DsfaGestionAppState extends ConsumerState<DsfaGestionApp>
    with WindowListener {
  bool _fermetureEnCours = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) windowManager.addListener(this);
  }

  @override
  void dispose() {
    if (Platform.isWindows) windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() {
    unawaited(_traiterFermetureFenetre());
  }

  Future<void> _traiterFermetureFenetre() async {
    if (_fermetureEnCours) return;
    _fermetureEnCours = true;
    final reglages = ref.read(reglagesAffichageProvider);
    if (reglages.sauvegardeAutomatique) {
      try {
        await ref
            .read(sauvegardeServiceProvider)
            .sauvegarder(automatique: true);
      } catch (error) {
        if (!mounted) return;
        final quitter = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sauvegarde automatique impossible'),
            content: Text('$error\n\nVoulez-vous quitter sans sauvegarde ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Quitter sans sauvegarde'),
              ),
            ],
          ),
        );
        if (quitter != true || !mounted) {
          _fermetureEnCours = false;
          return;
        }
      }
    }
    await windowManager.setPreventClose(false);
    await windowManager.close();
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final mode = ref.watch(themeModeProvider);
    final routeur = ref.watch(appRouterProvider);
    final reglages = ref.watch(reglagesAffichageProvider);
    // Configuration personnalisée (titres, champs, formules, statuts,
    // rubriques, onglets créés) : diffusée à tout l'arbre de widgets.
    final configuration = ref.watch(configurationProvider);
    final couleurs = (
      primaire: reglages.couleurPrimaire,
      secondaire: reglages.couleurSecondaire,
    );

    return MaterialApp.router(
      title: 'DSFA Gestion',
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: const Duration(milliseconds: 420),
      themeAnimationCurve: Curves.easeInOutCubic,
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
        // Le parcours d'authentification doit rester fluide : l'écran de
        // démarrage ne doit pas masquer la salutation ni le formulaire de
        // connexion. Il est réservé aux utilisateurs déjà connectés, ou à la
        // préparation initiale des données après connexion.
        final initialisation = ref.watch(databaseBootstrapProvider);
        final demarrageVu = ref.watch(demarrageTermineProvider);
        final connecte = ref.watch(sessionUtilisateurProvider) != null;
        final Widget contenu;
        if (!demarrageVu ||
            (connecte &&
                (initialisation.isLoading || initialisation.hasError))) {
          contenu = const DemarrageScreen();
        } else {
          contenu = child ?? const SizedBox.shrink();
        }

        // Taille de police personnalisée : on conserve l'échelle du système
        // (accessibilité) et on la multiplie par le réglage utilisateur.
        final media = MediaQuery.maybeOf(context);
        Widget result = ConfigurationScope(
          configuration: configuration,
          child: ReglagesAffichageScope(reglages: reglages, child: contenu),
        );
        if (media != null) {
          final systeme = media.textScaler.scale(1.0);
          final cible = (systeme * reglages.echellePolice).clamp(0.7, 2.5);
          result = MediaQuery(
            data: media.copyWith(textScaler: TextScaler.linear(cible)),
            child: result,
          );
        }
        if (reglages.motifFond) {
          result = Stack(
            fit: StackFit.expand,
            children: [
              result,
              IgnorePointer(
                child: CustomPaint(
                  painter: _MotifFond(reglages.couleurPrimaire),
                ),
              ),
            ],
          );
        }
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => jouerSonApp(actif: reglages.sonActif),
          child: result,
        );
      },
    );
  }
}

class _MotifFond extends CustomPainter {
  const _MotifFond(this.couleur);

  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final pinceau = Paint()
      ..color = couleur.withValues(alpha: 0.025)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const ecart = 58.0;
    for (var x = 24.0; x < size.width; x += ecart) {
      for (var y = 24.0; y < size.height; y += ecart) {
        canvas.drawCircle(Offset(x, y), 2.2, pinceau);
      }
    }
    canvas
      ..drawCircle(
        Offset(size.width * 0.92, size.height * 0.88),
        size.shortestSide * 0.16,
        pinceau,
      )
      ..drawCircle(
        Offset(size.width * 0.92, size.height * 0.88),
        size.shortestSide * 0.22,
        pinceau,
      );
  }

  @override
  bool shouldRepaint(_MotifFond oldDelegate) => oldDelegate.couleur != couleur;
}
