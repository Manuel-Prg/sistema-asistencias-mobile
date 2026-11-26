import 'package:flutter/material.dart';

import '../../providers/color_theme_provider.dart';
import '../constants/app_colors.dart';

/// Aplica la paleta de colores seleccionada sobre el tema base para el estilo Liquid Glass.
class PaletteThemeBuilder {
  PaletteThemeBuilder._();

  static ThemeData build(
    ThemeData baseTheme,
    AppColorPalette palette, {
    required bool isDark,
    required String? fontFamily,
  }) {
    final Color primaryColor = palette.isDefault
        ? (isDark ? AppColors.signalAqua : AppColors.primary)
        : (isDark ? palette.accent : palette.primary);

    final Color accentColor = palette.isDefault
        ? AppColors.accentLimnological
        : palette.accent;

    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: primaryColor,
        secondary: accentColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      iconTheme: IconThemeData(color: isDark ? Colors.white : primaryColor),
      primaryIconTheme: const IconThemeData(color: Colors.white),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          iconColor: Colors.white,
          disabledForegroundColor: Colors.white60,
          disabledIconColor: Colors.white38,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: Colors.white,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          iconColor: Colors.white,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? Colors.white : primaryColor,
          iconColor: isDark ? Colors.white : primaryColor,
          minimumSize: const Size.fromHeight(50),
          side: BorderSide(
            color: isDark
                ? Colors.white38
                : primaryColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
