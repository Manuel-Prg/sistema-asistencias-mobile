import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_surface.dart';
import '../../providers/color_theme_provider.dart';
import '../../providers/glass_settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../student/profile/theme/color_palette_section.dart';
import '../student/profile/theme/font_family_section.dart';
import '../student/profile/theme/theme_mode_section.dart';

/// Diapositiva 3 (Interactiva): personalización en vivo de colores, tema y tipografía.
class OnboardingPersonalizationStep extends ConsumerWidget {
  final Color activeAccent;
  final bool isDark;

  const OnboardingPersonalizationStep({
    super.key,
    required this.activeAccent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPalette = ref.watch(colorThemeProvider);
    final currentThemeMode = ref.watch(themeModeProvider);
    final glassSettings = ref.watch(glassSettingsProvider);

    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.mineralInk;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.slateMuted;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Text(
            'Personaliza a tu gusto',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.brandFont,
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Elige tu color favorito, el modo claro/oscuro y si prefieres la fuente Archer o la de tu dispositivo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.brandFont,
              fontSize: 12.5,
              height: 1.4,
              color: subColor,
            ),
          ),
          const SizedBox(height: 16),
          GlassSurface(
            borderRadius: BorderRadius.circular(22),
            padding: const EdgeInsets.all(18),
            enableRefraction: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ColorPaletteSection(
                  selectedPalette: selectedPalette,
                  activeAccent: activeAccent,
                  onPaletteSelected: (palette) => ref
                      .read(colorThemeProvider.notifier)
                      .setColorTheme(palette),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 14),
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
                FontFamilySection(
                  useSystemFont: glassSettings.useSystemFont,
                  activeAccent: activeAccent,
                  isDark: isDark,
                  isMaterial3: glassSettings.isMaterial3,
                  onUseSystemFontChanged: (useSystem) => ref
                      .read(glassSettingsProvider.notifier)
                      .setUseSystemFont(useSystem),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
