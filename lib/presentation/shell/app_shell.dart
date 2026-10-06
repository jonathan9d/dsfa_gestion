import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/statuts.dart';
import '../providers/app_providers.dart';
import '../providers/providers.dart';
import '../reglages/reglages_affichage.dart';
import '../router/app_router.dart';
import '../screens/profil/profil_screen.dart';
import '../widgets/common.dart';

/// Coquille responsive : sidebar sur desktop, barre + drawer sur mobile.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  static const _breakpointDesktop = 1000.0;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  Timer? _minuteurSession;

  @override
  void initState() {
    super.initState();
    // L'horodatage d'ouverture est rafraîchi régulièrement : la reconnexion
    // automatique ne dépend donc pas de la durée de la session en cours.
    _minuteurSession = Timer.periodic(const Duration(minutes: 5), (_) {
      if (!mounted) return;
      if (ref.read(sessionUtilisateurProvider) != null) {
        ref.read(sessionRepositoryProvider).marquerOuverture();
      }
    });
  }

  @override
  void dispose() {
    // `ref` ne doit plus être utilisé ici : l'horodatage d'ouverture est
    // enregistré par le minuteur ci-dessus et à chaque démarrage.
    _minuteurSession?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    final largeur = MediaQuery.sizeOf(context).width;
    final estDesktop = largeur >= AppShell._breakpointDesktop;

    final location = widget.location;
    final entreeActive = entreesNavigation.firstWhere(
      (e) =>
          location == e.path || (e.path != '/' && location.startsWith(e.path)),
      orElse: () => entreesNavigation.first,
    );

    if (estDesktop) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(location: location),
            const VerticalDivider(width: 1),
            Expanded(
              child: _FondPage(
                child: _ContenuAnime(location: location, child: child),
              ),
            ),
          ],
        ),
      );
    }

    // Mobile / tablette : destinations principales + drawer complet.
    final destinations = entreesNavigation.take(5).toList();
    final index = destinations.indexWhere((e) => e.path == entreeActive.path);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo_dsfa1.jpeg',
              width: 34,
              height: 30,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            const Text('DSFA Gestion'),
          ],
        ),
        actions: const [
          _Horloge(compact: true),
          SizedBox(width: 4),
        ],
      ),
      drawer: Drawer(child: _DrawerMobile(entreeActive: entreeActive)),
      body: _FondPage(
        child: _ContenuAnime(location: location, child: child),
      ),
      bottomNavigationBar: index < 0
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => context.go(destinations[i].path),
              destinations: [
                for (final e in destinations)
                  NavigationDestination(icon: Icon(e.icon), label: e.label),
              ],
            ),
    );
  }
}

/// Fond de page : léger dégradé institutionnel (rose DSFa → surface) qui
/// s'adapte **automatiquement** au mode clair ou sombre. Il donne de la
/// profondeur à l'interface sans jamais gêner la lisibilité des tableaux.
class _FondPage extends StatelessWidget {
  const _FondPage({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sombre = scheme.brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.alphaBlend(
              scheme.primary.withValues(alpha: sombre ? 0.10 : 0.07),
              scheme.surface,
            ),
            scheme.surface,
          ],
          stops: const [0.0, 0.45],
        ),
      ),
      child: child,
    );
  }
}

/// Contenu de page, avec transition douce entre les écrans.
///
/// Le `ClipRect` évite qu'une page plus large que la zone disponible (tableau
/// très large, dialogue ouvert…) ne déborde du cadre et laisse apparaître des
/// zones vides.
class _ContenuAnime extends StatelessWidget {
  const _ContenuAnime({required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        layoutBuilder: (courant, precedents) => Stack(
          fit: StackFit.expand,
          children: [...precedents, ?courant],
        ),
        child: KeyedSubtree(key: ValueKey<String>(location), child: child),
      ),
    );
  }
}

