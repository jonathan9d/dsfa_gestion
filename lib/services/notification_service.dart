import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notifications système de l'application (Windows).
///
/// Sert notamment à envoyer **le code de vérification** lors d'une
/// réinitialisation de mot de passe. Si Windows refuse d'afficher la
/// notification (application non installée, notifications désactivées…),
/// l'application le signale et affiche le code dans sa propre fenêtre : le
/// parcours de réinitialisation reste donc toujours possible.
class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Identifiant de l'application pour Windows (AUMID).
  static const _appUserModelId = 'mg.dsfa.gestion';
  static const _guid = 'd8b9bb90-4a58-4a6e-9b1a-71e1a3f8c001';
  static const _appName = 'DSFA Gestion';

  bool _initialise = false;
  bool _indisponible = false;
  int _compteur = 0;

  /// Prépare le canal de notification. Sans erreur bloquante.
  Future<void> initialiser() async {
    if (_initialise || _indisponible) return;
    if (!Platform.isWindows) {
      _indisponible = true;
      return;
    }
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          windows: WindowsInitializationSettings(
            appName: _appName,
            appUserModelId: _appUserModelId,
            guid: _guid,
          ),
        ),
      );
      _initialise = true;
    } catch (error) {
      _indisponible = true;
      debugPrint('Notifications système indisponibles : $error');
    }
  }

  /// Affiche une notification sur l'ordinateur. Renvoie `true` lorsque le
  /// système a bien pris en charge la notification.
  Future<bool> notifier({
    required String titre,
    required String corps,
    String? sousTitre,
  }) async {
    await initialiser();
    if (!_initialise) return false;
    try {
      await _plugin.show(
        id: ++_compteur,
        title: titre,
        body: corps,
        notificationDetails: NotificationDetails(
          windows: WindowsNotificationDetails(subtitle: sousTitre),
        ),
      );
      return true;
    } catch (error) {
      debugPrint('Envoi de la notification impossible : $error');
      return false;
    }
  }
}
