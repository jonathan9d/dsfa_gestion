import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/statuts.dart';

final _fmtMontant = NumberFormat('#,##0', 'fr_FR');
final _fmtDate = DateFormat('dd/MM/yyyy');

/// Logos officiels DSFa (les deux variantes livrées dans les assets).
const logoDsfa = 'assets/logo_dsfa1.jpeg';
const logoDsfaRose = 'assets/logo_dsfa2.jpeg';

String formatMontant(num? valeur) =>
    valeur == null ? '—' : '${_fmtMontant.format(valeur)} Ar';

String formatDate(DateTime? date) => date == null ? '—' : _fmtDate.format(date);

/// Couleurs sémantiques de contrôle, **adaptées automatiquement** au thème
/// (mode clair ou sombre) pour rester lisibles sans changer de sens.
Color vertValide(BuildContext context) => _semantique(
  context,
  clair: const Color(0xFF2E7D32),
  sombre: const Color(0xFF81C784),
);

Color rougeAlerte(BuildContext context) => _semantique(
  context,
  clair: const Color(0xFFC62828),
  sombre: const Color(0xFFEF5350),
);

Color ambreAttention(BuildContext context) => _semantique(
  context,
  clair: const Color(0xFFF9A825),
  sombre: const Color(0xFFFFD54F),
);

Color _semantique(
  BuildContext context, {
  required Color clair,
  required Color sombre,
}) => Theme.of(context).colorScheme.brightness == Brightness.dark
    ? sombre
    : clair;

/// Largeur de contenu d'un dialogue, bornée à l'écran de l'appareil.
///
/// Évite les débordements horizontaux des formulaires sur téléphone même
/// quand le formulaire est pensé pour le bureau.
double largeurDialogue(BuildContext context, double max) {
  final largeur = MediaQuery.sizeOf(context).width;
  return (largeur - 48).clamp(240.0, max);
}

/// Titre de dialogue standard : libellé, sous-titre facultatif, icône et
/// **bouton de fermeture explicite** (« × »).
///
/// Le bouton renvoie `null` au `showDialog` d'origine — donc l'annulation —
/// exactement comme un clic en dehors du dialogue ou la touche `Échap`.
/// On peut ainsi revenir en arrière sans chercher l'action « Annuler ».
class TitreDialogue extends StatelessWidget {
  const TitreDialogue(this.titre, {this.sousTitre, this.icone, super.key});

  final String titre;
  final String? sousTitre;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icone != null) ...[
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icone, size: 18, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                titre,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              if (sousTitre != null) ...[
                const SizedBox(height: 3),
                Text(
                  sousTitre!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          tooltip: 'Fermer',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.close, size: 20),
          visualDensity: VisualDensity.compact,
          style: IconButton.styleFrom(foregroundColor: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// En-tête de page avec titre, sous-titre et actions.
class EnTetePage extends StatelessWidget {
  const EnTetePage({
    required this.titre,
    this.sousTitre,
    this.actions = const [],
    super.key,
  });

  final String titre;
  final String? sousTitre;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 34,
            margin: const EdgeInsets.only(top: 4, right: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    // Charte DSFa : titres / en-têtes en rose institutionnel.
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (sousTitre != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    sousTitre!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      // Charte DSFa : sous-titres en violet.
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions.isNotEmpty)
            Wrap(spacing: 8, runSpacing: 8, children: actions),
        ],
      ),
    );
  }
}

