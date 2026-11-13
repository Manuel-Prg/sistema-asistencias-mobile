import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../models/infraction_models.dart';
import 'heatmap/heatmap_day_details_sheet.dart';
import 'heatmap/heatmap_legend.dart';
import 'heatmap/infractions_tracker.dart';

class AttendanceHeatmapCard extends StatelessWidget {
  final StudentInfractions infractions;
  final List<HeatmapWeek> heatmapWeeks;

  const AttendanceHeatmapCard({
    super.key,
    required this.infractions,
    required this.heatmapWeeks,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassSurface(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(16),
      enableRefraction: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                size: 20,
                color: isDark
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Control de Puntualidad y Faltas',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.amberTolerance.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Tol. 15 min',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.amberTolerance,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InfractionsTracker(infractions: infractions),
          if (infractions.faltaQuote != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: infractions.isBajaRisk
                    ? AppColors.statusFalta.withValues(alpha: 0.12)
                    : AppColors.amberTolerance.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: infractions.isBajaRisk
                      ? AppColors.statusFalta
                      : AppColors.amberTolerance,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    infractions.isBajaRisk
                        ? Icons.warning_rounded
                        : Icons.info_outline_rounded,
                    color: infractions.isBajaRisk
                        ? AppColors.statusFalta
                        : AppColors.amberTolerance,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      infractions.faltaQuote!,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                        color: infractions.isBajaRisk
                            ? AppColors.statusFalta
                            : AppColors.amberTolerance,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Actividad de las últimas 16 semanas:',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Toca un día para ver detalle',
                style: TextStyle(fontSize: 10, color: AppColors.slateMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          RepaintBoundary(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: heatmapWeeks.map((week) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Column(
                      children: week.days.map((day) {
                        Color tileColor;
                        if (day.status == 'falta') {
                          tileColor = AppColors.statusFalta;
                        } else if (day.status == 'retardo') {
                          tileColor = AppColors.statusLate;
                        } else if (day.status == 'on_time') {
                          tileColor = day.isJustified
                              ? AppColors.statusJustified
                              : AppColors.statusOnTime;
                        } else {
                          tileColor = isDark
                              ? AppColors.statusInactiveDark
                              : AppColors.statusInactive.withValues(alpha: 0.4);
                        }

                        return GestureDetector(
                          onTap: () =>
                              HeatmapDayDetailsSheet.show(context, day),
                          child: Container(
                            width: 14,
                            height: 14,
                            margin: const EdgeInsets.only(bottom: 3),
                            decoration: BoxDecoration(
                              color: tileColor,
                              borderRadius: BorderRadius.circular(2.5),
                              boxShadow: day.status == 'falta'
                                  ? [
                                      BoxShadow(
                                        color: AppColors.statusFalta.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const HeatmapLegend(),
        ],
      ),
    );
  }
}
