import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/database/database.dart';
import '../../data/repositories/activite_repository.dart';
import '../../domain/models.dart';
import '../../domain/regles_parametres.dart';
import '../../domain/services/rapport_financier_service.dart';
import '../../domain/statuts.dart';
import 'providers.dart';
import '../../services/excel_import_service.dart';

// --- Préférences d'interface ---

/// Thème de l'interface. Par défaut **automatique** : l'application suit le
/// réglage clair/sombre du système et bascule toute seule. L'utilisateur peut
/// forcer un mode depuis les Paramètres (le choix est conservé).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final roleProvider = StateProvider<RoleUtilisateur>(
  (ref) => RoleUtilisateur.admin,
);

final sessionUtilisateurProvider = StateProvider<Utilisateur?>((ref) => null);

/// Repli de la barre latérale (mode « concentration » sur le contenu).
final sidebarReduiteProvider = StateProvider<bool>((ref) => false);

/// L'écran de démarrage a-t-il été affiché suffisamment longtemps ?
/// Tant qu'il est à `false`, l'application reste sur l'écran de démarrage.
final demarrageTermineProvider = StateProvider<bool>((ref) => false);

/// Notifie le routeur lorsque l'état de connexion change, afin que
/// la redirection (connexion ↔ application) soit appliquée immédiatement.
class RafraichissementSession extends ChangeNotifier {
  void rafraichir() => notifyListeners();
}

final sessionRafraichissementProvider = Provider<RafraichissementSession>((
  ref,
) {
  final rafraichissement = RafraichissementSession();
  ref.listen<Utilisateur?>(sessionUtilisateurProvider, (_, _) {
    rafraichissement.rafraichir();
  });
  ref.onDispose(rafraichissement.dispose);
  return rafraichissement;
});

final configurationCompteProvider = FutureProvider<bool>(
  (ref) => ref.watch(authentificationRepositoryProvider).aUnCompteConfigure(),
);

/// Liste des comptes utilisateurs (gestion de compte, réservée aux admins).
final comptesUtilisateursProvider = StreamProvider<List<Utilisateur>>(
  (ref) => ref.watch(authentificationRepositoryProvider).watchTous(),
);

/// Compte connecté, relu depuis la base (suit les modifications de profil).
final utilisateurCourantProvider = FutureProvider<Utilisateur?>((ref) async {
  final id = ref.watch(sessionUtilisateurProvider)?.id;
  if (id == null) return null;
  return ref.watch(authentificationRepositoryProvider).parId(id);
});

/// Indique si au moins un compte administrateur est configuré (sans recharger).
final compteConfigureProvider = Provider<bool>((ref) {
  return ref.watch(configurationCompteProvider).value ?? false;
});

// --- Filtres ---

final filtreActivitesProvider = StateProvider<FiltreActivite>(
  (ref) => const FiltreActivite(),
);

final filtreRechercheProvider = StateProvider<String>((ref) => '');

// --- Activités ---

final activitesProvider = StreamProvider<List<Activite>>((ref) {
  final filtre = ref.watch(filtreActivitesProvider);
  return ref.watch(activitesRepositoryProvider).watchAll(filtre: filtre);
});

final activiteSelectionneeProvider = StateProvider<String?>((ref) => null);

final activitesCodesProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(activitesRepositoryProvider).codes(),
);

final lignesBudgetActiviteProvider =
    StreamProvider.family<List<LigneBudget>, String>(
      (ref, code) =>
          ref.watch(lignesBudgetRepositoryProvider).watchParActivite(code),
    );

final lignesBudgetProvider = StreamProvider<List<LigneBudget>>((ref) {
  final recherche = ref.watch(filtreRechercheProvider);
  return ref
      .watch(lignesBudgetRepositoryProvider)
      .watchAll(recherche: recherche);
});

/// Lignes budgétaires **non filtrées** : reprises automatiques de budget
/// (dossier PJ, rapport financier, suggestions) indépendantes de la recherche
/// d'un écran.
final toutesLignesBudgetProvider = StreamProvider<List<LigneBudget>>(
  (ref) => ref.watch(lignesBudgetRepositoryProvider).watchAll(),
);

// --- Participants ---

final participantsProvider = StreamProvider<List<Participant>>((ref) {
  final recherche = ref.watch(filtreRechercheProvider);
  return ref
      .watch(participantsRepositoryProvider)
      .watchAll(recherche: recherche);
});

/// Participants **non filtrés** : sélection dans les formulaires et calculs
/// (les suggestions ne doivent pas dépendre de la recherche d'un autre écran).
final tousParticipantsProvider = StreamProvider<List<Participant>>(
  (ref) => ref.watch(participantsRepositoryProvider).watchAll(),
);

final affectationsActiviteProvider =
    StreamProvider.family<List<ActiviteParticipant>, String>(
      (ref, code) => ref
          .watch(activiteParticipantsRepositoryProvider)
          .watchParActivite(code),
    );

// --- Présences ---

final presencesActiviteProvider = StreamProvider.family<List<Presence>, String>(
  (ref, code) => ref.watch(presencesRepositoryProvider).watchParActivite(code),
);

final resultatsPresencesProvider =
    FutureProvider.family<List<ResultatPresenceIndemnite>, String>((
      ref,
      code,
    ) async {
      // Recalcule quand les présences changent.
      ref.watch(presencesActiviteProvider(code));
      return ref.watch(presenceIndemniteServiceProvider).evaluerActivite(code);
    });

final syntheseIndemnitesProvider =
    FutureProvider.family<List<SyntheseIndemniteParticipant>, String>((
      ref,
      code,
    ) async {
      ref.watch(presencesActiviteProvider(code));
      return ref
          .watch(presenceIndemniteServiceProvider)
          .syntheseParParticipant(code);
    });

