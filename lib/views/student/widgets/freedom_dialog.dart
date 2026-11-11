import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/skippy_quotes.dart';
import '../../../core/widgets/glass_surface.dart';

class FreedomDialog extends StatefulWidget {
  final String studentType;
  final String studentId;
  final double accumulatedHours;

  const FreedomDialog({
    super.key,
    required this.studentType,
    required this.studentId,
    required this.accumulatedHours,
  });

  static Future<void> show(
    BuildContext context, {
    required String studentType,
    required String studentId,
    required double accumulatedHours,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => FreedomDialog(
        studentType: studentType,
        studentId: studentId,
        accumulatedHours: accumulatedHours,
      ),
    );
  }

  @override
  State<FreedomDialog> createState() => _FreedomDialogState();
}

class _FreedomDialogState extends State<FreedomDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quote = SkippyQuotes.getCompletedQuote(
      widget.studentType,
      widget.studentId,
    );

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 40,
          ),
          child: GlassSurface(
            tintColor: isDark ? const Color(0xFF0C2430) : Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24),
            padding: const EdgeInsets.all(24),
            enableRefraction: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Imagen de Nuty celebrando
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.signalAqua.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/images/nuty/nuty-pose-1.png',
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.celebration_rounded,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '🎉 ¡HORAS COMPLETADAS!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.accumulatedHours.toStringAsFixed(1)} Horas Registradas con Éxito',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentLimnological,
                  ),
                ),
                const SizedBox(height: 16),
                // Tarjeta de cita de Skippy / Nuty
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.stoneBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.smart_toy_rounded,
                            size: 18,
                            color: AppColors.accentLimnological,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'MENSAJE OFICIAL DE NUTY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slateMuted.withValues(
                                alpha: 0.9,
                              ),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '"$quote"',
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppColors.mineralInk,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    iconColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('¡Genial, Gracias!'),
                ),
              ],
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            AppColors.primary,
            AppColors.signalAqua,
            AppColors.accentLimnological,
            AppColors.amberTolerance,
            Colors.amber,
          ],
        ),
      ],
    );
  }
}
