import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_surface.dart';
import '../../providers/glass_settings_provider.dart';

/// Diapositiva 2 (Interactiva): permite al usuario elegir en vivo entre
/// Material 3 (ligero y plano) o Liquid Glass (translúcido con refracción).
class OnboardingStyleStep extends ConsumerWidget {
  final Color activeAccent;
  final bool isDark;

  const OnboardingStyleStep({
    super.key,
    required this.activeAccent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glassSettings = ref.watch(glassSettingsProvider);
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.mineralInk;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.slateMuted;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 124,
                height: 124,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      activeAccent.withValues(alpha: isDark ? 0.24 : 0.14),
                      activeAccent.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              Image.asset(
                'assets/images/nuty/nuty-pose-1.png',
                height: 118,
                cacheHeight: 240,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Icon(
                  Icons.auto_awesome_mosaic_rounded,
                  size: 42,
                  color: activeAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Elige el estilo visual',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.brandFont,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¡Pruébalo ahora mismo! Toca una opción para ver cómo cambia toda la app al instante.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.brandFont,
              fontSize: 13,
              height: 1.4,
              color: subColor,
            ),
          ),
          const SizedBox(height: 16),
          if (glassSettings.isLowEndDevice) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: activeAccent.withValues(alpha: isDark ? 0.16 : 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: activeAccent.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.speed_rounded, size: 18, color: activeAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      glassSettings.deviceRamLabel.isNotEmpty
                          ? 'Optimizamos la app para tu equipo (${glassSettings.deviceRamLabel}) activando Material 3.'
                          : 'Optimizamos la app para tu dispositivo activando Material 3 para máxima fluidez.',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.mineralInk,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ] else
            const SizedBox(height: 6),
          _StyleChoiceCard(
            icon: Icons.layers_rounded,
            title: 'Material 3',
            badge: glassSettings.isLowEndDevice
                ? 'Recomendado para tu equipo'
                : 'Recomendado · Ligero',
            description:
                'Superficies tonales planas, botones cápsula y máxima fluidez con menor consumo de batería.',
            isSelected: glassSettings.isMaterial3,
            activeAccent: activeAccent,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              ref
                  .read(glassSettingsProvider.notifier)
                  .setVisualStyle(AppVisualStyle.material3);
            },
          ),
          const SizedBox(height: 12),
          _StyleChoiceCard(
            icon: Icons.blur_on_rounded,
            title: 'Liquid Glass',
            badge: 'Cristal',
            description:
                'Vidrio esmerilado translúcido, barra flotante adaptable y control de transparencia.',
            isSelected: glassSettings.isLiquidGlass,
            activeAccent: activeAccent,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              ref
                  .read(glassSettingsProvider.notifier)
                  .setVisualStyle(AppVisualStyle.liquidGlass);
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Podrás cambiar de estilo cuando quieras en Configuraciones > Apariencia.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              color: subColor.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _StyleChoiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String badge;
  final String description;
  final bool isSelected;
  final Color activeAccent;
  final bool isDark;
  final VoidCallback onTap;

  const _StyleChoiceCard({
    required this.icon,
    required this.title,
    required this.badge,
    required this.description,
    required this.isSelected,
    required this.activeAccent,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? activeAccent
                : (isDark ? Colors.white12 : AppColors.stoneBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: GlassSurface(
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.all(16),
          enableRefraction: false,
          tintColor: isSelected
              ? activeAccent.withValues(alpha: isDark ? 0.16 : 0.08)
              : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: activeAccent.withValues(alpha: isDark ? 0.24 : 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22, color: activeAccent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: AppTheme.brandFont,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? activeAccent
                                : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.mineralInk),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: activeAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: activeAccent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.slateMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected
                    ? activeAccent
                    : (isDark ? Colors.white30 : AppColors.stoneBorder),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
