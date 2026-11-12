import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../core/utils/mexican_business_days.dart';
import '../core/utils/skippy_quotes.dart';

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
        debugPrint('Zona horaria America/Mexico_City no disponible, usando UTC: $e');
      }

      // 2. Ajustes de plataforma
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const initSettings = InitializationSettings(
        android: androidSettings,
      );

      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notificación de reporte seleccionada: ${response.payload}');
        },
      );

      // 3. Crear el canal de alta importancia en Android 8.0+
      final androidNotificationPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidNotificationPlugin != null) {
        const channel = AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        );

        await androidNotificationPlugin.createNotificationChannel(channel);
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
      final first5Days = MexicanBusinessDays.getFirstNBusinessDays(y, m, count: 5);
      for (var i = 0; i < first5Days.length; i++) {
        final bDay = first5Days[i];
        final scheduledDateTime = DateTime(bDay.year, bDay.month, bDay.day, 9, 0);

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
      final last3Days = MexicanBusinessDays.getLastNBusinessDays(y, m, count: 3);
      for (var j = 0; j < last3Days.length; j++) {
        final bDay = last3Days[j];
        final scheduledDateTime = DateTime(bDay.year, bDay.month, bDay.day, 10, 0);

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

  /// Envía una notificación instantánea de prueba para verificar en el dispositivo
  static Future<void> sendTestNotification({required bool isStartOfMonth}) async {
    await initialize();

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    final details = NotificationDetails(android: androidDetails);

    if (isStartOfMonth) {
      await _plugin.show(
        id: 9991,
        title: SkippyQuotes.getStartOfMonthTitle(1),
        body: SkippyQuotes.getStartOfMonthBody(1),
        notificationDetails: details,
        payload: 'test_start_of_month',
      );
    } else {
      await _plugin.show(
        id: 9992,
        title: SkippyQuotes.getEndOfMonthTitle(1),
        body: SkippyQuotes.getEndOfMonthBody(1),
        notificationDetails: details,
        payload: 'test_end_of_month',
      );
    }
  }

  /// Cancela todas las notificaciones de reportes
  static Future<void> cancelAllReportReminders() async {
    await _plugin.cancelAll();
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
