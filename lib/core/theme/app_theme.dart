import 'package:flutter/material.dart';
import '../../providers/color_theme_provider.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static const String brandFont = 'Archer';

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: brandFont,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontFamily: brandFont, color: AppColors.mineralInk, fontSize: 16),
        bodyMedium: TextStyle(fontFamily: brandFont, color: AppColors.slateMuted, fontSize: 14),
        bodySmall: TextStyle(fontFamily: brandFont, color: AppColors.slateMuted, fontSize: 12),
        titleLarge: TextStyle(fontFamily: brandFont, color: AppColors.mineralInk, fontSize: 20, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontFamily: brandFont, color: AppColors.mineralInk, fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontFamily: brandFont, color: AppColors.mineralInk, fontSize: 14, fontWeight: FontWeight.w600),
        labelLarge: TextStyle(
          fontFamily: brandFont,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        labelMedium: TextStyle(fontFamily: brandFont, color: AppColors.slateMuted, fontSize: 12),
        labelSmall: TextStyle(fontFamily: brandFont, color: AppColors.slateMuted, fontSize: 11),
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
      appBarTheme: const AppBarTheme(
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.limestoneGround,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          borderSide: const BorderSide(color: AppColors.terracottaRule, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.slateMuted, fontSize: 14),
        hintStyle: TextStyle(color: AppColors.slateMuted.withValues(alpha: 0.7), fontSize: 14),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: brandFont,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontFamily: brandFont, color: AppColors.darkTextPrimary, fontSize: 16),
        bodyMedium: TextStyle(fontFamily: brandFont, color: AppColors.darkTextSecondary, fontSize: 14),
        bodySmall: TextStyle(fontFamily: brandFont, color: AppColors.darkTextSecondary, fontSize: 12),
        titleLarge: TextStyle(fontFamily: brandFont, color: AppColors.darkTextPrimary, fontSize: 20, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontFamily: brandFont, color: AppColors.darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontFamily: brandFont, color: AppColors.darkTextPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        labelLarge: TextStyle(
          fontFamily: brandFont,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        labelMedium: TextStyle(fontFamily: brandFont, color: AppColors.darkTextSecondary, fontSize: 12),
        labelSmall: TextStyle(fontFamily: brandFont, color: AppColors.darkTextSecondary, fontSize: 11),
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
      appBarTheme: const AppBarTheme(
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.signalAqua,
          foregroundColor: AppColors.abyssalGroundDark,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.signalAqua,
          minimumSize: const Size.fromHeight(50),
          side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F2B38),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
  }) {
    if (palette.isDefault) {
      return baseTheme;
    }

    final primary = palette.primary;
    final accent = palette.accent;

    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: isDark ? accent : primary,
        secondary: accent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? accent : primary,
          foregroundColor: isDark ? Colors.black87 : Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? accent : primary,
          minimumSize: const Size.fromHeight(50),
          side: BorderSide(
            color: isDark ? accent.withValues(alpha: 0.5) : primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
