import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../providers/color_theme_provider.dart';
import '../../../providers/glass_settings_provider.dart';
import '../../../providers/progress_bar_style_provider.dart';
import '../../../providers/theme_provider.dart';
import 'theme/color_palette_section.dart';
import 'theme/font_family_section.dart';
import 'theme/glass_effects_section.dart';
import 'theme/progress_bar_style_section.dart';
import 'theme/theme_mode_section.dart';
import 'theme/visual_style_section.dart';

/// Tarjeta principal de Apariencia que orquesta las secciones de
/// estilo visual, paleta de colores, efectos de vidrio, tema y barra de progreso.
class ProfileThemeCard extends ConsumerWidget {
  const ProfileThemeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentThemeMode = ref.watch(themeModeProvider);
    final selectedPalette = ref.watch(colorThemeProvider);
    final glassSettings = ref.watch(glassSettingsProvider);
    final selectedBarStyle = ref.watch(progressBarStyleProvider);

    final activeAccent = isDark
        ? (selectedPalette.isDefault
              ? AppColors.signalAqua
              : selectedPalette.accent)
        : selectedPalette.primary;

    return GlassSurface(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: activeAccent.withValues(alpha: isDark ? 0.25 : 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.palette_rounded,
                  color: activeAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Apariencia',
                  style: TextStyle(
                    fontFamily: AppTheme.brandFont,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: activeAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 1. Estilo de la aplicación (Material 3 vs Liquid Glass)
          VisualStyleSection(
            glassSettings: glassSettings,
            activeAccent: activeAccent,
            isDark: isDark,
            onStyleChanged: (style) =>
                ref.read(glassSettingsProvider.notifier).setVisualStyle(style),
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // 2. Colores de tema
          ColorPaletteSection(
            selectedPalette: selectedPalette,
            activeAccent: activeAccent,
            onPaletteSelected: (palette) =>
                ref.read(colorThemeProvider.notifier).setColorTheme(palette),
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // 3. Efectos de Liquid Glass (solo visible en estilo Liquid Glass)
          if (glassSettings.isLiquidGlass) ...[
            GlassEffectsSection(
              glassSettings: glassSettings,
              selectedPalette: selectedPalette,
              activeAccent: activeAccent,
              isDark: isDark,
              onTransparencyChanged: (val) => ref
                  .read(glassSettingsProvider.notifier)
                  .setTransparency(val),
              onShowBordersChanged: (show) =>
                  ref.read(glassSettingsProvider.notifier).setShowBorders(show),
              onHighPerformanceChanged: (highPerf) => ref
                  .read(glassSettingsProvider.notifier)
                  .setEnableBlur(!highPerf),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 14),
          ],

          // 4. Modo de Tema (Claro / Oscuro / Auto)
          ThemeModeSection(
            currentThemeMode: currentThemeMode,
            activeAccent: activeAccent,
            isDark: isDark,
            isMaterial3: glassSettings.isMaterial3,
            onThemeChanged: (mode) =>
                ref.read(themeModeProvider.notifier).setTheme(mode),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // 5. Tipografía (Fuente de la app vs Sistema)
          FontFamilySection(
            useSystemFont: glassSettings.useSystemFont,
            activeAccent: activeAccent,
            isDark: isDark,
            isMaterial3: glassSettings.isMaterial3,
            onUseSystemFontChanged: (useSystem) => ref
                .read(glassSettingsProvider.notifier)
                .setUseSystemFont(useSystem),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // 6. Estilo de Barra de Progreso
          ProgressBarStyleSection(
            selectedBarStyle: selectedBarStyle,
            activeAccent: activeAccent,
            isDark: isDark,
            onStyleSelected: (style) =>
                ref.read(progressBarStyleProvider.notifier).setStyle(style),
          ),
        ],
      ),
    );
  }
}
