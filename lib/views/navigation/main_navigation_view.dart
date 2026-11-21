import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/glass_settings_provider.dart';
import '../../services/onboarding_service.dart';
import '../../services/update_service.dart';
import '../common/update_dialog.dart';
import '../onboarding/onboarding_view.dart';
import '../student/dashboard_view.dart';
import '../student/events_view.dart';
import '../student/profile_view.dart';
import '../student/resources_view.dart';
import '../student/schedule_view.dart';
import 'widgets/liquid_glass_dock.dart';
import 'widgets/material3_dock.dart';
import 'widgets/nav_tab_item.dart';

class MainNavigationView extends ConsumerStatefulWidget {
  const MainNavigationView({super.key});

  @override
  ConsumerState<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends ConsumerState<MainNavigationView>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isSplit = false;

  late final AnimationController _splitController;
  late final Animation<double> _splitAnimation;

  static const List<NavTabItem> _tabs = [
    NavTabItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Inicio',
    ),
    NavTabItem(
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month_rounded,
      label: 'Horario',
    ),
    NavTabItem(
      icon: Icons.stars_outlined,
      selectedIcon: Icons.stars_rounded,
      label: 'Eventos',
    ),
    NavTabItem(
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
      label: 'Recursos',
    ),
    NavTabItem(
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
      _runStartupFlows();
    });
  }

  Future<void> _runStartupFlows() async {
    try {
      final shouldShowOnboarding =
          await OnboardingService.shouldShowOnboarding();
      if (shouldShowOnboarding && mounted) {
        await OnboardingView.show(context);
      }
    } catch (e) {
      debugPrint('Error mostrando onboarding: $e');
    }

    if (mounted) {
      await _checkAppUpdates();
    }
  }

  Future<void> _checkAppUpdates() async {
    try {
      final result = await UpdateService.checkForUpdates();
      if (result.hasUpdate && result.updateInfo != null && mounted) {
        UpdateDialog.show(
          context,
          updateInfo: result.updateInfo!,
          currentVersion: result.currentVersion,
          versionsBehind: result.versionsBehind,
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

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;

    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      if (delta > 3 && !_isSplit && notification.metrics.pixels > 20) {
        _splitDock();
      } else if (delta < -3 && _isSplit) {
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

    if (notification.metrics.pixels <= 10 && _isSplit) {
      _unsplitDock();
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isMaterial3 = ref.watch(
      glassSettingsProvider.select((s) => s.isMaterial3),
    );

    final indexedBody = IndexedStack(
      index: _currentIndex,
      children: List.generate(
        _views.length,
        (i) => TickerMode(enabled: _currentIndex == i, child: _views[i]),
      ),
    );

    final dockWidget = isMaterial3
        ? Material3Dock(
            tabs: _tabs,
            currentIndex: _currentIndex,
            splitAnimation: _splitAnimation,
            onTabSelected: _onTabSelected,
            onUnsplit: _unsplitDock,
          )
        : LiquidGlassDock(
            tabs: _tabs,
            currentIndex: _currentIndex,
            splitAnimation: _splitAnimation,
            onTabSelected: _onTabSelected,
            onUnsplit: _unsplitDock,
          );

    return Scaffold(
      extendBody: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: indexedBody,
      ),
      bottomNavigationBar: dockWidget,
    );
  }
}
