import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../core/utils/date_utils.dart';
import '../core/utils/mexican_business_days.dart';
import '../core/utils/skippy_quotes.dart';
import '../models/student_schedule.dart';

class ScheduledReminderItem {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledDate;
  final bool isStartOfMonth;

  const ScheduledReminderItem({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.isStartOfMonth,
  });
}

class ReportNotificationService {
  ReportNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'report_reminders_channel';
  static const String _channelName = 'Recordatorios de Reportes CUA';
  static const String _channelDesc =
      'Alertas para llenado de reportes en los primeros 5 días hábiles y subida a plataforma a fin de mes.';

  static const String _attendanceChannelId = 'attendance_tolerance_channel';
  static const String _attendanceChannelName = 'Tolerancia de Asistencia (15 min)';
  static const String _attendanceChannelDesc =
      'Alertas de Nuty cuando transcurren 15 minutos de tolerancia sin registrar tu entrada según tu horario.';

  static bool _initialized = false;

  /// Inicializa el motor de notificaciones y la zona horaria de Villahermosa, Tabasco (UTC-6)
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 1. Inicializar bases de datos de zonas horarias
      tz.initializeTimeZones();
      try {
        // Villahermosa, Tabasco se rige bajo la zona horaria Centro de México (UTC-6)
        final mexicoLocation = tz.getLocation('America/Mexico_City');
        tz.setLocalLocation(mexicoLocation);
      } catch (e) {
        debugPrint(
          'Zona horaria America/Mexico_City no disponible, usando UTC: $e',
        );
      }