/// Menu latéral complet (mobile / tablette) avec pied utilisateur.
///
/// Le pied est placé dans un `Flexible` : sur une fenêtre peu haute, c'est la
/// liste des rubriques qui reste toujours visible et défilable, jamais un
/// écran vide.
class _DrawerMobile extends ConsumerWidget {
  const _DrawerMobile({required this.entreeActive});
  final EntreeNavigation entreeActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      key: const ValueKey('menu-lateral'),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
            decoration: BoxDecoration(color: scheme.primaryContainer),
            child: Row(
              children: [
                Image.asset(
                  'assets/logo_dsfa1.jpeg',
                  width: 46,
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'DSFA GESTION',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        'Suivi & contrôle',
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final e in entreesNavigation)
                  ListTile(
                    dense: true,
                    leading: Icon(
                      e.iconePour(e.path == entreeActive.path),
                      color: e.path == entreeActive.path
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                    title: Text(
                      e.label,
                      style: TextStyle(
                        fontWeight: e.path == entreeActive.path
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    selected: e.path == entreeActive.path,
                    selectedTileColor: scheme.primaryContainer.withValues(
                      alpha: 0.35,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(e.path);
                    },
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Pied compact placé sous la liste : la liste garde toute la hauteur
          // restante (aucune zone vide en bas du menu).
          const _PiedUtilisateur(reduite: false),
        ],
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.location});

  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, contraintes) => _contenu(
        context,
        ref,
        // Sur une fenêtre peu haute, le menu devient plus dense afin que
        // **toutes** les rubriques restent visibles, sans défilement.
        dense: contraintes.maxHeight < 800,
      ),
    );
  }

  Widget _contenu(
    BuildContext context,
    WidgetRef ref, {
    required bool dense,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final reduite = ref.watch(sidebarReduiteProvider);
    final groupes = <String, List<EntreeNavigation>>{};
    for (final e in entreesNavigation) {
      groupes.putIfAbsent(e.groupe, () => []).add(e);
    }
    final tailleLogo = reduite ? 30.0 : (dense ? 32.0 : 38.0);

    return AnimatedContainer(
      key: const ValueKey('menu-lateral'),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: reduite ? 80 : 264,
      color: scheme.surface,
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              reduite ? 10 : (dense ? 16 : 20),
              dense ? 12 : 20,
              10,
              dense ? 8 : 14,
            ),
            child: Row(
              mainAxisAlignment: reduite
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(reduite ? 6 : 8),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    'assets/logo_dsfa1.jpeg',
                    width: tailleLogo,
                    height: tailleLogo,
                    fit: BoxFit.contain,
                  ),
                ),
                if (!reduite) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'DSFA GESTION',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: dense ? 14 : 15,
                            color: scheme.onSurface,
                          ),
                        ),
                        if (!dense)
                          Text(
                            'Suivi & contrôle',
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Tooltip(
              message: reduite ? 'Déployer le menu' : 'Replier le menu',
              child: dense
                  ? Align(
                      alignment: reduite
                          ? Alignment.center
                          : Alignment.centerRight,
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        iconSize: 20,
                        icon: Icon(
                          reduite
                              ? Icons.keyboard_double_arrow_right
                              : Icons.keyboard_double_arrow_left,
                        ),
                        onPressed: () => ref
                            .read(sidebarReduiteProvider.notifier)
                            .state = !reduite,
                      ),
                    )
                  : TextButton.icon(
                      onPressed: () => ref
                          .read(sidebarReduiteProvider.notifier)
                          .state = !reduite,
                      icon: Icon(
                        reduite
                            ? Icons.keyboard_double_arrow_right
                            : Icons.keyboard_double_arrow_left,
                        size: 18,
                      ),
                      label: reduite
                          ? const SizedBox.shrink()
                          : const Text(
                              'Replier',
                              style: TextStyle(fontSize: 12.5),
                            ),
                    ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: dense ? 6 : 12),
              children: [
                for (final entry in groupes.entries) ...[
                  if (entry.key.isNotEmpty && !reduite)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        dense ? 8 : 12,
                        20,
                        dense ? 3 : 6,
                      ),
                      child: Text(
                        entry.key.toUpperCase(),
                        style: TextStyle(
                          fontSize: dense ? 9.5 : 10,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  for (final e in entry.value)
                    _SidebarItem(
                      entree: e,
                      reduite: reduite,
                      dense: dense,
                      selectionne:
                          e.path == location ||
                          (e.path != '/' && location.startsWith(e.path)),
                    ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          // Pied utilisateur compact : la liste des rubriques ci-dessus garde
          // toujours l'essentiel de la hauteur, quelle que soit la taille de
          // la fenêtre.
          _PiedUtilisateur(reduite: reduite),
        ],
      ),
    );
  }
}

