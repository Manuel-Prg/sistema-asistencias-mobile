import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'progress_bar_expressive_helpers.dart';

/// Barra de progreso estilo Segmentos Expresivos: micro-cápsulas cuya altura
/// ondula suavemente como un ecualizador fluido, con marcador vertical en el
/// punto de avance y segmentos inactivos estilizados.
class SegmentedProgressBar extends StatefulWidget {
  final double ratio;
  final Color barColor;
  final double height;
  final bool isDark;
  final int totalSegments;

  const SegmentedProgressBar({
    super.key,
    required this.ratio,
    required this.barColor,
    required this.height,
    required this.isDark,
    this.totalSegments = 18,
  });

  @override
  State<SegmentedProgressBar> createState() => _SegmentedProgressBarState();
}

class _SegmentedProgressBarState extends State<SegmentedProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
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
        width: double.infinity,
        height: effectiveHeight,
        child: CustomPaint(
          painter: _ExpressiveSegmentedPainter(
            animation: _controller,
            ratio: widget.ratio.clamp(0.0, 1.0),
            barColor: widget.barColor,
            isDark: widget.isDark,
            totalSegments: widget.totalSegments,
          ),
        ),
      ),
    );
  }
}

class _ExpressiveSegmentedPainter extends CustomPainter {
  final Animation<double> animation;
  final double ratio;
  final Color barColor;
  final bool isDark;
  final int totalSegments;

  _ExpressiveSegmentedPainter({
    required this.animation,
    required this.ratio,
    required this.barColor,
    required this.isDark,
    required this.totalSegments,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final h = size.height;
    if (width <= 0 || h <= 0) return;

    final centerY = h / 2;
    const gap = 3.2;
    final segWidth = (width - gap * (totalSegments - 1)) / totalSegments;
    if (segWidth <= 1.0) return;

    final filledCount = (ratio * totalSegments).round().clamp(0, totalSegments);
    final t = animation.value;
    final phase = t * 2 * math.pi;

    final deepColor =
        Color.lerp(barColor, const Color(0xFF0A2E3D), 0.28) ?? barColor;
    final brightColor = Color.lerp(barColor, Colors.white, 0.34) ?? barColor;
    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : const Color(0xFF9EA7B3).withValues(alpha: 0.32);

    double lastFilledRightX = 0.0;

    for (var i = 0; i < totalSegments; i++) {
      final left = i * (segWidth + gap);
      final isFilled = i < filledCount;
      final isFrontier = i == filledCount - 1 && filledCount > 0;

      if (isFilled) {
        // Onda suave de altura (efecto ecualizador líquido)
        final wave = 0.5 + 0.5 * math.sin((i * 0.65) - phase);
        final segHeight = isFrontier
            ? h * 0.86
            : (h * 0.38) + (h * 0.36 * wave);

        final rect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(left + segWidth / 2, centerY),
            width: segWidth,
            height: segHeight,
          ),
          Radius.circular(segWidth / 2),
        );

        final colorPos = filledCount > 1 ? i / (filledCount - 1) : 1.0;
        final segColor = isFrontier
            ? brightColor
            : Color.lerp(deepColor, barColor, colorPos)!;

        if (isFrontier) {
          canvas.drawRRect(
            rect.inflate(1.5),
            Paint()
              ..color = barColor.withValues(alpha: isDark ? 0.45 : 0.28)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5),
          );
        }

        canvas.drawRRect(rect, Paint()..color = segColor);

        // Pequeño reflejo superior
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              left + segWidth * 0.2,
              centerY - segHeight / 2 + 1.0,
              segWidth * 0.6,
              math.max(1.2, segHeight * 0.24),
            ),
            Radius.circular(segWidth / 3),
          ),
          Paint()..color = Colors.white.withValues(alpha: isDark ? 0.35 : 0.48),
        );

        lastFilledRightX = left + segWidth;
      } else {
        // Segmentos inactivos delgados y discretos alineados al centro
        final inactiveHeight = (h * 0.26).clamp(3.2, 4.6);
        final rect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(left + segWidth / 2, centerY),
            width: segWidth,
            height: inactiveHeight,
          ),
          Radius.circular(inactiveHeight / 2),
        );
        canvas.drawRRect(rect, Paint()..color = inactiveColor);
      }
    }

    // Marcador vertical sutil si no está al 0% ni 100%
    if (filledCount > 0 && filledCount < totalSegments) {
      ExpressiveProgressPainterHelper.drawLeadingCap(
        canvas: canvas,
        x: (lastFilledRightX + gap / 2).clamp(2.5, width - 2.5),
        centerY: centerY,
        totalHeight: h,
        barColor: barColor,
        isDark: isDark,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ExpressiveSegmentedPainter oldDelegate) {
    return oldDelegate.ratio != ratio ||
        oldDelegate.barColor != barColor ||
        oldDelegate.isDark != isDark ||
        oldDelegate.totalSegments != totalSegments;
  }
}
