import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HeatmapLegend extends StatelessWidget {
  const HeatmapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        const _LegendItem(color: AppColors.statusOnTime, label: 'Puntual'),
        const _LegendItem(color: AppColors.statusLate, label: 'Retardo'),
        const _LegendItem(color: AppColors.statusFalta, label: 'Falta'),
        const _LegendItem(
          color: AppColors.statusJustified,
          label: 'Justificado',
        ),
        _LegendItem(
          color: isDark
              ? AppColors.statusInactiveDark
              : AppColors.statusInactive,
          label: 'Sin registro',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.slateMuted),
        ),
      ],
    );
  }
}

