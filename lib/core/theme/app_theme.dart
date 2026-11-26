import 'package:flutter/material.dart';

import '../../providers/color_theme_provider.dart';
import 'base_theme_builder.dart';
import 'material3_theme_builder.dart';
import 'palette_theme_builder.dart';

class AppTheme {
  AppTheme._();

  static const String defaultBrandFont = 'Archer';
  static bool _useSystemFont = false;

  /// Retorna la fuente de marca ('Archer') o `null` para usar la fuente nativa del sistema.
  static String? get brandFont => _useSystemFont ? null : defaultBrandFont;

  static void setUseSystemFont(bool useSystem) {
    _useSystemFont = useSystem;
  }

  static ThemeData get lightTheme => BaseThemeBuilder.buildLight(brandFont);

  static ThemeData get darkTheme => BaseThemeBuilder.buildDark(brandFont);

  static ThemeData getThemeWithPalette(
    ThemeData baseTheme,
    AppColorPalette palette, {
    required bool isDark,
    bool isMaterial3 = false,
  }) {
    if (isMaterial3) {
      return Material3ThemeBuilder.build(
        baseTheme,
        palette: palette,
        isDark: isDark,
        fontFamily: brandFont,
      );
    }

    return PaletteThemeBuilder.build(
      baseTheme,
      palette,
      isDark: isDark,
      fontFamily: brandFont,
    );
  }
}
