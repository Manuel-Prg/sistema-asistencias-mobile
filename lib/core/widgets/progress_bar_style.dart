import 'package:flutter/material.dart';

import 'progress_bar/aurora_progress_bar.dart';
import 'progress_bar/bubbles_progress_bar.dart';
import 'progress_bar/capsule_progress_bar.dart';
import 'progress_bar/glowing_progress_bar.dart';
import 'progress_bar/segmented_progress_bar.dart';
import 'progress_bar/wave_progress_bar.dart';

export 'progress_bar/aurora_progress_bar.dart';
export 'progress_bar/bubbles_progress_bar.dart';
export 'progress_bar/capsule_progress_bar.dart';
export 'progress_bar/glowing_progress_bar.dart';
export 'progress_bar/progress_bar_expressive_helpers.dart';
export 'progress_bar/progress_bar_track.dart';
export 'progress_bar/segmented_progress_bar.dart';
export 'progress_bar/wave_progress_bar.dart';

/// Estilos disponibles para las barras de progreso de horas.
/// Todos comparten el lenguaje expresivo (deformación orgánica de la píldora,
/// riel inactivo delgado y marcador vertical estilizado).
/// NOTA: Mantener el orden de los índices existentes para compatibilidad con SharedPreferences.
enum ProgressBarStyle {
  /// Cápsula orgánica perfilada con brillo especular y marcador estilizado.
  defaultStyle('Cápsula'),

  /// Olas expresivas: trazo sinusoidal fluido con onda de profundidad.
  gradient('Olas'),

  /// Segmentos expresivos con ondulación tipo ecualizador líquido.
  segmented('Segmentos'),

  /// Resplandor neón con pulso de plasma que deforma el contorno y halo difuso.
  glowing('Resplandor'),

  /// Burbujas orgánicas: cadena líquida de gotas conectadas en movimiento.
  bubbles('Burbujas'),

  /// Aurora boreal: doble cinta sinusoidal entrelazada con gradiente iridiscente.
  aurora('Aurora');

  final String label;
  const ProgressBarStyle(this.label);
}

/// Widget reutilizable de barra de progreso de horas con soporte para
/// múltiples estilos visuales expresivos.
class StyledProgressBar extends StatelessWidget {
  /// Ratio de progreso entre 0.0 y 1.0.
  final double ratio;

  /// Color principal activo del tema.
  final Color barColor;

  /// Si está en modo oscuro.
  final bool isDark;

  /// Estilo visual seleccionado para la barra.
  final ProgressBarStyle style;

  /// Altura base de la barra en píxeles lógicos.
  final double height;

  const StyledProgressBar({
    super.key,
    required this.ratio,
    required this.barColor,
    required this.isDark,
    this.style = ProgressBarStyle.defaultStyle,
    this.height = 12,
  });

  @override
  Widget build(BuildContext context) {
    final clampedRatio = ratio.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        switch (style) {
          case ProgressBarStyle.defaultStyle:
            return CapsuleProgressBar(
              ratio: clampedRatio,
              barColor: barColor,
              height: height,
              maxWidth: maxWidth,
              isDark: isDark,
            );

          case ProgressBarStyle.gradient:
            return WaveProgressBar(
              ratio: clampedRatio,
              barColor: barColor,
              height: height,
              maxWidth: maxWidth,
              isDark: isDark,
            );

          case ProgressBarStyle.segmented:
            return SegmentedProgressBar(
              ratio: clampedRatio,
              barColor: barColor,
              height: height,
              isDark: isDark,
            );

          case ProgressBarStyle.glowing:
            return GlowingProgressBar(
              ratio: clampedRatio,
              barColor: barColor,
              height: height,
              maxWidth: maxWidth,
              isDark: isDark,
            );

          case ProgressBarStyle.bubbles:
            return BubblesProgressBar(
              ratio: clampedRatio,
              barColor: barColor,
              height: height,
              maxWidth: maxWidth,
              isDark: isDark,
            );

          case ProgressBarStyle.aurora:
            return AuroraProgressBar(
              ratio: clampedRatio,
              barColor: barColor,
              height: height,
              maxWidth: maxWidth,
              isDark: isDark,
            );
        }
      },
    );
  }
}