/// Pied de la sidebar : utilisateur connecté, horloge live, profil, thème,
/// déconnexion. Version compacte : hauteur fixe réduite pour que le menu
/// reste toujours entièrement visible.
class _PiedUtilisateur extends ConsumerWidget {
  const _PiedUtilisateur({required this.reduite});
  final bool reduite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final utilisateur = ref.watch(sessionUtilisateurProvider);
    final mode = ref.watch(themeModeProvider);
    final nom = utilisateur?.nom.trim().isNotEmpty == true
        ? utilisateur!.nom
        : (utilisateur?.identifiant ?? 'Invité');
    final role = RoleUtilisateur.depuisCode(utilisateur?.role).libelle;

    Future<void> basculerTheme() async {
      final nouveau =
          mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      ref.read(themeModeProvider.notifier).state = nouveau;
      try {
        await ref.read(parametresRepositoryProvider).ecrire(
          ReglagesAffichage.cleTheme,
          ReglagesAffichage.themeVersTexte(nouveau),
        );
      } catch (_) {
        // Le basculement visuel reste prioritaire sur la persistance.
      }
    }

    Future<void> deconnecter() async {
      // Confirmation avant déconnexion.
      final ok = await confirmer(
        context,
        titre: 'Se déconnecter',
        message:
            'Voulez-vous vraiment vous déconnecter ? Vous devrez saisir à '
            'nouveau votre mot de passe à la prochaine ouverture.',
        confirmerLabel: 'Se déconnecter',
        destructif: false,
      );
      if (!ok || !context.mounted) return;
      await ref.read(sessionRepositoryProvider).effacer();
      ref.read(sessionUtilisateurProvider.notifier).state = null;
      if (context.mounted) context.go(AppRoutes.connexion);
    }

