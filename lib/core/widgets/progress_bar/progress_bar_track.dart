import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

/// Riel base para las barras de progreso con diseño de cápsula de cristal,
/// ranura embutida y marcas sutiles de hitos (25%, 50%, 75%).
class ProgressBarTrack extends StatelessWidget {
  final double height;
  final bool isDark;
  final Widget child;
  final bool showMilestones;

  const ProgressBarTrack({
    super.key,
    required this.height,
    required this.isDark,
    required this.child,
    this.showMilestones = true,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(height / 2);

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: isDark
            ? Colors.black.withValues(alpha: 0.35)
            : const Color(0xFFDED8CD).withValues(alpha: 0.65),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : AppColors.stoneBorder.withValues(alpha: 0.8),
          width: 1.0,
        ),
        boxShadow: [
          // Sombra interior sutil para efecto de canal embutido
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.45)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 3,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            // Contenido de la barra (progreso activo)
            Positioned.fill(child: child),

            // Marcas sutiles de hitos a 25%, 50%, 75%
            if (showMilestones)
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final tickColor = isDark
                        ? Colors.white.withValues(alpha: 0.16)
                        : Colors.black.withValues(alpha: 0.12);

                    return Row(
                      children: [
                        SizedBox(width: width * 0.25 - 0.5),
                        _buildTick(tickColor),
                        SizedBox(width: width * 0.25 - 1.0),
                        _buildTick(tickColor),
                        SizedBox(width: width * 0.25 - 1.0),
                        _buildTick(tickColor),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTick(Color color) {
    return Container(
      width: 1.0,
      height: height * 0.45,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(0.5),
      ),
    );
  }
}
