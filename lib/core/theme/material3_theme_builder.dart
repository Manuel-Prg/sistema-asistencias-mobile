import 'package:flutter/material.dart';

import '../../providers/color_theme_provider.dart';
import '../constants/app_colors.dart';

/// Tema Material 3 Expressive: superficies tonales sin bordes, botones cápsula
/// (StadiumBorder), switches con palomita interna y barra de navegación nativa.
class Material3ThemeBuilder {
  Material3ThemeBuilder._();

  static ThemeData build(
    ThemeData baseTheme, {
    required AppColorPalette palette,
    required bool isDark,
    required String? fontFamily,
  }) {
    final m3Scheme = _buildColorScheme(palette: palette, isDark: isDark);

    return baseTheme.copyWith(
      scaffoldBackgroundColor: m3Scheme.surface,
      colorScheme: m3Scheme,
      iconTheme: IconThemeData(color: m3Scheme.onSurface),
      primaryIconTheme: IconThemeData(color: m3Scheme.onPrimary),
      cardTheme: CardThemeData(
        color: m3Scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: m3Scheme.primary,
          foregroundColor: m3Scheme.onPrimary,
          iconColor: m3Scheme.onPrimary,
          minimumSize: const Size.fromHeight(50),
          shape: const StadiumBorder(),
          elevation: 0,
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: m3Scheme.primary,
          foregroundColor: m3Scheme.onPrimary,
          iconColor: m3Scheme.onPrimary,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: m3Scheme.primary,
          iconColor: m3Scheme.primary,
          minimumSize: const Size.fromHeight(50),
          side: BorderSide(color: m3Scheme.outlineVariant, width: 1.2),
          shape: const StadiumBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: m3Scheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: m3Scheme.primary, width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
      ),
      switchTheme: _buildSwitchTheme(m3Scheme),
      navigationBarTheme: _buildNavigationBarTheme(m3Scheme, fontFamily),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: m3Scheme.primaryContainer,
        foregroundColor: m3Scheme.onPrimaryContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  static ColorScheme _buildColorScheme({
    required AppColorPalette palette,
    required bool isDark,
  }) {
    final seedScheme = ColorScheme.fromSeed(
      seedColor: palette.isDefault ? AppColors.primary : palette.primary,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    final Color m3Primary = palette.isDefault
        ? (isDark ? AppColors.accentLimnological : AppColors.primary)
        : palette.primary;

    final Color m3Accent = palette.isDefault
        ? (isDark ? AppColors.signalAqua : AppColors.accentLimnological)
        : palette.accent;

    return seedScheme.copyWith(
      primary: m3Primary,
      onPrimary: Colors.white,
      secondary: m3Accent,
      onSecondary: Colors.white,
      primaryContainer: isDark
          ? Color.alphaBlend(
              m3Primary.withValues(alpha: 0.34),
              const Color(0xFF141419),
            )
          : Color.alphaBlend(m3Primary.withValues(alpha: 0.16), Colors.white),
      onPrimaryContainer: isDark ? Colors.white : m3Primary,
      secondaryContainer: isDark
          ? Color.alphaBlend(
              m3Primary.withValues(alpha: 0.28),
              const Color(0xFF141419),
            )
          : Color.alphaBlend(m3Primary.withValues(alpha: 0.14), Colors.white),
      onSecondaryContainer: isDark ? m3Accent : m3Primary,
      surface: isDark ? AppColors.abyssalGroundDark : seedScheme.surface,
      surfaceContainerLowest: isDark ? const Color(0xFF0A0A0D) : Colors.white,
      surfaceContainerLow: isDark
          ? const Color(0xFF141419)
          : Color.alphaBlend(
              m3Primary.withValues(alpha: 0.04),
              const Color(0xFFFAF9F6),
            ),
      surfaceContainer: isDark
          ? const Color(0xFF1B1B22)
          : Color.alphaBlend(
              m3Primary.withValues(alpha: 0.07),
              const Color(0xFFF6F4EF),
            ),
      surfaceContainerHigh: isDark
          ? const Color(0xFF23232C)
          : Color.alphaBlend(
              m3Primary.withValues(alpha: 0.11),
              const Color(0xFFF0EDE6),
            ),
    );
  }

  static SwitchThemeData _buildSwitchTheme(ColorScheme m3Scheme) {
    return SwitchThemeData(
      thumbIcon: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Icon(Icons.check_rounded, size: 16, color: m3Scheme.primary);
        }
        return null;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return m3Scheme.primary;
        }
        return m3Scheme.surfaceContainerHigh;
      }),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return m3Scheme.onPrimary;
        }
        return m3Scheme.outline;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }
        return m3Scheme.outline;
      }),
    );
  }

  static NavigationBarThemeData _buildNavigationBarTheme(
    ColorScheme m3Scheme,
    String? fontFamily,
  ) {
    return NavigationBarThemeData(
      backgroundColor: m3Scheme.surfaceContainerLow,
      indicatorColor: m3Scheme.secondaryContainer,
      indicatorShape: const StadiumBorder(),
      elevation: 0,
      height: 70,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: fontFamily,
          fontSize: 11.5,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? m3Scheme.onSurface : m3Scheme.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 22,
          color: selected
              ? m3Scheme.onSecondaryContainer
              : m3Scheme.onSurfaceVariant,
        );
      }),
    );
  }
}
