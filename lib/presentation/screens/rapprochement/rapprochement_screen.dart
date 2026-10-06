import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models.dart';
import '../../../domain/statuts.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/tableau.dart';

/// Rapprochement bancaire : journal de banque vs relevé bancaire.
class RapprochementScreen extends ConsumerWidget {
  const RapprochementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultat = ref.watch(rapprochementProvider);
    return Scaffold(
      body: Column(
        children: [
          EnTetePage(
            titre: 'Rapprochement bancaire',
            sousTitre:
                'Comparaison entre le journal de banque et le relevé bancaire',
            actions: [
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(rapprochementProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Recalculer'),
              ),
            ],
          ),
          Expanded(
            child: resultat.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EtatErreur(
                erreur: e,
                onReessayer: () => ref.invalidate(rapprochementProvider),
              ),
              data: (r) => _Contenu(resultat: r),
            ),
          ),
        ],
      ),
    );
  }
}

class _Contenu extends StatelessWidget {
  const _Contenu({required this.resultat});
  final ResultatRapprochement resultat;

  @override
  Widget build(BuildContext context) {
    final rapproches = resultat.lignes
        .where((l) => l.statut == StatutRapprochement.rapproche)
        .length;
    final differences = resultat.lignes
        .where((l) => l.statut == StatutRapprochement.difference)
        .length;
    final nonTrouves = resultat.lignes
        .where((l) => l.statut == StatutRapprochement.nonTrouve)
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final colonnes = c.maxWidth > 1100
                ? 4
                : c.maxWidth > 640
                ? 2
                : 1;
            const espace = 16.0;
            final largeur = colonnes == 1
                ? c.maxWidth
                : (c.maxWidth - espace * (colonnes - 1)) / colonnes;
            return Wrap(
              spacing: espace,
              runSpacing: espace,
              children: [
                SizedBox(
                  width: largeur,
                  child: CarteIndicateur(
                    titre: 'Solde rapproché journal',
                    valeur: formatMontant(resultat.soldeJournal),
                    icone: Icons.account_balance_outlined,
                    couleur: const Color(0xFF1F4E79),
                  ),
                ),
                SizedBox(
                  width: largeur,
                  child: CarteIndicateur(
                    titre: 'Solde rapproché relevé',
                    valeur: formatMontant(resultat.soldeReleve),
                    icone: Icons.receipt_outlined,
                    couleur: const Color(0xFF37474F),
                  ),
                ),
                SizedBox(
                  width: largeur,
                  child: CarteIndicateur(
                    titre: 'Écart',
                    valeur: formatMontant(resultat.ecart),
                    icone: resultat.equilibre
                        ? Icons.check_circle_outline
                        : Icons.warning_amber_rounded,
                    couleur: resultat.equilibre
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828),
                    sousTitre: resultat.equilibre
                        ? 'Soldes équilibrés'
                        : 'Un écart subsiste',
                  ),
                ),
                SizedBox(
                  width: largeur,
                  child: CarteIndicateur(
                    titre: 'Lignes analysées',
                    valeur: '${resultat.lignes.length}',
                    icone: Icons.compare_arrows,
                    couleur: const Color(0xFF6A1B9A),
                    sousTitre:
                        '$rapproches rapprochées · $differences différences · $nonTrouves non trouvées',
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        TableauGestion<LigneRapprochement>(
            lignes: resultat.lignes,
            cleLigne: (l) =>
                '${l.reference}|${l.date?.toIso8601String() ?? ''}|${l.libelle}|'
                '${l.montantJournal}',
            taillePage: 10,
            messageVide:
                'Aucune ligne à rapprocher pour le moment.\n'
                'Ajoutez des opérations bancaires et un relevé, puis relancez '
                'le calcul.',
            colonnes: [
              ColonneTableau(
                label: 'Date',
                flex: 2,
                valeur: (l) => formatDate(l.date),
                cleTri: (l) => l.date,
              ),
              ColonneTableau(
                label: 'Référence',
                flex: 3,
                valeur: (l) => l.reference,
              ),
              ColonneTableau(
                label: 'Libellé',
                flex: 5,
                valeur: (l) => l.libelle,
              ),
              ColonneTableau(
                label: 'Montant journal',
                flex: 3,
                numerique: true,
                valeur: (l) => formatMontant(l.montantJournal),
                cleTri: (l) => l.montantJournal,
              ),
              ColonneTableau(
                label: 'Montant relevé',
                flex: 3,
                numerique: true,
                valeur: (l) => formatMontant(l.montantReleve),
                cleTri: (l) => l.montantReleve,
              ),
              ColonneTableau(
                label: 'Écart',
                flex: 3,
                numerique: true,
                valeur: (l) => formatMontant(l.ecart),
                cleTri: (l) => l.ecart,
                cellule: (context, l) => Text(
                  formatMontant(l.ecart),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: l.ecart.abs() < 0.000001
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828),
                  ),
                ),
              ),
              ColonneTableau(
                label: 'Statut',
                flex: 3,
                valeur: (l) => l.statut.libelle,
                cellule: (_, l) => _PastilleRapprochement(statut: l.statut),
              ),
            ],
        ),
      ],
    );
  }
}

class _PastilleRapprochement extends StatelessWidget {
  const _PastilleRapprochement({required this.statut});
  final StatutRapprochement statut;

  @override
  Widget build(BuildContext context) {
    final (couleur, icone) = switch (statut) {
      StatutRapprochement.rapproche => (
        const Color(0xFF2E7D32),
        Icons.check_circle,
      ),
      StatutRapprochement.difference => (
        const Color(0xFFF9A825),
        Icons.warning_amber_rounded,
      ),
      StatutRapprochement.nonTrouve => (const Color(0xFFC62828), Icons.cancel),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 13, color: couleur),
          const SizedBox(width: 5),
          Text(
            statut.libelle,
            style: TextStyle(
              fontSize: 11.5,
              color: couleur,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