/// Saisies d'indemnités d'une activité (dossier PJ ▸ indemnités).
final indemnitesSaisiesActiviteProvider =
    StreamProvider.family<List<IndemniteSaisie>, String>(
      (ref, code) => ref
          .watch(indemnitesSaisiesRepositoryProvider)
          .watchParActivite(code),
    );

// --- Contrôle PJ ---

final controlesPJProvider = StreamProvider<List<ControlePJ>>((ref) {
  final recherche = ref.watch(filtreRechercheProvider);
  return ref
      .watch(controlesPJRepositoryProvider)
      .watchAll(recherche: recherche);
});

final resultatsControlePJProvider =
    FutureProvider<List<(ControlePJ, ResultatControlePJ)>>((ref) async {
      ref.watch(controlesPJProvider);
      return ref.watch(controlePJServiceProvider).evaluerTout();
    });

// --- Dépenses ---

final depensesProvider = StreamProvider<List<Depense>>((ref) {
  final recherche = ref.watch(filtreRechercheProvider);
  return ref.watch(depensesRepositoryProvider).watchAll(recherche: recherche);
});

// --- Banque ---

final banqueProvider = StreamProvider<List<BanqueOperation>>((ref) {
  final recherche = ref.watch(filtreRechercheProvider);
  return ref.watch(banqueRepositoryProvider).watchAll(recherche: recherche);
});

final releveBancaireProvider = StreamProvider<List<ReleveBancaireLigne>>(
  (ref) => ref.watch(releveRepositoryProvider).watchAll(),
);

final rapprochementProvider = FutureProvider<ResultatRapprochement>((
  ref,
) async {
  ref.watch(banqueProvider);
  ref.watch(releveBancaireProvider);
  return ref.watch(rapprochementServiceProvider).calculer();
});

// --- Référentiels ---

final districtsProvider = StreamProvider<List<District>>((ref) {
  final recherche = ref.watch(filtreRechercheProvider);
  return ref.watch(districtsRepositoryProvider).watchAll(recherche: recherche);
});

/// Districts **non filtrés** : le référentiel géographique sert aux calculs
/// de distance et de délai de route — il ne doit jamais dépendre du filtre de
/// recherche d'un écran (sinon les distances carburant deviennent fausses).
final tousDistrictsProvider = StreamProvider<List<District>>(
  (ref) => ref.watch(districtsRepositoryProvider).watchAll(),
);

final tarifsProvider = StreamProvider<List<TarifReferentiel>>((ref) {
  final recherche = ref.watch(filtreRechercheProvider);
  return ref.watch(tarifsRepositoryProvider).watchAll(recherche: recherche);
});

/// Tarifs **non filtrés** : pré-remplissage des taux et PU.
final tousTarifsProvider = StreamProvider<List<TarifReferentiel>>(
  (ref) => ref.watch(tarifsRepositoryProvider).watchAll(),
);

final listesProvider = StreamProvider<List<ReferenceValeur>>(
  (ref) => ref.watch(listesRepositoryProvider).watchAll(),
);

final valeursListeProvider = FutureProvider.family<List<String>, String>(
  (ref, categorie) => ref.watch(listesRepositoryProvider).valeurs(categorie),
);

// --- Tableau de bord ---

final indicateursProvider = FutureProvider<IndicateursDashboard>((ref) async {
  ref.watch(controlesPJProvider);
  ref.watch(presencesActiviteProvider(''));
  ref.watch(depensesProvider);
  ref.watch(banqueProvider);
  ref.watch(activitesProvider);
  ref.watch(tousParticipantsProvider);
  return ref.watch(dashboardServiceProvider).calculer();
});

final depensesParRubriqueProvider = FutureProvider<List<SeriePoint>>((
  ref,
) async {
  ref.watch(controlesPJProvider);
  return ref.watch(dashboardServiceProvider).depensesParRubrique();
});

final evolutionDepensesProvider = FutureProvider<List<SeriePoint>>((ref) async {
  ref.watch(depensesProvider);
  return ref.watch(dashboardServiceProvider).evolutionDepenses();
});

final repartitionActivitesProvider = FutureProvider<List<SeriePoint>>((
  ref,
) async {
  ref.watch(activitesProvider);
  return ref.watch(dashboardServiceProvider).repartitionActivites();
});

// --- Rapport financier ---

/// Rapport financier : budget alloué vs dépenses réalisées, par ligne
/// budgétaire (alimenté automatiquement par le dossier PJ).
final rapportFinancierProvider =
    FutureProvider<ResumeRapportFinancier>((ref) async {
  ref.watch(toutesLignesBudgetProvider);
  ref.watch(depensesProvider);
  ref.watch(activitesProvider);
  return ref.watch(rapportFinancierServiceProvider).calculer();
});

// --- Paramètres ---

final parametresProvider = FutureProvider<Map<String, String>>((ref) async {
  return ref.watch(parametresRepositoryProvider).tous();
});

/// Règles consolidées de la feuille `PARAMETRES` (taux, seuils, matrice PJ).
final reglesParametresProvider = FutureProvider<ReglesParametres>((ref) async {
  final brut = await ref
      .watch(parametresRepositoryProvider)
      .lire(ExcelImportService.cleParametres);
  if (brut == null || brut.isEmpty) return const ReglesParametres();
  try {
    return ReglesParametres.fromJson(
      (jsonDecode(brut) as Map).cast<String, dynamic>(),
    );
  } catch (_) {
    return const ReglesParametres();
  }
});

// --- Audit ---

final auditProvider = FutureProvider((ref) async {
  return ref.watch(auditRepositoryProvider).recents();
});
