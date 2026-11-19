import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../providers/color_theme_provider.dart';

/// Pantalla de carga inicial limpia, centrada a pantalla completa y minimalista.
/// Usa el mismo fondo ambiental [GlassScaffold] del resto de la app para una
/// transición sin cortes hacia Login o el Dashboard.
class AppSplashLoadingView extends ConsumerStatefulWidget {
  const AppSplashLoadingView({super.key});

  @override
  ConsumerState<AppSplashLoadingView> createState() =>
      _AppSplashLoadingViewState();
}

class _AppSplashLoadingViewState extends ConsumerState<AppSplashLoadingView>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _loopController;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _logoFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    _textFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.28, 0.90, curve: Curves.easeOut),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.28, 0.90, curve: Curves.easeOutCubic),
      ),
    );

    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _loopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = ref.watch(colorThemeProvider);
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    final accentColor = isDark
        ? (palette.isDefault ? AppColors.signalAqua : palette.accent)
        : palette.primary;

    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.mineralInk;
    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.slateMuted;

    return GlassScaffold(
      body: SizedBox.expand(
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 5),

              // Bloque central: Emblema + Identidad
              RepaintBoundary(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo con aura sutil y entrada fluida
                    FadeTransition(
                      opacity: disableAnimations
                          ? const AlwaysStoppedAnimation(1.0)
                          : _logoFade,
                      child: ScaleTransition(
                        scale: disableAnimations
                            ? const AlwaysStoppedAnimation(1.0)
                            : _logoScale,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Aura ambiental suave detrás del emblema
                            Container(
                              width: 144,
                              height: 144,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    accentColor.withValues(
                                      alpha: isDark ? 0.22 : 0.14,
                                    ),
                                    accentColor.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),

                            // Contenedor tipo app-icon (squircle limpio)
                            Container(
                              width: 96,
                              height: 96,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF141418)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.10)
                                      : accentColor.withValues(alpha: 0.12),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? Colors.black : accentColor)
                                        .withValues(
                                          alpha: isDark ? 0.55 : 0.12,
                                        ),
                                    blurRadius: 28,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/logo/logo_remove_background.png',
                                cacheWidth: 200,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.water_drop_rounded,
                                  size: 46,
                                  color: accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Tipografía oficial de marca
                    FadeTransition(
                      opacity: disableAnimations
                          ? const AlwaysStoppedAnimation(1.0)
                          : _textFade,
                      child: SlideTransition(
                        position: disableAnimations
                            ? const AlwaysStoppedAnimation(Offset.zero)
                            : _textSlide,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppConstants.appName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppTheme.brandFont,
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppConstants.institutionName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppTheme.brandFont,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: accentColor,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 4),

              // Pie minimalista anclado abajo con indicador de 3 puntos animados
              Padding(
                padding: const EdgeInsets.only(bottom: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RepaintBoundary(
                      child: disableAnimations
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: accentColor,
                              ),
                            )
                          : AnimatedBuilder(
                              animation: _loopController,
                              builder: (context, _) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(3, (index) {
                                    final phase =
                                        (_loopController.value - index * 0.18) %
                                        1.0;
                                    final wave = math.sin(
                                      phase.clamp(0.0, 1.0) * math.pi,
                                    );
                                    final scale = 0.72 + (wave * 0.48);
                                    final opacity = 0.30 + (wave * 0.70);

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: Transform.scale(
                                        scale: scale,
                                        child: Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: accentColor.withValues(
                                              alpha: opacity.clamp(0.0, 1.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Portal de Alumnos',
                      style: TextStyle(
                        fontFamily: AppTheme.brandFont,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor.withValues(alpha: 0.75),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
