import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../models/attendance_record.dart';

class EventHistoryCard extends StatelessWidget {
  final List<AttendanceRecord> eventHistory;
  final double totalEventHours;

  const EventHistoryCard({
    super.key,
    required this.eventHistory,
    required this.totalEventHours,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).colorScheme.primary;

    return GlassSurface(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history_edu_rounded,
                    color: isDark ? Colors.white : themePrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Historial de Eventos',
                    style: TextStyle(
                      fontFamily: AppTheme.brandFont,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : themePrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: themePrimary.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${totalEventHours.toStringAsFixed(1)} hrs (2x)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : themePrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (eventHistory.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Text(
                  'Aún no has registrado eventos especiales.\n¡Cada evento suma el doble de horas!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: AppTheme.brandFont,
                    color: isDark ? Colors.white38 : AppColors.slateMuted,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ] else ...[
            ...eventHistory.map((rec) => _EventHistoryItem(record: rec)),
          ],
        ],
      ),
    );
  }
}

class _EventHistoryItem extends StatelessWidget {
  final AttendanceRecord record;

  const _EventHistoryItem({required this.record});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF9F7F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: themePrimary.withValues(alpha: isDark ? 0.25 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.stars_rounded,
              color: isDark ? Colors.white : themePrimary,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.cleanEventName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTheme.brandFont,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : themePrimary,
                  ),
                ),
                Text(
                  '${AppDateUtils.formatShortDate(record.checkIn)} • Turno ${record.shift}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : AppColors.slateMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${record.hoursWorked?.toStringAsFixed(1) ?? '0.0'} hrs',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.signalAqua : AppColors.accentLimnological,
            ),
          ),
        ],
      ),
    );
  }
}

