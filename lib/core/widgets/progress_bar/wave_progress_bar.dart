import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Barra de progreso estilo Olas (inspirada en Material 3 Expressive Wavy):
/// trazo sinusoidal fluido en bucle infinito perfecto con onda de profundidad,
/// brillo especular y marcador de gota en el extremo de avance.
class WaveProgressBar extends StatefulWidget {
  final double ratio;
  final Color barColor;
  final double height;
  final double maxWidth;
  final bool isDark;

  const WaveProgressBar({
    super.key,
    required this.ratio,
    required this.barColor,
    required this.height,
    required this.maxWidth,
    this.isDark = false,
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
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = math.max(widget.height + 4.0, 16.0);

    return SizedBox(
      width: widget.maxWidth,
      height: effectiveHeight,
      child: CustomPaint(
        painter: _ExpressiveWavePainter(
          animation: _controller,
          ratio: widget.ratio.clamp(0.0, 1.0),
          barColor: widget.barColor,
          isDark: widget.isDark,
        ),
        size: Size(widget.maxWidth, effectiveHeight),
      ),
    );
  }
}

class _ExpressiveWavePainter extends CustomPainter {
  final Animation<double> animation;
  final double ratio;
  final Color barColor;
  final bool isDark;

  _ExpressiveWavePainter({
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
    final strokeWidth = (h * 0.30).clamp(4.0, 6.0);
    final padX = strokeWidth / 2;
    final usableWidth = math.max(0.0, width - strokeWidth);
    final activeEndX = padX + (usableWidth * ratio);

    // ──────────────────────────────────────────────────────────────────────────
    // 1. RIEL INACTIVO (línea limpia y delgada a la derecha del progreso)
    // ──────────────────────────────────────────────────────────────────────────
    final trackStartX = ratio > 0.0 ? math.min(activeEndX + 7.0, width - padX) : padX;
    if (trackStartX < width - padX) {
      final trackPaint = Paint()
        ..color = isDark
            ? Colors.white.withValues(alpha: 0.14)
            : const Color(0xFF9EA7B3).withValues(alpha: 0.32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.85
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(trackStartX, centerY),
        Offset(width - padX, centerY),
        trackPaint,
      );
    }

    if (ratio <= 0.001) return;

    // ──────────────────────────────────────────────────────────────────────────
    // 2. ONDAS SINUSOIDALES FLUIDAS (bucle matemático exacto 2π * t)
    // ──────────────────────────────────────────────────────────────────────────
    final t = animation.value;
    const wavelength = 24.0;
    final k = (2 * math.pi) / wavelength;
    final phase = t * 2 * math.pi;
    final amplitude = (h - strokeWidth - 3.0) / 2;
    final activeLen = activeEndX - padX;

    // Para avances muy pequeños, dibujar una cápsula limpia sin deformación
    if (activeLen < 6.0) {
      canvas.drawCircle(
        Offset(activeEndX, centerY),
        strokeWidth * 0.65,
        Paint()..color = barColor,
      );
      return;
    }

    final backPath = Path();
    final mainPath = Path();
    final highlightPath = Path();

    const step = 2.0;
    for (double x = padX; x <= activeEndX; x += step) {
      final cx = math.min(x, activeEndX);
      // Envolvente suave al inicio y al final para que la ola nazca y termine
      // limpiamente alineada al centro
      final distFromStart = cx - padX;
      final distFromEnd = activeEndX - cx;
      final edgeEnvelope = (math.min(distFromStart, distFromEnd) / 10.0).clamp(
        0.0,
        1.0,
      );
      final smoothEnv = edgeEnvelope * edgeEnvelope * (3 - 2 * edgeEnvelope);
      final localAmp = amplitude * smoothEnv;

      final mainY = centerY + math.sin(k * cx - phase) * localAmp;
      final backY = centerY + math.sin(k * cx - phase + 1.35) * (localAmp * 0.85);

      if (x == padX) {
        mainPath.moveTo(cx, mainY);
        backPath.moveTo(cx, backY);
        highlightPath.moveTo(cx, mainY - strokeWidth * 0.22);
      } else {
        mainPath.lineTo(cx, mainY);
        backPath.lineTo(cx, backY);
        highlightPath.lineTo(cx, mainY - strokeWidth * 0.22);
      }
    }

    // Asegurar cierre exacto en activeEndX
    mainPath.lineTo(activeEndX, centerY);
    backPath.lineTo(activeEndX, centerY);

    final deepColor = Color.lerp(barColor, const Color(0xFF0A2E3D), 0.30) ?? barColor;
    final brightColor = Color.lerp(barColor, Colors.white, 0.35) ?? barColor;

    // 2a. Onda trasera de profundidad (efecto agua en capas)
    final backPaint = Paint()
      ..color = barColor.withValues(alpha: isDark ? 0.32 : 0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.90
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(backPath, backPaint);

    // 2b. Onda principal con gradiente luminoso hacia el extremo activo
    final mainRect = Rect.fromLTWH(padX, 0, math.max(1.0, activeLen), h);
    final mainPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [deepColor, barColor, brightColor],
        stops: const [0.0, 0.68, 1.0],
      ).createShader(mainRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(mainPath, mainPaint);

    // 2c. Cresta especular fina sobre la onda principal
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.42 : 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(highlightPath, highlightPaint);

    // ──────────────────────────────────────────────────────────────────────────
    // 3. MARCADOR VERTICAL DE AVANCE (píldora estilizada estilo M3 Expressive)
    // ──────────────────────────────────────────────────────────────────────────
    final capHeight = h * 0.86;
    final capWidth = 4.2;
    final capRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(activeEndX, centerY),
        width: capWidth,
        height: capHeight,
      ),
      const Radius.circular(2.1),
    );

    // Halo suave detrás del marcador
    canvas.drawRRect(
      capRect.inflate(1.5),
      Paint()
        ..color = barColor.withValues(alpha: isDark ? 0.40 : 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
    );

    canvas.drawRRect(
      capRect,
      Paint()..color = Color.lerp(barColor, Colors.white, isDark ? 0.35 : 0.15)!,
    );
  }

  @override
  bool shouldRepaint(covariant _ExpressiveWavePainter oldDelegate) {
    return oldDelegate.ratio != ratio ||
        oldDelegate.barColor != barColor ||
        oldDelegate.isDark != isDark;
  }
}
