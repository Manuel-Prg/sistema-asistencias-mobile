import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_asistencia_mobile/core/utils/skippy_quotes.dart';

void main() {
  group('SkippyQuotes - Frases de Nuty (Cyberpunk Skippy)', () {
    test('Frases de llenado de reporte (Días 1 a 5) tienen títulos y cuerpos definidos', () {
      for (var day = 1; day <= 5; day++) {
        final title = SkippyQuotes.getStartOfMonthTitle(day);
        final body = SkippyQuotes.getStartOfMonthBody(day);

        expect(title, isNotEmpty);
        expect(body, isNotEmpty);
        expect(title.contains('Nuty'), isTrue);
        expect(body.contains('reporte'), isTrue);
      }
    });

    test('Día 5 de inicio de mes contiene alerta de último día', () {
      final title = SkippyQuotes.getStartOfMonthTitle(5);
      final body = SkippyQuotes.getStartOfMonthBody(5);

      expect(title.contains('ÚLTIMO DÍA HÁBIL'), isTrue);
      expect(body.contains('último día hábil'), isTrue);
    });

    test('Frases de fin de mes (3, 2, 1 días restantes) tienen títulos y cuerpos definidos', () {
      for (var remaining = 1; remaining <= 3; remaining++) {
        final title = SkippyQuotes.getEndOfMonthTitle(remaining);
        final body = SkippyQuotes.getEndOfMonthBody(remaining);

        expect(title, isNotEmpty);
        expect(body, isNotEmpty);
        expect(title.contains('Nuty'), isTrue);
        expect(body.toLowerCase().contains('plataforma') || body.toLowerCase().contains('reporte'), isTrue);
      }
    });

    test('Último día de entrega en plataforma (remaining = 1) contiene advertencia crítica', () {
      final title = SkippyQuotes.getEndOfMonthTitle(1);
      final body = SkippyQuotes.getEndOfMonthBody(1);

      expect(title.contains('HOY CIERRA PLATAFORMA'), isTrue);
      expect(body.contains('Último día hábil del mes'), isTrue);
    });

    test('Frases de faltas y baja inminente alertan al estudiante con el tono de Nuty', () {
      final bajaQuote = SkippyQuotes.getBajaQuote('user_123');
      expect(bajaQuote.contains('Nuty'), isTrue);
      expect(bajaQuote.contains('3 faltas'), isTrue);

      final falta1Quote = SkippyQuotes.getFaltaWarningQuote(1, 'user_123');
      expect(falta1Quote.contains('1ra Falta') || falta1Quote.contains('1 falta'), isTrue);

      final falta2Quote = SkippyQuotes.getFaltaWarningQuote(2, 'user_123');
      expect(falta2Quote.contains('2 faltas'), isTrue);
    });

    test('Frases de conclusión al 100% de horas son personalizadas por tipo de servicio', () {
      final ss = SkippyQuotes.getCompletedQuote('servicio_social', 'student_1');
      expect(ss.contains('Servicio Social') || ss.contains('horas'), isTrue);

      final practicas = SkippyQuotes.getCompletedQuote('practicas', 'student_1');
      expect(practicas.contains('Prácticas') || practicas.contains('horas') || practicas.contains('CUA'), isTrue);

      final dual = SkippyQuotes.getCompletedQuote('convenio_dual', 'student_1');
      expect(dual.contains('Convenio Dual') || dual.contains('horas') || dual.contains('Cyborg'), isTrue);
    });
  });
}
