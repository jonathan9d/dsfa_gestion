import 'package:flutter/material.dart';

import '../../widgets/common.dart';
import '../indemnites/indemnites_screen.dart';
import '../pieces_justificatives/pieces_justificatives_screen.dart';
import '../presences/presences_screen.dart';

/// Dossier PJ : regroupe en un seul onglet les présences, les indemnités et
/// les pièces justificatives, qui concourent tous au contrôle du même dossier.
class DossierPjScreen extends StatelessWidget {
  const DossierPjScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const EnTetePage(
            titre: 'Dossier PJ',
            sousTitre:
                'Présences, indemnités et pièces justificatives — contrôle du dossier',
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
                      label: 'Présences',
                      icon: Icons.calendar_month_outlined,
                    ),
                    OngletAnime(
                      label: 'Indemnités',
                      icon: Icons.payments_outlined,
                    ),
                    OngletAnime(
                      label: 'Pièces justificatives',
                      icon: Icons.attach_file_outlined,
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
                PresencesScreen(imbrique: true),
                IndemnitesScreen(imbrique: true),
                PiecesJustificativesScreen(imbrique: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
