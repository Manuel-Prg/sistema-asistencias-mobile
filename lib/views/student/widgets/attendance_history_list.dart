import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/attendance_record.dart';

class AttendanceHistoryList extends StatelessWidget {
  final List<AttendanceRecord> records;

  const AttendanceHistoryList({
    super.key,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (records.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 40,
                  color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aún no tienes registros de asistencia',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.slateMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Historial Reciente',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Últimos ${records.length} registros',
              style: const TextStyle(fontSize: 12, color: AppColors.slateMuted),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...records.map((record) {
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

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.pondCardDark : AppColors.sillarCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
              ),
            ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.12),
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
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              record.cleanEventName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '•  Turno ${record.shift}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.slateMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      record.hoursWorked != null
                          ? '${record.hoursWorked!.toStringAsFixed(1)} hrs'
                          : '--',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 13, color: AppColors.slateMuted),
                    const SizedBox(width: 4),
                    Text(
                      AppDateUtils.formatTimeRange(record.checkIn, record.checkOut),
                      style: const TextStyle(fontSize: 12, color: AppColors.slateMuted),
                    ),
                  ],
                ),
                if (record.isLate || record.isJustified || record.earlyDepartureReason != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (record.isLate)
                        _Tag(
                          text: 'Retardo ${record.lateMinutes != null ? "(${record.lateMinutes}m)" : ""}',
                          color: AppColors.statusLate,
                        ),
                      if (record.isJustified)
                        const _Tag(
                          text: 'Justificado',
                          color: AppColors.statusJustified,
                        ),
                      if (record.earlyDepartureReason != null &&
                          !record.earlyDepartureReason!.contains('[RETARDO]'))
                        _Tag(
                          text: record.earlyDepartureReason!,
                          color: AppColors.slateMuted,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;

  const _Tag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

