import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/color_theme_provider.dart';

/// Pantalla y animación de carga al abrir la aplicación.
/// Diseñada con la identidad estética de la Casa Universitaria del Agua:
/// efectos de agua líquida, ondas concéntricas de refracción (ripples),
/// disco de cristal esmerilado (Liquid Glass) y transición ambiental suave.
class AppSplashLoadingView extends ConsumerStatefulWidget {
  const AppSplashLoadingView({super.key});

  @override
  ConsumerState<AppSplashLoadingView> createState() =>
      _AppSplashLoadingViewState();
}

class _AppSplashLoadingViewState extends ConsumerState<AppSplashLoadingView>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final AnimationController _rippleController;

  late final Animation<double> _entryFade;
  late final Animation<double> _entryScale;
  late final Animation<double> _pulseScale;
  late final Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();

    // 1. Animación de entrada inicial suave
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _entryFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );

    _entryScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutBack),
      ),
    );

    // 2. Respiración armónica continua del logo y halo ambiental
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.98, end: 1.03).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    _glowOpacity = Tween<double>(begin: 0.25, end: 0.60).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    // 3. Ondas concéntricas de agua líquida (Ripples)
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorPalette = ref.watch(colorThemeProvider);
    final primaryColor = colorPalette.primary;
    final accentColor = colorPalette.accent;

    // Colores ambientales adaptados al tema
    final backgroundColor = isDark
        ? AppColors.abyssalGroundDark
        : AppColors.limestoneGround;

    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.mineralInk;

    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.slateMuted;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Fondo con gradiente ambiental sutil
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: isDark
                      ? [
                          primaryColor.withValues(alpha: 0.18),
                          backgroundColor,
                        ]
                      : [
                          accentColor.withValues(alpha: 0.12),
                          backgroundColor,
                        ],
                ),
              ),
            ),
          ),

          // Ondas de agua concéntricas animadas (Ripples)
          AnimatedBuilder(
            animation: _rippleController,
            builder: (context, _) {
              return CustomPaint(
                painter: _WaterRipplesPainter(
                  progress: _rippleController.value,
                  color: primaryColor,
                  isDark: isDark,
                ),
                size: const Size(360, 360),
              );
            },
          ),

          // Contenido central animado (Entrada + Respiración)
          AnimatedBuilder(
            animation: Listenable.merge([_entryController, _pulseController]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _entryFade,
                child: Transform.scale(
                  scale: _entryScale.value * _pulseScale.value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Disco de Liquid Glass con el logo
                _buildLiquidGlassLogo(
                  primaryColor: primaryColor,
                  accentColor: accentColor,
                  isDark: isDark,
                ),

                const SizedBox(height: 32),

                // Títulos institucionales con tipografía de alta jerarquía
                Text(
                  'CASA UNIVERSITARIA DEL AGUA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    letterSpacing: 2.4,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sistema de Control de Asistencia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w500,
                    color: subtitleColor,
                  ),
                ),

                const SizedBox(height: 36),

                // Barra de carga fluida con shimmer acuático
                _buildLoadingPill(
                  primaryColor: primaryColor,
                  accentColor: accentColor,
                  isDark: isDark,
                ),

                const SizedBox(height: 14),

                // Indicador de estado sutil
                Text(
                  'Iniciando sistema...',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.3,
                    fontWeight: FontWeight.w500,
                    color: subtitleColor.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el orbe de cristal líquido con el logo flotante
  Widget _buildLiquidGlassLogo({
    required Color primaryColor,
    required Color accentColor,
    required bool isDark,
  }) {
    return AnimatedBuilder(
      animation: _glowOpacity,
      builder: (context, child) {
        return Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              // Halo de resplandor ambiental interactivo
              BoxShadow(
                color: (isDark ? accentColor : primaryColor).withValues(
                  alpha: _glowOpacity.value * 0.35,
                ),
                blurRadius: 36,
                spreadRadius: 4,
              ),
              // Sombra de profundidad estilo cristal
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(52),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? const Color(0xFF16161A).withValues(alpha: 0.75)
                  : Colors.white.withValues(alpha: 0.85),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : primaryColor.withValues(alpha: 0.20),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.transparent,
                      ]
                    : [
                        Colors.white,
                        Colors.white.withValues(alpha: 0.5),
                      ],
              ),
            ),
            child: Image.asset(
              'assets/logo/logo_remove_background.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.water_drop_rounded,
                size: 46,
                color: primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Barra de carga estética con onda de agua continua
  Widget _buildLoadingPill({
    required Color primaryColor,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      width: 140,
      height: 4,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : primaryColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            final t = _pulseController.value;
            return FractionallySizedBox(
              alignment: Alignment(-1.0 + (t * 2.0), 0),
              widthFactor: 0.45,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withValues(alpha: 0.4),
                      accentColor,
                      primaryColor.withValues(alpha: 0.4),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// CustomPainter para generar ondas concéntricas de agua líquida
class _WaterRipplesPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isDark;

  _WaterRipplesPainter({
    required this.progress,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const int rippleCount = 3;
    const double maxRadius = 145.0;
    const double minRadius = 54.0;

    for (int i = 0; i < rippleCount; i++) {
      final double waveProgress = (progress + (i / rippleCount)) % 1.0;
      final double currentRadius =
          minRadius + (maxRadius - minRadius) * waveProgress;

      // Desvanecimiento suave conforme la onda se expande
      final double opacity = (1.0 - waveProgress) * (isDark ? 0.35 : 0.22);

      final paint = Paint()
        ..color = color.withValues(alpha: math.max(0.0, opacity))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4 * (1.0 - (waveProgress * 0.4));

      canvas.drawCircle(center, currentRadius, paint);
    }
  }

  @override
  bool shouldRepaint(_WaterRipplesPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isDark != isDark;
  }
}
