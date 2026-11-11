import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_surface.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/student_provider.dart';
import 'dashboard/notification_banner.dart';
import 'dashboard/punctuality_warning_dialog.dart';
import 'widgets/attendance_heatmap_card.dart';
import 'widgets/attendance_history_list.dart';
import 'widgets/check_in_out_card.dart';
import 'widgets/progress_card.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  bool _showNotificationBanner = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(
        studentProvider.select((s) => s.lastWarningMessage),
        (previous, next) {
          if (next != null && next.isNotEmpty) {
            PunctualityWarningDialog.show(context, next);
            ref.read(studentProvider.notifier).clearWarning();
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final studentState = ref.watch(studentProvider);
    final notificationState = ref.watch(notificationProvider);

    final firstName =
        authState.profile?.fullName.split(' ').first ?? 'Estudiante';

    if (studentState.isLoading && !studentState.isRefreshing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Cargando tu información...',
                style: TextStyle(color: AppColors.slateMuted),
              ),
            ],
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).colorScheme.primary;

    return GlassScaffold(
      appBar: const GlassAppBar(),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(studentProvider.notifier).loadData(isRefresh: true),
        color: themePrimary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 130),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, $firstName!',
                      style: TextStyle(
                        fontFamily: AppTheme.brandFont,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : themePrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Casa Universitaria del Agua · Portal Alumnos',
                      style: TextStyle(
                        fontFamily: AppTheme.brandFont,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white70
                            : themePrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (studentState.errorMessage != null)
                GlassSurface(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(12),
                  tintColor: AppColors.terracottaRule.withValues(alpha: 0.18),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.terracottaRule,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          studentState.errorMessage!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.terracottaRule,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () =>
                            ref.read(studentProvider.notifier).clearError(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              if (!notificationState.isEnabled && _showNotificationBanner)
                NotificationBanner(
                  onActivate: () => ref
                      .read(notificationProvider.notifier)
                      .setNotificationsEnabled(true),
                  onClose: () => setState(() => _showNotificationBanner = false),
                ),
              RepaintBoundary(
                child: CheckInOutCard(
                  activeRecord: studentState.activeRecord,
                  isLoading: studentState.isLoading,
                  onCheckIn: (room, shift) {
                    ref
                        .read(studentProvider.notifier)
                        .checkIn(room: room, shift: shift);
                  },
                  onCheckOut: (earlyDepartureReason) {
                    ref.read(studentProvider.notifier).checkOut(
                          earlyDepartureReason: earlyDepartureReason,
                        );
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (studentState.student != null)
                RepaintBoundary(
                  child: ProgressCard(student: studentState.student!),
                ),
              const SizedBox(height: 16),
              if (studentState.infractions != null)
                RepaintBoundary(
                  child: AttendanceHeatmapCard(
                    infractions: studentState.infractions!,
                    heatmapWeeks: studentState.heatmapWeeks,
                  ),
                ),
              const SizedBox(height: 20),
              RepaintBoundary(
                child: AttendanceHistoryList(records: studentState.history),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
