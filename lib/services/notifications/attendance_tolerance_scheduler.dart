import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/utils/date_utils.dart';
import '../../core/utils/skippy_quotes.dart';
import '../../models/student_schedule.dart';

class AttendanceToleranceScheduler {
  AttendanceToleranceScheduler._();

  static const String channelId = 'attendance_tolerance_channel';
  static const String channelName = 'Tolerancia de Asistencia (15 min)';
  static const String channelDesc =
      'Alertas de Nuty cuando transcurren 15 minutos de tolerancia sin registrar tu entrada según tu horario.';

  /// Crea el canal de notificación para las alertas de tolerancia
  static Future<void> createNotificationChannel(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    final androidNotificationPlugin = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidNotificationPlugin != null) {
      const attendanceChannel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDesc,
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
      );

      await androidNotificationPlugin.createNotificationChannel(
        attendanceChannel,
      );
    }
  }

  /// Programa las alertas de tolerancia de entrada (hora de inicio + 15 min)
  /// para los próximos 14 días basándose en el horario configurado del estudiante.
  static Future<void> scheduleToleranceReminders({
    required FlutterLocalNotificationsPlugin plugin,
    required List<StudentSchedule> schedules,
  }) async {
    if (schedules.isEmpty) return;

    final activeSchedules = schedules.where((s) => s.isActive).toList();
    if (activeSchedules.isEmpty) return;

    final now = DateTime.now();

    for (var dayOffset = 0; dayOffset < 14; dayOffset++) {
      final targetDate = now.add(Duration(days: dayOffset));
      final scheduleDay = AppDateUtils.dartWeekdayToScheduleDay(
        targetDate.weekday,
      );

      final daySchedules = activeSchedules
          .where((s) => s.dayOfWeek == scheduleDay)
          .toList();

      if (daySchedules.isEmpty) continue;

      final targetSch = daySchedules.first;
      final parts = targetSch.startTime.split(':');
      final startHour = int.tryParse(parts[0]) ?? 11;
      final startMin = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

      final toleranceTotalMins = startHour * 60 + startMin + 15;
      final tolHour = toleranceTotalMins ~/ 60;
      final tolMin = toleranceTotalMins % 60;

      final scheduledDateTime = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        tolHour,
        tolMin,
      );

      if (scheduledDateTime.isAfter(now)) {
        final id = 30000 + (targetDate.month * 100) + targetDate.day;
        final startTimeFormatted =
            '${startHour.toString().padLeft(2, '0')}:${startMin.toString().padLeft(2, '0')}';
        final title = SkippyQuotes.getEntryToleranceTitle(dayOffset);
        final body = SkippyQuotes.getEntryToleranceBody(
          scheduledStart: startTimeFormatted,
          variant: dayOffset,
        );

        await _scheduleSingleToleranceNotification(
          plugin: plugin,
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDateTime,
          payload:
              'entry_tolerance_${targetDate.year}_${targetDate.month}_${targetDate.day}',
        );
      }
    }
  }

  static Future<void> _scheduleSingleToleranceNotification({
    required FlutterLocalNotificationsPlugin plugin,
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
  }) async {
    try {
      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      );

      final details = NotificationDetails(android: androidDetails);

      try {
        await plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tzDateTime,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: payload,
        );
      } catch (_) {
        await plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tzDateTime,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: payload,
        );
      }
    } catch (e) {
      debugPrint('Error programando alerta de tolerancia $id: $e');
    }
  }

  /// Cancela la alerta de tolerancia de entrada de hoy (ej. cuando el alumno ya hizo check-in)
  static Future<void> cancelTodayEntryReminder(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    final now = DateTime.now();
    final todayId = 30000 + (now.month * 100) + now.day;
    await plugin.cancel(id: todayId);
    debugPrint(
      'Alerta de tolerancia ($todayId) cancelada porque se registró check-in.',
    );
  }

  /// Cancela todas las alertas de tolerancia programadas
  static Future<void> cancelAllEntryReminders(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    final now = DateTime.now();
    for (var i = 0; i < 15; i++) {
      final d = now.add(Duration(days: i));
      final id = 30000 + (d.month * 100) + d.day;
      await plugin.cancel(id: id);
    }
  }

  /// Dispara una notificación inmediata de prueba de la alerta de tolerancia de 15 min
  static Future<void> triggerTestToleranceNotification({
    required FlutterLocalNotificationsPlugin plugin,
    String scheduledStart = '11:00 AM',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    final details = NotificationDetails(android: androidDetails);

    await plugin.show(
      id: 39999,
      title: SkippyQuotes.getEntryToleranceTitle(0),
      body: SkippyQuotes.getEntryToleranceBody(scheduledStart: scheduledStart),
      notificationDetails: details,
      payload: 'manual_test_entry_tolerance',
    );
  }
}
