import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'progress_bar_expressive_helpers.dart';

/// Barra de progreso estilo Cápsula Orgánica: píldora líquida perfilada que se
/// ensancha suavemente hacia el frente, con brillo especular, marcador vertical
/// expresivo y riel inactivo delgado.
class CapsuleProgressBar extends StatelessWidget {
  final double ratio;
  final Color barColor;
  final double height;
  final double maxWidth;
  final bool isDark;

  const CapsuleProgressBar({
    super.key,
    required this.ratio,
    required this.barColor,
    required this.height,
    required this.maxWidth,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = ExpressiveProgressPainterHelper.effectiveHeight(
      height,
    );

    return RepaintBoundary(
      child: SizedBox(
        width: maxWidth,
        height: effectiveHeight,
        child: CustomPaint(
          painter: _SculptedCapsulePainter(
            ratio: ratio.clamp(0.0, 1.0),
            barColor: barColor,
            isDark: isDark,
          ),
          size: Size(maxWidth, effectiveHeight),
        ),
      ),
    );
  }
}

class _SculptedCapsulePainter extends CustomPainter {
  final double ratio;
  final Color barColor;
  final bool isDark;

  _SculptedCapsulePainter({
    required this.ratio,
    required this.barColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final h = size.height;
    if (width <= 0 || h <= 0) return;

    final centerY = h / 2;
    final baseStroke = (h * 0.30).clamp(4.0, 6.0);
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
      );
      return;
    }

    // 2. Píldora líquida esculpida (forma aerodinámica de gota que crece hacia el frente)
    final bodyPath = Path();
    final highlightPath = Path();
    const step = 2.5;
    final minHalfH = baseStroke * 0.42;
    final maxHalfH = (h * 0.40).clamp(5.0, 8.0);

    // Borde superior (de izquierda a derecha)
    for (double x = padX; x <= activeEndX; x += step) {
      final cx = math.min(x, activeEndX);
      final progress = ((cx - padX) / activeLen).clamp(0.0, 1.0);
      final endTaper = ExpressiveProgressPainterHelper.edgeSmoothstep(
        activeEndX - cx,
        8.0,
      );
      final startTaper = ExpressiveProgressPainterHelper.edgeSmoothstep(
        cx - padX,
        6.0,
      );
      final bulge = math.pow(progress, 0.75).toDouble();
      final halfH =
          (minHalfH + (maxHalfH - minHalfH) * bulge * endTaper) *
          (0.65 + 0.35 * startTaper);

      final topY = centerY - halfH;
      if (x == padX) {
        bodyPath.moveTo(cx, topY);
        highlightPath.moveTo(cx, topY + 1.2);
      } else {
        bodyPath.lineTo(cx, topY);
        highlightPath.lineTo(cx, topY + 1.2);
      }
    }

    // Borde inferior (de derecha a izquierda)
    for (double x = activeEndX; x >= padX; x -= step) {
      final cx = math.max(x, padX);
      final progress = ((cx - padX) / activeLen).clamp(0.0, 1.0);
      final endTaper = ExpressiveProgressPainterHelper.edgeSmoothstep(
        activeEndX - cx,
        8.0,
      );
      final startTaper = ExpressiveProgressPainterHelper.edgeSmoothstep(
        cx - padX,
        6.0,
      );
      final bulge = math.pow(progress, 0.75).toDouble();
      final halfH =
          (minHalfH + (maxHalfH - minHalfH) * bulge * endTaper) *
          (0.65 + 0.35 * startTaper);

      bodyPath.lineTo(cx, centerY + halfH);
    }
    bodyPath.close();

    final deepColor =
        Color.lerp(barColor, const Color(0xFF0A2E3D), 0.28) ?? barColor;
    final brightColor = Color.lerp(barColor, Colors.white, 0.32) ?? barColor;
    final activeRect = Rect.fromLTWH(padX, 0, math.max(1.0, activeLen), h);

    // Sombra suave bajo la cápsula líquida
    canvas.drawPath(
      bodyPath.shift(const Offset(0, 1.2)),
      Paint()
        ..color = barColor.withValues(alpha: isDark ? 0.30 : 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
    );

    canvas.drawPath(
      bodyPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [deepColor, barColor, brightColor],
          stops: const [0.0, 0.65, 1.0],
        ).createShader(activeRect),
    );

    // Brillo especular superior fino
    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = Colors.white.withValues(alpha: isDark ? 0.38 : 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round,
    );

    // 3. Marcador vertical estilizado
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
  bool shouldRepaint(covariant _SculptedCapsulePainter oldDelegate) {
    return oldDelegate.ratio != ratio ||
        oldDelegate.barColor != barColor ||
        oldDelegate.isDark != isDark;
  }
}
