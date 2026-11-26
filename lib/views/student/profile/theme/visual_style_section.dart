import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../providers/glass_settings_provider.dart';

/// Selector de estilo global de la aplicación (Material 3 vs Liquid Glass)
/// acompañado de una vista previa en vivo de la barra de navegación.
class VisualStyleSection extends StatelessWidget {
  final GlassSettings glassSettings;
  final Color activeAccent;
  final bool isDark;
  final ValueChanged<AppVisualStyle> onStyleChanged;

  const VisualStyleSection({
    super.key,
    required this.glassSettings,
    required this.activeAccent,
    required this.isDark,
    required this.onStyleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estilo de la aplicación',
          style: TextStyle(
            fontSize: 14,
            fontFamily: AppTheme.brandFont,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : activeAccent,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : AppColors.stoneBorder.withValues(alpha: 0.7),
            ),
          ),
          child: Column(
            children: [
              _VisualStyleOptionTile(
                title: 'Material 3',
                badgeText: glassSettings.isLowEndDevice
                    ? 'Recomendado'
                    : 'Ligero',
                subtitle: glassSettings.isLowEndDevice
                    ? 'Óptimo para tu dispositivo · Máxima fluidez y menor RAM'
                    : 'Superficies planas sólidas · Máximo rendimiento',
                isSelected: glassSettings.isMaterial3,
                activeAccent: activeAccent,
                isDark: isDark,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                onTap: () => onStyleChanged(AppVisualStyle.material3),
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.stoneBorder.withValues(alpha: 0.5),
              ),
              _VisualStyleOptionTile(
                title: 'Liquid Glass',
                badgeText: 'Cristal',
                subtitle: 'Vidrio esmerilado translúcido y refracción',
                isSelected: glassSettings.isLiquidGlass,
                activeAccent: activeAccent,
                isDark: isDark,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(18),
                ),
                onTap: () => onStyleChanged(AppVisualStyle.liquidGlass),
              ),
            ],
          ),
        ),
        if (glassSettings.isLowEndDevice && glassSettings.isLiquidGlass) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.amberTolerance.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.amberTolerance.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.speed_rounded,
                  size: 16,
                  color: AppColors.amberTolerance,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tu equipo tiene recursos limitados. Si notas lentitud, te recomendamos usar Material 3.',
                    style: TextStyle(
                      fontSize: 11,
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
        ],
        const SizedBox(height: 12),
        _VisualStylePreviewCard(
          isMaterial3: glassSettings.isMaterial3,
          activeAccent: activeAccent,
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.privacy_tip_outlined,
              size: 14,
              color: (isDark ? AppColors.darkTextSecondary : AppColors.slateMuted)
                  .withValues(alpha: 0.8),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'La recomendación de estilo consulta localmente capacidades básicas del dispositivo (RAM y CPU) solo para optimizar la fluidez; ningún dato de tu equipo se guarda ni se envía fuera del teléfono.',
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.35,
                  color: (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.slateMuted)
                      .withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VisualStyleOptionTile extends StatelessWidget {
  final String title;
  final String badgeText;
  final String subtitle;
  final bool isSelected;
  final Color activeAccent;
  final bool isDark;
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  const _VisualStyleOptionTile({
    required this.title,
    required this.badgeText,
    required this.subtitle,
    required this.isSelected,
    required this.activeAccent,
    required this.isDark,
    required this.borderRadius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
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
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? activeAccent
                              : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.mineralInk),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: activeAccent.withValues(
                            alpha: isSelected ? 0.18 : 0.10,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: activeAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.slateMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? activeAccent : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? activeAccent
                      : (isDark ? Colors.white24 : AppColors.stoneBorder),
                  width: 1.6,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _VisualStylePreviewCard extends StatelessWidget {
  final bool isMaterial3;
  final Color activeAccent;
  final bool isDark;

  const _VisualStylePreviewCard({
    required this.isMaterial3,
    required this.activeAccent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceBg = isDark
        ? const Color(0xFF141418)
        : const Color(0xFFF3EFE7);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.stoneBorder.withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isMaterial3 ? Icons.layers_rounded : Icons.blur_on_rounded,
                size: 16,
                color: activeAccent,
              ),
              const SizedBox(width: 6),
              Text(
                isMaterial3
                    ? 'Vista previa · Material 3'
                    : 'Vista previa · Liquid Glass',
                style: TextStyle(
                  fontFamily: AppTheme.brandFont,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.mineralInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMaterial3 ? 6 : 8,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isMaterial3
                  ? (isDark ? const Color(0xFF1E1E24) : Colors.white)
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.55)),
              borderRadius: BorderRadius.circular(isMaterial3 ? 14 : 26),
              border: Border.all(
                color: isMaterial3
                    ? (isDark ? AppColors.darkBorder : AppColors.stoneBorder)
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.22)
                          : Colors.white.withValues(alpha: 0.85)),
                width: 1,
              ),
              boxShadow: isMaterial3
                  ? null
                  : [
                      BoxShadow(
                        color: activeAccent.withValues(alpha: 0.16),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniPreviewNavItem(
                  icon: Icons.home_rounded,
                  label: 'Inicio',
                  isActive: true,
                  isMaterial3: isMaterial3,
                  activeAccent: activeAccent,
                  isDark: isDark,
                ),
                _MiniPreviewNavItem(
                  icon: Icons.calendar_month_outlined,
                  label: 'Horario',
                  isActive: false,
                  isMaterial3: isMaterial3,
                  activeAccent: activeAccent,
                  isDark: isDark,
                ),
                _MiniPreviewNavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Perfil',
                  isActive: false,
                  isMaterial3: isMaterial3,
                  activeAccent: activeAccent,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPreviewNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isMaterial3;
  final Color activeAccent;
  final bool isDark;

  const _MiniPreviewNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isMaterial3,
    required this.activeAccent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? Colors.white60 : AppColors.slateMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: isActive
            ? activeAccent.withValues(alpha: isDark ? 0.24 : 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(isMaterial3 ? 12 : 20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isActive ? activeAccent : muted),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? activeAccent : muted,
            ),
          ),
        ],
      ),
    );
  }
}
