import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_asistencia_mobile/services/report_notification_service.dart';

void main() {
  group('ReportNotificationService - Programación de Recordatorios', () {
    test('getUpcomingReminders genera exactamente 16 alertas (8 por cada uno de los 2 meses)', () {
      final reminders = ReportNotificationService.getUpcomingReminders();

      // Son 2 meses proyectados (mes en curso y mes siguiente)
      // Cada mes tiene 5 alertas de llenado (días 1 a 5) + 3 alertas de plataforma fin de mes = 8 alertas
      // 8 alertas * 2 meses = 16 alertas
      expect(reminders.length, equals(16));

      final startOfMonthReminders = reminders.where((r) => r.isStartOfMonth).toList();
      final endOfMonthReminders = reminders.where((r) => !r.isStartOfMonth).toList();

      expect(startOfMonthReminders.length, equals(10)); // 5 por cada mes
      expect(endOfMonthReminders.length, equals(6));   // 3 por cada mes

      // Verificar que las horas programadas coinciden con las especificaciones
      for (final r in startOfMonthReminders) {
        expect(r.scheduledDate.hour, equals(9));
        expect(r.scheduledDate.minute, equals(0));
        expect(r.title.contains('Nuty'), isTrue);
      }

      for (final r in endOfMonthReminders) {
        expect(r.scheduledDate.hour, equals(10));
        expect(r.scheduledDate.minute, equals(0));
        expect(r.title.contains('Nuty'), isTrue);
      }
    });
  });
}
