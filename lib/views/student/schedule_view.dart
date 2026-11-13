import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_toast.dart';
import '../../models/student_schedule.dart';
import '../../providers/schedule_provider.dart';
import 'schedule/academic_calendar_banner_card.dart';
import 'schedule/day_schedule_form.dart';
import 'schedule/schedule_day_card.dart';
import 'schedule/schedule_header.dart';
import 'schedule/schedule_presets_bar.dart';
import 'schedule/schedule_save_button.dart';
import 'schedule/schedule_stats_card.dart';

class ScheduleView extends ConsumerStatefulWidget {
  const ScheduleView({super.key});

  @override
  ConsumerState<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends ConsumerState<ScheduleView> {
  final Map<int, DayScheduleForm> _daysForm = {
    1: DayScheduleForm(
      dayOfWeek: 1,
      startTime: '11:00',
      endTime: '14:00',
      isActive: false,
    ),
    2: DayScheduleForm(
      dayOfWeek: 2,
      startTime: '11:00',
      endTime: '14:00',
      isActive: false,
    ),
    3: DayScheduleForm(
      dayOfWeek: 3,
      startTime: '11:00',
      endTime: '14:00',
      isActive: false,
    ),
    4: DayScheduleForm(
      dayOfWeek: 4,
      startTime: '11:00',
      endTime: '14:00',
      isActive: false,
    ),
    5: DayScheduleForm(
      dayOfWeek: 5,
      startTime: '11:00',
      endTime: '14:00',
      isActive: false,
    ),
    6: DayScheduleForm(
      dayOfWeek: 6,
      startTime: '11:00',
      endTime: '14:00',
      isActive: false,
    ),
  };

  bool _initialized = false;

  void _syncFromSchedules(List<StudentSchedule> schedules) {
    if (_initialized) return;
    for (final sch in schedules) {
      if (_daysForm.containsKey(sch.dayOfWeek)) {
        _daysForm[sch.dayOfWeek] = DayScheduleForm(
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

  void _applyPresetToAll(String start, String end) {
    setState(() {
      for (final form in _daysForm.values) {
        if (form.isActive) {
          form.startTime = start;
          form.endTime = end;
        }
      }
    });
    AppGlassToast.show(
      context,
      message: 'Horario ($start - $end) aplicado a días activos.',
      type: GlassToastType.info,
    );
  }

  Future<void> _saveAll() async {
    final notifier = ref.read(scheduleProvider.notifier);
    final ok = await notifier.saveAllSchedules(_daysForm.values.toList());

    if (!mounted) return;

    if (ok) {
      AppGlassToast.show(
        context,
        title: 'Horario Guardado',
        message: '¡Tu horario semanal se actualizó con éxito!',
        type: GlassToastType.success,
      );
    } else {
      final error =
          ref.read(scheduleProvider).errorMessage ??
          'No fue posible guardar el horario. Revisa tu conexión a internet.';
      AppGlassToast.show(
        context,
        title: 'Error al Guardar',
        message: error,
        type: GlassToastType.error,
      );
    }
  }

  double _calculateTotalWeeklyHours() {
    double total = 0.0;
    for (final f in _daysForm.values) {
      if (f.isActive) {
        final startP = f.startTime.split(':');
        final endP = f.endTime.split(':');
        final startM =
            (int.tryParse(startP[0]) ?? 0) * 60 +
            (startP.length > 1 ? (int.tryParse(startP[1]) ?? 0) : 0);
        final endM =
            (int.tryParse(endP[0]) ?? 0) * 60 +
            (endP.length > 1 ? (int.tryParse(endP[1]) ?? 0) : 0);
        final diff = endM - startM;
        if (diff > 0) total += diff / 60.0;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleProvider);
    Theme.of(context).brightness == Brightness.dark;

    if (scheduleState.schedules.isNotEmpty && !_initialized) {
      _syncFromSchedules(scheduleState.schedules);
    }

    final activeCount = _daysForm.values.where((d) => d.isActive).length;
    final weeklyHours = _calculateTotalWeeklyHours();

    return GlassScaffold(
      appBar: const GlassAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 130),
        children: [
          const ScheduleHeader(),

          // Banner: Calendario Escolar Oficial
          const AcademicCalendarBannerCard(),
          const SizedBox(height: 14),

          // Tarjeta 1: Estadísticas y regla de retardo
          ScheduleStatsCard(
            activeDaysCount: activeCount,
            weeklyHours: weeklyHours,
          ),
          const SizedBox(height: 14),

          // Tarjeta 2: Atajos rápidos
          SchedulePresetsBar(onApplyPreset: _applyPresetToAll),
          const SizedBox(height: 14),

          // Lista de días de la semana
          ...AppConstants.scheduleDaysMap.entries.map((entry) {
            final dayIndex = entry.key;
            final dayName = entry.value;
            final form = _daysForm[dayIndex]!;

            return ScheduleDayCard(
              dayName: dayName,
              isActive: form.isActive,
              startTime: form.startTime,
              endTime: form.endTime,
              onToggleActive: (val) => setState(() => form.isActive = val),
              onPickStartTime: () => _pickTime(dayIndex, true),
              onPickEndTime: () => _pickTime(dayIndex, false),
            );
          }),
          const SizedBox(height: 14),

          ScheduleSaveButton(
            isLoading: scheduleState.isSaving,
            onSave: _saveAll,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
