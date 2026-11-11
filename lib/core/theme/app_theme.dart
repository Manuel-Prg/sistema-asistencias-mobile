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
          foregroundColor: Colors.white,
          iconColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.primary,
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
      iconTheme: const IconThemeData(
        color: Colors.white,
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
      iconTheme: IconThemeData(
        color: isDark ? Colors.white : primaryColor,
      ),
      primaryIconTheme: const IconThemeData(
        color: Colors.white,
      ),
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
          textStyle: const TextStyle(
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
            color: isDark ? Colors.white38 : primaryColor.withValues(alpha: 0.5),
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
