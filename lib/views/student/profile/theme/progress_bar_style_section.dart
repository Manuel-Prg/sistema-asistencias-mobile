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
    final styles = ProgressBarStyle.values;
    final firstRow = styles.take(3).toList();
    final secondRow = styles.skip(3).toList();

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vista previa · ${selectedBarStyle.label}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.slateMuted,
                      ),
                    ),
                    Text(
                      '65%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: activeAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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

        // Cuadrícula 3x2 de chips de selección
        _buildStyleRow(firstRow),
        if (secondRow.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildStyleRow(secondRow),
        ],
      ],
    );
  }

  Widget _buildStyleRow(List<ProgressBarStyle> rowStyles) {
    return Row(
      children: rowStyles.map((style) {
        final isSelected = style == selectedBarStyle;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
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
      case ProgressBarStyle.bubbles:
        return Icons.bubble_chart_rounded;
      case ProgressBarStyle.aurora:
        return Icons.gradient_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
