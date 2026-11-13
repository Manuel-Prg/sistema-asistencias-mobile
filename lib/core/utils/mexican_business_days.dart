/// Utilidad para cálculo de días hábiles y días feriados oficiales
/// en Villahermosa, Tabasco, México (conforme a la Ley Federal del Trabajo
/// y descansos obligatorios institucionales / universitarios).
class MexicanBusinessDays {
  MexicanBusinessDays._();

  /// Comprueba si la fecha cae en fin de semana (sábado o domingo).
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  /// Calcula la fecha del Domingo de Pascua para el año dado (Algoritmo de Meeus/Jones/Butcher).
  static DateTime _getEasterSunday(int year) {
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31;
    final day = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(year, month, day);
  }

  /// Retorna el enésimo lunes de un mes determinado (p. ej. 1er lunes o 3er lunes).
  static DateTime _getNthMondayOfMonth(int year, int month, int n) {
    var count = 0;
    for (var day = 1; day <= 31; day++) {
      final dt = DateTime(year, month, day);
      if (dt.month != month) break;
      if (dt.weekday == DateTime.monday) {
        count++;
        if (count == n) return dt;
      }
    }
    return DateTime(year, month, 1);
  }

  /// Retorna el nombre del día festivo o de descanso obligatorio si la fecha coincide.
  static String? getHolidayName(DateTime date) {
    final year = date.year;
    final month = date.month;
    final day = date.day;

    // 1 de Enero: Año Nuevo
    if (month == 1 && day == 1) return 'Año Nuevo';

    // Primer lunes de Febrero: Día de la Constitución (en conmemoración del 5 de Feb)
    final primerLunesFeb = _getNthMondayOfMonth(year, 2, 1);
    if (month == 2 && day == primerLunesFeb.day) {
      return 'Día de la Constitución';
    }

    // 27 de Febrero: Conmemoración en Tabasco (Batalla de San Pedro)
    if (month == 2 && day == 27) return 'Batalla de San Pedro (Tabasco)';

    // Tercer lunes de Marzo: Natalicio de Benito Juárez (en conmemoración del 21 de Mar)
    final tercerLunesMar = _getNthMondayOfMonth(year, 3, 3);
    if (month == 3 && day == tercerLunesMar.day) {
      return 'Natalicio de Benito Juárez';
    }

    // Semana Santa (Jueves Santo y Viernes Santo)
    final easter = _getEasterSunday(year);
    final juevesSanto = easter.subtract(const Duration(days: 3));
    final viernesSanto = easter.subtract(const Duration(days: 2));
    if (month == juevesSanto.month && day == juevesSanto.day) {
      return 'Jueves Santo';
    }
    if (month == viernesSanto.month && day == viernesSanto.day) {
      return 'Viernes Santo';
    }

    // 1 de Mayo: Día del Trabajo
    if (month == 5 && day == 1) return 'Día del Trabajo';

    // 5 de Mayo: Batalla de Puebla (Feriado escolar / universitario)
    if (month == 5 && day == 5) return 'Batalla de Puebla';

    // 16 de Septiembre: Día de la Independencia de México
    if (month == 9 && day == 16) return 'Día de la Independencia';

    // 1 de Octubre cada 6 años (Transmisión del Poder Ejecutivo Federal)
    if (year % 6 == 2024 % 6 && month == 10 && day == 1) {
      return 'Transmisión del Poder Ejecutivo Federal';
    }

    // 2 de Noviembre: Día de Muertos (Feriado tradicional en Tabasco y México)
    if (month == 11 && day == 2) return 'Día de Muertos';

    // Tercer lunes de Noviembre: Revolución Mexicana (en conmemoración del 20 de Nov)
    final tercerLunesNov = _getNthMondayOfMonth(year, 11, 3);
    if (month == 11 && day == tercerLunesNov.day) {
      return 'Revolución Mexicana';
    }

    // 25 de Diciembre: Navidad
    if (month == 12 && day == 25) return 'Navidad';

    return null;
  }

  /// Comprueba si la fecha es un día feriado o de descanso obligatorio.
  static bool isMexicanHoliday(DateTime date) {
    return getHolidayName(date) != null;
  }

  /// Determina si una fecha es un día hábil (no es fin de semana ni feriado obligatorio).
  static bool isBusinessDay(DateTime date) {
    return !isWeekend(date) && !isMexicanHoliday(date);
  }

  /// Obtiene los primeros [count] días hábiles del mes especificado.
  static List<DateTime> getFirstNBusinessDays(
    int year,
    int month, {
    int count = 5,
  }) {
    final businessDays = <DateTime>[];
    var currentDay = 1;

    while (businessDays.length < count) {
      final dt = DateTime(year, month, currentDay);
      if (dt.month != month) break; // Fin de mes alcanzado

      if (isBusinessDay(dt)) {
        businessDays.add(DateTime(year, month, currentDay));
      }
      currentDay++;
    }

    return businessDays;
  }

  /// Obtiene los últimos [count] días hábiles del mes especificado.
  static List<DateTime> getLastNBusinessDays(
    int year,
    int month, {
    int count = 3,
  }) {
    final businessDays = <DateTime>[];
    // Obtener el último día del mes
    final lastDay = DateTime(year, month + 1, 0).day;

    for (var d = lastDay; d >= 1; d--) {
      final dt = DateTime(year, month, d);
      if (isBusinessDay(dt)) {
        businessDays.insert(0, DateTime(year, month, d));
        if (businessDays.length == count) break;
      }
    }

    return businessDays;
  }

  /// Si [date] es uno de los primeros 5 días hábiles de su mes, retorna su posición (1..5).
  /// En caso contrario, retorna null.
  static int? getFirst5BusinessDayIndex(DateTime date) {
    final first5 = getFirstNBusinessDays(date.year, date.month, count: 5);
    for (var i = 0; i < first5.length; i++) {
      if (first5[i].year == date.year &&
          first5[i].month == date.month &&
          first5[i].day == date.day) {
        return i + 1;
      }
    }
    return null;
  }

  /// Indica si [date] se encuentra en la ventana de entrega de fin de mes
  /// (en los últimos [count] días hábiles del mes).
  static bool isEndOfMonthWindow(DateTime date, {int count = 3}) {
    final lastDays = getLastNBusinessDays(date.year, date.month, count: count);
    return lastDays.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }
}
