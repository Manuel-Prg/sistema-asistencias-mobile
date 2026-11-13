import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/student_schedule.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

class ScheduleState {
  final bool isLoading;
  final bool isSaving;
  final List<StudentSchedule> schedules;
  final String? errorMessage;
  final String? successMessage;

  ScheduleState({
    this.isLoading = false,
    this.isSaving = false,
    this.schedules = const [],
    this.errorMessage,
    this.successMessage,
  });

  ScheduleState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<StudentSchedule>? schedules,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return ScheduleState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      schedules: schedules ?? this.schedules,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

final scheduleProvider = NotifierProvider<ScheduleNotifier, ScheduleState>(
  ScheduleNotifier.new,
);

class ScheduleNotifier extends Notifier<ScheduleState> {
  String? get _userId => ref.watch(authProvider).user?.id;

  @override
  ScheduleState build() {
    final uid = _userId;
    if (uid != null) {
      Future.microtask(() => loadSchedules());
      return ScheduleState(isLoading: true);
    }
    return ScheduleState(isLoading: false);
  }

  Future<void> loadSchedules() async {
    final uid = _userId;
    if (uid == null) return;
    state = state.copyWith(isLoading: true, clearMessages: true);

    try {
      final list = await SupabaseService.getStudentSchedules(uid);
      state = state.copyWith(isLoading: false, schedules: list);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar horarios: $e',
      );
    }
  }

  Future<bool> saveAllSchedules(List<dynamic> dayForms) async {
    final uid = _userId;
    if (uid == null) {
      state = state.copyWith(errorMessage: 'No se encontró la sesión del usuario.');
      return false;
    }
    state = state.copyWith(isSaving: true, clearMessages: true);

    try {
      final existingMap = {for (var s in state.schedules) s.dayOfWeek: s.id};

      final payload = dayForms.map((f) {
        final start = f.startTime as String;
        final end = f.endTime as String;
        final data = <String, dynamic>{
          'student_id': uid,
          'day_of_week': f.dayOfWeek as int,
          'start_time': start.length == 5 ? '$start:00' : start,
          'end_time': end.length == 5 ? '$end:00' : end,
          'is_active': f.isActive as bool,
        };
        if (existingMap.containsKey(f.dayOfWeek)) {
          data['id'] = existingMap[f.dayOfWeek];
        }
        return data;
      }).toList();

      await SupabaseService.saveAllSchedules(
        userId: uid,
        schedules: payload,
      );

      await loadSchedules();
      state = state.copyWith(
        isSaving: false,
        successMessage: '¡Horario semanal guardado correctamente!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Error al guardar horario: $e',
      );
      return false;
    }
  }

  Future<bool> saveSchedule({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required bool isActive,
  }) async {
    final uid = _userId;
    if (uid == null) return false;
    state = state.copyWith(isSaving: true, clearMessages: true);

    try {
      await SupabaseService.saveSchedule(
        userId: uid,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
        isActive: isActive,
      );

      await loadSchedules();
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Horario actualizado correctamente',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Error al guardar horario: $e',
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearMessages: true);
  }
}