    Future<void> fermer() async {
      final choix = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const TitreDialogue(
            'Quitter l\'application',
            icone: Icons.power_settings_new_outlined,
          ),
          content: const Text(
            'Voulez-vous créer une sauvegarde avant de fermer DSFA Gestion ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('annuler'),
              child: const Text('Annuler'),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(ctx).pop('quitter'),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Quitter sans sauvegarder'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(ctx).pop('sauvegarder'),
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Sauvegarder et quitter'),
            ),
          ],
        ),
      );
      if (choix == null || choix == 'annuler') return;
      if (choix == 'sauvegarder') {
        var succes = true;
        try {
          await ref.read(sauvegardeServiceProvider).sauvegarder();
        } catch (_) {
          succes = false;
        }
        if (!succes) {
          if (!context.mounted) return;
          final quandMeme = await confirmer(
            context,
            titre: 'Sauvegarde impossible',
            message:
                'La sauvegarde n\'a pas pu être créée. Quitter quand même ?',
            confirmerLabel: 'Quitter',
          );
          if (!quandMeme || !context.mounted) return;
        }
      }
      _fermerApplication();
    }

    if (reduite) {
      return Padding(
        key: const ValueKey('pied-utilisateur'),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: '$nom\n$role',
              child: AvatarUtilisateur(utilisateur: utilisateur, rayon: 16),
            ),
            const SizedBox(height: 4),
            const _Horloge(vertical: true),
            IconButton(
              tooltip: 'Mon profil',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.account_circle_outlined, size: 20),
              onPressed: () => context.go(AppRoutes.profil),
            ),
            IconButton(
              tooltip: 'Thème clair / sombre',
              visualDensity: VisualDensity.compact,
              icon: Icon(
                mode == ThemeMode.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                size: 20,
              ),
              onPressed: basculerTheme,
            ),
            IconButton(
              tooltip: 'Se déconnecter',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.logout_outlined, size: 20),
              onPressed: deconnecter,
            ),
            IconButton(
              tooltip: 'Quitter l\'application',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.power_settings_new, size: 20),
              onPressed: fermer,
            ),
          ],
        ),
      );
    }

    return Padding(
      key: const ValueKey('pied-utilisateur'),
      padding: const EdgeInsets.fromLTRB(12, 8, 6, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AvatarUtilisateur(utilisateur: utilisateur, rayon: 17),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        color: scheme.onSurface,
                      ),
                    ),
                    Text(
                      role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Tooltip(
                message: 'Mon profil',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.account_circle_outlined, size: 20),
                  onPressed: () => context.go(AppRoutes.profil),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(child: _Horloge(compact: true)),
              IconButton(
                tooltip: 'Thème clair / sombre',
                visualDensity: VisualDensity.compact,
                iconSize: 20,
                icon: Icon(
                  mode == ThemeMode.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
                onPressed: basculerTheme,
              ),
              IconButton(
                tooltip: 'Se déconnecter',
                visualDensity: VisualDensity.compact,
                iconSize: 20,
                icon: const Icon(Icons.logout_outlined),
                onPressed: deconnecter,
              ),
              IconButton(
                tooltip: 'Quitter l\'application',
                visualDensity: VisualDensity.compact,
                iconSize: 20,
                icon: const Icon(Icons.power_settings_new),
                onPressed: fermer,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Fermeture de l'application Windows : la sauvegarde éventuelle est déjà
  /// terminée avant cet appel.
  void _fermerApplication() {
    unawaited(SystemNavigator.pop());
    Future<void>.delayed(const Duration(milliseconds: 400), () => exit(0));
  }
}

/// Horloge live (HH:mm:ss), rafraîchie chaque seconde.
class _Horloge extends StatefulWidget {
  const _Horloge({this.compact = false, this.vertical = false});
  final bool compact;
  final bool vertical;

  @override
  State<_Horloge> createState() => _HorlogeState();
}

class _HorlogeState extends State<_Horloge> {
  static final _format = DateFormat('HH:mm:ss');
  static final _formatJour = DateFormat('EEEE dd MMM', 'fr_FR');
  late DateTime _maintenant;
  Timer? _minuteur;

  @override
  void initState() {
    super.initState();
    _maintenant = DateTime.now();
    _minuteur = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _maintenant = DateTime.now());
    });
  }

  @override
  void dispose() {
    _minuteur?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final heure = _format.format(_maintenant);
    if (widget.compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, size: 16, color: scheme.onSurfaceVariant),
            const SizedBox(width: 6),
            // Texte réductible : dans le pied du menu, la largeur disponible
            // peut être étroite (l'horloge ne doit jamais déborder).
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  heure,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (widget.vertical) {
      return Text(
        heure,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
          color: scheme.onSurfaceVariant,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 16, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heure,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: scheme.onSurface,
                  ),
                ),
                Text(
                  _formatJour.format(_maintenant),
                  style: TextStyle(
                    fontSize: 10.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.entree,
    required this.selectionne,
    this.reduite = false,
    this.dense = false,
  });

  final EntreeNavigation entree;
  final bool selectionne;
  final bool reduite;

  /// Version resserrée (fenêtre peu haute) : toutes les rubriques tiennent
  /// dans la hauteur disponible.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final contenu = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selectionne ? scheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.go(entree.path),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: reduite ? 0 : 12,
              vertical: dense ? 7 : 11,
            ),
            child: Row(
              mainAxisAlignment: reduite
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  // Icône pleine lorsque l'onglet est actif.
                  entree.iconePour(selectionne),
                  size: dense ? 19 : 20,
                  color: selectionne
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
                if (!reduite) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entree.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: dense ? 12.5 : 13.5,
                        fontWeight: selectionne
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: selectionne
                            ? scheme.onPrimaryContainer
                            : scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: dense ? 1 : 2,
      ),
      child: reduite
          ? Tooltip(message: entree.label, child: contenu)
          : contenu,
    );
  }
}
