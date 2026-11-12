import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_asistencia_mobile/core/utils/mexican_business_days.dart';

void main() {
  group('MexicanBusinessDays - Fines de Semana y Feriados en Villahermosa', () {
    test('isWeekend identifica sábados y domingos correctamente', () {
      final saturday = DateTime(2026, 11, 7);
      final sunday = DateTime(2026, 11, 8);
      final monday = DateTime(2026, 11, 9);
      final friday = DateTime(2026, 11, 6);

      expect(MexicanBusinessDays.isWeekend(saturday), isTrue);
      expect(MexicanBusinessDays.isWeekend(sunday), isTrue);
      expect(MexicanBusinessDays.isWeekend(monday), isFalse);
      expect(MexicanBusinessDays.isWeekend(friday), isFalse);
    });

    test('isMexicanHoliday detecta feriados oficiales y estatales de Tabasco', () {
      // 1 de Enero
      expect(MexicanBusinessDays.isMexicanHoliday(DateTime(2026, 1, 1)), isTrue);
      expect(MexicanBusinessDays.getHolidayName(DateTime(2026, 1, 1)), 'Año Nuevo');

      // 27 de Febrero: Batalla de San Pedro (Tabasco)
      expect(MexicanBusinessDays.isMexicanHoliday(DateTime(2026, 2, 27)), isTrue);
      expect(MexicanBusinessDays.getHolidayName(DateTime(2026, 2, 27)), 'Batalla de San Pedro (Tabasco)');

      // 1 de Mayo: Día del Trabajo
      expect(MexicanBusinessDays.isMexicanHoliday(DateTime(2026, 5, 1)), isTrue);

      // 5 de Mayo: Batalla de Puebla
      expect(MexicanBusinessDays.isMexicanHoliday(DateTime(2026, 5, 5)), isTrue);

      // 16 de Septiembre: Independencia
      expect(MexicanBusinessDays.isMexicanHoliday(DateTime(2026, 9, 16)), isTrue);

      // 2 de Noviembre: Día de Muertos (Tabasco / México)
      expect(MexicanBusinessDays.isMexicanHoliday(DateTime(2026, 11, 2)), isTrue);
      expect(MexicanBusinessDays.getHolidayName(DateTime(2026, 11, 2)), 'Día de Muertos');

      // 25 de Diciembre: Navidad
      expect(MexicanBusinessDays.isMexicanHoliday(DateTime(2026, 12, 25)), isTrue);

      // Un día normal no es festivo
      expect(MexicanBusinessDays.isMexicanHoliday(DateTime(2026, 11, 10)), isFalse);
    });

    test('Noviembre 2026 calcula los primeros 5 días hábiles saltando fin de semana y 2 de Noviembre', () {
      // Nov 1 = Domingo (fin de semana)
      // Nov 2 = Lunes (Día de Muertos - feriado)
      // Nov 3 = Martes -> Día hábil 1
      // Nov 4 = Miércoles -> Día hábil 2
      // Nov 5 = Jueves -> Día hábil 3
      // Nov 6 = Viernes -> Día hábil 4
      // Nov 7 = Sábado (fin de semana)
      // Nov 8 = Domingo (fin de semana)
      // Nov 9 = Lunes -> Día hábil 5
      final first5 = MexicanBusinessDays.getFirstNBusinessDays(2026, 11, count: 5);

      expect(first5.length, equals(5));
      expect(first5[0], equals(DateTime(2026, 11, 3)));
      expect(first5[1], equals(DateTime(2026, 11, 4)));
      expect(first5[2], equals(DateTime(2026, 11, 5)));
      expect(first5[3], equals(DateTime(2026, 11, 6)));
      expect(first5[4], equals(DateTime(2026, 11, 9)));
    });

    test('getFirst5BusinessDayIndex mapea correctamente la posición y rechaza feriados', () {
      expect(MexicanBusinessDays.getFirst5BusinessDayIndex(DateTime(2026, 11, 1)), isNull); // Domingo
      expect(MexicanBusinessDays.getFirst5BusinessDayIndex(DateTime(2026, 11, 2)), isNull); // Feriado Día de Muertos
      expect(MexicanBusinessDays.getFirst5BusinessDayIndex(DateTime(2026, 11, 3)), equals(1));
      expect(MexicanBusinessDays.getFirst5BusinessDayIndex(DateTime(2026, 11, 4)), equals(2));
      expect(MexicanBusinessDays.getFirst5BusinessDayIndex(DateTime(2026, 11, 5)), equals(3));
      expect(MexicanBusinessDays.getFirst5BusinessDayIndex(DateTime(2026, 11, 6)), equals(4));
      expect(MexicanBusinessDays.getFirst5BusinessDayIndex(DateTime(2026, 11, 9)), equals(5));
      expect(MexicanBusinessDays.getFirst5BusinessDayIndex(DateTime(2026, 11, 10)), isNull); // Día 6 ya no entra
    });

    test('getLastNBusinessDays calcula los últimos 3 días hábiles del mes para entrega en plataforma', () {
      // Noviembre 2026 tiene 30 días. El 30 de Nov es Lunes (hábil).
      // 29 Dom, 28 Sáb.
      // 27 Viernes (hábil)
      // 26 Jueves (hábil)
      final last3 = MexicanBusinessDays.getLastNBusinessDays(2026, 11, count: 3);

      expect(last3.length, equals(3));
      expect(last3[0], equals(DateTime(2026, 11, 26)));
      expect(last3[1], equals(DateTime(2026, 11, 27)));
      expect(last3[2], equals(DateTime(2026, 11, 30)));

      expect(MexicanBusinessDays.isEndOfMonthWindow(DateTime(2026, 11, 30)), isTrue);
      expect(MexicanBusinessDays.isEndOfMonthWindow(DateTime(2026, 11, 25)), isFalse);
    });
  });
}
