import 'package:flutter/material.dart';

import '../../providers/color_theme_provider.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static const String defaultBrandFont = 'Archer';
  static bool _useSystemFont = false;

  /// Retorna la fuente de marca ('Archer') o `null` para usar la fuente nativa del sistema.
  static String? get brandFont => _useSystemFont ? null : defaultBrandFont;

  static void setUseSystemFont(bool useSystem) {
    _useSystemFont = useSystem;
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: brandFont,
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          fontFamily: brandFont,
          color: AppColors.mineralInk,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          fontFamily: brandFont,
          color: AppColors.slateMuted,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          fontFamily: brandFont,
          color: AppColors.slateMuted,
          fontSize: 12,
        ),
        titleLarge: TextStyle(
          fontFamily: brandFont,
          color: AppColors.mineralInk,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          fontFamily: brandFont,
          color: AppColors.mineralInk,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          fontFamily: brandFont,
          color: AppColors.mineralInk,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelLarge: TextStyle(
          fontFamily: brandFont,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        labelMedium: TextStyle(
          fontFamily: brandFont,
          color: AppColors.slateMuted,
          fontSize: 12,
        ),
        labelSmall: TextStyle(
          fontFamily: brandFont,
          color: AppColors.slateMuted,
          fontSize: 11,
        ),
      ),
      scaffoldBackgroundColor: AppColors.limestoneGround,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.limestoneGround,
        secondary: AppColors.accentLimnological,
        onSecondary: Colors.white,
        surface: AppColors.sillarCard,
        onSurface: AppColors.mineralInk,
        error: AppColors.terracottaRule,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: brandFont,
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.sillarCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.stoneBorder, width: 1),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          iconColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.primary),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(50),
          side: const BorderSide(color: AppColors.stoneBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.stoneBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.stoneBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.terracottaRule,
            width: 1.5,
          ),
        ),
        labelStyle: const TextStyle(color: AppColors.slateMuted, fontSize: 14),
        hintStyle: TextStyle(
          color: AppColors.slateMuted.withValues(alpha: 0.7),
          fontSize: 14,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: brandFont,
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          fontFamily: brandFont,
          color: AppColors.darkTextPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          fontFamily: brandFont,
          color: AppColors.darkTextSecondary,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          fontFamily: brandFont,
          color: AppColors.darkTextSecondary,
          fontSize: 12,
        ),
        titleLarge: TextStyle(
          fontFamily: brandFont,
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          fontFamily: brandFont,
          color: AppColors.darkTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          fontFamily: brandFont,
          color: AppColors.darkTextPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelLarge: TextStyle(
          fontFamily: brandFont,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        labelMedium: TextStyle(
          fontFamily: brandFont,
          color: AppColors.darkTextSecondary,
          fontSize: 12,
        ),
        labelSmall: TextStyle(
          fontFamily: brandFont,
          color: AppColors.darkTextSecondary,
          fontSize: 11,
        ),
      ),
      scaffoldBackgroundColor: AppColors.abyssalGroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.signalAqua,
        onPrimary: AppColors.abyssalGroundDark,
        secondary: AppColors.accentLimnological,
        surface: AppColors.pondCardDark,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.terracottaRule,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: brandFont,
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.pondCardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          iconColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          iconColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF141416),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.signalAqua, width: 2),
        ),
      ),
    );
  }

  static ThemeData getThemeWithPalette(
    ThemeData baseTheme,
    AppColorPalette palette, {
    required bool isDark,
    bool isMaterial3 = false,
  }) {
    final Color primaryColor = palette.isDefault
        ? (isDark ? AppColors.signalAqua : AppColors.primary)
        : (isDark ? palette.accent : palette.primary);

    final Color accentColor = palette.isDefault
        ? AppColors.accentLimnological
        : palette.accent;

    if (isMaterial3) {
      return _buildMaterial3ExpressiveTheme(
        baseTheme,
        palette: palette,
        primaryColor: primaryColor,
        isDark: isDark,
      );
    }

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
            fontFamily: brandFont,
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

  /// Tema Material 3 Expressive: superficies tonales sin bordes, botones cápsula
  /// (StadiumBorder), switches con palomita interna y barra de navegación nativa.
  static ThemeData _buildMaterial3ExpressiveTheme(
    ThemeData baseTheme, {
    required AppColorPalette palette,
    required Color primaryColor,
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

    final m3Scheme = seedScheme.copyWith(
      primary: m3Primary,
      onPrimary: Colors.white,
      secondary: m3Accent,
      onSecondary: Colors.white,
      primaryContainer: isDark
          ? Color.alphaBlend(
              m3Primary.withValues(alpha: 0.34),
              const Color(0xFF141419),
            )
          : Color.alphaBlend(
              m3Primary.withValues(alpha: 0.16),
              Colors.white,
            ),
      onPrimaryContainer: isDark ? Colors.white : m3Primary,
      secondaryContainer: isDark
          ? Color.alphaBlend(
              m3Primary.withValues(alpha: 0.28),
              const Color(0xFF141419),
            )
          : Color.alphaBlend(
              m3Primary.withValues(alpha: 0.14),
              Colors.white,
            ),
      onSecondaryContainer: isDark ? m3Accent : m3Primary,
      surface: isDark ? AppColors.abyssalGroundDark : seedScheme.surface,
      surfaceContainerLowest: isDark
          ? const Color(0xFF0A0A0D)
          : Colors.white,
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

    return baseTheme.copyWith(
      useMaterial3: true,
      scaffoldBackgroundColor: m3Scheme.surface,
      colorScheme: m3Scheme,
      iconTheme: IconThemeData(color: m3Scheme.onSurface),
      primaryIconTheme: IconThemeData(color: m3Scheme.onPrimary),
      cardTheme: CardThemeData(
        color: m3Scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
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
            fontFamily: brandFont,
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
          side: BorderSide(
            color: m3Scheme.outlineVariant,
            width: 1.2,
          ),
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
      switchTheme: SwitchThemeData(
        thumbIcon: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Icon(
              Icons.check_rounded,
              size: 16,
              color: m3Scheme.primary,
            );
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
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: m3Scheme.surfaceContainerLow,
        indicatorColor: m3Scheme.secondaryContainer,
        indicatorShape: const StadiumBorder(),
        elevation: 0,
        height: 70,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: brandFont,
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? m3Scheme.onSurface
                : m3Scheme.onSurfaceVariant,
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
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: m3Scheme.primaryContainer,
        foregroundColor: m3Scheme.onPrimaryContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
