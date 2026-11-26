import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'progress_bar_expressive_helpers.dart';

/// Barra de progreso estilo Burbujas Expresivas: esferas cristalinas de agua
/// translúcidas de distintos tamaños que flotan y avanzan suavemente sobre un
/// hilo acuático sutil, con brillo curvo en cada burbuja, marcador vertical y
/// riel inactivo delgado.
class BubblesProgressBar extends StatefulWidget {
  final double ratio;
  final Color barColor;
  final double height;
  final double maxWidth;
  final bool isDark;

  const BubblesProgressBar({
    super.key,
    required this.ratio,
    required this.barColor,
    required this.height,
    required this.maxWidth,
    this.isDark = false,
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
      duration: const Duration(milliseconds: 3600),
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
          painter: _ExpressiveBubblesPainter(
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

class _BubbleSpec {
  final double spacingOffset;
  final double radiusFactor;
  final double yBias;
  final double bobPhase;

  const _BubbleSpec({
    required this.spacingOffset,
    required this.radiusFactor,
    required this.yBias,
    required this.bobPhase,
  });
}

class _ExpressiveBubblesPainter extends CustomPainter {
  final Animation<double> animation;
  final double ratio;
  final Color barColor;
  final bool isDark;

  // Patrón orgánico de burbujas grandes, medianas y micro-burbujas
  static const List<_BubbleSpec> _pattern = [
    _BubbleSpec(spacingOffset: 0.00, radiusFactor: 0.36, yBias: -0.10, bobPhase: 0.0),
    _BubbleSpec(spacingOffset: 0.22, radiusFactor: 0.22, yBias: 0.22, bobPhase: 1.4),
    _BubbleSpec(spacingOffset: 0.44, radiusFactor: 0.42, yBias: 0.04, bobPhase: 2.6),
    _BubbleSpec(spacingOffset: 0.69, radiusFactor: 0.25, yBias: -0.22, bobPhase: 4.0),
    _BubbleSpec(spacingOffset: 0.85, radiusFactor: 0.31, yBias: 0.14, bobPhase: 5.1),
  ];

  _ExpressiveBubblesPainter({
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
    final baseStroke = (h * 0.26).clamp(3.6, 5.0);
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
      strokeWidth: baseStroke * 0.88,
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

    // 2. Hilo acuático translúcido de base que une la corriente de burbujas
    final threadRect = Rect.fromLTWH(padX, 0, math.max(1.0, activeLen), h);
    canvas.drawLine(
      Offset(padX, centerY),
      Offset(activeEndX, centerY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            barColor.withValues(alpha: isDark ? 0.22 : 0.16),
            barColor.withValues(alpha: isDark ? 0.42 : 0.32),
          ],
        ).createShader(threadRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (h * 0.16).clamp(2.2, 3.2)
        ..strokeCap = StrokeCap.round,
    );

    // 3. Burbujas cristalinas translúcidas flotando en bucle infinito perfecto
    final t = animation.value;
    const cycleWidth = 68.0; // Ancho de cada grupo de 5 burbujas
    final driftPx = t * cycleWidth; // Al reiniciar t=0->1 avanza exactamente 1 ciclo
    final bobPhaseGlobal = t * 2 * math.pi;

    final rimColor = Color.lerp(barColor, Colors.white, isDark ? 0.28 : 0.05)!;
    final tintFill = barColor.withValues(alpha: isDark ? 0.34 : 0.22);

    final startCycle = -1;
    final endCycle = (activeLen / cycleWidth).ceil() + 1;

    for (var c = startCycle; c <= endCycle; c++) {
      for (final spec in _pattern) {
        final rawX = padX + (c + spec.spacingOffset) * cycleWidth + driftPx;
        if (rawX < padX - 4.0 || rawX > activeEndX - 3.0) continue;

        // Aparición y fusión suave en ambos extremos
        final edgeScale = ExpressiveProgressPainterHelper.edgeSmoothstep(
          math.min(rawX - padX, activeEndX - 3.0 - rawX),
          10.0,
        );
        if (edgeScale <= 0.05) continue;

        final maxR = (h * spec.radiusFactor).clamp(2.4, h * 0.46);
        final r = maxR * (0.35 + 0.65 * edgeScale);

        final bobY = math.sin(bobPhaseGlobal + spec.bobPhase) * (h * 0.12);
        final cy = (centerY + (h * spec.yBias) + bobY).clamp(
          r + 0.8,
          h - r - 0.8,
        );
        final center = Offset(rawX, cy);

        // Interior cristalino con gradiente radial (centro claro -> borde con color)
        final bubbleRect = Rect.fromCircle(center: center, radius: r);
        canvas.drawCircle(
          center,
          r,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.35, -0.35),
              radius: 0.95,
              colors: [
                Colors.white.withValues(alpha: isDark ? 0.32 : 0.72),
                tintFill,
                barColor.withValues(alpha: isDark ? 0.62 : 0.48),
              ],
              stops: const [0.0, 0.58, 1.0],
            ).createShader(bubbleRect),
        );

        // Aro cristalino nítido de la burbuja
        canvas.drawCircle(
          center,
          r,
          Paint()
            ..color = rimColor.withValues(alpha: (0.85 * edgeScale).clamp(0.0, 1.0))
            ..style = PaintingStyle.stroke
            ..strokeWidth = r > 4.2 ? 1.35 : 1.05,
        );

        // Destello curvo blanco en la esquina superior izquierda (efecto pompa real)
        final arcRect = Rect.fromCircle(center: center, radius: r * 0.64);
        canvas.drawArc(
          arcRect,
          math.pi * 1.12,
          math.pi * 0.42,
          false,
          Paint()
            ..color = Colors.white.withValues(
              alpha: ((isDark ? 0.80 : 0.95) * edgeScale).clamp(0.0, 1.0),
            )
            ..style = PaintingStyle.stroke
            ..strokeWidth = r > 4.2 ? 1.3 : 0.95
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    // 4. Marcador vertical estilizado
    ExpressiveProgressPainterHelper.drawLeadingCap(
      canvas: canvas,
      x: activeEndX,
      centerY: centerY,
      totalHeight: h,
      barColor: barColor,
      isDark: isDark,
    );
  }

  @override
  bool shouldRepaint(covariant _ExpressiveBubblesPainter oldDelegate) {
    return oldDelegate.ratio != ratio ||
        oldDelegate.barColor != barColor ||
        oldDelegate.isDark != isDark;
  }
}
