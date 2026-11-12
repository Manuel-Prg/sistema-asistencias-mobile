import 'package:flutter/material.dart';

/// Barra de progreso estilo Segmentado / Matriz de Precisión.
/// Muestra micro-cápsulas discretas con ranuras embutidas y realce en la
/// celda frontera activa.
class SegmentedProgressBar extends StatelessWidget {
  final double ratio;
  final Color barColor;
  final double height;
  final bool isDark;
  final int totalSegments;

  const SegmentedProgressBar({
    super.key,
    required this.ratio,
    required this.barColor,
    required this.height,
    required this.isDark,
    this.totalSegments = 16,
  });

  @override
  Widget build(BuildContext context) {
    final filledSegments = (ratio * totalSegments).round().clamp(0, totalSegments);
    const gap = 2.5;
    final segmentRadius = BorderRadius.circular(height * 0.28);

    return SizedBox(
      height: height,
      child: Row(
        children: List.generate(totalSegments, (index) {
          final isFilled = index < filledSegments;
          final isFrontier = index == filledSegments - 1 && filledSegments > 0;
          final isMilestone = (index + 1) % (totalSegments / 4).round() == 0;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < totalSegments - 1 ? gap : 0,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: height,
                decoration: BoxDecoration(
                  borderRadius: segmentRadius,
                  gradient: isFilled
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            isFrontier
                                ? Color.lerp(barColor, Colors.white, 0.40)!
                                : Color.lerp(barColor, Colors.white, 0.18)!,
                            barColor,
                            Color.lerp(barColor, Colors.black, 0.15)!,
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        )
                      : null,
                  color: isFilled
                      ? null
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.06)),
                  border: Border.all(
                    color: isFilled
                        ? (isFrontier
                            ? Colors.white.withValues(alpha: 0.70)
                            : Colors.white.withValues(alpha: 0.25))
                        : (isMilestone
                            ? (isDark
                                ? Colors.white.withValues(alpha: 0.14)
                                : Colors.black.withValues(alpha: 0.12))
                            : Colors.transparent),
                    width: 0.8,
                  ),
                  boxShadow: [
                    if (isFrontier)
                      BoxShadow(
                        color: barColor.withValues(alpha: 0.55),
                        blurRadius: 6,
                        spreadRadius: 0.5,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

