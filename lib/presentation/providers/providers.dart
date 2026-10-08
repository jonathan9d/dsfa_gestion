import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/repositories/activite_repository.dart';
import '../../data/repositories/authentification_repository.dart';
import '../../data/repositories/audit_repository.dart';
import '../../data/repositories/controle_pj_repository.dart';
import '../../data/repositories/finance_repository.dart';
import '../../data/repositories/participant_repository.dart';
import '../../data/repositories/presence_repository.dart';
import '../../data/repositories/referentiel_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../domain/services/controle_pj_service.dart';
import '../../domain/statuts.dart';
import '../../domain/services/dashboard_service.dart';
import '../../domain/services/journal_depenses_service.dart';
import '../../domain/services/rapport_financier_service.dart';
import '../../domain/services/presence_indemnite_service.dart';
import '../../domain/services/rapprochement_service.dart';
import '../../domain/services/reinitialisation_service.dart';
import '../../services/excel_export_service.dart';
import '../../services/excel_import_service.dart';
import '../../services/notification_service.dart';
import '../../services/pdf_export_service.dart';
import '../../services/ressources.dart';
import '../../services/sauvegarde_service.dart';
import '../reglages/reglages_affichage.dart';
import 'app_providers.dart';

/// Base de données unique de l'application.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final authentificationRepositoryProvider = Provider<AuthentificationRepository>(
  (ref) => AuthentificationRepository(ref.watch(databaseProvider)),
);

/// Mémorisation de la session (reconnexion automatique sous 2 jours).
final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(
    ref.watch(parametresRepositoryProvider),
    ref.watch(authentificationRepositoryProvider),
  ),
);

/// Notifications système (Windows).
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

/// Parcours « mot de passe oublié » (code de vérification).
final reinitialisationServiceProvider = Provider<ReinitialisationService>(
  (ref) => ReinitialisationService(
    parametres: ref.watch(parametresRepositoryProvider),
    authentification: ref.watch(authentificationRepositoryProvider),
    notifications: ref.watch(notificationServiceProvider),
  ),
);

final databaseBootstrapProvider = FutureProvider<void>((ref) async {
  final database = ref.watch(databaseProvider);
  final parameters = ref.watch(parametresRepositoryProvider);

  // Préférences d'affichage (couleurs, police, filtres, défilement…),
  // restaurées avant le premier écran.
  final tousParametres = await parameters.tous();
  final reglages = ReglagesAffichage.depuisParametres(tousParametres);
  ref.read(reglagesAffichageProvider.notifier).state = reglages;

  // Thème : « automatique » par défaut, ou le choix conservé de l'utilisateur.
  ref.read(themeModeProvider.notifier).state =
      ReglagesAffichage.themeDepuisTexte(
        tousParametres[ReglagesAffichage.cleTheme],
      );

  // Les règles de la feuille PARAMETRES sont chargées même pour une base déjà
  // initialisée : elles doivent toujours refléter le classeur de référence.
  if (await parameters.lire(ExcelImportService.cleParametres) == null) {
    final assetParametres = await rootBundle.load(classeurReference);
    final importeurParametres = ref.read(excelImportServiceProvider);
    importeurParametres.chargerOctets(assetParametres.buffer.asUint8List());
    await importeurParametres.importerParametres();
  }

  const importKey = 'classeur_reference_initialise_v1';
  if (await parameters.lire(importKey) != null) return;

  final hasData = await Future.wait<bool>([
    database.select(database.districts).get().then((rows) => rows.isNotEmpty),
    database
        .select(database.referentielTarifs)
        .get()
        .then((rows) => rows.isNotEmpty),
    database.select(database.activites).get().then((rows) => rows.isNotEmpty),
    database
        .select(database.lignesBudget)
        .get()
        .then((rows) => rows.isNotEmpty),
    database
        .select(database.participants)
        .get()
        .then((rows) => rows.isNotEmpty),
    database.select(database.presences).get().then((rows) => rows.isNotEmpty),
    database.select(database.controlesPJ).get().then((rows) => rows.isNotEmpty),
    database.select(database.depenses).get().then((rows) => rows.isNotEmpty),
    database
        .select(database.banqueOperations)
        .get()
        .then((rows) => rows.isNotEmpty),
  ]);

  if (!hasData.any((containsRows) => containsRows)) {
    final asset = await rootBundle.load(classeurReference);
    final importer = ref.read(excelImportServiceProvider);
    importer.chargerOctets(asset.buffer.asUint8List());
    await importer.importer();
  }
  await parameters.ecrire(importKey, DateTime.now().toIso8601String());

  // Reconnexion automatique : la session est restaurée si l'application a été
  // ouverte il y a moins de 2 jours. Sinon, l'utilisateur doit saisir son nom
  // d'utilisateur et son mot de passe (l'identifiant reste pré-rempli).
  final session = ref.read(sessionRepositoryProvider);
  final restauration = await session.restaurer();
  if (restauration != null && !restauration.motDePasseRequis) {
    ref.read(sessionUtilisateurProvider.notifier).state =
        restauration.utilisateur;
    ref.read(roleProvider.notifier).state = RoleUtilisateur.depuisCode(
      restauration.utilisateur.role,
    );
  }
  await session.marquerOuverture();
});

