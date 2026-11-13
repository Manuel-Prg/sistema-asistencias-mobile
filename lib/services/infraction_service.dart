import '../core/utils/date_utils.dart';
import '../core/utils/skippy_quotes.dart';
import '../models/attendance_record.dart';
import '../models/infraction_models.dart';
import '../models/student_schedule.dart';

class InfractionService {
  InfractionService._();

  /// Comprueba si la hora actual tiene retardo (>15 minutos) según el horario configurado en "Tu horario"
  static LateCheckResult checkIfCheckInIsLate(
    DateTime checkIn,
    List<StudentSchedule> schedules,
  ) {
    if (schedules.isEmpty) {
      return LateCheckResult(isLate: false, lateMinutes: 0);
    }

    final localDate = checkIn.toLocal();
    final scheduleDay = AppDateUtils.dartWeekdayToScheduleDay(
      localDate.weekday,
    );

    // Buscar horarios activos para el día de la semana
    final matchingSchedules = schedules
        .where((s) => s.dayOfWeek == scheduleDay && s.isActive)
        .toList();

    if (matchingSchedules.isEmpty) {
      return LateCheckResult(isLate: false, lateMinutes: 0);
    }

    final currentMinutes = localDate.hour * 60 + localDate.minute;

    // Si hay más de un horario en el día, buscar el más cercano
    StudentSchedule targetSchedule = matchingSchedules.first;
    if (matchingSchedules.length > 1) {
      int minDiff = 999999;
      for (final sch in matchingSchedules) {
        final parts = sch.startTime.split(':');
        final schMins =
            (int.tryParse(parts[0]) ?? 0) * 60 +
            (parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0);
        final diff = (currentMinutes - schMins).abs();
        if (diff < minDiff) {
          minDiff = diff;
          targetSchedule = sch;
        }
      }
    }

    final parts = targetSchedule.startTime.split(':');
    final scheduledMinutes =
        (int.tryParse(parts[0]) ?? 0) * 60 +
        (parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0);
    final diffMinutes = currentMinutes - scheduledMinutes;

    // Regla: Retardo si entra con más de 15 min después de la hora pactada
    if (diffMinutes > 15) {
      return LateCheckResult(
        isLate: true,
        lateMinutes: diffMinutes,
        scheduledStart: targetSchedule.startTime.substring(0, 5),
        scheduleDay: scheduleDay,
      );
    }

    return LateCheckResult(
      isLate: false,
      lateMinutes: 0,
      scheduledStart: targetSchedule.startTime.substring(0, 5),
      scheduleDay: scheduleDay,
    );
  }

  /// Clasifica un registro individual
  static RecordStatus classifyRecord(AttendanceRecord record) {
    if (record.room == 'Ajuste Manual') {
      return RecordStatus.onTime;
    }

    if (record.isJustified ||
        (record.earlyDepartureReason != null &&
            record.earlyDepartureReason!.contains('[JUSTIFICADO]'))) {
      return RecordStatus.justified;
    }

    if (record.room == 'Falta Injustificada' ||
        (record.earlyDepartureReason != null &&
            record.earlyDepartureReason!.contains('[FALTA]'))) {
      return RecordStatus.falta;
    }

    if (record.isLate ||
        (record.earlyDepartureReason != null &&
            record.earlyDepartureReason!.contains('[RETARDO]'))) {
      return RecordStatus.retardo;
    }

    return RecordStatus.onTime;
  }

