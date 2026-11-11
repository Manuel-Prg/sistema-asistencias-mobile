import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    final targetRatio = (percentage / 100).clamp(0.0, 1.0);

    return GlassSurface(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(16),
      enableRefraction: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: targetRatio),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (context, animatedRatio, _) {
          final animatedPercentage = (animatedRatio * 100);

          return Column(
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
                  // Porcentaje animado
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
                      '${animatedPercentage.toStringAsFixed(1)}%',
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
              // Barra de progreso animada con destello líquido en modo idle
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 12,
                  width: double.infinity,
                  color: isDark
                      ? const Color(0xFF16323F)
                      : AppColors.stoneBorder.withValues(alpha: 0.5),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth = constraints.maxWidth;
                      final barWidth =
                          (maxWidth * animatedRatio).clamp(0.0, maxWidth);

                      if (barWidth <= 0) return const SizedBox.shrink();

                      final barColor = isCompleted
                          ? AppColors.statusOnTime
                          : AppColors.accentLimnological;

                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: barWidth,
                          height: 12,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              colors: [
                                barColor,
                                Color.lerp(barColor, Colors.white, 0.16) ??
                                    barColor,
                              ],
                            ),
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat())
                            .shimmer(
                              delay: 1400.ms,
                              duration: 2200.ms,
                              color: Colors.white.withValues(alpha: 0.45),
                              curve: Curves.easeInOutCubic,
                            ),
                      );
                    },
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
                          '¡Felicidades! Has completado la meta de horas requeridas.',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.statusOnTime,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => FreedomDialog.show(
                      context,
                      studentType: student.studentType,
                      studentId: student.id,
                      accumulatedHours: student.accumulatedHours,
                    ),
                    icon: const Icon(Icons.workspace_premium_rounded, size: 20),
                    label: const Text(
                      'TRAMITAR CARTA DE LIBERACIÓN',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusOnTime,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
