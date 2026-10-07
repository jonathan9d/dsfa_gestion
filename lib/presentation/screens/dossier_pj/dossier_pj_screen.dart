import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';
import '../../widgets/common.dart';
import '../pieces_justificatives/checklist_pj_screen.dart';
import 'presences_indemnites_screen.dart';

/// Dossier PJ : **deux** onglets seulement.
///
/// 1. « Présences & indemnités » — les deux anciens onglets fusionnés en un
///    seul tableau, où le nombre de jours d'activité met à jour la présence.
/// 2. « Pièces justificatives » — la **checklist des PJ requises**, déduite
///    des paramètres, sans aucun autre bandeau ni fiche de contrôle.
class DossierPjScreen extends StatelessWidget {
  const DossierPjScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) => Column(
          children: [
            EnTetePage(
              titre: 'Dossier PJ',
              sousTitre:
                  'Présences et indemnités des participants, puis checklist '
                  'des pièces justificatives requises',
              // La checklist remplace l'ancien écran de contrôle dans l'onglet :
              // les contrôles détaillés (écarts, journal des dépenses) restent
              // accessibles par cette action secondaire.
              actions: [
                OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.controlesPj),
                  icon: const Icon(Icons.fact_check_outlined, size: 18),
                  label: const Text('Contrôles détaillés'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: const BarreOngletsAnimee(
                    onglets: [
                      OngletAnime(
                        label: 'Présences & indemnités',
                        icon: Icons.groups_outlined,
                      ),
                      OngletAnime(
                        label: 'Pièces justificatives',
                        icon: Icons.checklist_outlined,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Expanded(
              child: TabBarView(
                children: [
                  PresencesIndemnitesScreen(imbrique: true),
                  ChecklistPJScreen(imbrique: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
