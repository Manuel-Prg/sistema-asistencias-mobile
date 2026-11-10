import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../theme/app_theme.dart';
import 'glass_surface.dart';

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
                                  Color(0xFF07161D),
                                  Color(0xFF0B2633),
                                  Color(0xFF06141B),
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
                            isDark
                                ? AppColors.signalAqua.withValues(alpha: 0.16)
                                : AppColors.signalAqua.withValues(alpha: 0.22),
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
                            isDark
                                ? const Color(0xFF0C4656).withValues(alpha: 0.20)
                                : const Color(0xFFD2EBE7).withValues(alpha: 0.28),
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
                            isDark
                                ? const Color(0xFF0C3847).withValues(alpha: 0.28)
                                : AppColors.accentLimnological
                                    .withValues(alpha: 0.10),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
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

/// AppBar con acabado de vidrio líquido translúcido estilo iOS
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final double height;

  const GlassAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.height = kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? AppColors.darkTextPrimary : AppColors.primary;

    return GlassSurface(
      borderRadius: BorderRadius.zero,
      enableRefraction: true,
      child: AppBar(
        title: title != null
            ? DefaultTextStyle.merge(
                style: TextStyle(
                  fontFamily: AppTheme.brandFont,
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 19,
                  letterSpacing: -0.2,
                ),
                child: title!,
              )
            : null,
        actions: actions,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: Colors.transparent,
        foregroundColor: fg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
