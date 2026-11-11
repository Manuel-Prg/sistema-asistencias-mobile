import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../providers/glass_settings_provider.dart';
import '../../../providers/theme_provider.dart';

class ProfileThemeCard extends ConsumerStatefulWidget {
  const ProfileThemeCard({super.key});

  @override
  ConsumerState<ProfileThemeCard> createState() => _ProfileThemeCardState();
}

class _ProfileThemeCardState extends ConsumerState<ProfileThemeCard> {
  bool _showAdvancedGlass = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentThemeMode = ref.watch(themeModeProvider);
    final glassSettings = ref.watch(glassSettingsProvider);

    return GlassSurface(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_rounded,
                color: isDark ? AppColors.signalAqua : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tema y Rendimiento',
                style: TextStyle(
                  fontFamily: AppTheme.brandFont,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ThemeChip(
                  label: 'Claro',
                  icon: Icons.light_mode_rounded,
                  isSelected: currentThemeMode == ThemeMode.light,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setTheme(ThemeMode.light),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ThemeChip(
                  label: 'Oscuro',
                  icon: Icons.dark_mode_rounded,
                  isSelected: currentThemeMode == ThemeMode.dark,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setTheme(ThemeMode.dark),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ThemeChip(
                  label: 'Auto',
                  icon: Icons.brightness_auto_rounded,
                  isSelected: currentThemeMode == ThemeMode.system,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setTheme(ThemeMode.system),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Modo Rendimiento',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Optimiza animaciones y desactiva blur para máxima fluidez',
              style: TextStyle(fontSize: 12, color: AppColors.slateMuted),
            ),
            value: !glassSettings.enableBlur,
            activeTrackColor: AppColors.signalAqua,
            onChanged: (val) => ref
                .read(glassSettingsProvider.notifier)
                .setEnableBlur(!val),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              initiallyExpanded: _showAdvancedGlass,
              onExpansionChanged: (exp) =>
                  setState(() => _showAdvancedGlass = exp),
              title: const Text(
                'Personalización de Cristal (iOS Glass)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentLimnological,
                ),
              ),
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Intensidad de Desenfoque (Blur):',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '${glassSettings.blurSigma.toInt()} px',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: glassSettings.blurSigma,
                  min: 4,
                  max: 20,
                  divisions: 16,
                  activeColor: AppColors.signalAqua,
                  onChanged: (sigma) => ref
                      .read(glassSettingsProvider.notifier)
                      .setBlurSigma(sigma),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Contornos de Cristal:',
                      style: TextStyle(fontSize: 12),
                    ),
                    Switch.adaptive(
                      value: glassSettings.showBorders,
                      activeTrackColor: AppColors.signalAqua,
                      onChanged: (show) => ref
                          .read(glassSettingsProvider.notifier)
                          .setShowBorders(show),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.signalAqua : AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.18)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : const Color(0xFFEFECE6)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? activeColor
                  : (isDark ? Colors.white60 : AppColors.slateMuted),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? activeColor
                    : (isDark ? Colors.white70 : AppColors.slateMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
