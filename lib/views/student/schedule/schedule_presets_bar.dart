import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';

class SchedulePresetsBar extends StatelessWidget {
  final void Function(String start, String end) onApplyPreset;

  const SchedulePresetsBar({super.key, required this.onApplyPreset});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: BorderRadius.circular(14),
      child: Row(
        children: [
          Text(
            'Atajos:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: AppTheme.brandFont,
              color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _PresetButton(
                    label: 'Matutino (11 - 14)',
                    onTap: () => onApplyPreset('11:00', '14:00'),
                  ),
                  const SizedBox(width: 6),
                  _PresetButton(
                    label: 'Vespertino (14 - 18)',
                    onTap: () => onApplyPreset('14:00', '18:00'),
                  ),
                  const SizedBox(width: 6),
                  _PresetButton(
                    label: 'Completo (11 - 18)',
                    onTap: () => onApplyPreset('11:00', '18:00'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.signalAqua : AppColors.primary)
              .withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (isDark ? AppColors.signalAqua : AppColors.primary)
                .withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.signalAqua : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

