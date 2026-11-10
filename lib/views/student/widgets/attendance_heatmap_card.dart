import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../models/infraction_models.dart';

class AttendanceHeatmapCard extends StatelessWidget {
  final StudentInfractions infractions;
  final List<HeatmapWeek> heatmapWeeks;

  const AttendanceHeatmapCard({
    super.key,
    required this.infractions,
    required this.heatmapWeeks,
  });

  void _showDayDetails(BuildContext context, HeatmapDay day) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
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
      },
    );
  }

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
          // Título de la sección
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                size: 20,
                color: AppColors.primary,
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

          // Tracker de Faltas (3 bloques)
          const Text(
            'Límite de Faltas Injustificadas (Baja al llegar a 3):',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(3, (index) {
              final isReached = infractions.faltasCount > index;
              final isLast = index == 2;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isReached
                        ? (isLast
                              ? AppColors.statusFalta
                              : AppColors.terracottaRule)
                        : (isDark
                              ? const Color(0xFF162E3B)
                              : AppColors.stoneBorder.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isReached
                          ? (isLast
                                ? Colors.redAccent
                                : AppColors.terracottaRule)
                          : (isDark
                                ? AppColors.darkBorder
                                : AppColors.stoneBorder),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'FALTA ${index + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isReached
                              ? Colors.white
                              : (isDark
                                    ? const Color(0xFFC5D7DF)
                                    : AppColors.slateMuted),
                        ),
                      ),
                      if (isLast)
                        Text(
                          'Límite de Baja',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: isReached
                                ? Colors.white70
                                : (isDark
                                      ? const Color(0xFFC5D7DF)
                                      : AppColors.slateMuted),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Tracker de Retardos (9 casillas organizadas en 3 grupos)
          const Text(
            'Retardos acumulados (3 retardos = 1 falta):',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(9, (index) {
              final isMarked = infractions.retardosCount > index;
              final isGroupEnd = (index + 1) % 3 == 0;
              return Expanded(
                child: Container(
                  height: 24,
                  margin: EdgeInsets.only(
                    right: isGroupEnd && index < 8 ? 8 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: isMarked
                        ? AppColors.statusLate
                        : (isDark
                              ? const Color(0xFF162E3B)
                              : AppColors.stoneBorder.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isMarked
                          ? AppColors.terracottaRule
                          : (isDark
                                ? AppColors.darkBorder
                                : AppColors.stoneBorder),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isMarked ? Colors.white : AppColors.slateMuted,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          // Alerta Skippy / Nuty si hay faltas o baja
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
          // Header del Heatmap de 16 semanas
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

          // Cuadrícula Heatmap desplazable horizontalmente
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true, // Mostrar la semana más reciente a la derecha
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
                        onTap: () => _showDayDetails(context, day),
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
          const SizedBox(height: 12),

          // Leyenda de colores
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _LegendItem(color: AppColors.statusOnTime, label: 'Puntual'),
              _LegendItem(color: AppColors.statusLate, label: 'Retardo'),
              _LegendItem(color: AppColors.statusFalta, label: 'Falta'),
              _LegendItem(
                color: AppColors.statusJustified,
                label: 'Justificado',
              ),
              _LegendItem(
                color: isDark
                    ? AppColors.statusInactiveDark
                    : AppColors.statusInactive,
                label: 'Sin registro',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.slateMuted),
        ),
      ],
    );
  }
}
