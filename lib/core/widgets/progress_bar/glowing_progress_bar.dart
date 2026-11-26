import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'progress_bar_expressive_helpers.dart';

/// Barra de progreso estilo Resplandor Neón Expresivo: filamento de plasma
/// luminoso con pulso energético que deforma su contorno al viajar hacia el
/// extremo, halo difuso exterior (bloom) y faro vertical pulsante.
class GlowingProgressBar extends StatefulWidget {
  final double ratio;
  final Color barColor;
  final double height;
  final double maxWidth;
  final bool isDark;

  const GlowingProgressBar({
    super.key,
    required this.ratio,
    required this.barColor,
    required this.height,
    required this.maxWidth,
    required this.isDark,
  });

  @override
  State<GlowingProgressBar> createState() => _GlowingProgressBarState();
}

class _GlowingProgressBarState extends State<GlowingProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations) {
      _pulseController.stop();
      _pulseController.value = 0.5;
    } else if (!_pulseController.isAnimating) {
      _pulseController.repeat();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
          painter: _ExpressiveNeonPainter(
            animation: _pulseController,
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

class _ExpressiveNeonPainter extends CustomPainter {
  final Animation<double> animation;
  final double ratio;
  final Color barColor;
  final bool isDark;

  _ExpressiveNeonPainter({
    required this.animation,
    required this.ratio,
    required this.barColor,
    required this.isDark,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final h = size.height;
    if (width <= 0 || h <= 0) return;

    final centerY = h / 2;
    final baseStroke = (h * 0.28).clamp(3.8, 5.4);
    final padX = baseStroke / 2;
    final usableWidth = math.max(0.0, width - baseStroke);
    final activeEndX = padX + (usableWidth * ratio);

    // 1. Riel inactivo delgado
    final trackStartX =
        ratio > 0.0 ? math.min(activeEndX + 7.0, width - padX) : padX;
    ExpressiveProgressPainterHelper.drawInactiveTrack(
      canvas: canvas,
      startX: trackStartX,
      endX: width - padX,
      centerY: centerY,
      strokeWidth: baseStroke * 0.85,
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
        haloIntensity: 1.5,
      );
      return;
    }

    final t = animation.value;
    final pulseCenterX = padX + (t * (activeLen + 36.0)) - 18.0;
    final breath = 0.5 + 0.5 * math.sin(t * 2 * math.pi);

    // 2. Contorno de plasma neón con bulto energético viajando hacia el frente
    final plasmaPath = Path();
    final corePath = Path();
    const step = 2.0;
    final minHalfH = baseStroke * 0.45;
    final pulseExtraHalfH = (h * 0.28).clamp(2.8, 5.2);

    for (double x = padX; x <= activeEndX; x += step) {
      final cx = math.min(x, activeEndX);
      final distToPulse = (cx - pulseCenterX).abs();
      final gaussian = math.exp(-(distToPulse * distToPulse) / 220.0);
      final edgeEnv = ExpressiveProgressPainterHelper.edgeSmoothstep(
        math.min(cx - padX, activeEndX - cx),
        8.0,
      );
      final halfH = minHalfH + (pulseExtraHalfH * gaussian * edgeEnv);

      if (x == padX) {
        plasmaPath.moveTo(cx, centerY - halfH);
        corePath.moveTo(cx, centerY);
      } else {
        plasmaPath.lineTo(cx, centerY - halfH);
        corePath.lineTo(cx, centerY);
      }
    }
    for (double x = activeEndX; x >= padX; x -= step) {
      final cx = math.max(x, padX);
      final distToPulse = (cx - pulseCenterX).abs();
      final gaussian = math.exp(-(distToPulse * distToPulse) / 220.0);
      final edgeEnv = ExpressiveProgressPainterHelper.edgeSmoothstep(
        math.min(cx - padX, activeEndX - cx),
        8.0,
      );
      final halfH = minHalfH + (pulseExtraHalfH * gaussian * edgeEnv);
      plasmaPath.lineTo(cx, centerY + halfH);
    }
    plasmaPath.close();

    final brightColor = Color.lerp(barColor, Colors.white, 0.45) ?? barColor;
    final activeRect = Rect.fromLTWH(padX, 0, math.max(1.0, activeLen), h);

    // Halo difuso exterior (Bloom)
    canvas.drawPath(
      plasmaPath,
      Paint()
        ..color = barColor.withValues(alpha: isDark ? 0.65 : 0.40)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5.5 + breath * 3.0),
    );

    // Cuerpo principal del filamento
    canvas.drawPath(
      plasmaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [barColor, brightColor, Colors.white.withValues(alpha: 0.92)],
          stops: const [0.0, 0.72, 1.0],
        ).createShader(activeRect),
    );

    // Núcleo blanco eléctrico interior
    canvas.drawPath(
      corePath,
      Paint()
        ..color = Colors.white.withValues(alpha: isDark ? 0.70 : 0.60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );

    // 3. Faro vertical neón pulsante
    ExpressiveProgressPainterHelper.drawLeadingCap(
      canvas: canvas,
      x: activeEndX,
      centerY: centerY,
      totalHeight: h,
      barColor: barColor,
      isDark: isDark,
      haloIntensity: 1.3 + breath * 0.5,
      capColorOverride: Color.lerp(brightColor, Colors.white, 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant _ExpressiveNeonPainter oldDelegate) {
    return oldDelegate.ratio != ratio ||
        oldDelegate.barColor != barColor ||
        oldDelegate.isDark != isDark;
  }
}
