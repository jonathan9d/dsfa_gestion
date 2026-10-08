import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../router/app_router.dart';
import '../../widgets/common.dart';

/// Écran d'accueil affiché **avant** le formulaire de connexion.
///
/// L'application salue d'abord l'utilisateur (« Bonjour », ou « Bonsoir »
/// selon l'heure, suivi de son prénom lorsqu'il est connu), puis rejoint
/// **automatiquement** la page de connexion après [dureeAvantConnexion].
/// Aucun bouton ni raccourci clavier : la salutation s'affiche, on avance.
/// La salutation n'apparaît donc *pas* dans le formulaire d'identifiants.
class AccueilScreen extends ConsumerStatefulWidget {
  const AccueilScreen({super.key});

  /// Durée de l'animation d'apparition du contenu.
  static const dureeAnimation = Duration(milliseconds: 650);

  /// Durée d'affichage de la salutation avant la connexion automatique.
  static const dureeAvantConnexion = Duration(milliseconds: 1500);

  @override
  ConsumerState<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends ConsumerState<AccueilScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: AccueilScreen.dureeAnimation,
  )..forward();

  /// Minuteur du passage automatique vers l'écran de connexion.
  Timer? _minuteur;

  /// Prénom (ou nom) du dernier utilisateur connu.
  String? _destinataire;

  String get _salutation => switch (DateTime.now().hour) {
    < 12 => 'Bonjour',
    < 18 => 'Bon après-midi',
    _ => 'Bonsoir',
  };

  @override
  void initState() {
    super.initState();
    // Passage automatique à la connexion après l'affichage de la salutation.
    _minuteur = Timer(AccueilScreen.dureeAvantConnexion, () {
      if (!mounted) return;
      context.go(AppRoutes.connexion);
    });
    // Le nom du dernier utilisateur connecté personnalise la salutation.
    // Tant qu'il n'est pas chargé, on affiche simplement « Bonjour ».
    Future.microtask(() async {
      final identifiant = await ref
          .read(sessionRepositoryProvider)
          .dernierIdentifiant();
      if (!mounted || identifiant == null || identifiant.isEmpty) return;
      final utilisateur = await ref
          .read(authentificationRepositoryProvider)
          .parIdentifiant(identifiant);
      if (!mounted || utilisateur == null) return;
      final prenom = utilisateur.prenomUtilisateur?.trim() ?? '';
      final nom = utilisateur.nom.trim();
      final affiche = prenom.isNotEmpty ? prenom : nom;
      if (affiche.isEmpty) return;
      setState(() => _destinataire = affiche);
    });
  }

  @override
  void dispose() {
    _minuteur?.cancel();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primaryContainer.withValues(alpha: 0.55),
              scheme.surface,
              scheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, contraintes) => SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (contraintes.maxHeight - 48).clamp(0, 4000),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: _contenu(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _contenu() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final destinataire = _destinataire;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _apparition(
          0,
          0.6,
          Image.asset(
            logoDsfa,
            width: 260,
            height: 110,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
        ),
        const SizedBox(height: 26),
        _apparition(
          0.15,
          0.75,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    DateTime.now().hour < 18
                        ? Icons.wb_sunny_outlined
                        : Icons.nightlight_outlined,
                    size: 30,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      destinataire == null
                          ? _salutation
                          : '$_salutation $destinataire',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Apparition douce : fondu + léger glissement vers le haut.
  Widget _apparition(double debut, double fin, Widget enfant) {
    final animation = CurvedAnimation(
      parent: _animation,
      curve: Interval(
        debut.clamp(0, 1),
        fin.clamp(0, 1),
        curve: Curves.easeOutCubic,
      ),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.10),
          end: Offset.zero,
        ).animate(animation),
        child: enfant,
      ),
    );
  }
}
