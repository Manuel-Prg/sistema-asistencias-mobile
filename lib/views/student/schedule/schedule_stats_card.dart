import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';

class ScheduleStatsCard extends StatelessWidget {
  final int activeDaysCount;
  final double weeklyHours;

  const ScheduleStatsCard({
    super.key,
    required this.activeDaysCount,
    required this.weeklyHours,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).colorScheme.primary;

    return GlassSurface(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatMiniCard(
                  icon: Icons.calendar_today_rounded,
                  label: 'Días pactados',
                  value: '$activeDaysCount días',
                  color: isDark ? Colors.white : themePrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatMiniCard(
                  icon: Icons.access_time_filled_rounded,
                  label: 'Horas/semana',
                  value: '${weeklyHours.toStringAsFixed(1)} hrs',
                  color: AppColors.accentLimnological,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: _StatMiniCard(
                  icon: Icons.timer_outlined,
                  label: 'Tolerancia',
                  value: '15 min',
                  color: AppColors.amberTolerance,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: themePrimary.withValues(alpha: isDark ? 0.20 : 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: isDark ? Colors.white70 : themePrimary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'El sistema usa esta hora de entrada para verificar puntualidad.',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: AppTheme.brandFont,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.slateMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatMiniCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF2EFE9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.slateMuted,
            ),
          ),
        ],
      ),
    );
  }
}
