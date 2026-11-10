import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../../../models/infraction_models.dart';

class HeatmapDayDetailsSheet extends StatelessWidget {
  final HeatmapDay day;

  const HeatmapDayDetailsSheet({super.key, required this.day});

  static void show(BuildContext context, HeatmapDay day) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => HeatmapDayDetailsSheet(day: day),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassSurface(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.stoneBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppDateUtils.formatFullDate(day.dateTime),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (day.records.isEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No hay registros de asistencia en esta fecha.',
                    style: TextStyle(color: AppColors.slateMuted),
                  ),
                ),
              ),
            ] else ...[
              ...day.records.map((rec) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF142C38)
                        : AppColors.limestoneGround,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.stoneBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              rec.cleanEventName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            rec.hoursWorked != null
                                ? '${rec.hoursWorked!.toStringAsFixed(1)} hrs'
                                : 'En curso',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentLimnological,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppDateUtils.formatTimeRange(
                          rec.checkIn,
                          rec.checkOut,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFFC5D7DF)
                              : AppColors.slateMuted,
                        ),
                      ),
                      if (rec.earlyDepartureReason != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          rec.earlyDepartureReason!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: rec.isLate
                                ? AppColors.terracottaRule
                                : (isDark
                                    ? const Color(0xFFC5D7DF)
                                    : AppColors.slateMuted),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

