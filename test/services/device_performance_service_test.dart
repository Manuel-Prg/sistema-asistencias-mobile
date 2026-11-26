import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_asistencia_mobile/services/device_performance_service.dart';

void main() {
  group('DevicePerformanceService.classifyIsLowEnd', () {
    test('detecta dispositivos Android Go (isLowRamDevice = true)', () {
      expect(
        DevicePerformanceService.classifyIsLowEnd(
          totalRamMb: 6144,
          isLowRamDevice: true,
          cpuCores: 8,
          sdkInt: 34,
        ),
        isTrue,
      );
    });

    test('detecta equipos con <= 4 GB de RAM como limitados', () {
      expect(
        DevicePerformanceService.classifyIsLowEnd(
          totalRamMb: 3800,
          isLowRamDevice: false,
          cpuCores: 8,
          sdkInt: 33,
        ),
        isTrue,
      );
    });

    test('detecta equipos con <= 4 núcleos o Android <= 10 como limitados', () {
      expect(
        DevicePerformanceService.classifyIsLowEnd(
          totalRamMb: 6144,
          isLowRamDevice: false,
          cpuCores: 4,
          sdkInt: 33,
        ),
        isTrue,
      );

      expect(
        DevicePerformanceService.classifyIsLowEnd(
          totalRamMb: 6144,
          isLowRamDevice: false,
          cpuCores: 8,
          sdkInt: 29,
        ),
        isTrue,
      );
    });

    test('clasifica equipos modernos (6+ GB RAM, 8 núcleos, Android 11+) como estándar', () {
      expect(
        DevicePerformanceService.classifyIsLowEnd(
          totalRamMb: 8192,
          isLowRamDevice: false,
          cpuCores: 8,
          sdkInt: 35,
        ),
        isFalse,
      );
    });
  });
}
