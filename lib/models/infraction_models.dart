import 'attendance_record.dart';

enum RecordStatus {
  onTime,
  retardo,
  falta,
  justified,
}

class LateCheckResult {
  final bool isLate;
  final int lateMinutes;
  final String? scheduledStart;
  final int? scheduleDay;

  LateCheckResult({
    required this.isLate,
    required this.lateMinutes,
    this.scheduledStart,
    this.scheduleDay,
  });
}

class StudentInfractions {
  final int retardosCount;
  final int directFaltasCount;
  final int faltasFromRetardos;
  final int faltasCount;
  final int retardosInCurrentFalta;
  final bool isBajaRisk;
  final String? bajaQuote;
  final String? faltaQuote;
  final List<AttendanceRecord> lateRecords;
  final List<AttendanceRecord> faltaRecords;
  final List<AttendanceRecord> justifiedRecords;

  StudentInfractions({
    required this.retardosCount,
    required this.directFaltasCount,
    required this.faltasFromRetardos,
    required this.faltasCount,
    required this.retardosInCurrentFalta,
    required this.isBajaRisk,
    this.bajaQuote,
    this.faltaQuote,
    required this.lateRecords,
    required this.faltaRecords,
    required this.justifiedRecords,
  });
}

class HeatmapDay {
  final String date; // "yyyy-MM-dd"
  final DateTime dateTime;
  final int dayOfWeek; // 1=Lunes, 7=Domingo
  final String status; // 'on_time' | 'retardo' | 'falta' | 'none'
  final bool isJustified;
  final List<AttendanceRecord> records;

  HeatmapDay({
    required this.date,
    required this.dateTime,
    required this.dayOfWeek,
    required this.status,
    required this.isJustified,
    required this.records,
  });
}

class HeatmapWeek {
  final List<HeatmapDay> days; // 7 días (Lunes a Domingo)

  HeatmapWeek({required this.days});
}