/// Carte de section avec titre optionnel.
class CarteSection extends StatelessWidget {
  const CarteSection({
    required this.child,
    this.titre,
    this.actions = const [],
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final Widget child;
  final String? titre;
  final List<Widget> actions;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (titre != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      titre!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...actions,
                ],
              ),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

/// Carte d'indicateur (KPI).
///
/// Variante [compact] : une ligne titre + icône puis la valeur — cartes
/// réduites, alignées sur une seule rangée.
class CarteIndicateur extends StatelessWidget {
  const CarteIndicateur({
    required this.titre,
    required this.valeur,
    this.icone,
    this.couleur,
    this.sousTitre,
    this.compact = false,
    super.key,
  });

  final String titre;
  final String valeur;
  final IconData? icone;
  final Color? couleur;
  final String? sousTitre;

  /// Format réduit (tableau de bord, rangée d'indemnités…).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = couleur ?? theme.colorScheme.primary;
    if (compact) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (icone != null) ...[
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: c.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Icon(icone, size: 14, color: c),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      titre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  valeur,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (sousTitre != null) ...[
                const SizedBox(height: 2),
                Text(
                  sousTitre!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10.5,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icone != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icone, size: 18, color: c),
                  ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              titre,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                valeur,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (sousTitre != null) ...[
              const SizedBox(height: 2),
              Text(
                sousTitre!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pastille de statut (icône + libellé colorés).
class PastilleStatut extends StatelessWidget {
  const PastilleStatut({required this.statut, this.compact = false, super.key});

  final StatutControle statut;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final couleur = statut.color(scheme);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: couleur.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statut.icon, size: compact ? 12 : 14, color: couleur),
          const SizedBox(width: 5),
          Text(
            statut.libelle,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              color: couleur,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Interrupteur compact : même comportement qu'un `Switch`, mais plus petit
/// (utile pour les lignes de tableau, les listes et les formulaires denses).
class SwitchCompact extends StatelessWidget {
  const SwitchCompact({
    required this.value,
    required this.onChanged,
    this.infobulle,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? infobulle;

  @override
  Widget build(BuildContext context) {
    final interrupteur = SizedBox(
      width: 40,
      height: 24,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Switch(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
    return infobulle == null
        ? interrupteur
        : Tooltip(message: infobulle!, child: interrupteur);
  }
}

/// Ligne avec libellé et interrupteur compact (remplace `SwitchListTile`).
class LigneBascule extends StatelessWidget {
  const LigneBascule({
    required this.label,
    required this.value,
    required this.onChanged,
    this.sousTitre,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? sousTitre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.bodyMedium),
                  if (sousTitre != null)
                    Text(
                      sousTitre!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SwitchCompact(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

/// Champ de recherche standard.
class ChampRecherche extends StatelessWidget {
  const ChampRecherche({
    required this.controller,
    this.onChanged,
    this.hint = 'Rechercher…',
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  controller.clear();
                  onChanged?.call('');
                },
              ),
      ),
    );
  }
}

/// État vide : explique simplement pourquoi il n'y a rien à afficher.
class EtatVide extends StatelessWidget {
  const EtatVide({
    required this.message,
    this.icone = Icons.inbox_outlined,
    this.titre,
    this.action,
    super.key,
  });

  final String message;
  final IconData icone;
  final String? titre;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // L'état vide s'adapte aux fenêtres basses : sur une zone réduite (petit
    // écran, volet replié), le bloc se resserre puis devient défilant au lieu
    // de déborder — rien n'est jamais coupé.
    return LayoutBuilder(
      builder: (context, contraintes) {
        final basse =
            contraintes.maxHeight.isFinite && contraintes.maxHeight < 260;
        final corps = Padding(
          padding: EdgeInsets.all(basse ? 14 : 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(basse ? 8 : 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icone,
                    size: basse ? 22 : 34,
                    color: theme.colorScheme.primary.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: basse ? 8 : 16),
                if (titre != null) ...[
                  Text(
                    titre!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: basse ? 12.5 : null,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (action != null) ...[
                  SizedBox(height: basse ? 10 : 18),
                  action!,
                ],
              ],
            ),
          ),
        );
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: contraintes.maxHeight.isFinite
                  ? contraintes.maxHeight
                  : 0,
            ),
            child: Center(child: corps),
          ),
        );
      },
    );
  }
}

/// Traduit une erreur technique en message compréhensible par tout le monde.
String messageErreurLisible(Object erreur) {
  final texte = erreur.toString();
  final minuscule = texte.toLowerCase();
  if (minuscule.contains('socketexception') ||
      minuscule.contains('connection') ||
      minuscule.contains('réseau') ||
      minuscule.contains('network')) {
    return 'La connexion a échoué. Vérifiez votre réseau puis réessayez.';
  }
  if (minuscule.contains('permission') ||
      minuscule.contains('access is denied')) {
    return 'Accès refusé : l\'application n\'a pas la permission '
        'd\'effectuer cette opération.';
  }
  if (minuscule.contains('file system') ||
      minuscule.contains('cannot find') ||
      minuscule.contains('introuvable') ||
      minuscule.contains('no such file')) {
    return 'Le fichier recherché est introuvable. '
        'Il a peut-être été déplacé ou supprimé.';
  }
  if (minuscule.contains('unique constraint') ||
      minuscule.contains('unique') ||
      minuscule.contains('duplicate')) {
    return 'Cet enregistrement existe déjà : les doublons ne sont pas autorisés.';
  }
  if (minuscule.contains('foreign key') || minuscule.contains('constraint')) {
    return 'Cet élément est utilisé ailleurs dans l\'application : '
        'il ne peut pas être supprimé en l\'état.';
  }
  if (minuscule.contains('database') || minuscule.contains('sqlite')) {
    return 'Les données n\'ont pas pu être enregistrées. '
        'Fermez puis relancez l\'application si le problème persiste.';
  }
  return 'L\'opération n\'a pas pu aboutir. Détail technique : $texte';
}

/// Affiche une erreur de chargement dans un langage clair.
class EtatErreur extends StatelessWidget {
  const EtatErreur({
    required this.erreur,
    this.onReessayer,
    this.titre = 'Impossible d\'afficher les données',
    super.key,
  });

  final Object erreur;
  final VoidCallback? onReessayer;
  final String titre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 40,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 14),
              Text(
                titre,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                messageErreurLisible(erreur),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (onReessayer != null) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: onReessayer,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Demande confirmation avant une action destructive.
Future<bool> confirmer(
  BuildContext context, {
  required String titre,
  required String message,
  String confirmerLabel = 'Confirmer',
  bool destructif = true,
}) async {
  final res = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: TitreDialogue(
        titre,
        icone: destructif
            ? Icons.warning_amber_rounded
            : Icons.help_outline_rounded,
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          style: destructif
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                )
              : null,
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmerLabel),
        ),
      ],
    ),
  );
  return res ?? false;
}

/// Notification (message court en bas de l'écran).
void notifier(BuildContext context, String message, {bool erreur = false}) {
  final theme = Theme.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            Icon(
              erreur ? Icons.error_outline : Icons.check_circle_outline,
              color: erreur ? Colors.white : theme.colorScheme.onInverseSurface,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: erreur
                      ? Colors.white
                      : theme.colorScheme.onInverseSurface,
                ),
              ),
            ),
            if (erreur)
              IconButton(
                tooltip: 'Fermer',
                icon: const Icon(Icons.close, size: 18, color: Colors.white),
                onPressed: () =>
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              ),
          ],
        ),
        backgroundColor: erreur ? Colors.red.shade700 : null,
        duration: Duration(seconds: erreur ? 6 : 3),
      ),
    );
}

