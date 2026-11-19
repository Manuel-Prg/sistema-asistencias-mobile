import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/progress_bar_style.dart';

/// Selector del estilo visual de las barras de progreso con vista previa en vivo.
class ProgressBarStyleSection extends StatelessWidget {
  final ProgressBarStyle selectedBarStyle;
  final Color activeAccent;
  final bool isDark;
  final ValueChanged<ProgressBarStyle> onStyleSelected;

  const ProgressBarStyleSection({
    super.key,
    required this.selectedBarStyle,
    required this.activeAccent,
    required this.isDark,
    required this.onStyleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estilo de Barra de Progreso',
          style: TextStyle(
            fontSize: 14,
            fontFamily: AppTheme.brandFont,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : activeAccent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Elige cómo se ven las barras de progreso de horas acumuladas.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.slateMuted,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),

        // Vista previa en vivo
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.stoneBorder.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vista previa',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.slateMuted,
                  ),
                ),
                const SizedBox(height: 8),
                StyledProgressBar(
                  ratio: 0.65,
                  barColor: activeAccent,
                  isDark: isDark,
                  style: selectedBarStyle,
                  height: 12,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Chips de selección
        Row(
          children: ProgressBarStyle.values.map((style) {
            final isSelected = style == selectedBarStyle;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _BarStyleChip(
                  style: style,
                  isSelected: isSelected,
                  activeColor: activeAccent,
                  isDark: isDark,
                  onTap: () => onStyleSelected(style),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BarStyleChip extends StatelessWidget {
  final ProgressBarStyle style;
  final bool isSelected;
  final Color activeColor;
  final bool isDark;
  final VoidCallback onTap;

  const _BarStyleChip({
    required this.style,
    required this.isSelected,
    required this.activeColor,
    required this.isDark,
    required this.onTap,
  });

  IconData get _icon {
    switch (style) {
      case ProgressBarStyle.defaultStyle:
        return Icons.water_drop_rounded;
      case ProgressBarStyle.gradient:
        return Icons.waves_rounded;
      case ProgressBarStyle.segmented:
        return Icons.view_week_rounded;
      case ProgressBarStyle.glowing:
        return Icons.auto_awesome_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              _icon,
              size: 20,
              color: isSelected
                  ? activeColor
                  : (isDark ? Colors.white60 : AppColors.slateMuted),
            ),
            const SizedBox(height: 4),
            Text(
              style.label,
              style: TextStyle(
                fontSize: 11,
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
