import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../providers/color_theme_provider.dart';
import '../../services/onboarding_service.dart';
import 'onboarding_permissions_step.dart';
import 'onboarding_personalization_step.dart';
import 'onboarding_style_step.dart';
import 'onboarding_usage_step.dart';
import 'onboarding_welcome_step.dart';

/// Pantalla interactiva de Onboarding y Novedades.
/// Muestra las mejoras de la versión, permite probar Material 3 vs Liquid Glass,
/// personalizar colores/tema/fuente en vivo y repasar el uso de la app.
class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const OnboardingView(),
      ),
    );
  }

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    HapticFeedback.lightImpact();
    await OnboardingService.markAsSeen();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _nextPage() {
    HapticFeedback.selectionClick();
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    HapticFeedback.selectionClick();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = ref.watch(colorThemeProvider);
    final activeAccent = isDark
        ? (palette.isDefault ? AppColors.signalAqua : palette.accent)
        : palette.primary;

    final isLastPage = _currentPage == _totalPages - 1;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          OnboardingService.markAsSeen();
        }
      },
      child: GlassScaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Barra superior con botón Omitir
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_currentPage + 1} / $_totalPages',
                      style: TextStyle(
                        fontFamily: AppTheme.brandFont,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.slateMuted,
                      ),
                    ),
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        isLastPage ? 'Cerrar' : 'Omitir',
                        style: TextStyle(
                          fontFamily: AppTheme.brandFont,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: activeAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Páginas interactivas
              Expanded(
                child: PageView(
                  key: const PageStorageKey<String>('onboarding_page_view'),
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  children: [
                    OnboardingWelcomeStep(
                      activeAccent: activeAccent,
                      isDark: isDark,
                    ),
                    OnboardingStyleStep(
                      activeAccent: activeAccent,
                      isDark: isDark,
                    ),
                    OnboardingPersonalizationStep(
                      activeAccent: activeAccent,
                      isDark: isDark,
                    ),
                    OnboardingPermissionsStep(
                      activeAccent: activeAccent,
                      isDark: isDark,
                    ),
                    OnboardingUsageStep(
                      activeAccent: activeAccent,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              // Indicadores + botones de navegación
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_totalPages, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? activeAccent
                                : (isDark
                                      ? Colors.white24
                                      : AppColors.stoneBorder),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        if (_currentPage > 0) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousPage,
                              child: const Text(
                                'Anterior',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          flex: _currentPage > 0 ? 2 : 1,
                          child: ElevatedButton.icon(
                            onPressed: _nextPage,
                            icon: Icon(
                              isLastPage
                                  ? Icons.check_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 19,
                            ),
                            label: Text(
                              isLastPage ? '¡Comenzar!' : 'Siguiente',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
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