/// Affiche le message d'erreur d'un formulaire sous un champ.
String? validateurObligatoire(String? valeur, {String champ = 'Ce champ'}) {
  if (valeur == null || valeur.trim().isEmpty) {
    return '$champ est obligatoire';
  }
  return null;
}

String? validateurMontant(String? valeur, {bool obligatoire = false}) {
  if (valeur == null || valeur.trim().isEmpty) {
    return obligatoire ? 'Montant obligatoire' : null;
  }
  final n = double.tryParse(valeur.replaceAll(' ', '').replaceAll(',', '.'));
  if (n == null) return 'Montant invalide';
  if (n < 0) return 'Le montant doit être positif';
  return null;
}

/// Vérifie qu'une valeur est **choisie dans une liste de référence** (celle des
/// paramètres) : aucune rubrique, unité ou type ne peut être saisi librement.
String? validateurReference(
  String? valeur,
  List<String> valeurs, {
  String champ = 'Ce champ',
  bool obligatoire = true,
}) {
  final manquant = validateurObligatoire(valeur, champ: champ);
  if (manquant != null) return obligatoire ? manquant : null;
  final v = valeur!.trim().toLowerCase();
  if (valeurs.any((e) => e.trim().toLowerCase() == v)) return null;
  if (valeurs.isEmpty) return null;
  return '$champ doit être choisi dans les paramètres';
}

/// Vérifie une **année** : quatre chiffres, comprise entre 2000 et 2100.
String? validateurAnnee(String? valeur, {String champ = 'L’année'}) {
  final manquant = validateurObligatoire(valeur, champ: champ);
  if (manquant != null) return manquant;
  final n = int.tryParse(valeur!.trim());
  if (n == null) return '$champ : nombre entier attendu';
  if (n < 2000 || n > 2100)
    return '$champ doit être comprise entre 2000 et 2100';
  return null;
}

/// Vérifie qu'un champ numérique est un nombre **strictement positif**
/// (quantité, jours, taux, prix unitaire…).
String? validateurNombrePositif(
  String? valeur, {
  String champ = 'Ce champ',
  bool obligatoire = true,
  bool zeroAutorise = false,
}) {
  if (valeur == null || valeur.trim().isEmpty) {
    return obligatoire ? '$champ est obligatoire' : null;
  }
  final n = double.tryParse(
    valeur.trim().replaceAll(' ', '').replaceAll(',', '.'),
  );
  if (n == null) return '$champ : nombre attendu';
  if (n < 0) return '$champ doit être positif';
  if (n == 0 && !zeroAutorise) return '$champ doit être supérieur à 0';
  return null;
}

