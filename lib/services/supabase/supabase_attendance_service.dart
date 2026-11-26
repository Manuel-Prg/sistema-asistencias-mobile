import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/skippy_quotes.dart';
import '../../models/active_student.dart';
import '../../models/attendance_record.dart';
import '../../models/infraction_models.dart';
import '../infraction_service.dart';
import 'supabase_profile_service.dart';
import 'supabase_schedule_service.dart';

class CheckInResult {
  final bool success;
  final bool isLate;
  final int lateMinutes;
  final String? warning;
  final String? error;

  CheckInResult({
    required this.success,
    this.isLate = false,
    this.lateMinutes = 0,
    this.warning,
    this.error,
  });
}

class CheckOutResult {
  final bool success;
  final double hoursWorked;
  final String? error;

  CheckOutResult({required this.success, this.hoursWorked = 0.0, this.error});
}

/// Operaciones de asistencia (check-in, check-out, historial y validaciones) en Supabase.
class SupabaseAttendanceService {
  SupabaseAttendanceService._();

  static SupabaseClient get _client => Supabase.instance.client;

  static Future<AttendanceRecord?> getActiveRecord(String userId) async {
    final response = await _client
        .from('attendance_records')
        .select()
        .eq('student_id', userId)
        .isFilter('check_out', null)
        .order('check_in', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return AttendanceRecord.fromJson(response);
  }

  static Future<List<AttendanceRecord>> getAttendanceHistory(
    String userId, {
    int limit = 15,
  }) async {
    final response = await _client
        .from('attendance_records')
        .select()
        .eq('student_id', userId)
        .order('check_in', ascending: false)
        .limit(limit);

    return (response as List<dynamic>)
        .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<AttendanceRecord>> getAllStudentAttendance(
    String userId,
  ) async {
    final response = await _client
        .from('attendance_records')
        .select()
        .eq('student_id', userId)
        .order('check_in', ascending: false);

    return (response as List<dynamic>)
        .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Realiza Check-In con validación de horas completadas, sesión abierta,
  /// cálculo de retardo contra "Tu Horario" y avisos satíricos de Skippy/Nuty.
  static Future<CheckInResult> checkIn({
    required String room,
    required String shift,
    bool isEvent = false,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return CheckInResult(success: false, error: 'No autenticado');
    }

    // 1. Validar que no haya completado horas
    final student = await SupabaseProfileService.getStudentData(user.id);
    if (student != null && student.isCompleted) {
      return CheckInResult(
        success: false,
        error:
            'Has completado tus horas requeridas. Ya no puedes registrar entradas.',
      );
    }

    // 2. Validar entrada activa existente
    final activeRecord = await getActiveRecord(user.id);
    if (activeRecord != null) {
      final now = DateTime.now().toUtc();
      if (now.difference(activeRecord.checkIn.toUtc()).inHours >= 24) {
        await _client
            .from('attendance_records')
            .update({
              'check_out': activeRecord.checkIn
                  .toUtc()
                  .add(const Duration(hours: 4))
                  .toIso8601String(),
              'hours_worked': 4.0,
              'early_departure_reason': 'Auto-cerrado por sistema (>24h)',
            })
            .eq('id', activeRecord.id);
      } else {
        return CheckInResult(
          success: false,
          error:
              'Ya tienes una entrada activa. Debes registrar salida primero.',
        );
      }
    }

    // 3. Consultar horarios para calcular retardo
    final schedules = await SupabaseScheduleService.getStudentSchedules(
      user.id,
    );
    final now = DateTime.now();
    final lateCheck = isEvent
        ? LateCheckResult(isLate: false, lateMinutes: 0)
        : InfractionService.checkIfCheckInIsLate(now, schedules);

    final finalRoom = isEvent ? '[EVENTO] $room' : room;

    final recordPayload = <String, dynamic>{
      'student_id': user.id,
      'check_in': now.toUtc().toIso8601String(),
      'shift': shift,
      'room': finalRoom,
      'is_late': lateCheck.isLate,
      'is_justified': false,
      'late_minutes': lateCheck.lateMinutes,
    };

    String? warning;
    if (lateCheck.isLate) {
      recordPayload['early_departure_reason'] =
          '[RETARDO] Entrada con retardo de ${lateCheck.lateMinutes} min (horario: ${lateCheck.scheduledStart})';
      warning = await _buildLateWarning(user.id);
    }

    try {
      await _client.from('attendance_records').insert(recordPayload);
      return CheckInResult(
        success: true,
        isLate: lateCheck.isLate,
        lateMinutes: lateCheck.lateMinutes,
        warning: warning,
      );
    } catch (e) {
      return CheckInResult(success: false, error: e.toString());
    }
  }

  /// Realiza Check-Out calculando horas trabajadas, límites (10h o 20h para eventos),
  /// y preservando retardos.
  static Future<CheckOutResult> checkOut({String? earlyDepartureReason}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return CheckOutResult(success: false, error: 'No autenticado');
    }

    final activeRecord = await getActiveRecord(user.id);
    if (activeRecord == null) {
      return CheckOutResult(
        success: false,
        error: 'No hay entrada activa para registrar salida',
      );
    }

    final checkInTime = activeRecord.checkIn.toUtc();
    final checkOutTime = DateTime.now().toUtc();
    final isEvent = activeRecord.isEvent;

    final diffMs = checkOutTime.difference(checkInTime).inMilliseconds;
    double hoursWorkedRaw = (diffMs < 0 ? 0 : diffMs) / (1000 * 60 * 60);
    if (isEvent) hoursWorkedRaw *= 2;

    final limit = isEvent
        ? AppConstants.maxEventHours
        : AppConstants.maxStandardHours;
    final hoursWorked = hoursWorkedRaw > limit ? limit : hoursWorkedRaw;

    final updateData = <String, dynamic>{
      'check_out': checkOutTime.toIso8601String(),
      'hours_worked': double.parse(hoursWorked.toStringAsFixed(2)),
    };

    if (activeRecord.isLate ||
        (activeRecord.earlyDepartureReason != null &&
            activeRecord.earlyDepartureReason!.contains('[RETARDO]'))) {
      updateData['is_late'] = true;
      if (activeRecord.lateMinutes != null) {
        updateData['late_minutes'] = activeRecord.lateMinutes;
      }
    }

    final existingReason = activeRecord.earlyDepartureReason ?? '';
    final retardoRegex = RegExp(r'\[RETARDO\][^|\n]*');
    final retardoMatch = retardoRegex
        .firstMatch(existingReason)
        ?.group(0)
        ?.trim();

    if (hoursWorkedRaw > limit) {
      final limitNote =
          earlyDepartureReason != null && earlyDepartureReason.isNotEmpty
          ? 'Límite ${limit}h excedido (+${(hoursWorkedRaw - limit).toStringAsFixed(1)}h reales). $earlyDepartureReason'
          : 'Auto-limitado a ${limit}h (real: ${hoursWorkedRaw.toStringAsFixed(1)}h)';
      updateData['early_departure_reason'] = retardoMatch != null
          ? '$retardoMatch | $limitNote'
          : limitNote;
    } else if (earlyDepartureReason != null &&
        earlyDepartureReason.isNotEmpty) {
      updateData['early_departure_reason'] = retardoMatch != null
          ? '$retardoMatch | $earlyDepartureReason'
          : earlyDepartureReason;
    }

    try {
      await _client
          .from('attendance_records')
          .update(updateData)
          .eq('id', activeRecord.id);

      return CheckOutResult(
        success: true,
        hoursWorked: double.parse(hoursWorked.toStringAsFixed(2)),
      );
    } catch (e) {
      return CheckOutResult(success: false, error: e.toString());
    }
  }

  static Future<List<ActiveStudent>> getActiveStudents() async {
    // La consulta con profiles!inner causaba error 400 en PostgREST al no existir
    // relación directa de clave foránea entre attendance_records y profiles.
    // Como esta lista no se utiliza en la interfaz móvil del estudiante, se retorna vacía.
    return [];
  }

  static Future<String> _buildLateWarning(String userId) async {
    final priorLatesResponse = await _client
        .from('attendance_records')
        .select('id')
        .eq('student_id', userId)
        .eq('is_late', true)
        .eq('is_justified', false);

    final totalLate = (priorLatesResponse as List).length + 1;
    final totalFaltasFromLate = totalLate ~/ 3;

    if (totalLate % 3 == 0) {
      if (totalFaltasFromLate >= 3) {
        return 'Estás entrando con un retardo mayor a 15 min del horario establecido en "Tu horario".\n\n🚨 ¡ALERTA MÁXIMA DE BAJA! Has acumulado 3 faltas injustificadas:\n\n${SkippyQuotes.getBajaQuote(userId)}';
      }
      final quote = SkippyQuotes.getFaltaWarningQuote(
        totalFaltasFromLate,
        userId,
      );
      return 'Estás entrando con un retardo mayor a 15 min del horario establecido en "Tu horario".\n\n⚠️ ¡Atención! Con este retardo acumulas 3 retardos sin justificar, equivalente a tu Falta #$totalFaltasFromLate.\n\n"$quote"';
    }

    return 'Estás entrando con un retardo mayor a 15 min del horario que estableciste en "Tu horario". Si tienes justificantes, repórtate con tu supervisor.';
  }
}
