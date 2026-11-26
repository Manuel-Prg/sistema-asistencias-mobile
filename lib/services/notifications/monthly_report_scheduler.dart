import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/utils/mexican_business_days.dart';
import '../../core/utils/skippy_quotes.dart';

class ScheduledReminderItem {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledDate;
  final bool isStartOfMonth;
  final String payload;

  const ScheduledReminderItem({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.isStartOfMonth,
    this.payload = '',
  });
}

/// Programador de recordatorios mensuales de reportes CUA conforme al
/// calendario oficial de días hábiles de México:
/// - Primeros 5 días hábiles a las 09:00 AM
/// - Últimos 3 días hábiles a las 10:00 AM
class MonthlyReportScheduler {
  MonthlyReportScheduler._();

  static const String channelId = 'report_reminders_channel';
  static const String channelName = 'Recordatorios de Reportes CUA';
  static const String channelDesc =
      'Alertas para llenado de reportes en los primeros 5 días hábiles y subida a plataforma a fin de mes.';

  static Future<void> createNotificationChannel(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    final androidPlugin = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return;

    const channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDesc,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await androidPlugin.createNotificationChannel(channel);
  }

  /// Genera la lista de recordatorios de inicio y cierre de mes para el mes
  /// actual y el siguiente.
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

      // Primeros 5 días hábiles (09:00 AM)
      final first5 = MexicanBusinessDays.getFirstNBusinessDays(y, m, count: 5);
      for (var i = 0; i < first5.length; i++) {
        final bDay = first5[i];
        items.add(
          ScheduledReminderItem(
            id: 1000 + m * 10 + (i + 1),
            title: SkippyQuotes.getStartOfMonthTitle(i + 1),
            body: SkippyQuotes.getStartOfMonthBody(i + 1),
            scheduledDate: DateTime(bDay.year, bDay.month, bDay.day, 9, 0),
            isStartOfMonth: true,
            payload: 'start_of_month_${bDay.month}_$i',
          ),
        );
      }

      // Últimos 3 días hábiles (10:00 AM)
      final last3 = MexicanBusinessDays.getLastNBusinessDays(y, m, count: 3);
      for (var j = 0; j < last3.length; j++) {
        final bDay = last3[j];
        final remaining = last3.length - j;
        items.add(
          ScheduledReminderItem(
            id: 2000 + m * 10 + (j + 1),
            title: SkippyQuotes.getEndOfMonthTitle(remaining),
            body: SkippyQuotes.getEndOfMonthBody(remaining),
            scheduledDate: DateTime(bDay.year, bDay.month, bDay.day, 10, 0),
            isStartOfMonth: false,
            payload: 'end_of_month_${bDay.month}_$j',
          ),
        );
      }
    }

    return items;
  }

  /// Programa todas las notificaciones futuras de reportes mensuales.
  static Future<void> scheduleMonthlyReportReminders(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    final now = DateTime.now();
    final reminders = getUpcomingReminders();

    for (final item in reminders) {
      if (item.scheduledDate.isAfter(now)) {
        await _scheduleNotification(
          plugin: plugin,
          id: item.id,
          title: item.title,
          body: item.body,
          scheduledDate: item.scheduledDate,
          payload: item.payload,
        );
      }
    }
  }

  /// Dispara una notificación de prueba específica de Nuty en el dispositivo.
  static Future<void> triggerSpecificTestNotification(
    FlutterLocalNotificationsPlugin plugin, {
    required bool isStartOfMonth,
    required int index,
  }) async {
    final details = _buildDetails(importance: Importance.max);

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

    await plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: 'manual_test_${isStartOfMonth ? 'start' : 'end'}_$index',
    );
  }

  static NotificationDetails _buildDetails({
    Importance importance = Importance.high,
  }) {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: importance,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );
    return NotificationDetails(android: androidDetails);
  }

  static Future<void> _scheduleNotification({
    required FlutterLocalNotificationsPlugin plugin,
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
  }) async {
    try {
      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);
      final details = _buildDetails();

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
        // En caso de que el sistema operativo no conceda permiso de alarma exacta
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
      debugPrint('Error programando notificación $id: $e');
    }
  }
}
