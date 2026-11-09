import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/active_student.dart';
import '../models/attendance_record.dart';
import '../models/infraction_models.dart';
import '../models/student.dart';
import '../services/infraction_service.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

class StudentDashboardState {
  final bool isLoading;
  final bool isRefreshing;
  final Student? student;
  final AttendanceRecord? activeRecord;
  final List<AttendanceRecord> history;
  final List<AttendanceRecord> allRecords;
  final StudentInfractions? infractions;
  final List<HeatmapWeek> heatmapWeeks;
  final List<ActiveStudent> activeStudents;
  final String? errorMessage;
  final String? lastWarningMessage;

  StudentDashboardState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.student,
    this.activeRecord,
    this.history = const [],
    this.allRecords = const [],
    this.infractions,
    this.heatmapWeeks = const [],
    this.activeStudents = const [],
    this.errorMessage,
    this.lastWarningMessage,
  });

  bool get hasActiveSession => activeRecord != null;

  StudentDashboardState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    Student? student,
    AttendanceRecord? activeRecord,
    bool clearActiveRecord = false,
    List<AttendanceRecord>? history,
    List<AttendanceRecord>? allRecords,
    StudentInfractions? infractions,
    List<HeatmapWeek>? heatmapWeeks,
    List<ActiveStudent>? activeStudents,
    String? errorMessage,
    String? lastWarningMessage,
    bool clearError = false,
    bool clearWarning = false,
  }) {
    return StudentDashboardState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      student: student ?? this.student,
      activeRecord: clearActiveRecord ? null : (activeRecord ?? this.activeRecord),
      history: history ?? this.history,
      allRecords: allRecords ?? this.allRecords,
      infractions: infractions ?? this.infractions,
      heatmapWeeks: heatmapWeeks ?? this.heatmapWeeks,
      activeStudents: activeStudents ?? this.activeStudents,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastWarningMessage:
          clearWarning ? null : (lastWarningMessage ?? this.lastWarningMessage),
    );
  }
}

final studentProvider =
    NotifierProvider<StudentNotifier, StudentDashboardState>(StudentNotifier.new);

class StudentNotifier extends Notifier<StudentDashboardState> {
  String? get _userId => ref.watch(authProvider).user?.id;

  @override
  StudentDashboardState build() {
    final uid = _userId;
    if (uid != null) {
      // Diferir llamada asíncrona para no mutar el estado durante el build
      Future.microtask(() => loadData());
      return StudentDashboardState(isLoading: true);
    }
    return StudentDashboardState(isLoading: false);
  }

  Future<void> loadData({bool isRefresh = false}) async {
    final uid = _userId;
    if (uid == null) return;

    if (isRefresh) {
      state = state.copyWith(isRefreshing: true, clearError: true);
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final studentFuture = SupabaseService.getStudentData(uid);
      final activeRecordFuture = SupabaseService.getActiveRecord(uid);
      final historyFuture = SupabaseService.getAttendanceHistory(uid, limit: 15);
      final allRecordsFuture = SupabaseService.getAllStudentAttendance(uid);
      final activeStudentsFuture = SupabaseService.getActiveStudents();

      final results = await Future.wait([
        studentFuture,
        activeRecordFuture,
        historyFuture,
        allRecordsFuture,
        activeStudentsFuture,
      ]);

      final student = results[0] as Student?;
      final activeRecord = results[1] as AttendanceRecord?;
      final history = results[2] as List<AttendanceRecord>;
      final allRecords = results[3] as List<AttendanceRecord>;
      final activeStudents = results[4] as List<ActiveStudent>;

      final infractions = InfractionService.calculateInfractions(
        allRecords,
        null,
        uid,
      );

      final heatmap = InfractionService.generateHeatmapGrid(
        allRecords,
        weeksCount: 16,
      );

      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        student: student,
        activeRecord: activeRecord,
        clearActiveRecord: activeRecord == null,
        history: history,
        allRecords: allRecords,
        infractions: infractions,
        heatmapWeeks: heatmap,
        activeStudents: activeStudents,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: 'Error al cargar información: $e',
      );
    }
  }

  Future<CheckInResult> checkIn({
    required String room,
    required String shift,
    bool isEvent = false,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearWarning: true);

    final result = await SupabaseService.checkIn(
      room: room,
      shift: shift,
      isEvent: isEvent,
    );

    if (result.success) {
      await loadData();
      if (result.warning != null) {
        state = state.copyWith(lastWarningMessage: result.warning);
      }
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error ?? 'Error desconocido al registrar entrada',
      );
    }

    return result;
  }

  Future<CheckOutResult> checkOut({String? earlyDepartureReason}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await SupabaseService.checkOut(
      earlyDepartureReason: earlyDepartureReason,
    );

    if (result.success) {
      await loadData();
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error ?? 'Error desconocido al registrar salida',
      );
    }

    return result;
  }

  Future<void> refreshActiveStudents() async {
    try {
      final active = await SupabaseService.getActiveStudents();
      state = state.copyWith(activeStudents: active);
    } catch (_) {}
  }

  void clearWarning() {
    state = state.copyWith(clearWarning: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
