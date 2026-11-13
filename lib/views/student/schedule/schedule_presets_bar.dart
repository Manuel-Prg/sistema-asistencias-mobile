import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';

class SchedulePresetsBar extends StatelessWidget {
  final void Function(String start, String end) onApplyPreset;

  const SchedulePresetsBar({super.key, required this.onApplyPreset});

  @override
  Widget build(BuildContext context) {
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
              color: Theme.of(context).colorScheme.primary,
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
    final themePrimary = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: themePrimary.withValues(alpha: isDark ? 0.25 : 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (isDark ? Colors.white38 : themePrimary).withValues(
              alpha: 0.35,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : themePrimary,
          ),
        ),
      ),
    );
  }
}
