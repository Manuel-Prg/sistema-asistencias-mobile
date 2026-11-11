import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../theme/app_theme.dart';
import '../../providers/theme_provider.dart';

/// Scaffold con fondo ambiental orgánico estilo iOS Liquid Glass
/// que permite que los componentes de vidrio refracten la luz y el color de fondo.
class GlassScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  const GlassScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.extendBody = true,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          // Fondo ambiental y brillos estáticos aislados en capa de renderizado
          Positioned.fill(
            child: RepaintBoundary(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? const [
                                  Color(0xFF000000),
                                  Color(0xFF000000),
                                ]
                              : const [
                                  Color(0xFFF8F5EE),
                                  Color(0xFFE8F6F4),
                                  Color(0xFFF4F0E8),
                                ],
                        ),
                      ),
                    ),
                  ),
                  if (!isDark) ...[
                    Positioned(
                      top: -60,
                      right: -60,
                      width: 280,
                      height: 280,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.signalAqua.withValues(alpha: 0.22),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 280,
                      right: -90,
                      width: 300,
                      height: 300,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFD2EBE7).withValues(alpha: 0.28),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 120,
                      left: -80,
                      width: 280,
                      height: 280,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.accentLimnological
                                  .withValues(alpha: 0.10),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Contenido principal de la pantalla
          Positioned.fill(child: body),
        ],
      ),
    );
  }
}

/// AppBar con acabado de vidrio líquido translúcido estilo iOS y branding oficial
class GlassAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final double height;
  final bool showBrandHeader;

  const GlassAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.height = kToolbarHeight,
    this.showBrandHeader = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? AppColors.darkTextPrimary : AppColors.primary;

    final Widget effectiveTitle;
    if (title != null) {
      effectiveTitle = DefaultTextStyle.merge(
        style: TextStyle(
          fontFamily: AppTheme.brandFont,
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: -0.2,
        ),
        child: title!,
      );
    } else if (showBrandHeader) {
      effectiveTitle = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/logo/iconoFavicon.webp',
            width: 26,
            height: 26,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.water_drop_rounded,
              color: AppColors.signalAqua,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'Casa Universitaria del Agua',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTheme.brandFont,
                color: fg,
                fontWeight: FontWeight.w700,
                fontSize: 16.5,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      );
    } else {
      effectiveTitle = const SizedBox.shrink();
    }

    final effectiveActions = actions ??
        [
          IconButton(
            tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => RotationTransition(
                turns: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey<bool>(isDark),
                color: isDark ? AppColors.amberTolerance : AppColors.primary,
                size: 21,
              ),
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
          ),
          const SizedBox(width: 4),
        ];

    return RepaintBoundary(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF000000).withValues(alpha: 0.85)
                  : const Color(0xFFF9F6F0).withValues(alpha: 0.88),
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFF0C3C4C).withValues(alpha: 0.07),
                  width: 1,
                ),
              ),
            ),
            child: AppBar(
              title: effectiveTitle,
              actions: effectiveActions,
              leading: leading,
              automaticallyImplyLeading: automaticallyImplyLeading,
              backgroundColor: Colors.transparent,
              foregroundColor: fg,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              centerTitle: false,
            ),
          ),
        ),
      ),
    );
  }
}
