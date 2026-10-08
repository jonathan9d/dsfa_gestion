import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../providers/providers.dart';

class DemarrageScreen extends ConsumerStatefulWidget {
  const DemarrageScreen({super.key});

  static const dureeMinimale = Duration(milliseconds: 2600);

  @override
  ConsumerState<DemarrageScreen> createState() => _DemarrageScreenState();
}

class _DemarrageScreenState extends ConsumerState<DemarrageScreen>
    with TickerProviderStateMixin {
  Timer? _minuteur;
  Timer? _minuteurFin;
  bool _afficherCredit = false;
  late final AnimationController _animation;
  late final AnimationController _progression;
  late final Animation<double> _echelle;
  late final Animation<double> _opacite;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _progression = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
    _echelle = CurvedAnimation(parent: _animation, curve: Curves.easeOutBack);
    _opacite = CurvedAnimation(parent: _animation, curve: Curves.easeOut);
    if (!ref.read(demarrageTermineProvider)) {
      _minuteur = Timer(const Duration(milliseconds: 1800), () {
        if (!mounted) return;
        setState(() => _afficherCredit = true);
      });
      _minuteurFin = Timer(DemarrageScreen.dureeMinimale, () {
        if (!mounted) return;
        ref.read(demarrageTermineProvider.notifier).state = true;
      });
    }
  }

  @override
  void dispose() {
    _minuteur?.cancel();
    _minuteurFin?.cancel();
    _animation.dispose();
    _progression.dispose();
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
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: etat.when(
                      loading: () => _phase(context),
                      error: (error, _) => _contenuErreur(context, error),
                      data: (_) => _phase(context),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _phase(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 320),
    switchInCurve: Curves.easeOutCubic,
    switchOutCurve: Curves.easeInCubic,
    child: _afficherCredit
        ? _contenuCredit(context)
        : _contenuChargement(context),
  );

  Widget _contenuChargement(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return FadeTransition(
      opacity: _opacite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _echelle,
            child: Image.asset(
              'assets/logo_dsfa1.jpeg',
              width: 280,
              height: 138,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(height: 26),
          Text(
            'DSFA Gestion',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Préparation de votre espace de gestion…',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 26),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 300,
              child: AnimatedBuilder(
                animation: _progression,
                builder: (context, _) => LinearProgressIndicator(
                  value: _progression.value,
                  minHeight: 7,
                  backgroundColor: scheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenuCredit(BuildContext context) {
    final theme = Theme.of(context);
    return FadeTransition(
      key: const ValueKey('credit-demarrage'),
      opacity: _opacite,
      child: Text(
        'Powered by JojoDev | Copilot',
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _contenuErreur(BuildContext context, Object error) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/logo_dsfa1.jpeg',
          width: 220,
          height: 100,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 20),
        const Text(
          'Impossible de préparer les données',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text('$error', textAlign: TextAlign.center),
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
