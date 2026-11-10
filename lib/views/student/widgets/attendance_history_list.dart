import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../models/attendance_record.dart';
import 'attendance/attendance_history_item.dart';

class AttendanceHistoryList extends StatelessWidget {
  final List<AttendanceRecord> records;

  const AttendanceHistoryList({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (records.isEmpty) {
      return GlassSurface(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        borderRadius: BorderRadius.circular(16),
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
                style: TextStyle(fontSize: 14, color: AppColors.slateMuted),
              ),
            ],
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              'Últimos ${records.length} registros',
              style: const TextStyle(fontSize: 12, color: AppColors.slateMuted),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...records.map((record) => AttendanceHistoryItem(record: record)),
      ],
    );
  }
}
