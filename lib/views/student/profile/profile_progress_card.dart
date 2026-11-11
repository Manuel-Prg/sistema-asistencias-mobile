import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';

class ProfileProgressCard extends StatelessWidget {
  final double accumulatedHours;
  final num requiredHours;

  const ProfileProgressCard({
    super.key,
    required this.accumulatedHours,
    required this.requiredHours,
  });

  double get remainingHours =>
      (requiredHours - accumulatedHours).clamp(0.0, double.infinity);

  double get progressRatio =>
      requiredHours > 0 ? (accumulatedHours / requiredHours).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassSurface(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(18),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: progressRatio),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (context, animatedRatio, _) {
          final animatedPercent = (animatedRatio * 100).toStringAsFixed(1);
          final barColor =
              isDark ? AppColors.signalAqua : AppColors.accentLimnological;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.insights_rounded,
                        color: isDark ? AppColors.signalAqua : AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Progreso del Servicio',
                        style: TextStyle(
                          fontFamily: AppTheme.brandFont,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.signalAqua : AppColors.primary)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$animatedPercent%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.signalAqua : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Barra de progreso animada con destello líquido en modo idle
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 10,
                  width: double.infinity,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : AppColors.secondary.withValues(alpha: 0.5),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth = constraints.maxWidth;
                      final barWidth =
                          (maxWidth * animatedRatio).clamp(0.0, maxWidth);

                      if (barWidth <= 0) return const SizedBox.shrink();

                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: barWidth,
                          height: 10,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(6),
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
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      label: 'Acumuladas',
                      value: '${accumulatedHours.toStringAsFixed(1)}h',
                      color: isDark ? AppColors.signalAqua : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricTile(
                      label: 'Faltantes',
                      value: '${remainingHours.toStringAsFixed(1)}h',
                      color: AppColors.amberTolerance,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricTile(
                      label: 'Meta total',
                      value: '${requiredHours.toInt()}h',
                      color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.stoneBorder,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFamily: AppTheme.brandFont,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontFamily: AppTheme.brandFont,
              color: isDark ? AppColors.darkTextSecondary : AppColors.slateMuted,
            ),
          ),
        ],
      ),
    );
  }
}
