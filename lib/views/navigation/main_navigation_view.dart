import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_surface.dart';
import '../student/dashboard_view.dart';
import '../student/events_view.dart';
import '../student/profile_view.dart';
import '../student/resources_view.dart';
import '../student/schedule_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  final List<Widget> _views = const [
    DashboardView(),
    ScheduleView(),
    EventsView(),
    ResourcesView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: GlassSurface(
            borderRadius: BorderRadius.circular(28),
            enableRefraction: true,
            child: NavigationBar(
              selectedIndex: _currentIndex,
              backgroundColor: Colors.transparent,
              indicatorColor: isDark
                  ? AppColors.signalAqua.withValues(alpha: 0.25)
                  : AppColors.primary.withValues(alpha: 0.14),
              surfaceTintColor: Colors.transparent,
              height: 64,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded,
                      color: isDark ? AppColors.signalAqua : AppColors.primary),
                  label: 'Inicio',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded,
                      color: isDark ? AppColors.signalAqua : AppColors.primary),
                  label: 'Horario',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.stars_outlined),
                  selectedIcon: Icon(Icons.stars_rounded,
                      color: isDark ? AppColors.signalAqua : AppColors.primary),
                  label: 'Eventos',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded,
                      color: isDark ? AppColors.signalAqua : AppColors.primary),
                  label: 'Recursos',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded,
                      color: isDark ? AppColors.signalAqua : AppColors.primary),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

