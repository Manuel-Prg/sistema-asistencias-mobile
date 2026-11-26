import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Barra de progreso acuática con burbujas cristalinas animadas que flotan
/// continuamente dentro del líquido en bucle infinito perfecto.
class BubblesProgressBar extends StatefulWidget {
  final double ratio;
  final Color barColor;
  final double height;
  final double maxWidth;

  const BubblesProgressBar({
    super.key,
    required this.ratio,
    required this.barColor,
    required this.height,
    required this.maxWidth,
  });

  @override
  State<BubblesProgressBar> createState() => _BubblesProgressBarState();
}

class _BubblesProgressBarState extends State<BubblesProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations) {
      _controller.stop();
      _controller.value = 0.25;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
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

    return RepaintBoundary(
      child: Align(
        alignment: Alignment.centerLeft,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            width: barWidth,
            height: widget.height,
            child: CustomPaint(
              painter: _BubblesPainter(
                animation: _controller,
                barColor: widget.barColor,
              ),
              size: Size(barWidth, widget.height),
            ),
          ),
        ),
      ),
    );
  }
}

class _BubbleSeed {
  final double xPhase; // 0..1 posición horizontal inicial
  final double yPhase; // 0..1 posición vertical inicial
  final double radiusFactor; // fracción de la altura de la barra
  final int speed; // entero para bucle perfecto (1 o 2)
  final double wobblePhase;

  const _BubbleSeed({
    required this.xPhase,
    required this.yPhase,
    required this.radiusFactor,
    required this.speed,
    required this.wobblePhase,
  });
}

class _BubblesPainter extends CustomPainter {
  final Animation<double> animation;
  final Color barColor;

  static const List<_BubbleSeed> _bubbles = [
    _BubbleSeed(xPhase: 0.06, yPhase: 0.25, radiusFactor: 0.20, speed: 1, wobblePhase: 0.0),
    _BubbleSeed(xPhase: 0.14, yPhase: 0.72, radiusFactor: 0.14, speed: 2, wobblePhase: 1.2),
    _BubbleSeed(xPhase: 0.23, yPhase: 0.45, radiusFactor: 0.24, speed: 1, wobblePhase: 2.1),
    _BubbleSeed(xPhase: 0.32, yPhase: 0.80, radiusFactor: 0.16, speed: 2, wobblePhase: 0.7),
    _BubbleSeed(xPhase: 0.41, yPhase: 0.30, radiusFactor: 0.18, speed: 1, wobblePhase: 3.0),
    _BubbleSeed(xPhase: 0.50, yPhase: 0.65, radiusFactor: 0.22, speed: 1, wobblePhase: 1.8),
    _BubbleSeed(xPhase: 0.59, yPhase: 0.20, radiusFactor: 0.15, speed: 2, wobblePhase: 4.1),
    _BubbleSeed(xPhase: 0.68, yPhase: 0.55, radiusFactor: 0.25, speed: 1, wobblePhase: 2.7),
    _BubbleSeed(xPhase: 0.77, yPhase: 0.78, radiusFactor: 0.16, speed: 2, wobblePhase: 0.4),
    _BubbleSeed(xPhase: 0.86, yPhase: 0.35, radiusFactor: 0.20, speed: 1, wobblePhase: 5.0),
    _BubbleSeed(xPhase: 0.94, yPhase: 0.60, radiusFactor: 0.14, speed: 2, wobblePhase: 1.5),
  ];

  _BubblesPainter({
    required this.animation,
    required this.barColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final t = animation.value;
    final rect = Rect.fromLTWH(0, 0, w, h);

    // 1. Cuerpo líquido con profundidad vertical
    final topColor = Color.lerp(barColor, Colors.white, 0.22) ?? barColor;
    final bottomColor =
        Color.lerp(barColor, const Color(0xFF092C3A), 0.35) ?? barColor;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, barColor, bottomColor],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    // 2. Burbujas cristalinas flotando de izquierda a derecha y ascendiendo suave
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (final b in _bubbles) {
      final progressX = (b.xPhase + t * b.speed) % 1.0;
      final cx = progressX * (w + h) - h * 0.5;
      if (cx < -h || cx > w + h) continue;

      final wobbleY =
          math.sin(t * 2 * math.pi * b.speed + b.wobblePhase) * (h * 0.14);
      final cy = (b.yPhase * h + wobbleY).clamp(h * 0.18, h * 0.82);
      final r = (h * b.radiusFactor).clamp(1.6, 4.2);

      // Cuerpo translúcido de la burbuja
      fillPaint.color = Colors.white.withValues(alpha: 0.22);
      canvas.drawCircle(Offset(cx, cy), r, fillPaint);

      // Borde fino brillante
      strokePaint.color = Colors.white.withValues(alpha: 0.65);
      canvas.drawCircle(Offset(cx, cy), r, strokePaint);

      // Punto especular en esquina superior izquierda
      fillPaint.color = Colors.white.withValues(alpha: 0.92);
      canvas.drawCircle(
        Offset(cx - r * 0.32, cy - r * 0.32),
        math.max(0.65, r * 0.28),
        fillPaint,
      );
    }

    // 3. Reflejo superior de vidrio curvo
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.42),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.40),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h * 0.42)),
    );

    // 4. Menisco brillante en el borde derecho
    if (w >= 6) {
      canvas.drawCircle(
        Offset(w - h * 0.32, h * 0.5),
        h * 0.28,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BubblesPainter oldDelegate) {
    return oldDelegate.barColor != barColor;
  }
}
