import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/student_schedule.dart';

/// Operaciones CRUD de horarios del estudiante ("Tu Horario") en Supabase.
class SupabaseScheduleService {
  SupabaseScheduleService._();

  static SupabaseClient get _client => Supabase.instance.client;

  static Future<List<StudentSchedule>> getStudentSchedules(
    String userId,
  ) async {
    final response = await _client
        .from('student_schedules')
        .select()
        .eq('student_id', userId)
        .order('day_of_week', ascending: true);

    return (response as List<dynamic>)
        .map((e) => StudentSchedule.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String generateUuid() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40; // Version 4 (0100)
    values[8] = (values[8] & 0x3f) | 0x80; // Variant (10xx)
    final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  static Future<void> saveSchedule({
    required String userId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required bool isActive,
    String? id,
  }) async {
    final payload = <String, dynamic>{
      'student_id': userId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'is_active': isActive,
      'id': (id != null && id.trim().isNotEmpty) ? id.trim() : generateUuid(),
    };
    await _client.from('student_schedules').upsert(
      payload,
      onConflict: 'student_id,day_of_week',
    );
  }

  static Future<void> saveAllSchedules({
    required String userId,
    required List<Map<String, dynamic>> schedules,
  }) async {
    final sanitized = schedules.map((item) {
      final map = Map<String, dynamic>.from(item);
      final rawId = map['id']?.toString().trim();
      if (rawId == null || rawId.isEmpty) {
        map['id'] = generateUuid();
      } else {
        map['id'] = rawId;
      }
      return map;
    }).toList();

    try {
      await _client.from('student_schedules').upsert(
        sanitized,
        onConflict: 'student_id,day_of_week',
      );
    } catch (_) {
      // Fallback en caso de que la tabla resuelva conflicto por la clave primaria 'id'
      await _client.from('student_schedules').upsert(sanitized);
    }
  }
}
