import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dateFormatEs = DateFormat(
    "EEEE, d 'de' MMMM 'de' y",
    'es_MX',
  );
  static final DateFormat _dateShortFormatEs = DateFormat(
    "d 'de' MMM",
    'es_MX',
  );
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _isoDateFormat = DateFormat('yyyy-MM-dd');

  /// Formatea una fecha completa: "Lunes, 25 de mayo de 2026"
  static String formatFullDate(DateTime dateTime) {
    try {
      final text = _dateFormatEs.format(dateTime.toLocal());
      return text[0].toUpperCase() + text.substring(1);
    } catch (_) {
      return dateTime.toLocal().toString().split(' ')[0];
    }
  }

  /// Formatea una fecha corta: "25 de may"
  static String formatShortDate(DateTime dateTime) {
    try {
      return _dateShortFormatEs.format(dateTime.toLocal());
    } catch (_) {
      return dateTime.toLocal().toString().split(' ')[0];
    }
  }

  /// Formatea una hora en formato de 12 horas con am/pm: "11:30 AM"
  static String formatTime(DateTime dateTime) {
    try {
      return _timeFormat.format(dateTime.toLocal());
    } catch (_) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Formatea en "yyyy-MM-dd"
  static String formatIsoDate(DateTime dateTime) {
    return _isoDateFormat.format(dateTime.toLocal());
  }

  /// Formatea un rango de horas: "11:00 AM - 02:30 PM"
  static String formatTimeRange(DateTime start, DateTime? end) {
    final startStr = formatTime(start);
    if (end == null) {
      return '$startStr - En curso';
    }
    return '$startStr - ${formatTime(end)}';
  }

  /// Convierte día JS / Dart (1=Lun, 2=Mar, 3=Mié, 4=Jue, 5=Vie, 6=Sáb, 7=Dom)
  /// al esquema de la base de datos `student_schedules`:
  /// 0=Lunes, 1=Martes, 2=Miércoles, 3=Jueves, 4=Viernes, 5=Sábado, 6=Domingo
  static int dartWeekdayToScheduleDay(int dartWeekday) {
    // Dart: 1 (Mon) -> 0, 2 (Tue) -> 1, ..., 7 (Sun) -> 6
    return dartWeekday - 1;
  }
}
