import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'progress_bar_expressive_helpers.dart';

/// Barra de progreso estilo Aurora Expresiva: doble cinta sinusoidal sedosa
/// entrelazada (efecto hélice boreal) con gradiente iridiscente dinámico,
/// marcador vertical perla y riel inactivo delgado.
class AuroraProgressBar extends StatefulWidget {
  final double ratio;
  final Color barColor;
  final double height;
  final double maxWidth;
  final bool isDark;

  const AuroraProgressBar({
    super.key,
    required this.ratio,
    required this.barColor,
    required this.height,
    required this.maxWidth,
    this.isDark = false,
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
    final effectiveHeight = ExpressiveProgressPainterHelper.effectiveHeight(
      widget.height,
    );

    return RepaintBoundary(
      child: SizedBox(
        width: widget.maxWidth,
        height: effectiveHeight,
        child: CustomPaint(
          painter: _ExpressiveAuroraPainter(
            animation: _controller,
            ratio: widget.ratio.clamp(0.0, 1.0),
            barColor: widget.barColor,
            isDark: widget.isDark,
          ),
          size: Size(widget.maxWidth, effectiveHeight),
        ),
      ),
    );
  }
}

class _ExpressiveAuroraPainter extends CustomPainter {
  final Animation<double> animation;
  final double ratio;
  final Color barColor;
  final bool isDark;

  _ExpressiveAuroraPainter({
    required this.animation,
    required this.ratio,
    required this.barColor,
    required this.isDark,
  }) : super(repaint: animation);

  Color _shiftHue(Color base, double deltaHue, {double lightnessDelta = 0.0}) {
    final hsl = HSLColor.fromColor(base);
    final rawHue = (hsl.hue + deltaHue) % 360.0;
    final newHue = rawHue < 0 ? rawHue + 360.0 : rawHue;
    final newLightness = (hsl.lightness + lightnessDelta).clamp(0.22, 0.84);
    final newSaturation = (hsl.saturation + 0.12).clamp(0.40, 1.0);
    return hsl
        .withHue(newHue)
        .withLightness(newLightness)
        .withSaturation(newSaturation)
        .toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final h = size.height;
    if (width <= 0 || h <= 0) return;

    final centerY = h / 2;
    final strokeWidth = (h * 0.26).clamp(3.6, 5.2);
    final padX = strokeWidth / 2;
    final usableWidth = math.max(0.0, width - strokeWidth);
    final activeEndX = padX + (usableWidth * ratio);

    // 1. Riel inactivo delgado
    final trackStartX =
        ratio > 0.0 ? math.min(activeEndX + 7.0, width - padX) : padX;
    ExpressiveProgressPainterHelper.drawInactiveTrack(
      canvas: canvas,
      startX: trackStartX,
      endX: width - padX,
      centerY: centerY,
      strokeWidth: strokeWidth * 0.90,
      isDark: isDark,
    );

    if (ratio <= 0.001) return;

    final activeLen = activeEndX - padX;
    if (activeLen < 6.0) {
      ExpressiveProgressPainterHelper.drawLeadingCap(
        canvas: canvas,
        x: activeEndX,
        centerY: centerY,
        totalHeight: h,
        barColor: barColor,
        isDark: isDark,
      );
      return;
    }

    // 2. Doble cinta sinusoidal entrelazada (longitud de onda sedosa amplia)
    final t = animation.value;
    const wavelength = 46.0;
    final k = (2 * math.pi) / wavelength;
    final phase = t * 2 * math.pi;
    final amplitude = (h - strokeWidth - 3.0) / 2;

    final ribbonAPath = Path();
    final ribbonBPath = Path();
    const step = 2.0;

    for (double x = padX; x <= activeEndX; x += step) {
      final cx = math.min(x, activeEndX);
      final env = ExpressiveProgressPainterHelper.edgeSmoothstep(
        math.min(cx - padX, activeEndX - cx),
        12.0,
      );
      final localAmp = amplitude * env;

      final yA = centerY + math.sin(k * cx - phase) * localAmp;
      final yB = centerY + math.sin(k * cx - phase + math.pi) * (localAmp * 0.85);

      if (x == padX) {
        ribbonAPath.moveTo(cx, yA);
        ribbonBPath.moveTo(cx, yB);
      } else {
        ribbonAPath.lineTo(cx, yA);
        ribbonBPath.lineTo(cx, yB);
      }
    }
    ribbonAPath.lineTo(activeEndX, centerY);
    ribbonBPath.lineTo(activeEndX, centerY);

    final coolTone = _shiftHue(barColor, -42, lightnessDelta: 0.02);
    final warmTone = _shiftHue(barColor, 44, lightnessDelta: 0.08);
    final pearlTone = Color.lerp(warmTone, Colors.white, 0.45) ?? warmTone;
    final activeRect = Rect.fromLTWH(padX, 0, math.max(1.0, activeLen), h);
    final colorShift = math.sin(phase) * 0.25;

    // Cinta B trasera (contrafase iridiscente translúcida)
    canvas.drawPath(
      ribbonBPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(-1.0 - colorShift, 0),
          end: Alignment(1.0 - colorShift, 0),
          colors: [
            warmTone.withValues(alpha: isDark ? 0.55 : 0.42),
            coolTone.withValues(alpha: isDark ? 0.55 : 0.42),
            barColor.withValues(alpha: isDark ? 0.60 : 0.45),
          ],
        ).createShader(activeRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.88
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Halo boreal suave tras cinta A
    canvas.drawPath(
      ribbonAPath,
      Paint()
        ..color = warmTone.withValues(alpha: isDark ? 0.32 : 0.20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 1.5
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5),
    );

    // Cinta A principal con gradiente cromático continuo
    canvas.drawPath(
      ribbonAPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(-1.0 + colorShift, 0),
          end: Alignment(1.0 + colorShift, 0),
          colors: [coolTone, barColor, warmTone, pearlTone],
          stops: const [0.0, 0.35, 0.72, 1.0],
        ).createShader(activeRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // 3. Marcador vertical perla
    ExpressiveProgressPainterHelper.drawLeadingCap(
      canvas: canvas,
      x: activeEndX,
      centerY: centerY,
      totalHeight: h,
      barColor: warmTone,
      isDark: isDark,
      haloIntensity: 1.2,
      capColorOverride: Color.lerp(barColor, pearlTone, 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant _ExpressiveAuroraPainter oldDelegate) {
    return oldDelegate.ratio != ratio ||
        oldDelegate.barColor != barColor ||
        oldDelegate.isDark != isDark;
  }
}
