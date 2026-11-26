import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/student_schedule.dart';
import 'notifications/attendance_tolerance_scheduler.dart';
import 'notifications/monthly_report_scheduler.dart';

export 'notifications/monthly_report_scheduler.dart' show ScheduledReminderItem;

class ReportNotificationService {
  ReportNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _notificationsPrefKey = 'app_push_notifications_enabled';
  static bool _initialized = false;

  /// Inicializa el motor de notificaciones y la zona horaria de Villahermosa, Tabasco (UTC-6).
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();
      try {
        final mexicoLocation = tz.getLocation('America/Mexico_City');
        tz.setLocalLocation(mexicoLocation);
      } catch (e) {
        debugPrint(
          'Zona horaria America/Mexico_City no disponible, usando UTC: $e',
        );
      }

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

      await MonthlyReportScheduler.createNotificationChannel(_plugin);
      await AttendanceToleranceScheduler.createNotificationChannel(_plugin);

      _initialized = true;
      debugPrint('ReportNotificationService inicializado correctamente');
    } catch (e) {
      debugPrint('Error inicializando ReportNotificationService: $e');
    }
  }

  /// Programa las notificaciones de reporte para el mes actual y el siguiente.
  static Future<void> scheduleMonthlyReportReminders() async {
    await initialize();
    await MonthlyReportScheduler.scheduleMonthlyReportReminders(_plugin);
  }

  /// Dispara una notificación de prueba específica de Nuty en el dispositivo.
  static Future<void> triggerSpecificTestNotification({
    required bool isStartOfMonth,
    required int index,
  }) async {
    await initialize();
    await MonthlyReportScheduler.triggerSpecificTestNotification(
      _plugin,
      isStartOfMonth: isStartOfMonth,
      index: index,
    );
  }

  /// Envía una notificación instantánea de prueba para verificar en el dispositivo.
  static Future<void> sendTestNotification({
    required bool isStartOfMonth,
  }) async {
    await triggerSpecificTestNotification(
      isStartOfMonth: isStartOfMonth,
      index: 1,
    );
  }

  /// Cancela todas las notificaciones de reportes y alertas de asistencia.
  static Future<void> cancelAllReportReminders() async {
    await _plugin.cancelAll();
  }

  /// Programa las alertas de tolerancia de entrada (hora de inicio + 15 min)
  /// para los próximos 14 días basándose en el horario configurado del estudiante.
  static Future<void> scheduleEntryToleranceReminders(
    List<StudentSchedule> schedules, {
    bool skipToday = false,
  }) async {
    await initialize();

    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_notificationsPrefKey) ?? false;
    if (!isEnabled) {
      await AttendanceToleranceScheduler.cancelAllEntryReminders(_plugin);
      return;
    }

    await AttendanceToleranceScheduler.scheduleToleranceReminders(
      plugin: _plugin,
      schedules: schedules,
      skipToday: skipToday,
    );
  }

  /// Cancela la alerta de tolerancia de entrada de hoy (ej. cuando el alumno ya hizo check-in).
  static Future<void> cancelTodayEntryReminder() async {
    await initialize();
    await AttendanceToleranceScheduler.cancelTodayEntryReminder(_plugin);
  }

  /// Cancela todas las alertas de tolerancia programadas.
  static Future<void> cancelAllEntryReminders() async {
    await initialize();
    await AttendanceToleranceScheduler.cancelAllEntryReminders(_plugin);
  }

  /// Dispara una notificación inmediata de prueba de la alerta de tolerancia de 15 min.
  static Future<void> triggerTestToleranceNotification({
    String scheduledStart = '11:00 AM',
  }) async {
    await initialize();
    await AttendanceToleranceScheduler.triggerTestToleranceNotification(
      plugin: _plugin,
      scheduledStart: scheduledStart,
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

  /// Retorna la lista de los próximos recordatorios programados para consulta en la app.
  static List<ScheduledReminderItem> getUpcomingReminders() {
    return MonthlyReportScheduler.getUpcomingReminders();
  }
}
