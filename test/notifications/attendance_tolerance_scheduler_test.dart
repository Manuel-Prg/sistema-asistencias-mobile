import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_asistencia_mobile/models/student_schedule.dart';
import 'package:sistema_asistencia_mobile/services/notifications/attendance_tolerance_scheduler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  late tz.Location mexicoCity;

  setUpAll(() {
    tz.initializeTimeZones();
    mexicoCity = tz.getLocation('America/Mexico_City');
    tz.setLocalLocation(mexicoCity);
  });

  StudentSchedule makeSchedule({
    required int dayOfWeek,
    required String startTime,
    bool isActive = true,
  }) {
    return StudentSchedule(
      id: 'sch-$dayOfWeek',
      studentId: 'student-1',
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: '18:00:00',
      isActive: isActive,
    );
  }

  group('AttendanceToleranceScheduler.computeUpcomingReminders', () {
    test('solo programa días activos y respeta hora de inicio + 15 min', () {
      // Martes 10 de noviembre de 2026 a las 08:00 AM (dayOfWeek=1)
      final now = tz.TZDateTime(mexicoCity, 2026, 11, 10, 8, 0);
      final schedules = [
        makeSchedule(dayOfWeek: 1, startTime: '11:00:00', isActive: true), // Martes
        makeSchedule(dayOfWeek: 2, startTime: '14:00:00', isActive: false), // Miércoles inactivo
        makeSchedule(dayOfWeek: 4, startTime: '14:30:00', isActive: true), // Viernes
      ];

      final items = AttendanceToleranceScheduler.computeUpcomingReminders(
        schedules: schedules,
        now: now,
        daysAhead: 7,
      );

      // En 7 días (Mar 10 a Lun 16) solo deben existir Martes 10 (11:15) y Viernes 13 (14:45)
      expect(items.length, 2);

      expect(items[0].scheduledDate.year, 2026);
      expect(items[0].scheduledDate.month, 11);
      expect(items[0].scheduledDate.day, 10);
      expect(items[0].scheduledDate.hour, 11);
      expect(items[0].scheduledDate.minute, 15);

      expect(items[1].scheduledDate.year, 2026);
      expect(items[1].scheduledDate.month, 11);
      expect(items[1].scheduledDate.day, 13);
      expect(items[1].scheduledDate.hour, 14);
      expect(items[1].scheduledDate.minute, 45);
    });

    test('ignora día 0 (Lunes) que no forma parte del horario oficial', () {
      // Lunes 9 de noviembre de 2026 a las 08:00 AM
      final now = tz.TZDateTime(mexicoCity, 2026, 11, 9, 8, 0);
      final schedules = [
        makeSchedule(dayOfWeek: 0, startTime: '11:00:00', isActive: true),
      ];

      final items = AttendanceToleranceScheduler.computeUpcomingReminders(
        schedules: schedules,
        now: now,
        daysAhead: 14,
      );

      expect(items, isEmpty);
    });

    test('ignora horarios con startTime inválido sin inventar 11:15', () {
      final now = tz.TZDateTime(mexicoCity, 2026, 11, 10, 8, 0);
      final schedules = [
        makeSchedule(dayOfWeek: 1, startTime: '', isActive: true),
        makeSchedule(dayOfWeek: 2, startTime: 'invalid', isActive: true),
        makeSchedule(dayOfWeek: 3, startTime: '25:99', isActive: true),
      ];

      final items = AttendanceToleranceScheduler.computeUpcomingReminders(
        schedules: schedules,
        now: now,
        daysAhead: 14,
      );

      expect(items, isEmpty);
    });

    test('omite el día de hoy cuando skipToday es true', () {
      // Martes 10 de noviembre de 2026 a las 08:00 AM
      final now = tz.TZDateTime(mexicoCity, 2026, 11, 10, 8, 0);
      final schedules = [
        makeSchedule(dayOfWeek: 1, startTime: '11:00:00', isActive: true),
      ];

      final items = AttendanceToleranceScheduler.computeUpcomingReminders(
        schedules: schedules,
        now: now,
        skipToday: true,
        daysAhead: 14,
      );

      // Martes 10 omitido -> solo queda Martes 17
      expect(items.length, 1);
      expect(items.first.scheduledDate.day, 17);
      expect(items.first.scheduledDate.hour, 11);
      expect(items.first.scheduledDate.minute, 15);
    });

    test('omite días festivos oficiales de México', () {
      // Martes 15 de septiembre de 2026 -> Miércoles 16 de septiembre es festivo oficial
      final now = tz.TZDateTime(mexicoCity, 2026, 9, 15, 8, 0);
      final schedules = [
        makeSchedule(dayOfWeek: 2, startTime: '11:00:00', isActive: true), // Miércoles
      ];

      final items = AttendanceToleranceScheduler.computeUpcomingReminders(
        schedules: schedules,
        now: now,
        daysAhead: 14,
      );

      // Miércoles 16 de septiembre se omite; solo queda Miércoles 23 de septiembre
      expect(items.length, 1);
      expect(items.first.scheduledDate.month, 9);
      expect(items.first.scheduledDate.day, 23);
    });

    test('retorna vacío si todos los días están desactivados', () {
      final now = tz.TZDateTime(mexicoCity, 2026, 11, 10, 8, 0);
      final schedules = [
        makeSchedule(dayOfWeek: 1, startTime: '11:00:00', isActive: false),
        makeSchedule(dayOfWeek: 3, startTime: '14:00:00', isActive: false),
      ];

      final items = AttendanceToleranceScheduler.computeUpcomingReminders(
        schedules: schedules,
        now: now,
      );

      expect(items, isEmpty);
    });
  });
}
