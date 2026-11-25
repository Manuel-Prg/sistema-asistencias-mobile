import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/mexican_business_days.dart';
import '../../core/utils/skippy_quotes.dart';
import '../../models/student_schedule.dart';

class ScheduledToleranceItem {
  final int id;
  final String title;
  final String body;
  final tz.TZDateTime scheduledDate;
  final String payload;

  const ScheduledToleranceItem({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.payload,
  });
}

class AttendanceToleranceScheduler {
  AttendanceToleranceScheduler._();

  static const String channelId = 'attendance_tolerance_channel';
  static const String channelName = 'Tolerancia de Asistencia (15 min)';
  static const String channelDesc =
      'Alertas de Nuty cuando transcurren 15 minutos de tolerancia sin registrar tu entrada según tu horario.';

  static const int _minId = 30000;
  static const int _maxId = 39999;

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

  /// Calcula la lista exacta de alertas de tolerancia (hora de inicio + 15 min)
  /// a programar en la zona horaria oficial (`tz.local`), ignorando:
  /// - Días desactivados (`isActive == false`)
  /// - Días fuera del esquema válido (`AppConstants.scheduleDaysMap`, Martes-Domingo)
  /// - Días festivos oficiales mexicanos / Tabasco
  /// - Hoy mismo si el alumno ya registró entrada (`skipToday == true`)
  /// - Horarios con `startTime` inválido o corrupto
  static List<ScheduledToleranceItem> computeUpcomingReminders({
    required List<StudentSchedule> schedules,
    required tz.TZDateTime now,
    bool skipToday = false,
    int daysAhead = 14,
  }) {
    if (schedules.isEmpty) return const [];

    final activeSchedules = schedules
        .where(
          (s) => s.isActive && AppConstants.scheduleDaysMap.containsKey(s.dayOfWeek),
        )
        .toList();
    if (activeSchedules.isEmpty) return const [];

    final items = <ScheduledToleranceItem>[];
    final todayMidnight = tz.TZDateTime(now.location, now.year, now.month, now.day);

    for (var dayOffset = 0; dayOffset < daysAhead; dayOffset++) {
      if (skipToday && dayOffset == 0) continue;

      final targetDate = todayMidnight.add(Duration(days: dayOffset));

      // No programar alertas de retardo en días festivos oficiales
      if (MexicanBusinessDays.isMexicanHoliday(targetDate)) continue;

      final scheduleDay = AppDateUtils.dartWeekdayToScheduleDay(
        targetDate.weekday,
      );

      final daySchedules = activeSchedules
          .where((s) => s.dayOfWeek == scheduleDay)
          .toList();

      if (daySchedules.isEmpty) continue;

      final targetSch = daySchedules.first;
      final parsed = _parseStartTime(targetSch.startTime);
      if (parsed == null) continue;

      final (startHour, startMin) = parsed;

      final startDateTime = tz.TZDateTime(
        now.location,
        targetDate.year,
        targetDate.month,
        targetDate.day,
        startHour,
        startMin,
      );
      final scheduledDateTime = startDateTime.add(
        const Duration(minutes: AppConstants.lateToleranceMinutes),
      );

      if (scheduledDateTime.isAfter(now)) {
        final id = _idForDate(targetDate);
        final startTimeFormatted =
            '${startHour.toString().padLeft(2, '0')}:${startMin.toString().padLeft(2, '0')}';
        final title = SkippyQuotes.getEntryToleranceTitle(dayOffset);
        final body = SkippyQuotes.getEntryToleranceBody(
          scheduledStart: startTimeFormatted,
          variant: dayOffset,
        );

        items.add(
          ScheduledToleranceItem(
            id: id,
            title: title,
            body: body,
            scheduledDate: scheduledDateTime,
            payload:
                'entry_tolerance_${targetDate.year}_${targetDate.month}_${targetDate.day}',
          ),
        );
      }
    }

    return items;
  }

  /// Parsea estrictamente un string "HH:mm" o "HH:mm:ss".
  /// Retorna `null` si el formato es inválido en lugar de inventar una hora por defecto.
  static (int, int)? _parseStartTime(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final parts = trimmed.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return (hour, minute);
  }

  static int _idForDate(DateTime date) {
    return _minId + (date.month * 100) + date.day;
  }

  /// Reemplaza todas las alertas de tolerancia de entrada (hora de inicio + 15 min)
  /// para los próximos 14 días basándose en el horario actual del estudiante.
  /// Siempre cancela primero las alertas previas para evitar notificaciones fantasma
  /// cuando el usuario modifica o desactiva días de su horario.
  static Future<void> scheduleToleranceReminders({
    required FlutterLocalNotificationsPlugin plugin,
    required List<StudentSchedule> schedules,
    bool skipToday = false,
  }) async {
    // 1. Limpiar SIEMPRE cualquier alerta de tolerancia previa (evita alarmas huérfanas)
    await cancelAllEntryReminders(plugin);

    final now = tz.TZDateTime.now(tz.local);
    final items = computeUpcomingReminders(
      schedules: schedules,
      now: now,
      skipToday: skipToday,
    );

    if (items.isEmpty) return;

    for (final item in items) {
      await _scheduleSingleToleranceNotification(
        plugin: plugin,
        id: item.id,
        title: item.title,
        body: item.body,
        tzDateTime: item.scheduledDate,
        payload: item.payload,
      );
    }
  }

  static Future<void> _scheduleSingleToleranceNotification({
    required FlutterLocalNotificationsPlugin plugin,
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime tzDateTime,
    required String payload,
  }) async {
    try {
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
    final now = tz.TZDateTime.now(tz.local);
    final todayId = _idForDate(now);
    await plugin.cancel(id: todayId);
    debugPrint(
      'Alerta de tolerancia ($todayId) cancelada porque se registró check-in.',
    );
  }

  /// Cancela TODAS las alertas de tolerancia pendientes en el sistema operativo
  static Future<void> cancelAllEntryReminders(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    try {
      final pending = await plugin.pendingNotificationRequests();
      for (final req in pending) {
        final isToleranceId = req.id >= _minId && req.id <= _maxId;
        final isTolerancePayload =
            req.payload?.startsWith('entry_tolerance_') ?? false;
        if (isToleranceId || isTolerancePayload) {
          await plugin.cancel(id: req.id);
        }
      }
    } catch (e) {
      debugPrint('Fallback cancelando alertas de tolerancia: $e');
      final now = tz.TZDateTime.now(tz.local);
      for (var i = 0; i < 16; i++) {
        final d = now.add(Duration(days: i));
        await plugin.cancel(id: _idForDate(d));
      }
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
