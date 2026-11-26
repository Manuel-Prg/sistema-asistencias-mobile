import 'package:flutter/material.dart';

import 'progress_bar/aurora_progress_bar.dart';
import 'progress_bar/bubbles_progress_bar.dart';
import 'progress_bar/capsule_progress_bar.dart';
import 'progress_bar/glowing_progress_bar.dart';
import 'progress_bar/progress_bar_track.dart';
import 'progress_bar/segmented_progress_bar.dart';
import 'progress_bar/wave_progress_bar.dart';

export 'progress_bar/aurora_progress_bar.dart';
export 'progress_bar/bubbles_progress_bar.dart';
export 'progress_bar/capsule_progress_bar.dart';
export 'progress_bar/glowing_progress_bar.dart';
export 'progress_bar/progress_bar_track.dart';
export 'progress_bar/segmented_progress_bar.dart';
export 'progress_bar/wave_progress_bar.dart';

/// Estilos disponibles para las barras de progreso de horas.
/// NOTA: Mantener el orden de los índices existentes para compatibilidad con SharedPreferences.
enum ProgressBarStyle {
  /// Cápsula cristalina: gradiente volumétrico con reflejo especular superior y gota guía.
  defaultStyle('Cápsula'),

  /// Olas expresivas: trazo sinusoidal fluido con onda de profundidad y marcador estilizado.
  gradient('Olas'),

  /// Bloques discretos de precisión técnica con realce en la celda activa.
  segmented('Segmentos'),

  /// Resplandor de neón líquido con halo exterior difuso (bloom) y faro pulsante.
  glowing('Resplandor'),

  /// Burbujas cristalinas flotando continuamente dentro del líquido acuático.
  bubbles('Burbujas'),

  /// Aurora iridiscente con gradiente cromático dinámico y haz de luz satinada.
  aurora('Aurora');

  final String label;
  const ProgressBarStyle(this.label);
}

/// Widget reutilizable de barra de progreso de horas con soporte para
/// múltiples estilos visuales y riel de cristal embutido.
class StyledProgressBar extends StatelessWidget {
  /// Ratio de progreso entre 0.0 y 1.0.
  final double ratio;

  /// Color principal activo del tema.
  final Color barColor;

  /// Si está en modo oscuro.
  final bool isDark;

  /// Estilo visual seleccionado para la barra.
  final ProgressBarStyle style;

  /// Altura de la barra en píxeles lógicos.
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
            return ProgressBarTrack(
              height: height,
              isDark: isDark,
              child: CapsuleProgressBar(
                ratio: clampedRatio,
                barColor: barColor,
                height: height,
                maxWidth: maxWidth,
              ),
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
            // Para el estilo glowing permitimos que el halo sobresalga suavemente
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ProgressBarTrack(
                    height: height,
                    isDark: isDark,
                    showMilestones: false,
                    child: const SizedBox.shrink(),
                  ),
                  GlowingProgressBar(
                    ratio: clampedRatio,
                    barColor: barColor,
                    height: height,
                    maxWidth: maxWidth,
                    isDark: isDark,
                  ),
                ],
              ),
            );

          case ProgressBarStyle.bubbles:
            return ProgressBarTrack(
              height: height,
              isDark: isDark,
              child: BubblesProgressBar(
                ratio: clampedRatio,
                barColor: barColor,
                height: height,
                maxWidth: maxWidth,
              ),
            );

          case ProgressBarStyle.aurora:
            return ProgressBarTrack(
              height: height,
              isDark: isDark,
              child: AuroraProgressBar(
                ratio: clampedRatio,
                barColor: barColor,
                height: height,
                maxWidth: maxWidth,
              ),
            );
        }
      },
    );
  }
}
