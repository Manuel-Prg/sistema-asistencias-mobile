import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_surface.dart';
import '../../services/update_service.dart';
import '../common/update_dialog.dart';
import '../student/dashboard_view.dart';
import '../student/events_view.dart';
import '../student/profile_view.dart';
import '../student/resources_view.dart';
import '../student/schedule_view.dart';

class _NavTabItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavTabItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isSplit = false;

  late final AnimationController _splitController;
  late final Animation<double> _splitAnimation;

  static const List<_NavTabItem> _tabs = [
    _NavTabItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Inicio',
    ),
    _NavTabItem(
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month_rounded,
      label: 'Horario',
    ),
    _NavTabItem(
      icon: Icons.stars_outlined,
      selectedIcon: Icons.stars_rounded,
      label: 'Eventos',
    ),
    _NavTabItem(
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
      label: 'Recursos',
    ),
    _NavTabItem(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Perfil',
    ),
  ];

  final List<Widget> _views = const [
    DashboardView(),
    ScheduleView(),
    EventsView(),
    ResourcesView(),
    ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    _splitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _splitAnimation = CurvedAnimation(
      parent: _splitController,
      curve: Curves.easeInOutCubicEmphasized,
      reverseCurve: Curves.easeInOutCubic,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAppUpdates();
    });
  }

  Future<void> _checkAppUpdates() async {
    try {
      final result = await UpdateService.checkForUpdates();
      if (result.hasUpdate && result.updateInfo != null && mounted) {
        UpdateDialog.show(
          context,
          updateInfo: result.updateInfo!,
          currentVersion: result.currentVersion,
        );
      }
    } catch (e) {
      debugPrint('Error en verificación de actualización: $e');
    }
  }

  @override
  void dispose() {
    _splitController.dispose();
    super.dispose();
  }

  void _splitDock() {
    if (!_isSplit && mounted) {
      setState(() => _isSplit = true);
      _splitController.forward();
    }
  }

  void _unsplitDock() {
    if (_isSplit && mounted) {
      setState(() => _isSplit = false);
      _splitController.reverse();
    }
  }

  void _onTabSelected(int index) {
    HapticFeedback.selectionClick();
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
    _unsplitDock();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      extendBody: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // Solo responder a desplazamientos en el eje vertical
          if (notification.metrics.axis != Axis.vertical) return false;

          if (notification is ScrollUpdateNotification) {
            final delta = notification.scrollDelta ?? 0;
            // Deslizar hacia abajo con umbral mínimo: se divide el dock en dos
            if (delta > 3 && !_isSplit && notification.metrics.pixels > 20) {
              _splitDock();
            }
            // Deslizar hacia arriba: vuelve a unirse el dock
            else if (delta < -3 && _isSplit) {
              _unsplitDock();
            }
          } else if (notification is UserScrollNotification) {
            if (notification.direction == ScrollDirection.reverse &&
                !_isSplit &&
                notification.metrics.pixels > 20) {
              _splitDock();
            } else if (notification.direction == ScrollDirection.forward &&
                _isSplit) {
              _unsplitDock();
            }
          }

          // Al llegar hasta arriba del todo, siempre reunir el dock
          if (notification.metrics.pixels <= 10 && _isSplit) {
            _unsplitDock();
          }

          return false;
        },
        child: IndexedStack(index: _currentIndex, children: _views),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SizedBox(
            height: 58,
            child: AnimatedBuilder(
              animation: _splitAnimation,
              builder: (context, child) {
                final t = _splitAnimation.value;

                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Dock Completo (Unificado)
                    if (t < 0.99)
                      Opacity(
                        opacity: (1.0 - t * 1.8).clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: 1.0 - t * 0.10,
                          child: IgnorePointer(
                            ignoring: t > 0.4,
                            child: _buildFullDock(context, activeColor, isDark),
                          ),
                        ),
                      ),

                    // Dock Dividido en dos islas flotantes (Izquierda: Pestaña actual, Derecha: Buscar)
                    if (t > 0.01)
                      Opacity(
                        opacity: ((t - 0.20) * 1.25).clamp(0.0, 1.0),
                        child: IgnorePointer(
                          ignoring: t < 0.6,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Isla Izquierda: Icono de pestaña activa (tocar para expandir)
                              Transform.translate(
                                offset: Offset((1.0 - t) * 44, 0),
                                child: Transform.scale(
                                  scale: 0.65 + t * 0.35,
                                  child: _buildActiveTabPod(
                                    context,
                                    activeColor,
                                    isDark,
                                  ),
                                ),
                              ),

                              // Isla Derecha: Icono de búsqueda rápida
                              Transform.translate(
                                offset: Offset(-(1.0 - t) * 44, 0),
                                child: Transform.scale(
                                  scale: 0.65 + t * 0.35,
                                  child: _buildSearchPod(
                                    context,
                                    activeColor,
                                    isDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullDock(BuildContext context, Color activeColor, bool isDark) {
    return GlassSurface(
      borderRadius: BorderRadius.circular(32),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      enableRefraction: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_tabs.length, (index) {
          final tab = _tabs[index];
          return _GlassNavItem(
            icon: tab.icon,
            selectedIcon: tab.selectedIcon,
            label: tab.label,
            isSelected: _currentIndex == index,
            onTap: () => _onTabSelected(index),
          );
        }),
      ),
    );
  }

  Widget _buildActiveTabPod(
    BuildContext context,
    Color activeColor,
    bool isDark,
  ) {
    final currentTab = _tabs[_currentIndex];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        _unsplitDock();
      },
      child: Tooltip(
        message: currentTab.label,
        child: GlassSurface(
          width: 54,
          height: 54,
          shape: BoxShape.circle,
          padding: EdgeInsets.zero,
          tintColor: isDark ? const Color(0xFF141418) : null,
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: activeColor.withValues(alpha: isDark ? 0.22 : 0.12),
              border: Border.all(
                color: activeColor.withValues(alpha: isDark ? 0.45 : 0.28),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Icon(
                currentTab.selectedIcon,
                size: 24,
                color: activeColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchPod(BuildContext context, Color activeColor, bool isDark) {
    final isRecursos = _currentIndex == 3;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        if (!isRecursos) {
          _onTabSelected(3);
        } else {
          _unsplitDock();
        }
      },
      child: Tooltip(
        message: 'Buscar recursos',
        child: GlassSurface(
          width: 54,
          height: 54,
          shape: BoxShape.circle,
          padding: EdgeInsets.zero,
          tintColor: isDark ? const Color(0xFF141418) : null,
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : activeColor.withValues(alpha: 0.20),
                width: 1.0,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.search_rounded,
                size: 23,
                color: isDark ? Colors.white : AppColors.mineralInk,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassNavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GlassNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = Theme.of(context).colorScheme.primary;
    final inactiveColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.slateMuted;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : activeColor.withValues(alpha: 0.12))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border: isSelected
                ? Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.38)
                        : activeColor.withValues(alpha: 0.30),
                    width: 1.2,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutBack,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isSelected ? selectedIcon : icon,
                    key: ValueKey<bool>(isSelected),
                    size: 22,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: AppTheme.brandFont,
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? activeColor : inactiveColor,
                  letterSpacing: 0.1,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
