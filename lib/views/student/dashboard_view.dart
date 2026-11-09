import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_surface.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import 'widgets/active_students_sheet.dart';
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
  @override
  void initState() {
    super.initState();
    // Escuchar warnings de tardanzas/Skippy para mostrarlos en un diálogo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(
        studentProvider.select((s) => s.lastWarningMessage),
        (previous, next) {
          if (next != null && next.isNotEmpty) {
            _showWarningDialog(next);
            ref.read(studentProvider.notifier).clearWarning();
          }
        },
      );
    });
  }

  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return GlassDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: AppColors.amberTolerance, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Aviso de Puntualidad',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final studentState = ref.watch(studentProvider);

    final firstName = authState.profile?.fullName.split(' ').first ?? 'Estudiante';

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

    return GlassScaffold(
      appBar: GlassAppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Hola, $firstName!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const Text(
              'Casa Universitaria del Agua',
              style: TextStyle(fontSize: 11, color: AppColors.signalAqua),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt_outlined),
            tooltip: 'Estudiantes activos',
            onPressed: () => ActiveStudentsSheet.show(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(studentProvider.notifier).loadData(isRefresh: true),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner de error si existe
              if (studentState.errorMessage != null) ...[
                GlassSurface(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(12),
                  tintColor: AppColors.terracottaRule.withValues(alpha: 0.18),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.terracottaRule, size: 20),
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
              ],

              // 1. Tarjeta de Entrada y Salida (Foco operativo primario)
              CheckInOutCard(
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
                onOpenActiveStudents: () => ActiveStudentsSheet.show(context),
              ),
              const SizedBox(height: 16),

              // 2. Tarjeta de Progreso de Horas
              if (studentState.student != null)
                ProgressCard(student: studentState.student!),
              const SizedBox(height: 16),

              // 3. Tarjeta de Heatmap y Control de Infracciones
              if (studentState.infractions != null)
                AttendanceHeatmapCard(
                  infractions: studentState.infractions!,
                  heatmapWeeks: studentState.heatmapWeeks,
                ),
              const SizedBox(height: 20),

              // 4. Historial Reciente de Asistencia
              AttendanceHistoryList(records: studentState.history),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
