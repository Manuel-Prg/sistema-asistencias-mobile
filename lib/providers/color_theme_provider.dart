import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_colors.dart';

class AppColorPalette {
  final String id;
  final String name;
  final Color primary;
  final Color accent;
  final Color previewColor;

  const AppColorPalette({
    required this.id,
    required this.name,
    required this.primary,
    required this.accent,
    required this.previewColor,
  });

  bool get isDefault => id == 'default';
}

class AppPalettes {
  AppPalettes._();

  static const defaultCua = AppColorPalette(
    id: 'default',
    name: 'CUA Original',
    primary: AppColors.primary, // 0xFF0C3C4C
    accent: AppColors.accentLimnological, // 0xFF0F766E
    previewColor: Color(0xFF0C3C4C),
  );

  static const purple = AppColorPalette(
    id: 'purple',
    name: 'Púrpura',
    primary: Color(0xFF7C3AED),
    accent: Color(0xFFA855F7),
    previewColor: Color(0xFFA855F7),
  );

  static const pink = AppColorPalette(
    id: 'pink',
    name: 'Rosado',
    primary: Color(0xFFE11D48),
    accent: Color(0xFFFB7185),
    previewColor: Color(0xFFF43F5E),
  );

  static const coral = AppColorPalette(
    id: 'coral',
    name: 'Coral',
    primary: Color(0xFFE11D48),
    accent: Color(0xFFEF4444),
    previewColor: Color(0xFFEF4444),
  );

  static const amber = AppColorPalette(
    id: 'amber',
    name: 'Ámbar',
    primary: Color(0xFFD97706),
    accent: Color(0xFFF59E0B),
    previewColor: Color(0xFFF59E0B),
  );

  static const emerald = AppColorPalette(
    id: 'emerald',
    name: 'Esmeralda',
    primary: Color(0xFF059669),
    accent: Color(0xFF10B981),
    previewColor: Color(0xFF10B981),
  );

  static const cyan = AppColorPalette(
    id: 'cyan',
    name: 'Cian',
    primary: Color(0xFF0891B2),
    accent: Color(0xFF06B6D4),
    previewColor: Color(0xFF06B6D4),
  );

  static const ocean = AppColorPalette(
    id: 'ocean',
    name: 'Océano',
    primary: Color(0xFF2563EB),
    accent: Color(0xFF3B82F6),
    previewColor: Color(0xFF3B82F6),
  );

  static const List<AppColorPalette> all = [
    defaultCua,
    purple,
    pink,
    coral,
    amber,
    emerald,
    cyan,
    ocean,
  ];
}

final colorThemeProvider =
    NotifierProvider<ColorThemeNotifier, AppColorPalette>(
      ColorThemeNotifier.new,
    );

class ColorThemeNotifier extends Notifier<AppColorPalette> {
  static const _prefKey = 'app_selected_color_theme';

  @override
  AppColorPalette build() {
    _loadFromPrefs();
    return AppPalettes.defaultCua;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_prefKey);
    if (savedId != null) {
      final found = AppPalettes.all.firstWhere(
        (p) => p.id == savedId,
        orElse: () => AppPalettes.defaultCua,
      );
      state = found;
    }
  }

  Future<void> setColorTheme(AppColorPalette palette) async {
    state = palette;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, palette.id);
  }
}
