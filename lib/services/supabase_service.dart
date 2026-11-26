import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/active_student.dart';
import '../models/attendance_record.dart';
import '../models/profile.dart';
import '../models/student.dart';
import '../models/student_schedule.dart';
import 'supabase/supabase_attendance_service.dart';
import 'supabase/supabase_profile_service.dart';
import 'supabase/supabase_schedule_service.dart';

export 'supabase/supabase_attendance_service.dart'
    show CheckInResult, CheckOutResult;

/// Fachada principal de acceso a Supabase.
/// Mantiene la API pública estable y delega perfil, horarios y asistencia a sus
/// módulos dedicados en `lib/services/supabase/`.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  // ─── Autenticación ──────────────────────────────────────────────────────────

  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: 'cua-asistencia://reset-password',
    );
  }

  static Future<void> verifyRecoveryAndSetPassword({
    required String email,
    required String token,
    required String newPassword,
    bool isDeepLinkRecovery = false,
  }) async {
    final cleanEmail = email.trim();
    final cleanToken = token.trim();

    if (!isDeepLinkRecovery && client.auth.currentSession == null) {
      final response = await client.auth.verifyOTP(
        email: cleanEmail,
        token: cleanToken,
        type: OtpType.recovery,
      );

      if (response.session == null && client.auth.currentSession == null) {
        throw const AuthException(
          'El código de recuperación es incorrecto o ha expirado. Verifica el código e intenta de nuevo.',
        );
      }
    }

    await client.auth.updateUser(UserAttributes(password: newPassword));
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;

  // ─── Perfil y Estudiante ───────────────────────────────────────────────────

  static Future<Profile?> getProfile(String userId) =>
      SupabaseProfileService.getProfile(userId);

  static Future<Student?> getStudentData(String userId) =>
      SupabaseProfileService.getStudentData(userId);

  static Future<void> updateProfile({
    required String userId,
    required String fullName,
    String? realName,
    String? guardianName,
    String? avatarUrl,
    bool updateAvatar = false,
  }) => SupabaseProfileService.updateProfile(
    userId: userId,
    fullName: fullName,
    realName: realName,
    guardianName: guardianName,
    avatarUrl: avatarUrl,
    updateAvatar: updateAvatar,
  );

  static Future<String> uploadProfileAvatar({
    required String userId,
    required Uint8List bytes,
    String? currentAvatarUrl,
  }) => SupabaseProfileService.uploadProfileAvatar(
    userId: userId,
    bytes: bytes,
    currentAvatarUrl: currentAvatarUrl,
  );

  // ─── Horarios del Estudiante ("Tu Horario") ──────────────────────────────────

  static Future<List<StudentSchedule>> getStudentSchedules(String userId) =>
      SupabaseScheduleService.getStudentSchedules(userId);

  static String generateUuid() => SupabaseScheduleService.generateUuid();

  static Future<void> saveSchedule({
    required String userId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required bool isActive,
    String? id,
  }) => SupabaseScheduleService.saveSchedule(
    userId: userId,
    dayOfWeek: dayOfWeek,
    startTime: startTime,
    endTime: endTime,
    isActive: isActive,
    id: id,
  );

  static Future<void> saveAllSchedules({
    required String userId,
    required List<Map<String, dynamic>> schedules,
  }) => SupabaseScheduleService.saveAllSchedules(
    userId: userId,
    schedules: schedules,
  );

  // ─── Asistencia (Check-in & Check-out) ──────────────────────────────────────

  static Future<AttendanceRecord?> getActiveRecord(String userId) =>
      SupabaseAttendanceService.getActiveRecord(userId);

  static Future<List<AttendanceRecord>> getAttendanceHistory(
    String userId, {
    int limit = 15,
  }) => SupabaseAttendanceService.getAttendanceHistory(userId, limit: limit);

  static Future<List<AttendanceRecord>> getAllStudentAttendance(
    String userId,
  ) => SupabaseAttendanceService.getAllStudentAttendance(userId);

  static Future<CheckInResult> checkIn({
    required String room,
    required String shift,
    bool isEvent = false,
  }) => SupabaseAttendanceService.checkIn(
    room: room,
    shift: shift,
    isEvent: isEvent,
  );

  static Future<CheckOutResult> checkOut({String? earlyDepartureReason}) =>
      SupabaseAttendanceService.checkOut(
        earlyDepartureReason: earlyDepartureReason,
      );

  static Future<List<ActiveStudent>> getActiveStudents() =>
      SupabaseAttendanceService.getActiveStudents();
}
