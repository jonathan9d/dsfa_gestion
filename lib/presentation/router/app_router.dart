import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


import '../providers/app_providers.dart';
import '../screens/activites/activites_screen.dart';
import '../screens/authentification/accueil_screen.dart';
import '../screens/authentification/connexion_screen.dart';
import '../screens/authentification/mot_de_passe_oublie_screen.dart';
import '../screens/banque/banque_screen.dart';
import '../screens/budgets/budgets_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/demarrage/demarrage_screen.dart';
import '../screens/depenses/depenses_screen.dart';
import '../screens/dossier_pj/dossier_pj_screen.dart';
import '../screens/participants/participants_screen.dart';
import '../screens/rapports/rapports_screen.dart';
import '../screens/rapprochement/rapprochement_screen.dart';
import '../screens/parametres/parametres_screen.dart';
import '../screens/profil/profil_screen.dart';
import '../screens/sauvegardes/sauvegardes_screen.dart';
import '../shell/app_shell.dart';

/// Routes de l'application.
class AppRoutes {
  static const demarrage = '/demarrage';
  static const accueil = '/accueil';
  static const connexion = '/connexion';
  static const motDePasseOublie = '/mot-de-passe-oublie';
  static const profil = '/profil';
  static const dashboard = '/';
  static const activites = '/activites';
  static const budgets = '/budgets';
  static const participants = '/participants';
  static const dossierPj = '/dossier-pj';
  static const depenses = '/depenses';
  static const banque = '/banque';
  static const rapprochement = '/rapprochement';
  static const rapports = '/rapports';
  static const parametres = '/parametres';
  static const sauvegardes = '/sauvegardes';
}

/// Entrée de navigation (utilisée par la sidebar et la barre mobile).
class EntreeNavigation {
  const EntreeNavigation({
    required this.path,
    required this.label,
    required this.icon,
    this.iconPlein,
    this.groupe = '',
    this.roleRequis = false,
  });

  final String path;
  final String label;
  final IconData icon;

  /// Icône pleine, affichée lorsque l'onglet est actif.
  final IconData? iconPlein;

  final String groupe;

  /// Réservé aux administrateurs.
  final bool roleRequis;

  /// Icône à afficher selon l'état de sélection (pleine si actif).
  IconData iconePour(bool actif) =>
      actif ? (iconPlein ?? icon) : icon;
}

const entreesNavigation = <EntreeNavigation>[
  EntreeNavigation(
    path: AppRoutes.dashboard,
    label: 'Tableau de bord',
    icon: Icons.dashboard_outlined,
    iconPlein: Icons.dashboard,
  ),
  EntreeNavigation(
    path: AppRoutes.activites,
    label: 'Activités',
    icon: Icons.event_note_outlined,
    iconPlein: Icons.event_note,
  ),
  EntreeNavigation(
    path: AppRoutes.budgets,
    label: 'Budgets',
    icon: Icons.savings_outlined,
    iconPlein: Icons.savings,
  ),
  EntreeNavigation(
    path: AppRoutes.dossierPj,
    label: 'Dossier PJ',
    icon: Icons.folder_shared_outlined,
    iconPlein: Icons.folder_shared,
  ),
  EntreeNavigation(
    path: AppRoutes.depenses,
    label: 'Dépenses',
    icon: Icons.receipt_long_outlined,
    iconPlein: Icons.receipt_long,
  ),
  EntreeNavigation(
    path: AppRoutes.banque,
    label: 'Banque',
    icon: Icons.account_balance_outlined,
    iconPlein: Icons.account_balance,
  ),
  EntreeNavigation(
    path: AppRoutes.rapprochement,
    label: 'Rapprochement',
    icon: Icons.sync_alt_outlined,
    iconPlein: Icons.sync_alt,
  ),
  EntreeNavigation(
    path: AppRoutes.rapports,
    label: 'Rapports',
    icon: Icons.insert_chart_outlined,
    iconPlein: Icons.insert_chart,
    groupe: 'Administration',
  ),
  EntreeNavigation(
    path: AppRoutes.parametres,
    label: 'Paramètres',
    icon: Icons.settings_outlined,
    iconPlein: Icons.settings,
    groupe: 'Administration',
  ),
  EntreeNavigation(
    path: AppRoutes.sauvegardes,
    label: 'Sauvegardes',
    icon: Icons.backup_outlined,
    iconPlein: Icons.backup,
    groupe: 'Administration',
  ),
];

