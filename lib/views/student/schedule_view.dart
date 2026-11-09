import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/student_schedule.dart';
import '../../providers/schedule_provider.dart';

class ScheduleView extends ConsumerStatefulWidget {
  const ScheduleView({super.key});

  @override
  ConsumerState<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends ConsumerState<ScheduleView> {
  // Mapa de días editables (1=Martes a 6=Domingo)
  final Map<int, _DayScheduleForm> _daysForm = {
    1: _DayScheduleForm(dayOfWeek: 1, startTime: '11:00', endTime: '14:00', isActive: false),
    2: _DayScheduleForm(dayOfWeek: 2, startTime: '11:00', endTime: '14:00', isActive: false),
    3: _DayScheduleForm(dayOfWeek: 3, startTime: '11:00', endTime: '14:00', isActive: false),
    4: _DayScheduleForm(dayOfWeek: 4, startTime: '11:00', endTime: '14:00', isActive: false),
    5: _DayScheduleForm(dayOfWeek: 5, startTime: '11:00', endTime: '14:00', isActive: false),
    6: _DayScheduleForm(dayOfWeek: 6, startTime: '11:00', endTime: '14:00', isActive: false),
  };

  bool _initialized = false;

  void _syncFromSchedules(List<StudentSchedule> schedules) {
    if (_initialized) return;
    for (final sch in schedules) {
      if (_daysForm.containsKey(sch.dayOfWeek)) {
        _daysForm[sch.dayOfWeek] = _DayScheduleForm(
          dayOfWeek: sch.dayOfWeek,
          startTime: sch.startTime.substring(0, 5),
          endTime: sch.endTime.substring(0, 5),
          isActive: sch.isActive,
        );
      }
    }
    _initialized = true;
  }

  Future<void> _pickTime(int dayOfWeek, bool isStart) async {
    final form = _daysForm[dayOfWeek]!;
    final currentTimeStr = isStart ? form.startTime : form.endTime;
    final parts = currentTimeStr.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 11,
      minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: isStart ? 'HORA DE ENTRADA' : 'HORA DE SALIDA',
    );

    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStart) {
          form.startTime = formatted;
        } else {
          form.endTime = formatted;
        }
      });
    }
  }

  Future<void> _saveAll() async {
    final notifier = ref.read(scheduleProvider.notifier);
    bool allSuccess = true;

    for (final dayForm in _daysForm.values) {
      final ok = await notifier.saveSchedule(
        dayOfWeek: dayForm.dayOfWeek,
        startTime: dayForm.startTime,
        endTime: dayForm.endTime,
        isActive: dayForm.isActive,
      );
      if (!ok) allSuccess = false;
    }

    if (mounted && allSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Horario guardado correctamente!'),
          backgroundColor: AppColors.statusOnTime,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (scheduleState.schedules.isNotEmpty && !_initialized) {
      _syncFromSchedules(scheduleState.schedules);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu Horario Semanal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner explicativo de la regla de retardos
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.accentLimnological,
                    size: 22,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Este horario es la referencia oficial con la que el sistema calcula si tienes un retardo (>15 minutos de tolerancia) al hacer check-in. Activa los días que asistes y define tus horas pactadas.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Lista de días de Martes a Domingo
            ...AppConstants.scheduleDaysMap.entries.map((entry) {
              final dayIndex = entry.key;
              final dayName = entry.value;
              final form = _daysForm[dayIndex]!;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.pondCardDark : AppColors.sillarCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: form.isActive
                        ? (isDark ? AppColors.signalAqua.withOpacity(0.4) : AppColors.primary)
                        : (isDark ? AppColors.darkBorder : AppColors.stoneBorder),
                    width: form.isActive ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: form.isActive
                                    ? AppColors.statusOnTime
                                    : AppColors.slateMuted.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              dayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: form.isActive
                                    ? (isDark ? AppColors.darkTextPrimary : AppColors.mineralInk)
                                    : AppColors.slateMuted,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: form.isActive,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() {
                              form.isActive = val;
                            });
                          },
                        ),
                      ],
                    ),
                    if (form.isActive) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _TimeBox(
                              label: 'Entrada',
                              timeStr: form.startTime,
                              onTap: () => _pickTime(dayIndex, true),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(Icons.arrow_forward_rounded,
                                size: 18, color: AppColors.slateMuted),
                          ),
                          Expanded(
                            child: _TimeBox(
                              label: 'Salida',
                              timeStr: form.endTime,
                              onTap: () => _pickTime(dayIndex, false),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: scheduleState.isSaving ? null : _saveAll,
              child: scheduleState.isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'GUARDAR HORARIOS',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DayScheduleForm {
  final int dayOfWeek;
  String startTime;
  String endTime;
  bool isActive;

  _DayScheduleForm({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });
}

class _TimeBox extends StatelessWidget {
  final String label;
  final String timeStr;
  final VoidCallback onTap;

  const _TimeBox({
    required this.label,
    required this.timeStr,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF142B36) : AppColors.limestoneGround,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.slateMuted),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(Icons.access_time_rounded,
                    size: 16, color: AppColors.accentLimnological),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