  /// Calcula el resumen completo de penalizaciones
  static StudentInfractions calculateInfractions(
    List<AttendanceRecord> records, [
    List<StudentSchedule>? schedules,
    String? studentId,
  ]) {
    final lateRecords = <AttendanceRecord>[];
    final faltaRecords = <AttendanceRecord>[];
    final justifiedRecords = <AttendanceRecord>[];

    int retardosCount = 0;
    int directFaltasCount = 0;

    for (final record in records) {
      if (record.room == 'Ajuste Manual') continue;

      final status = classifyRecord(record);
      if (status == RecordStatus.justified) {
        justifiedRecords.add(record);
      } else if (status == RecordStatus.falta) {
        faltaRecords.add(record);
        directFaltasCount++;
      } else if (status == RecordStatus.retardo) {
        lateRecords.add(record);
        retardosCount++;
      }
    }

    final faltasFromRetardos = retardosCount ~/ 3;
    final faltasCount = directFaltasCount + faltasFromRetardos;
    final retardosInCurrentFalta = retardosCount % 3;
    final isBajaRisk = faltasCount >= 3;

    String? faltaQuote;
    if (isBajaRisk) {
      faltaQuote = SkippyQuotes.getBajaQuote(studentId);
    } else if (faltasCount > 0) {
      faltaQuote = SkippyQuotes.getFaltaWarningQuote(faltasCount, studentId);
    }

    return StudentInfractions(
      retardosCount: retardosCount,
      directFaltasCount: directFaltasCount,
      faltasFromRetardos: faltasFromRetardos,
      faltasCount: faltasCount,
      retardosInCurrentFalta: retardosInCurrentFalta,
      isBajaRisk: isBajaRisk,
      bajaQuote: isBajaRisk ? SkippyQuotes.getBajaQuote(studentId) : null,
      faltaQuote: faltaQuote,
      lateRecords: lateRecords,
      faltaRecords: faltaRecords,
      justifiedRecords: justifiedRecords,
    );
  }

  /// Genera cuadrícula de actividad (heatmap estilo GitHub de 16 semanas)
  static List<HeatmapWeek> generateHeatmapGrid(
    List<AttendanceRecord> records, {
    int weeksCount = 16,
  }) {
    final now = DateTime.now().toLocal();

    // 1. Identificar registros de retardo que convirtieron en falta (cada 3 retardos)
    final lateRecordsChronological = records.where((r) {
      if (r.room == 'Ajuste Manual') return false;
      return classifyRecord(r) == RecordStatus.retardo;
    }).toList()..sort((a, b) => a.checkIn.compareTo(b.checkIn));

    final faltaTriggerRecordIds = <String>{};
    for (int i = 0; i < lateRecordsChronological.length; i++) {
      if ((i + 1) % 3 == 0) {
        faltaTriggerRecordIds.add(lateRecordsChronological[i].id);
      }
    }

    // Agrupar registros por fecha "yyyy-MM-dd"
    final recordsByDate = <String, List<AttendanceRecord>>{};
    for (final r in records) {
      final key = AppDateUtils.formatIsoDate(r.checkIn);
      recordsByDate.putIfAbsent(key, () => []).add(r);
    }

    // Encontrar el domingo de la semana actual
    final currentWeekday = now.weekday; // 1=Lunes, 7=Domingo
    final daysUntilSunday = 7 - currentWeekday;
    final endSunday = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: daysUntilSunday));

    // Inicio: N semanas antes empezando el lunes
    final startMonday = endSunday.subtract(
      Duration(days: (weeksCount * 7) - 1),
    );

    final weeks = <HeatmapWeek>[];
    DateTime cursor = startMonday;

    for (int w = 0; w < weeksCount; w++) {
      final days = <HeatmapDay>[];
      for (int d = 0; d < 7; d++) {
        final dateKey = AppDateUtils.formatIsoDate(cursor);
        final dayRecords = recordsByDate[dateKey] ?? [];

        String status = 'none';
        bool isJustified = false;

        if (dayRecords.isNotEmpty) {
          // Determinar estado prioritario: Falta > Retardo > Justificado > OnTime
          bool hasFalta = false;
          bool hasRetardo = false;
          bool hasJustified = false;
          bool hasOnTime = false;

          for (final rec in dayRecords) {
            final st = classifyRecord(rec);
            if (st == RecordStatus.falta ||
                faltaTriggerRecordIds.contains(rec.id)) {
              hasFalta = true;
            } else if (st == RecordStatus.retardo) {
              hasRetardo = true;
            } else if (st == RecordStatus.justified) {
              hasJustified = true;
            } else if (st == RecordStatus.onTime) {
              hasOnTime = true;
            }
          }

          if (hasFalta) {
            status = 'falta';
          } else if (hasRetardo) {
            status = 'retardo';
          } else if (hasJustified) {
            status = 'on_time';
            isJustified = true;
          } else if (hasOnTime) {
            status = 'on_time';
          }
        }

        days.add(
          HeatmapDay(
            date: dateKey,
            dateTime: cursor,
            dayOfWeek: cursor.weekday,
            status: status,
            isJustified: isJustified,
            records: dayRecords,
          ),
        );

        cursor = cursor.add(const Duration(days: 1));
      }
      weeks.add(HeatmapWeek(days: days));
    }

    return weeks;
  }
}
