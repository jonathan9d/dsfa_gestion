import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';

class RaccourcisApp {
  const RaccourcisApp({required this.menu, required this.dashboard});

  final String menu;
  final String dashboard;

  static const defaut = RaccourcisApp(menu: 'CTRL+B', dashboard: 'CTRL+1');

  Map<String, dynamic> toJson() => {'menu': menu, 'dashboard': dashboard};

  factory RaccourcisApp.fromJson(String? brut) {
    if (brut == null || brut.isEmpty) return defaut;
    try {
      final m = (jsonDecode(brut) as Map).cast<String, dynamic>();
      return RaccourcisApp(
        menu: '${m['menu'] ?? defaut.menu}',
        dashboard: '${m['dashboard'] ?? defaut.dashboard}',
      );
    } catch (_) {
      return defaut;
    }
  }
}

final raccourcisProvider = FutureProvider<RaccourcisApp>((ref) async {
  final brut = await ref.read(parametresRepositoryProvider).lire('raccourcis.app');
  return RaccourcisApp.fromJson(brut);
});

String normaliserRaccourci(String value) => value.trim().toUpperCase();

ShortcutActivator activatorPour(String value) {
  final v = normaliserRaccourci(value);
  final ctrl = v.contains('CTRL+') || v.contains('CMD+');
  final alt = v.contains('ALT+');
  final shift = v.contains('SHIFT+');
  final touche = v.split('+').last;
  final keys = <String, LogicalKeyboardKey>{
    'B': LogicalKeyboardKey.keyB,
    'D': LogicalKeyboardKey.keyD,
    'M': LogicalKeyboardKey.keyM,
    '1': LogicalKeyboardKey.digit1,
    '2': LogicalKeyboardKey.digit2,
    '3': LogicalKeyboardKey.digit3,
    '4': LogicalKeyboardKey.digit4,
    '5': LogicalKeyboardKey.digit5,
    '6': LogicalKeyboardKey.digit6,
    '0': LogicalKeyboardKey.digit0,
  };
  return SingleActivator(
    keys[touche] ?? LogicalKeyboardKey.keyB,
    control: ctrl,
    alt: alt,
    shift: shift,
  );
}

class OuvrirMenuIntent extends Intent {
  const OuvrirMenuIntent();
}

class AllerDashboardIntent extends Intent {
  const AllerDashboardIntent();
}

Map<ShortcutActivator, Intent> raccourcisClavier(RaccourcisApp r) => {
      activatorPour(r.menu): const OuvrirMenuIntent(),
      activatorPour(r.dashboard): const AllerDashboardIntent(),
    };

