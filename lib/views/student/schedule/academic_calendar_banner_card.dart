import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../calendar/academic_calendar_view.dart';

class AcademicCalendarBannerCard extends StatelessWidget {
  const AcademicCalendarBannerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = Theme.of(context).colorScheme.primary;

    return GlassSurface(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(16),
      tintColor: isDark ? const Color(0xFF141418) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor.withValues(alpha: isDark ? 0.22 : 0.12),
                  border: Border.all(
                    color: activeColor.withValues(alpha: isDark ? 0.45 : 0.25),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.calendar_month_rounded,
                    size: 24,
                    color: activeColor,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Calendario Escolar',
                            style: TextStyle(
                              fontFamily: AppTheme.brandFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.mineralInk,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: activeColor.withValues(
                              alpha: isDark ? 0.30 : 0.16,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '2026 - 2027',
                            style: TextStyle(
                              fontFamily: AppTheme.brandFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: activeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Fechas oficiales de cursos, días inhábiles y evaluaciones.',
                      style: TextStyle(
                        fontFamily: AppTheme.brandFont,
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.slateMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              HapticFeedback.lightImpact();
              AcademicCalendarView.open(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: isDark ? 0.20 : 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: activeColor.withValues(alpha: isDark ? 0.40 : 0.25),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.visibility_rounded, size: 18, color: activeColor),
                  const SizedBox(width: 8),
                  Text(
                    'Ver Calendario Completo (PDF)',
                    style: TextStyle(
                      fontFamily: AppTheme.brandFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: activeColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: activeColor,
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
