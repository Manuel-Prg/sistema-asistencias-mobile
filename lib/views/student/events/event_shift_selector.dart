import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class EventShiftSelector extends StatelessWidget {
  final String selectedShift;
  final bool enabled;
  final ValueChanged<String> onSelectShift;

  const EventShiftSelector({
    super.key,
    required this.selectedShift,
    required this.enabled,
    required this.onSelectShift,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _EventShiftOption(
            label: 'Matutino',
            hours: '11:00 - 14:00',
            isSelected: selectedShift == 'matutino',
            onTap: enabled ? () => onSelectShift('matutino') : () {},
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _EventShiftOption(
            label: 'Vespertino',
            hours: '14:00 - 18:00',
            isSelected: selectedShift == 'vespertino',
            onTap: enabled ? () => onSelectShift('vespertino') : () {},
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _EventShiftOption(
            label: 'Completo',
            hours: '11:00 - 18:00',
            isSelected: selectedShift == 'completo',
            onTap: enabled ? () => onSelectShift('completo') : () {},
          ),
        ),
      ],
    );
  }
}

class _EventShiftOption extends StatelessWidget {
  final String label;
  final String hours;
  final bool isSelected;
  final VoidCallback onTap;

  const _EventShiftOption({
    required this.label,
    required this.hours,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.35 : 0.18)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFF2EFE9)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isDark ? Colors.white70 : activeColor)
                : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : activeColor)
                    : (isDark ? Colors.white70 : AppColors.mineralInk),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              hours,
              style: TextStyle(
                fontSize: 9,
                color: isDark ? AppColors.darkTextSecondary : AppColors.slateMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

