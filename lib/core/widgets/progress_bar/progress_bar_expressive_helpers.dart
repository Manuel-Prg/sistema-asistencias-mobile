import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Utilidades compartidas de dibujo para los estilos expresivos de barra de
/// progreso (riel inactivo delgado y marcador vertical estilizado con halo).
class ExpressiveProgressPainterHelper {
  ExpressiveProgressPainterHelper._();

  /// Dibuja la línea de riel inactivo a la derecha del progreso actual.
  static void drawInactiveTrack({
    required Canvas canvas,
    required double startX,
    required double endX,
    required double centerY,
    required double strokeWidth,
    required bool isDark,
  }) {
    if (startX >= endX) return;
    final trackPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.14)
          : const Color(0xFF9EA7B3).withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(startX, centerY), Offset(endX, centerY), trackPaint);
  }

  /// Dibuja el marcador vertical estilizado (píldora vertical con halo suave)
  /// en el punto exacto de avance.
  static void drawLeadingCap({
    required Canvas canvas,
    required double x,
    required double centerY,
    required double totalHeight,
    required Color barColor,
    required bool isDark,
    double haloIntensity = 1.0,
    Color? capColorOverride,
  }) {
    final capHeight = totalHeight * 0.86;
    const capWidth = 4.2;
    final capRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(x, centerY),
        width: capWidth,
        height: capHeight,
      ),
      const Radius.circular(2.1),
    );

    canvas.drawRRect(
      capRect.inflate(1.5 * haloIntensity),
      Paint()
        ..color = barColor.withValues(
          alpha: ((isDark ? 0.40 : 0.25) * haloIntensity).clamp(0.0, 0.85),
        )
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          (3.0 * haloIntensity).clamp(1.5, 8.0),
        ),
    );

    canvas.drawRRect(
      capRect,
      Paint()
        ..color =
            capColorOverride ??
            Color.lerp(barColor, Colors.white, isDark ? 0.35 : 0.15)!,
    );
  }

  /// Envolvente suave (smoothstep) para que las deformaciones nazcan y cierren
  /// limpiamente alineadas al centro en los extremos.
  static double edgeSmoothstep(double distFromEdge, double rampWidth) {
    final t = (distFromEdge / rampWidth).clamp(0.0, 1.0);
    return t * t * (3.0 - 2.0 * t);
  }

  /// Altura efectiva recomendada para dar espacio vertical a la deformación.
  static double effectiveHeight(double requestedHeight) {
    return math.max(requestedHeight + 4.0, 16.0);
  }
}
