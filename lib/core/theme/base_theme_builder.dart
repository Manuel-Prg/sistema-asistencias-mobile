import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Construye los temas base (claro y oscuro) compartiendo tipografía y
/// configuración transparente para overlays (diálogos, bottom sheets, snackbars).
class BaseThemeBuilder {
  BaseThemeBuilder._();

  static const _transparentDialogTheme = DialogThemeData(
    backgroundColor: Colors.transparent,
    elevation: 0,
  );

  static const _transparentBottomSheetTheme = BottomSheetThemeData(
    backgroundColor: Colors.transparent,
    elevation: 0,
  );

  static const _transparentSnackBarTheme = SnackBarThemeData(
    backgroundColor: Colors.transparent,
    elevation: 0,
    behavior: SnackBarBehavior.floating,
  );

  static TextTheme _buildTextTheme({
    required String? fontFamily,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return TextTheme(
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        color: primaryText,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        color: secondaryText,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        color: secondaryText,
        fontSize: 12,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        color: primaryText,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        color: primaryText,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        color: primaryText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        color: secondaryText,
        fontSize: 12,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        color: secondaryText,
        fontSize: 11,
      ),
    );
  }

  static ThemeData buildLight(String? fontFamily) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily,
      textTheme: _buildTextTheme(
        fontFamily: fontFamily,
        primaryText: AppColors.mineralInk,
        secondaryText: AppColors.slateMuted,
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
          fontFamily: fontFamily,
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
      dialogTheme: _transparentDialogTheme,
      bottomSheetTheme: _transparentBottomSheetTheme,
      snackBarTheme: _transparentSnackBarTheme,
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

  static ThemeData buildDark(String? fontFamily) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      textTheme: _buildTextTheme(
        fontFamily: fontFamily,
        primaryText: AppColors.darkTextPrimary,
        secondaryText: AppColors.darkTextSecondary,
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
          fontFamily: fontFamily,
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
      dialogTheme: _transparentDialogTheme,
      bottomSheetTheme: _transparentBottomSheetTheme,
      snackBarTheme: _transparentSnackBarTheme,
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
}
