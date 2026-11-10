import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../../../models/attendance_record.dart';

class AttendanceHistoryItem extends StatelessWidget {
  final AttendanceRecord record;

  const AttendanceHistoryItem({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isComplete = (record.hoursWorked ?? 0) >= 4.0;
    final isInProgress = record.checkOut == null;

    Color badgeColor;
    String badgeText;

    if (isInProgress) {
      badgeColor = AppColors.signalAqua;
      badgeText = 'En curso';
    } else if (isComplete) {
      badgeColor = AppColors.statusOnTime;
      badgeText = 'Completo';
    } else {
      badgeColor = AppColors.amberTolerance;
      badgeText = 'Incompleto';
    }

    return GlassSurface(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppDateUtils.formatShortDate(record.checkIn),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${record.cleanEventName}  ·  Turno ${record.shift}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                record.hoursWorked != null
                    ? '${record.hoursWorked!.toStringAsFixed(1)} hrs'
                    : '—',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 13,
                color: isDark ? const Color(0xFF8FA7B2) : AppColors.slateMuted,
              ),
              const SizedBox(width: 5),
              Text(
                AppDateUtils.formatTimeRange(
                  record.checkIn,
                  record.checkOut,
                ),
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
                ),
              ),
            ],
          ),
          if (record.isLate || record.earlyDepartureReason != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (record.isLate)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.terracottaRule.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Retardo (${record.lateMinutes ?? 0}m)',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.terracottaRule,
                      ),
                    ),
                  ),
                if (record.earlyDepartureReason != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.stoneBorder.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      record.earlyDepartureReason!,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? const Color(0xFFC5D7DF)
                            : AppColors.slateMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

