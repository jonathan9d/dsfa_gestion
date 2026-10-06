import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../providers/providers.dart';

/// Écran de démarrage : logo DSFa, chargement circulaire et mention
/// « Powered by Jonathan ». Il reste affiché au minimum [dureeMinimale] puis
/// pendant toute la préparation des données de référence.
class DemarrageScreen extends ConsumerStatefulWidget {
  const DemarrageScreen({super.key});

  /// Durée minimale d'affichage de l'écran de démarrage.
  ///
  /// Volontairement courte (1 s) : assez pour lire le logo et le chargement,
  /// sans retarder l'accès à l'écran de connexion.
  static const dureeMinimale = Duration(milliseconds: 1000);

  @override
  ConsumerState<DemarrageScreen> createState() => _DemarrageScreenState();
}

class _DemarrageScreenState extends ConsumerState<DemarrageScreen> {
  Timer? _minuteur;

  @override
  void initState() {
    super.initState();
    if (!ref.read(demarrageTermineProvider)) {
      _minuteur = Timer(DemarrageScreen.dureeMinimale, () {
        if (!mounted) return;
        ref.read(demarrageTermineProvider.notifier).state = true;
      });
    }
  }

  @override
  void dispose() {
    _minuteur?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final etat = ref.watch(databaseBootstrapProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: etat.when(
                      loading: () => _contenuChargement(context),
                      error: (error, _) => _contenuErreur(context, error),
                      data: (_) => _contenuChargement(context),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Text(
                'Powered by Jonathan',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenuChargement(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/logo_dsfa1.jpeg',
          width: 240,
          height: 116,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
        const SizedBox(height: 22),
        Text(
          'DSFA Gestion',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Préparation des données de référence…',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 26),
        const SizedBox(
          width: 42,
          height: 42,
          child: CircularProgressIndicator(strokeWidth: 4),
        ),
      ],
    );
  }

  Widget _contenuErreur(BuildContext context, Object error) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/logo_dsfa1.jpeg',
          width: 200,
          height: 88,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 20),
        Text(
          'Impossible de préparer les données',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '$error',
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => ref.invalidate(databaseBootstrapProvider),
          icon: const Icon(Icons.refresh),
          label: const Text('Réessayer'),
        ),
      ],
    );
  }
}
