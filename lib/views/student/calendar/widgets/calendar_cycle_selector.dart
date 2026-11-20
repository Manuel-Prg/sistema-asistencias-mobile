import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../academic_calendar_view.dart';

/// Selector superior de ciclo escolar (ej. 2026-2027 vs 2025-2026).
class CalendarCycleSelector extends StatelessWidget {
  final List<AcademicCalendarDoc> calendars;
  final int selectedIndex;
  final Color activeColor;
  final bool isDark;
  final ValueChanged<int> onChanged;

  const CalendarCycleSelector({
    super.key,
    required this.calendars,
    required this.selectedIndex,
    required this.activeColor,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(4),
      tintColor: isDark ? const Color(0xFF141418) : null,
      child: Row(
        children: List.generate(calendars.length, (index) {
          final item = calendars[index];
          final isSelected = selectedIndex == index;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? activeColor.withValues(alpha: isDark ? 0.25 : 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(
                          color: activeColor.withValues(
                            alpha: isDark ? 0.45 : 0.30,
                          ),
                          width: 1.2,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: isSelected
                          ? activeColor
                          : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.slateMuted),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.cycle,
                      style: TextStyle(
                        fontFamily: AppTheme.brandFont,
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? activeColor
                            : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.slateMuted),
                      ),
                    ),
                    if (item.isCurrent) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: activeColor.withValues(
                            alpha: isDark ? 0.35 : 0.20,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Vigente',
                          style: TextStyle(
                            fontFamily: AppTheme.brandFont,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? activeColor
                                : (isDark ? Colors.white70 : activeColor),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
