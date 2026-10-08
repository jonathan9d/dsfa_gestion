import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void jouerSonApp({required bool actif, bool erreur = false}) {
  if (!actif) return;
  unawaited(_jouer(erreur ? SystemSoundType.alert : SystemSoundType.click));
}

Future<void> _jouer(SystemSoundType type) async {
  try {
    await SystemSound.play(type);
  } on MissingPluginException catch (error) {
    debugPrint('Son système non disponible : $error');
  } on PlatformException catch (error) {
    debugPrint('Impossible de jouer le son système : $error');
  }
}