// --- Repositories ---

final districtsRepositoryProvider = Provider<DistrictsRepository>(
  (ref) => DistrictsRepository(ref.watch(databaseProvider)),
);
final tarifsRepositoryProvider = Provider<TarifsRepository>(
  (ref) => TarifsRepository(ref.watch(databaseProvider)),
);
final listesRepositoryProvider = Provider<ListesRepository>(
  (ref) => ListesRepository(ref.watch(databaseProvider)),
);
final parametresRepositoryProvider = Provider<ParametresRepository>(
  (ref) => ParametresRepository(ref.watch(databaseProvider)),
);
final activitesRepositoryProvider = Provider<ActivitesRepository>(
  (ref) => ActivitesRepository(ref.watch(databaseProvider)),
);
final lignesBudgetRepositoryProvider = Provider<LignesBudgetRepository>(
  (ref) => LignesBudgetRepository(ref.watch(databaseProvider)),
);
final participantsRepositoryProvider = Provider<ParticipantsRepository>(
  (ref) => ParticipantsRepository(ref.watch(databaseProvider)),
);
final activiteParticipantsRepositoryProvider =
    Provider<ActiviteParticipantsRepository>(
      (ref) => ActiviteParticipantsRepository(ref.watch(databaseProvider)),
    );
final presencesRepositoryProvider = Provider<PresencesRepository>(
  (ref) => PresencesRepository(ref.watch(databaseProvider)),
);

final indemnitesSaisiesRepositoryProvider =
    Provider<IndemnitesSaisiesRepository>(
      (ref) => IndemnitesSaisiesRepository(ref.watch(databaseProvider)),
    );
final controlesPJRepositoryProvider = Provider<ControlesPJRepository>(
  (ref) => ControlesPJRepository(ref.watch(databaseProvider)),
);
final depensesRepositoryProvider = Provider<DepensesRepository>(
  (ref) => DepensesRepository(ref.watch(databaseProvider)),
);
final banqueRepositoryProvider = Provider<BanqueRepository>(
  (ref) => BanqueRepository(ref.watch(databaseProvider)),
);
final releveRepositoryProvider = Provider<ReleveBancaireRepository>(
  (ref) => ReleveBancaireRepository(ref.watch(databaseProvider)),
);
final auditRepositoryProvider = Provider<AuditRepository>(
  (ref) => AuditRepository(ref.watch(databaseProvider)),
);

// --- Services métier ---

final presenceIndemniteServiceProvider = Provider<PresenceIndemniteService>(
  (ref) => PresenceIndemniteService(
    presences: ref.watch(presencesRepositoryProvider),
    participants: ref.watch(participantsRepositoryProvider),
    activites: ref.watch(activitesRepositoryProvider),
  ),
);