/// Routeur de l'application.
///
/// L'authentification est gérée par redirection : tant qu'aucune session
/// n'est active, l'utilisateur reste sur l'écran de connexion ; dès qu'une
/// session existe, il accède à l'application. Cela évite tout état de
/// chargement bloqué après la connexion.
final appRouterProvider = Provider<GoRouter>((ref) {
  final rafraichissement = ref.watch(sessionRafraichissementProvider);
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: rafraichissement,
    redirect: (context, state) {
      final connecte = ref.read(sessionUtilisateurProvider) != null;
      final emplacement = state.matchedLocation;
      // Écrans accessibles sans session : l'accueil (qui salue l'utilisateur)
      // et le parcours d'identifiants.
      final public =
          emplacement == AppRoutes.accueil ||
          emplacement == AppRoutes.connexion ||
          emplacement == AppRoutes.motDePasseOublie;
      if (!connecte) {
        // Hors session, l'application ouvre d'abord l'écran d'accueil : la
        // salutation précède toujours la demande d'identifiants.
        return public ? null : AppRoutes.accueil;
      }
      if (public || emplacement == AppRoutes.demarrage) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.accueil,
        builder: (_, _) => const AccueilScreen(),
      ),
      GoRoute(
        path: AppRoutes.connexion,
        builder: (_, _) => const ConnexionScreen(),
      ),
      GoRoute(
        path: AppRoutes.motDePasseOublie,
        builder: (_, _) => const MotDePasseOublieScreen(),
      ),
      GoRoute(
        path: AppRoutes.demarrage,
        builder: (_, _) => const DemarrageScreen(),
      ),
      ShellRoute(
      builder: (context, state, child) =>
          AppShell(location: state.uri.path, child: child),
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (_, __) => const DashboardScreen(),
        ),
        GoRoute(
          path: AppRoutes.activites,
          builder: (_, __) => const ActivitesScreen(),
        ),
        GoRoute(
          path: AppRoutes.budgets,
          builder: (_, __) => const BudgetsScreen(),
        ),
        GoRoute(
          path: AppRoutes.participants,
          builder: (_, __) => const ParticipantsScreen(),
        ),
        GoRoute(
          path: AppRoutes.dossierPj,
          builder: (_, __) => const DossierPjScreen(),
        ),
        GoRoute(
          path: AppRoutes.depenses,
          builder: (_, __) => const DepensesScreen(),
        ),
        GoRoute(
          path: AppRoutes.banque,
          builder: (_, __) => const BanqueScreen(),
        ),
        GoRoute(
          path: AppRoutes.rapprochement,
          builder: (_, __) => const RapprochementScreen(),
        ),
        GoRoute(
          path: AppRoutes.rapports,
          builder: (_, __) => const RapportsScreen(),
        ),
        GoRoute(
          path: AppRoutes.parametres,
          builder: (_, __) => const ParametresScreen(),
        ),
        GoRoute(
          path: AppRoutes.profil,
          builder: (_, __) => const ProfilScreen(),
        ),
        GoRoute(
          path: AppRoutes.sauvegardes,
          builder: (_, _) => const SauvegardesScreen(),
        ),
      ],
    ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore_off_outlined, size: 42),
            const SizedBox(height: 12),
            const Text(
              'Cette page n\'existe pas dans l\'application.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Adresse demandée : ${state.uri.path}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => context.go(AppRoutes.dashboard),
              icon: const Icon(Icons.home_outlined),
              label: const Text('Revenir au tableau de bord'),
            ),
          ],
        ),
      ),
    ),
  );
});
