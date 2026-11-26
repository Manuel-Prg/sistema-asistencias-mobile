import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Barra de progreso estilo Aurora iridiscente: gradiente armónico dinámico
/// derivado del color del tema con flujo continuo de luz satinada.
class AuroraProgressBar extends StatefulWidget {
  final double ratio;
  final Color barColor;
  final double height;
  final double maxWidth;

  const AuroraProgressBar({
    super.key,
    required this.ratio,
    required this.barColor,
    required this.height,
    required this.maxWidth,
  });

  @override
  State<AuroraProgressBar> createState() => _AuroraProgressBarState();
}

class _AuroraProgressBarState extends State<AuroraProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
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
              painter: _AuroraPainter(
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

class _AuroraPainter extends CustomPainter {
  final Animation<double> animation;
  final Color barColor;

  _AuroraPainter({
    required this.animation,
    required this.barColor,
  }) : super(repaint: animation);

  Color _shiftHue(Color base, double deltaHue, {double lightnessDelta = 0.0}) {
    final hsl = HSLColor.fromColor(base);
    final newHue = (hsl.hue + deltaHue) % 360.0;
    final newLightness = (hsl.lightness + lightnessDelta).clamp(0.18, 0.85);
    final newSaturation = (hsl.saturation + 0.08).clamp(0.35, 1.0);
    return hsl
        .withHue(newHue < 0 ? newHue + 360.0 : newHue)
        .withLightness(newLightness)
        .withSaturation(newSaturation)
        .toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final t = animation.value;
    final rect = Rect.fromLTWH(0, 0, w, h);

    // Paleta iridiscente derivada del color del tema
    final coolTone = _shiftHue(barColor, -34, lightnessDelta: -0.04);
    final warmTone = _shiftHue(barColor, 36, lightnessDelta: 0.08);
    final pearlTone = Color.lerp(warmTone, Colors.white, 0.45) ?? warmTone;

    // Flujo cromático continuo en bucle infinito (sin salto al reiniciar t)
    final shift = math.sin(t * 2 * math.pi) * 0.22;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(-1.2 + shift, -0.4),
          end: Alignment(1.2 + shift, 0.4),
          colors: [coolTone, barColor, warmTone, pearlTone, barColor],
          stops: const [0.0, 0.30, 0.62, 0.84, 1.0],
        ).createShader(rect),
    );

    // Haz de luz satinada que recorre la barra suavemente
    final shimmerCenter = (t * (w + 90.0)) - 45.0;
    final shimmerRect = Rect.fromLTWH(shimmerCenter - 35.0, 0, 70.0, h);
    canvas.drawRect(
      shimmerRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.45),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(shimmerRect),
    );

    // Reflejo especular superior sutil
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.40),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h * 0.40)),
    );

    // Destello perla en la punta de avance
    if (w >= 6) {
      final pulse = 0.65 + 0.35 * math.sin(t * 2 * math.pi);
      canvas.drawCircle(
        Offset(w - h * 0.35, h * 0.5),
        h * 0.26,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.78 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) {
    return oldDelegate.barColor != barColor;
  }
}