      // 2. Ajustes de plataforma
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      const initSettings = InitializationSettings(android: androidSettings);

      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint(
            'Notificación de reporte seleccionada: ${response.payload}',
          );
        },
      );

      // 3. Crear los canales de alta importancia en Android 8.0+
      final androidNotificationPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidNotificationPlugin != null) {
        const reportChannel = AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        );

        const attendanceChannel = AndroidNotificationChannel(
          _attendanceChannelId,
          _attendanceChannelName,
          description: _attendanceChannelDesc,
          importance: Importance.max,
          enableVibration: true,
          playSound: true,
        );

        await androidNotificationPlugin.createNotificationChannel(reportChannel);
        await androidNotificationPlugin.createNotificationChannel(attendanceChannel);
      }

      _initialized = true;
      debugPrint('ReportNotificationService inicializado correctamente');
    } catch (e) {
      debugPrint('Error inicializando ReportNotificationService: $e');
    }
  }

  /// Programa las notificaciones de reporte para el mes actual y el siguiente
  /// conforme al calendario oficial de Villahermosa, Tabasco, México:
  /// - Primeros 5 días hábiles a las 09:00 AM (sin fines de semana ni festivos)
  /// - Últimos 3 días hábiles del mes a las 10:00 AM (para subir a plataforma)
  static Future<void> scheduleMonthlyReportReminders() async {
    await initialize();

    final now = DateTime.now();
    final monthsToSchedule = [
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month + 1, 1),
    ];

    for (final monthDate in monthsToSchedule) {
      final y = monthDate.year;
      final m = monthDate.month;

      // 1. PROGRAMAR: Primeros 5 días hábiles de inicio de mes (09:00 AM)
      final first5Days = MexicanBusinessDays.getFirstNBusinessDays(
        y,
        m,
        count: 5,
      );
      for (var i = 0; i < first5Days.length; i++) {
        final bDay = first5Days[i];
        final scheduledDateTime = DateTime(
          bDay.year,
          bDay.month,
          bDay.day,
          9,
          0,
        );

        if (scheduledDateTime.isAfter(now)) {
          final id = 1000 + m * 10 + (i + 1);
          final title = SkippyQuotes.getStartOfMonthTitle(i + 1);
          final body = SkippyQuotes.getStartOfMonthBody(i + 1);

          await _scheduleNotification(
            id: id,
            title: title,
            body: body,
            scheduledDate: scheduledDateTime,
            payload: 'start_of_month_${bDay.month}_$i',
          );
        }
      }

      // 2. PROGRAMAR: Cierre de mes / últimos 3 días hábiles (10:00 AM)
      final last3Days = MexicanBusinessDays.getLastNBusinessDays(
        y,
        m,
        count: 3,
      );
      for (var j = 0; j < last3Days.length; j++) {
        final bDay = last3Days[j];
        final scheduledDateTime = DateTime(
          bDay.year,
          bDay.month,
          bDay.day,
          10,
          0,
        );

        if (scheduledDateTime.isAfter(now)) {
          final id = 2000 + m * 10 + (j + 1);
          final remaining = last3Days.length - j;
          final title = SkippyQuotes.getEndOfMonthTitle(remaining);
          final body = SkippyQuotes.getEndOfMonthBody(remaining);

          await _scheduleNotification(
            id: id,
            title: title,
            body: body,
            scheduledDate: scheduledDateTime,
            payload: 'end_of_month_${bDay.month}_$j',
          );
        }
      }
    }
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
  }) async {
    try {
      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      );

      final details = NotificationDetails(android: androidDetails);

      try {
        await _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tzDateTime,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: payload,
        );
      } catch (_) {
        // En caso de que el sistema operativo no conceda permiso de alarma exacta
        await _plugin.zonedSchedule(
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
      debugPrint('Error programando notificación $id: $e');
    }
  }

  /// Dispara una notificación de prueba específica de Nuty en el dispositivo:
  /// - [isStartOfMonth]: true para inicio de mes (días 1 a 5), false para fin de mes (3, 2, 1 días antes)
  /// - [index]: 1..5 para inicio, o 1..3 para fin de mes (3 = 3 días antes, 1 = último día)
  static Future<void> triggerSpecificTestNotification({
    required bool isStartOfMonth,
    required int index,
  }) async {
    await initialize();

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    final details = NotificationDetails(android: androidDetails);

    final String title;
    final String body;
    final int id;

    if (isStartOfMonth) {
      final safeIndex = index.clamp(1, 5);
      title = SkippyQuotes.getStartOfMonthTitle(safeIndex);
      body = SkippyQuotes.getStartOfMonthBody(safeIndex);
      id = 9910 + safeIndex;
    } else {
      final safeRemaining = index.clamp(1, 3);
      title = SkippyQuotes.getEndOfMonthTitle(safeRemaining);
      body = SkippyQuotes.getEndOfMonthBody(safeRemaining);
      id = 9920 + safeRemaining;
    }

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: 'manual_test_${isStartOfMonth ? 'start' : 'end'}_$index',
    );
  }

  /// Envía una notificación instantánea de prueba para verificar en el dispositivo
  static Future<void> sendTestNotification({
    required bool isStartOfMonth,
  }) async {
    await triggerSpecificTestNotification(
      isStartOfMonth: isStartOfMonth,
      index: 1,
    );
  }

  /// Cancela todas las notificaciones de reportes y alertas de asistencia
  static Future<void> cancelAllReportReminders() async {
    await _plugin.cancelAll();
  }

  /// Programa las alertas de tolerancia de entrada (hora de inicio + 15 min)
  /// para los próximos 14 días basándose en el horario configurado del estudiante.
  static Future<void> scheduleEntryToleranceReminders(
    List<StudentSchedule> schedules,
  ) async {
    await initialize();
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

        await _scheduleToleranceNotification(
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

  static Future<void> _scheduleToleranceNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
  }) async {
    try {
      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

      final androidDetails = AndroidNotificationDetails(
        _attendanceChannelId,
        _attendanceChannelName,
        channelDescription: _attendanceChannelDesc,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      );

      final details = NotificationDetails(android: androidDetails);

      try {
        await _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tzDateTime,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: payload,
        );
      } catch (_) {
        await _plugin.zonedSchedule(
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
  static Future<void> cancelTodayEntryReminder() async {
    final now = DateTime.now();
    final todayId = 30000 + (now.month * 100) + now.day;
    await _plugin.cancel(id: todayId);
    debugPrint('Alerta de tolerancia ($todayId) cancelada porque se registró check-in.');
  }

  /// Cancela todas las alertas de tolerancia programadas
  static Future<void> cancelAllEntryReminders() async {
    final now = DateTime.now();
    for (var i = 0; i < 15; i++) {
      final d = now.add(Duration(days: i));
      final id = 30000 + (d.month * 100) + d.day;
      await _plugin.cancel(id: id);
    }
  }

  /// Dispara una notificación inmediata de prueba de la alerta de tolerancia de 15 min
  static Future<void> triggerTestToleranceNotification({
    String scheduledStart = '11:00 AM',
  }) async {
    await initialize();

    final androidDetails = AndroidNotificationDetails(
      _attendanceChannelId,
      _attendanceChannelName,
      channelDescription: _attendanceChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    final details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: 39999,
      title: SkippyQuotes.getEntryToleranceTitle(0),
      body: SkippyQuotes.getEntryToleranceBody(scheduledStart: scheduledStart),
      notificationDetails: details,
      payload: 'manual_test_entry_tolerance',
    );
  }

  /// Verifica si Android permite programar alarmas exactas (recordatorios puntuales).
  static Future<bool> canScheduleExactAlarms() async {
    try {
      await initialize();
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin == null) return true;
      return await androidPlugin.canScheduleExactNotifications() ?? true;
    } catch (e) {
      debugPrint('Error verificando permiso de alarmas exactas: $e');
      return false;
    }
  }

  /// Solicita el permiso de alarmas exactas en Android 12+ (abre el ajuste del sistema).
  static Future<bool> requestExactAlarmPermission() async {
    try {
      await initialize();
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin == null) return true;
      return await androidPlugin.requestExactAlarmsPermission() ?? false;
    } catch (e) {
      debugPrint('Error solicitando permiso de alarmas exactas: $e');
      return false;
    }
  }

  /// Retorna la lista de los próximos recordatorios programados para consulta en la app
  static List<ScheduledReminderItem> getUpcomingReminders() {
    final now = DateTime.now();
    final items = <ScheduledReminderItem>[];

    final months = [
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month + 1, 1),
    ];

    for (final monthDate in months) {
      final y = monthDate.year;
      final m = monthDate.month;

      // Primeros 5 días hábiles
      final first5 = MexicanBusinessDays.getFirstNBusinessDays(y, m, count: 5);
      for (var i = 0; i < first5.length; i++) {
        final bDay = first5[i];
        final dt = DateTime(bDay.year, bDay.month, bDay.day, 9, 0);
        items.add(
          ScheduledReminderItem(
            id: 1000 + m * 10 + (i + 1),
            title: SkippyQuotes.getStartOfMonthTitle(i + 1),
            body: SkippyQuotes.getStartOfMonthBody(i + 1),
            scheduledDate: dt,
            isStartOfMonth: true,
          ),
        );
      }

      // Últimos 3 días hábiles
      final last3 = MexicanBusinessDays.getLastNBusinessDays(y, m, count: 3);
      for (var j = 0; j < last3.length; j++) {
        final bDay = last3[j];
        final dt = DateTime(bDay.year, bDay.month, bDay.day, 10, 0);
        final remaining = last3.length - j;
        items.add(
          ScheduledReminderItem(
            id: 2000 + m * 10 + (j + 1),
            title: SkippyQuotes.getEndOfMonthTitle(remaining),
            body: SkippyQuotes.getEndOfMonthBody(remaining),
            scheduledDate: dt,
            isStartOfMonth: false,
          ),
        );
      }
    }

    return items;
  }
}
