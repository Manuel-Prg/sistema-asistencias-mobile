import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Información de hardware del dispositivo para adaptar los efectos visuales
/// y recomendar automáticamente Material 3 en equipos con recursos limitados.
class DevicePerformanceInfo {
  final int totalRamMb;
  final bool isLowRamDevice;
  final int cpuCores;
  final int sdkInt;
  final bool isLowEndDevice;

  const DevicePerformanceInfo({
    required this.totalRamMb,
    required this.isLowRamDevice,
    required this.cpuCores,
    required this.sdkInt,
    required this.isLowEndDevice,
  });

  static const DevicePerformanceInfo standard = DevicePerformanceInfo(
    totalRamMb: 0,
    isLowRamDevice: false,
    cpuCores: 0,
    sdkInt: 0,
    isLowEndDevice: false,
  );

  /// Etiqueta legible de RAM aproximada (ej. "4 GB RAM"), o vacío si no se conoce.
  String get ramLabel {
    if (totalRamMb <= 0) return '';
    final gb = (totalRamMb / 1024).round().clamp(1, 64);
    return '$gb GB RAM';
  }
}

class DevicePerformanceService {
  DevicePerformanceService._();

  static const MethodChannel _channel = MethodChannel(
    'com.casauniversitariadelagua/device_performance',
  );

  static DevicePerformanceInfo? _cached;

  /// Umbral de RAM (MB) por debajo del cual se considera un dispositivo limitado.
  /// En Android, equipos con ≤ 4 GB de RAM (~4096 MB) se benefician enormemente
  /// de usar Material 3 sin pases de BackdropFilter ni shaders.
  static const int lowEndRamThresholdMb = 4200;

  /// Clasifica si el dispositivo tiene prestaciones limitadas con base en RAM,
  /// flag oficial de Android Go (`isLowRamDevice`), núcleos CPU y versión de SDK.
  static bool classifyIsLowEnd({
    required int totalRamMb,
    required bool isLowRamDevice,
    required int cpuCores,
    required int sdkInt,
  }) {
    if (isLowRamDevice) return true;
    if (totalRamMb > 0 && totalRamMb <= lowEndRamThresholdMb) return true;
    if (cpuCores > 0 && cpuCores <= 4) return true;
    if (sdkInt > 0 && sdkInt <= 29) return true;
    return false;
  }

  /// Consulta una única vez las prestaciones nativas del dispositivo y guarda el resultado en caché.
  static Future<DevicePerformanceInfo> getDevicePerformance() async {
    if (_cached != null) return _cached!;

    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      _cached = DevicePerformanceInfo.standard;
      return _cached!;
    }

    try {
      final raw = await _channel.invokeMapMethod<String, dynamic>(
        'getDevicePerformance',
      );
      if (raw == null) {
        _cached = DevicePerformanceInfo.standard;
        return _cached!;
      }

      final totalRamMb = (raw['totalRamMb'] as num?)?.toInt() ?? 0;
      final isLowRamDevice = raw['isLowRamDevice'] as bool? ?? false;
      final cpuCores = (raw['cpuCores'] as num?)?.toInt() ?? 0;
      final sdkInt = (raw['sdkInt'] as num?)?.toInt() ?? 0;

      final isLowEnd = classifyIsLowEnd(
        totalRamMb: totalRamMb,
        isLowRamDevice: isLowRamDevice,
        cpuCores: cpuCores,
        sdkInt: sdkInt,
      );

      _cached = DevicePerformanceInfo(
        totalRamMb: totalRamMb,
        isLowRamDevice: isLowRamDevice,
        cpuCores: cpuCores,
        sdkInt: sdkInt,
        isLowEndDevice: isLowEnd,
      );
      return _cached!;
    } catch (e) {
      debugPrint('DevicePerformanceService: No se pudo consultar hardware: $e');
      _cached = DevicePerformanceInfo.standard;
      return _cached!;
    }
  }
}
