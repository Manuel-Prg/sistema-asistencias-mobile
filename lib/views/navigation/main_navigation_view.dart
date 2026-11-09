import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
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
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.pondCardDark : AppColors.sillarCard,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.primary.withOpacity(isDark ? 0.4 : 0.12),
          surfaceTintColor: Colors.transparent,
          height: 68,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
              label: 'Inicio',
            ),
            const NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon:
                  Icon(Icons.calendar_month_rounded, color: AppColors.primary),
              label: 'Horario',
            ),
            const NavigationDestination(
              icon: Icon(Icons.stars_outlined),
              selectedIcon: Icon(Icons.stars_rounded, color: AppColors.primary),
              label: 'Eventos',
            ),
            const NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon:
                  Icon(Icons.menu_book_rounded, color: AppColors.primary),
              label: 'Recursos',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon:
                  Icon(Icons.person_rounded, color: AppColors.primary),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

