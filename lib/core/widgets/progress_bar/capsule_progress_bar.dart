import 'package:flutter/material.dart';

/// Barra de progreso estilo Cápsula de Cristal Líquido.
/// Presenta gradiente acuático volumétrico, reflejo especular superior
/// y gota de luz en el punto frontera de avance.
class CapsuleProgressBar extends StatelessWidget {
  final double ratio;
  final Color barColor;
  final double height;
  final double maxWidth;

  const CapsuleProgressBar({
    super.key,
    required this.ratio,
    required this.barColor,
    required this.height,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final barWidth = (maxWidth * ratio).clamp(0.0, maxWidth);
    if (barWidth <= 0) return const SizedBox.shrink();

    final radius = height / 2;
    final baseDark = Color.lerp(barColor, Colors.black, 0.18) ?? barColor;
    final leadBright = Color.lerp(barColor, Colors.white, 0.28) ?? barColor;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: barWidth,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              baseDark,
              barColor,
              leadBright,
            ],
            stops: const [0.0, 0.70, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: barColor.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Reflejo especular superior continuo (brillo de vidrio)
            Positioned(
              top: 1.0,
              left: 2.0,
              right: 2.0,
              height: height * 0.38,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.55),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),

            // Gota de luz / Destello en el extremo frontera del progreso
            if (barWidth > 12)
              Positioned(
                top: 2.0,
                bottom: 2.0,
                right: 3.0,
                width: height - 4.0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.90),
                        Colors.white.withValues(alpha: 0.20),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