final controlePJServiceProvider = Provider<ControlePJService>(
  (ref) => ControlePJService(
    controles: ref.watch(controlesPJRepositoryProvider),
    lignesBudget: ref.watch(lignesBudgetRepositoryProvider),
    presenceService: ref.watch(presenceIndemniteServiceProvider),
  ),
);

final rapprochementServiceProvider = Provider<RapprochementService>(
  (ref) => RapprochementService(
    banque: ref.watch(banqueRepositoryProvider),
    releve: ref.watch(releveRepositoryProvider),
  ),
);

final dashboardServiceProvider = Provider<DashboardService>(
  (ref) => DashboardService(
    controlePJ: ref.watch(controlePJServiceProvider),
    presenceService: ref.watch(presenceIndemniteServiceProvider),
    controles: ref.watch(controlesPJRepositoryProvider),
    activites: ref.watch(activitesRepositoryProvider),
    participants: ref.watch(participantsRepositoryProvider),
    presences: ref.watch(presencesRepositoryProvider),
    depenses: ref.watch(depensesRepositoryProvider),
    banque: ref.watch(banqueRepositoryProvider),
  ),
);

// --- Services d'import/export ---

final excelImportServiceProvider = Provider<ExcelImportService>(
  (ref) => ExcelImportService(
    db: ref.watch(databaseProvider),
    activites: ref.watch(activitesRepositoryProvider),
    lignesBudget: ref.watch(lignesBudgetRepositoryProvider),
    participants: ref.watch(participantsRepositoryProvider),
    activiteParticipants: ref.watch(activiteParticipantsRepositoryProvider),
    presences: ref.watch(presencesRepositoryProvider),
    controles: ref.watch(controlesPJRepositoryProvider),
    depenses: ref.watch(depensesRepositoryProvider),
    banque: ref.watch(banqueRepositoryProvider),
    releve: ref.watch(releveRepositoryProvider),
    districts: ref.watch(districtsRepositoryProvider),
    tarifs: ref.watch(tarifsRepositoryProvider),
    listes: ref.watch(listesRepositoryProvider),
  ),
);

final excelExportServiceProvider = Provider<ExcelExportService>(
  (ref) => ExcelExportService(
    activites: ref.watch(activitesRepositoryProvider),
    lignesBudget: ref.watch(lignesBudgetRepositoryProvider),
    participants: ref.watch(participantsRepositoryProvider),
    presences: ref.watch(presencesRepositoryProvider),
    depenses: ref.watch(depensesRepositoryProvider),
    banque: ref.watch(banqueRepositoryProvider),
    presenceService: ref.watch(presenceIndemniteServiceProvider),
    controlePJService: ref.watch(controlePJServiceProvider),
    rapprochementService: ref.watch(rapprochementServiceProvider),
  ),
);

final pdfExportServiceProvider = Provider<PdfExportService>(
  (ref) => PdfExportService(
    dashboard: ref.watch(dashboardServiceProvider),
    presenceService: ref.watch(presenceIndemniteServiceProvider),
    controlePJ: ref.watch(controlePJServiceProvider),
    rapprochement: ref.watch(rapprochementServiceProvider),
    activites: ref.watch(activitesRepositoryProvider),
  ),
);

final sauvegardeServiceProvider = Provider<SauvegardeService>(
  (ref) => SauvegardeService(ref.watch(databaseProvider)),
);

/// Synchronisation automatique du journal des dépenses (dossier PJ,
/// indemnités).
final journalDepensesServiceProvider = Provider<JournalDepensesService>(
  (ref) => JournalDepensesService(
    depenses: ref.watch(depensesRepositoryProvider),
    activites: ref.watch(activitesRepositoryProvider),
  ),
);

/// Rapport financier : budget alloué vs dépenses réalisées.
final rapportFinancierServiceProvider = Provider<RapportFinancierService>(
  (ref) => RapportFinancierService(
    lignesBudget: ref.watch(lignesBudgetRepositoryProvider),
    activites: ref.watch(activitesRepositoryProvider),
    depenses: ref.watch(depensesRepositoryProvider),
  ),
);