/// Description d'un onglet pour [BarreOngletsAnimee].
class OngletAnime {
  const OngletAnime({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

/// Barre d'onglets avec **animation de remplissage** : un fond coloré glisse
/// vers l'onglet sélectionné. À placer sous un `DefaultTabController` (elle
/// pilote le même contrôleur que le `TabBarView` associé).
class BarreOngletsAnimee extends StatelessWidget {
  const BarreOngletsAnimee({required this.onglets, super.key});

  final List<OngletAnime> onglets;

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final position =
              controller.animation?.value ?? controller.index.toDouble();
          return LayoutBuilder(
            builder: (context, contraintes) {
              final largeur = contraintes.maxWidth / onglets.length;
              return SizedBox(
                height: 48,
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      left: largeur * position,
                      top: 0,
                      bottom: 0,
                      width: largeur,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < onglets.length; i++)
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(9),
                              onTap: () => controller.animateTo(i),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        onglets[i].icon,
                                        size: 18,
                                        color: controller.index == i
                                            ? scheme.onPrimary
                                            : scheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          onglets[i].label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: controller.index == i
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            color: controller.index == i
                                                ? scheme.onPrimary
                                                : scheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Champ texte avec **menu déroulant** de suggestions existantes, présent sur
/// **tous** les champs de saisie.
///
/// La saisie reste toujours libre : si la valeur souhaitée n'existe pas encore,
/// l'utilisateur la tape directement. Le menu propose les valeurs déjà
/// enregistrées (et, le cas échéant, une action « nouvelle valeur » ou
/// « générer automatiquement »).
class ChampListe extends StatelessWidget {
  const ChampListe({
    required this.controller,
    required this.label,
    this.valeurs = const [],
    this.prefixIcon,
    this.hint,
    this.helperText,
    this.onChanged,
    this.validator,
    this.onNouvelle,
    this.onSaisieAuto,
    this.saisieAutoLabel = 'Générer automatiquement',
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final List<String> valeurs;
  final IconData? prefixIcon;
  final String? hint;
  final String? helperText;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  /// Appelé lorsque l'utilisateur choisit « Ajouter une nouvelle valeur… ».
  final VoidCallback? onNouvelle;

  /// Appelé lorsque l'utilisateur choisit « Générer automatiquement ».
  final VoidCallback? onSaisieAuto;
  final String saisieAutoLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = valeurs.where((v) => v.trim().isNotEmpty).toList()..sort();
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
        suffixIconConstraints: const BoxConstraints(minWidth: 32),
        suffixIcon: PopupMenuButton<String>(
          tooltip: 'Choisir dans la liste',
          padding: EdgeInsets.zero,
          icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
          onSelected: (v) {
            if (v == '__nouvelle__') {
              onNouvelle?.call();
              return;
            }
            if (v == '__auto__') {
              onSaisieAuto?.call();
              return;
            }
            controller.text = v;
            controller.selection = TextSelection.collapsed(
              offset: controller.text.length,
            );
            onChanged?.call(v);
          },
          itemBuilder: (context) => [
            if (options.isEmpty)
              PopupMenuItem(
                enabled: false,
                height: 40,
                child: Text(
                  'Aucune valeur enregistrée',
                  style: theme.textTheme.bodySmall,
                ),
              )
            else
              for (final v in options)
                PopupMenuItem(
                  value: v,
                  height: 40,
                  child: Text(
                    v,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 13.5,
                    ),
                  ),
                ),
            if (onNouvelle != null || onSaisieAuto != null)
              const PopupMenuDivider(),
            if (onSaisieAuto != null)
              PopupMenuItem(
                value: '__auto__',
                height: 40,
                child: Row(
                  children: [
                    Icon(
                      Icons.autorenew,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      saisieAutoLabel,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            if (onNouvelle != null)
              PopupMenuItem(
                value: '__nouvelle__',
                height: 40,
                child: Row(
                  children: [
                    Icon(Icons.add, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Ajouter une nouvelle valeur…',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Champ numérique avec flèches haut/bas pour incrémenter ou décrémenter.
class ChampNombre extends StatelessWidget {
  const ChampNombre({
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.onChanged,
    this.validator,
    this.decimales = false,
    this.step = 1,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final VoidCallback? onChanged;
  final String? Function(String?)? validator;
  final bool decimales;
  final double step;

  double get _valeur =>
      double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;

  void _ajuster(double delta) {
    final n = _valeur + delta;
    if (n < 0) return;
    controller.text = decimales ? n.toStringAsFixed(2) : n.round().toString();
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
    onChanged?.call();
  }

  Widget _fleche(IconData icone, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: SizedBox(height: 18, width: 30, child: Icon(icone, size: 18)),
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimales),
      onChanged: (_) => onChanged?.call(),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
        suffixIconConstraints: const BoxConstraints(maxWidth: 36),
        suffixIcon: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _fleche(Icons.keyboard_arrow_up, () => _ajuster(step)),
            _fleche(Icons.keyboard_arrow_down, () => _ajuster(-step)),
          ],
        ),
      ),
    );
  }
}
