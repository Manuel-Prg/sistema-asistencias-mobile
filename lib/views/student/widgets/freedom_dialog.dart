import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../core/widgets/progress_bar_style.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/color_theme_provider.dart';
import '../../../providers/glass_settings_provider.dart';
import '../../../providers/progress_bar_style_provider.dart';
import '../../../core/utils/skippy_quotes.dart';

/// Diálogo de celebración cuando el alumno completa el 100% de sus horas.
/// Se adapta completamente al estilo visual elegido (Material 3 / Liquid Glass),
/// paleta de colores, modo claro/oscuro, tipografía y estilo de barra del usuario.
class FreedomDialog extends ConsumerStatefulWidget {
  final String studentType;
  final String studentTypeFormatted;
  final String studentId;
  final double accumulatedHours;
  final num requiredHours;

  const FreedomDialog({
    super.key,
    required this.studentType,
    required this.studentTypeFormatted,
    required this.studentId,
    required this.accumulatedHours,
    required this.requiredHours,
  });

  static Future<void> show(
    BuildContext context, {
    required String studentType,
    String? studentTypeFormatted,
    required String studentId,
    required double accumulatedHours,
    num requiredHours = 480,
  }) {
    final formatted = studentTypeFormatted ??
        (studentType.toLowerCase().contains('pract')
            ? 'Prácticas Profesionales'
            : 'Servicio Social');

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => FreedomDialog(
        studentType: studentType,
        studentTypeFormatted: formatted,
        studentId: studentId,
        accumulatedHours: accumulatedHours,
        requiredHours: requiredHours,
      ),
    );
  }

  @override
  ConsumerState<FreedomDialog> createState() => _FreedomDialogState();
}

class _FreedomDialogState extends ConsumerState<FreedomDialog> {
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

  Future<void> _openSurvey() async {
    final url = AppConstants.satisfactionSurveyUrl.trim();
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final palette = ref.watch(colorThemeProvider);
    final isMaterial3 = ref.watch(
      glassSettingsProvider.select((s) => s.isMaterial3),
    );
    final barStyle = ref.watch(progressBarStyleProvider);

    final activeAccent = isDark
        ? (palette.isDefault ? AppColors.signalAqua : palette.accent)
        : palette.primary;
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.mineralInk;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.slateMuted;
    final innerSurface = isMaterial3
        ? scheme.surfaceContainerHigh
        : (isDark
              ? Colors.white.withValues(alpha: 0.06)
              : activeAccent.withValues(alpha: 0.06));
    final innerBorder = isMaterial3
        ? null
        : Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.14)
                : activeAccent.withValues(alpha: 0.22),
          );

    final quote = SkippyQuotes.getCompletedQuote(
      widget.studentType,
      widget.studentId,
    );
    final shortId = widget.studentId.length > 9
        ? widget.studentId.substring(0, 9)
        : widget.studentId;
    final hasSurvey = AppConstants.satisfactionSurveyUrl.trim().isNotEmpty;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 28,
          ),
          child: GlassSurface(
            tintColor: isMaterial3
                ? null
                : (isDark
                      ? const Color(0xFF141418)
                      : Colors.white.withValues(alpha: 0.96)),
            borderRadius: BorderRadius.circular(26),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            enableRefraction: !isMaterial3,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Globo de diálogo con la cita de Nuty
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: innerSurface,
                      borderRadius: BorderRadius.circular(18),
                      border: innerBorder,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.workspace_premium_rounded,
                              size: 16,
                              color: activeAccent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'MENSAJE OFICIAL DE NUTY',
                              style: TextStyle(
                                fontFamily: AppTheme.brandFont,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: activeAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '“$quote”',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTheme.brandFont,
                            fontSize: 13.5,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Triangulito indicador del globo
                  Center(
                    child: CustomPaint(
                      size: const Size(16, 8),
                      painter: _BubblePointerPainter(color: innerSurface),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Nuty celebrando sobre halo del color elegido
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                activeAccent.withValues(
                                  alpha: isDark ? 0.30 : 0.18,
                                ),
                                activeAccent.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/images/nuty/nuty-pose-1.png',
                          height: 120,
                          cacheHeight: 240,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.celebration_rounded,
                            size: 64,
                            color: activeAccent,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tarjeta resumen de Progreso al 100%
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: innerSurface,
                      borderRadius: BorderRadius.circular(18),
                      border: innerBorder,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progreso total',
                              style: TextStyle(
                                fontFamily: AppTheme.brandFont,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: subColor,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: activeAccent.withValues(
                                  alpha: isDark ? 0.24 : 0.14,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '100%',
                                style: TextStyle(
                                  fontFamily: AppTheme.brandFont,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: activeAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        StyledProgressBar(
                          ratio: 1.0,
                          barColor: activeAccent,
                          isDark: isDark,
                          style: barStyle,
                          height: 10,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'HORAS ACUMULADAS',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                      color: subColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${widget.accumulatedHours.toStringAsFixed(1)} / ${widget.requiredHours.toStringAsFixed(0)} h',
                                    style: TextStyle(
                                      fontFamily: AppTheme.brandFont,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: titleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MODALIDAD',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                      color: subColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.studentTypeFormatted,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: AppTheme.brandFont,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: titleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Botón principal (Encuesta si está configurada, o cierre celebratorio)
                  if (hasSurvey) ...[
                    ElevatedButton.icon(
                      onPressed: _openSurvey,
                      icon: const Icon(Icons.assignment_turned_in_rounded,
                          size: 19),
                      label: const Text('Responder encuesta de satisfacción'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Continuar en la app',
                        style: TextStyle(
                          fontFamily: AppTheme.brandFont,
                          fontWeight: FontWeight.w700,
                          color: subColor,
                        ),
                      ),
                    ),
                  ] else
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.celebration_rounded, size: 19),
                      label: const Text('¡Genial, Gracias!'),
                    ),

                  const SizedBox(height: 10),

                  // Pie discreto con ID corto y Cerrar Sesión
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ID: $shortId',
                        style: TextStyle(
                          fontSize: 11,
                          color: subColor.withValues(alpha: 0.75),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ref.read(authProvider.notifier).signOut();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Cerrar Sesión',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.terracottaRule,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: [
            scheme.primary,
            activeAccent,
            AppColors.statusOnTime,
            AppColors.amberTolerance,
            Colors.amber,
          ],
        ),
      ],
    );
  }
}

class _BubblePointerPainter extends CustomPainter {
  final Color color;

  const _BubblePointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BubblePointerPainter oldDelegate) =>
      oldDelegate.color != color;
}
