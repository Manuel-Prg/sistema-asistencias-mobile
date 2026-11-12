import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_asistencia_mobile/models/app_version_info.dart';
import 'package:sistema_asistencia_mobile/services/update_service.dart';

void main() {
  group('UpdateService - Comparación de Versiones Semver', () {
    test('isVersionHigher detecta incrementos de patch, minor y major', () {
      expect(UpdateService.isVersionHigher('1.0.1', '1.0.0'), isTrue);
      expect(UpdateService.isVersionHigher('1.1.0', '1.0.5'), isTrue);
      expect(UpdateService.isVersionHigher('2.0.0', '1.9.9'), isTrue);
      expect(UpdateService.isVersionHigher('1.2.0', '1.1.9'), isTrue);
    });

    test('isVersionHigher rechaza versiones iguales o inferiores', () {
      expect(UpdateService.isVersionHigher('1.0.0', '1.0.0'), isFalse);
      expect(UpdateService.isVersionHigher('0.9.9', '1.0.0'), isFalse);
      expect(UpdateService.isVersionHigher('1.0.1', '1.0.2'), isFalse);
    });

    test('AppVersionInfo deserializa correctamente desde JSON de Supabase', () {
      final json = {
        'version': '1.1.0',
        'build_number': 2,
        'apk_url': 'https://ejemplo.com/app-release.apk',
        'changelog': '- Corrección de notificaciones\n- Nuevo dock animado',
        'is_mandatory': true,
        'created_at': '2026-11-11T12:00:00Z',
      };

      final info = AppVersionInfo.fromJson(json);

      expect(info.version, equals('1.1.0'));
      expect(info.buildNumber, equals(2));
      expect(info.apkUrl, equals('https://ejemplo.com/app-release.apk'));
      expect(info.changelog, contains('Nuevo dock animado'));
      expect(info.isMandatory, isTrue);
      expect(info.releaseDate, isNotNull);
    });
  });
}
