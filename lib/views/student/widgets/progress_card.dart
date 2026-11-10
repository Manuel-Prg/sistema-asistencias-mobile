import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../models/student.dart';
import 'freedom_dialog.dart';

class ProgressCard extends StatelessWidget {
  final Student student;

  const ProgressCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = student.progressPercentage;
    final isCompleted = student.isCompleted;

    return GlassSurface(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(16),
      enableRefraction: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Modalidad / Programa
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: isDark ? 0.3 : 0.08,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.stoneBorder,
                  ),
                ),
                child: Text(
                  student.studentTypeFormatted.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.signalAqua : AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // Porcentaje
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.statusOnTime.withValues(alpha: 0.15)
                      : AppColors.accentLimnological.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isCompleted
                        ? AppColors.statusOnTime
                        : AppColors.accentLimnological,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Horas acumuladas vs requeridas
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                student.accumulatedHours.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ ${student.requiredHours.toStringAsFixed(0)} hrs',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.slateMuted,
                ),
              ),
              const SizedBox(width: 8),
              if (!isCompleted)
                Expanded(
                  child: Text(
                    'Faltan ${student.remainingHours.toStringAsFixed(1)} hrs',
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.slateMuted,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          // Barra de progreso con gradiente
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: isDark
                    ? const Color(0xFF16323F)
                    : AppColors.stoneBorder.withValues(alpha: 0.5),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted
                      ? AppColors.statusOnTime
                      : AppColors.accentLimnological,
                ),
              ),
            ),
          ),
          if (isCompleted) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.statusOnTime.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.statusOnTime.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.celebration_rounded,
                    color: AppColors.statusOnTime,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      '¡Felicidades! Has completado el 100% de tus horas.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.statusOnTime,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      FreedomDialog.show(
                        context,
                        studentType: student.studentType,
                        studentId: student.id,
                        accumulatedHours: student.accumulatedHours,
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Ver Cita'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
