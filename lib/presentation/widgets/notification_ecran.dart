import 'dart:async';

import 'package:flutter/material.dart';

/// Notification affichée **dans la fenêtre de l'application**, dans le style
/// d'une notification Windows (coin supérieur droit, carte, ombre, accent).
///
/// Elle sert de relais visible lorsque le système n'affiche pas la
/// notification native : le code de vérification reste toujours consultable,
/// y compris dans un environnement où les notifications sont désactivées.
void afficherNotificationEcran(
  BuildContext context, {
  required String titre,
  required String message,
  String? code,
  String pied = 'DSFA Gestion',
  Duration duree = const Duration(seconds: 30),
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  late OverlayEntry entree;
  entree = OverlayEntry(
    builder: (_) => _NotificationEcran(
      titre: titre,
      message: message,
      code: code,
      pied: pied,
      duree: duree,
      onFermer: () {
        if (entree.mounted) entree.remove();
      },
    ),
  );
  overlay.insert(entree);
}

class _NotificationEcran extends StatefulWidget {
  const _NotificationEcran({
    required this.titre,
    required this.message,
    required this.pied,
    required this.duree,
    required this.onFermer,
    this.code,
  });

  final String titre;
  final String message;
  final String? code;
  final String pied;
  final Duration duree;
  final VoidCallback onFermer;

  @override
  State<_NotificationEcran> createState() => _NotificationEcranState();
}

class _NotificationEcranState extends State<_NotificationEcran>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controleur = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  Timer? _minuteur;
  bool _sourisDessus = false;

  @override
  void initState() {
    super.initState();
    _controleur.forward();
    _programmerFermeture();
  }

  void _programmerFermeture() {
    _minuteur?.cancel();
    _minuteur = Timer(widget.duree, () {
      if (!mounted || _sourisDessus) return;
      _fermer();
    });
  }

  void _fermer() {
    _controleur.reverse().then((_) {
      if (mounted) widget.onFermer();
    });
  }

  @override
  void dispose() {
    _minuteur?.cancel();
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Positioned(
      top: 16,
      right: 16,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.35, -0.4),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _controleur, curve: Curves.easeOutCubic),
        ),
        child: FadeTransition(
          opacity: _controleur,
          child: MouseRegion(
            onEnter: (_) => _sourisDessus = true,
            onExit: (_) {
              _sourisDessus = false;
              _programmerFermeture();
            },
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              color: scheme.surface,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 320,
                  maxWidth: 400,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.notifications_active_outlined,
                              size: 18,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.titre,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Fermer',
                            iconSize: 16,
                            visualDensity: VisualDensity.compact,
                            onPressed: _fermer,
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (widget.code != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: scheme.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Code de vérification',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              SelectableText(
                                widget.code!,
                                style: TextStyle(
                                  fontSize: 26,
                                  letterSpacing: 6,
                                  fontWeight: FontWeight.w700,
                                  color: scheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        widget.pied,
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
