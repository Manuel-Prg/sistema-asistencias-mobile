import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Barra de progreso con simulación fluida de olas acuáticas en bucle infinito
/// perfecto (sin cortes ni saltos temporales).
class WaveProgressBar extends StatefulWidget {
  final double ratio;
  final Color barColor;
  final double height;
  final double maxWidth;

  const WaveProgressBar({
    super.key,
    required this.ratio,
    required this.barColor,
    required this.height,
    required this.maxWidth,
  });

  @override
  State<WaveProgressBar> createState() => _WaveProgressBarState();
}

class _WaveProgressBarState extends State<WaveProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barWidth = (widget.maxWidth * widget.ratio).clamp(
      0.0,
      widget.maxWidth,
    );
    if (barWidth <= 0) return const SizedBox.shrink();

    final radius = widget.height / 2;

    return Align(
      alignment: Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: barWidth,
          height: widget.height,
          child: CustomPaint(
            painter: _DualWavePainter(
              animation: _controller,
              barColor: widget.barColor,
              height: widget.height,
            ),
            size: Size(barWidth, widget.height),
          ),
        ),
      ),
    );
  }
}

/// Pintor que genera dos olas sinusoidales armónicas con periodicidad matemática exacta
/// garantizando un bucle infinito continuo (seamless loop) al 100%.
class _DualWavePainter extends CustomPainter {
  final Animation<double> animation;
  final Color barColor;
  final double height;

  _DualWavePainter({
    required this.animation,
    required this.barColor,
    required this.height,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final h = size.height;
    if (width <= 0 || h <= 0) return;

    final t = animation.value; // 0.0 -> 1.0 continuo

    // Fondo base del líquido (cuerpo de agua profundo)
    final baseDark =
        Color.lerp(barColor, const Color(0xFF0C3C4C), 0.35) ?? barColor;
    final baseBright = Color.lerp(barColor, Colors.white, 0.30) ?? barColor;
    final fullRect = Rect.fromLTWH(0, 0, width, h);

    canvas.drawRect(
      fullRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(baseDark, barColor, 0.4)!, baseDark],
        ).createShader(fullRect),
    );

    // ──────────────────────────────────────────────────────────────────────────
    // 1. OLA TRASERA: Flujo armónico primario (1 ciclo temporal completo = 2π*t)
    // ──────────────────────────────────────────────────────────────────────────
    const wavelength1 = 56.0; // Longitud de onda fija en píxeles
    final k1 = (2 * math.pi) / wavelength1;
    final phase1 = t * 2 * math.pi; // Período temporal exacto = 1

    final backPath = Path();
    backPath.moveTo(0, h);

    const step = 3.0;
    final midY1 = h * 0.42;
    final amp1 = h * 0.22;

    for (double x = 0; x <= width + step; x += step) {
      final currentX = x.clamp(0.0, width);
      final y = midY1 + math.sin(k1 * currentX - phase1) * amp1;
      backPath.lineTo(currentX, y);
    }
    backPath.lineTo(width, h);
    backPath.close();

    final backPaint = Paint()
      ..color = barColor.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    canvas.drawPath(backPath, backPaint);

    // ──────────────────────────────────────────────────────────────────────────
    // 2. OLA FRONTAL: Cresta vibrante rápida (2 ciclos temporales completos = 4π*t)
    // ──────────────────────────────────────────────────────────────────────────
    const wavelength2 = 42.0;
    final k2 = (2 * math.pi) / wavelength2;
    final phase2 = t * 4 * math.pi; // Período temporal exacto = 2 (armónico)

    final frontPath = Path();
    final crestPath = Path();
    frontPath.moveTo(0, h);

    final midY2 = h * 0.35;
    final amp2 = h * 0.24;

    for (double x = 0; x <= width + step; x += step) {
      final currentX = x.clamp(0.0, width);
      final y = midY2 + math.sin(k2 * currentX + phase2) * amp2;
      frontPath.lineTo(currentX, y);
      if (x == 0) {
        crestPath.moveTo(currentX, y);
      } else {
        crestPath.lineTo(currentX, y);
      }
    }
    frontPath.lineTo(width, h);
    frontPath.close();

    // Relleno frontal con gradiente luminoso
    final frontPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [baseBright, barColor],
        stops: const [0.0, 0.85],
      ).createShader(fullRect);
    canvas.drawPath(frontPath, frontPaint);

    // Línea de cresta / espuma blanca brillante
    final crestPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawPath(crestPath, crestPaint);

    // ──────────────────────────────────────────────────────────────────────────
    // 3. REFLEJO ESPECULAR Y DESTELLO DE LUZ ACUÁTICO CONTINUO
    // ──────────────────────────────────────────────────────────────────────────
    // Reflejo superior de cristal
    final glassHighlight = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.45),
          Colors.white.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, h * 0.40));
    canvas.drawRect(Rect.fromLTWH(0, 0, width, h * 0.40), glassHighlight);

    // Destello de agua en movimiento (recorre la superficie en bucle infinito)
    final sweepX = (t * (width + 60.0)) - 30.0;
    final shimmerPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [Colors.white.withValues(alpha: 0.40), Colors.transparent],
            stops: const [0.0, 1.0],
          ).createShader(
            Rect.fromCircle(center: Offset(sweepX, h * 0.38), radius: 20.0),
          );
    canvas.drawCircle(Offset(sweepX, h * 0.38), 20.0, shimmerPaint);
  }

  @override
  bool shouldRepaint(covariant _DualWavePainter oldDelegate) {
    return oldDelegate.barColor != barColor || oldDelegate.height != height;
  }
}
