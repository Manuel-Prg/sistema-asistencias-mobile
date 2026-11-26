import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/device_performance_service.dart';

/// Estilo visual global de la aplicación:
/// - [material3]: Diseño plano/sólido Material 3 (máximo rendimiento y menor consumo de GPU/batería)
/// - [liquidGlass]: Estética translúcida estilo cristal líquido con desenfoque y refracción
enum AppVisualStyle {
  material3,
  liquidGlass,
}

class GlassSettings {
  /// Estilo visual principal (Material 3 vs Liquid Glass)
  final AppVisualStyle visualStyle;

  /// Usar la fuente nativa del sistema en lugar de la fuente personalizada de la app (Archer)
  final bool useSystemFont;

  /// Transparencia del vidrio: 0.10 (muy sólido) a 0.85 (máxima transparencia)
  final double transparency;

  /// Contornos y bordes decorativos de cristal
  final bool showBorders;

  /// Intensidad del desenfoque gaussiano (optimizado a 7.0 para fluidez a 60-120 FPS)
  final double blurSigma;

  /// Habilitar desenfoque gaussiano en tiempo real (si está desactivado, usa modo alto rendimiento)
  final bool? _enableBlur;

  /// Indica si el dispositivo fue detectado como de prestaciones limitadas
  final bool isLowEndDevice;

  /// Memoria RAM total reportada por el sistema en MB (0 si no aplica)
  final int totalRamMb;

  const GlassSettings({
    this.visualStyle = AppVisualStyle.liquidGlass,
    this.useSystemFont = false,
    this.transparency = 0.60,
    this.showBorders = true,
    this.blurSigma = 7.0,
    bool this._enableBlur = true,
    this.isLowEndDevice = false,
    this.totalRamMb = 0,
  });

  bool get enableBlur => _enableBlur ?? true;
  bool get isMaterial3 => visualStyle == AppVisualStyle.material3;
  bool get isLiquidGlass => visualStyle == AppVisualStyle.liquidGlass;

  String get deviceRamLabel {
    if (totalRamMb <= 0) return '';
    final gb = (totalRamMb / 1024).round().clamp(1, 64);
    return '$gb GB RAM';
  }

  GlassSettings copyWith({
    AppVisualStyle? visualStyle,
    bool? useSystemFont,
    double? transparency,
    bool? showBorders,
    double? blurSigma,
    bool? enableBlur,
    bool? isLowEndDevice,
    int? totalRamMb,
  }) {
    return GlassSettings(
      visualStyle: visualStyle ?? this.visualStyle,
      useSystemFont: useSystemFont ?? this.useSystemFont,
      transparency: transparency ?? this.transparency,
      showBorders: showBorders ?? this.showBorders,
      blurSigma: blurSigma ?? this.blurSigma,
      enableBlur: enableBlur ?? this.enableBlur,
      isLowEndDevice: isLowEndDevice ?? this.isLowEndDevice,
      totalRamMb: totalRamMb ?? this.totalRamMb,
    );
  }

  /// Nivel de opacidad derivado para el fondo matérico (permite máxima transparencia vítrea)
  double get effectiveOpacity => (1.0 - transparency).clamp(0.04, 0.92);
}

final glassSettingsProvider =
    NotifierProvider<GlassSettingsNotifier, GlassSettings>(
      GlassSettingsNotifier.new,
    );

class GlassSettingsNotifier extends Notifier<GlassSettings> {
  static const _visualStyleKey = 'app_visual_style';
  static const _useSystemFontKey = 'app_use_system_font';
  static const _transparencyKey = 'glass_transparency';
  static const _showBordersKey = 'glass_show_borders';
  static const _enableBlurKey = 'glass_enable_blur';
  static const _blurSigmaKey = 'glass_blur_sigma';

  @override
  GlassSettings build() {
    _loadSettings();
    return const GlassSettings();
  }

  Future<void> _loadSettings() async {
    final results = await Future.wait([
      SharedPreferences.getInstance(),
      DevicePerformanceService.getDevicePerformance(),
    ]);
    final prefs = results[0] as SharedPreferences;
    final perf = results[1] as DevicePerformanceInfo;

    // En equipos con prestaciones limitadas, reducir aún más el límite de caché de imágenes
    if (perf.isLowEndDevice) {
      PaintingBinding.instance.imageCache.maximumSizeBytes = 24 << 20; // 24 MB
      PaintingBinding.instance.imageCache.maximumSize = 50;
    }

    final savedStyle = prefs.getString(_visualStyleKey);
    final savedUseSystemFont = prefs.getBool(_useSystemFontKey);
    final savedTransparency = prefs.getDouble(_transparencyKey);
    final savedShowBorders = prefs.getBool(_showBordersKey);
    final savedEnableBlur = prefs.getBool(_enableBlurKey);
    final savedBlurSigma = prefs.getDouble(_blurSigmaKey);
    // Optimización de rendimiento: Si el valor guardado es muy alto (ej. 16.0 de versiones previas),
    // normalizar a 7.0 para garantizar 60-120 FPS en todos los dispositivos.
    final effectiveBlur = (savedBlurSigma == null || savedBlurSigma > 8.0)
        ? 7.0
        : savedBlurSigma;

    // Si el usuario aún no eligió estilo manualmente y el equipo es limitado,
    // activar Material 3 por defecto para garantizar máxima fluidez.
    final AppVisualStyle resolvedStyle;
    if (savedStyle == 'material3') {
      resolvedStyle = AppVisualStyle.material3;
    } else if (savedStyle == 'liquidGlass') {
      resolvedStyle = AppVisualStyle.liquidGlass;
    } else {
      resolvedStyle = perf.isLowEndDevice
          ? AppVisualStyle.material3
          : AppVisualStyle.liquidGlass;
    }

    state = state.copyWith(
      visualStyle: resolvedStyle,
      useSystemFont: savedUseSystemFont ?? false,
      transparency: savedTransparency ?? 0.60,
      showBorders: savedShowBorders ?? true,
      enableBlur: savedEnableBlur ?? !perf.isLowEndDevice,
      blurSigma: effectiveBlur,
      isLowEndDevice: perf.isLowEndDevice,
      totalRamMb: perf.totalRamMb,
    );
  }

  Future<void> setVisualStyle(AppVisualStyle style) async {
    state = state.copyWith(visualStyle: style);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _visualStyleKey,
      style == AppVisualStyle.material3 ? 'material3' : 'liquidGlass',
    );
  }

  Future<void> setUseSystemFont(bool value) async {
    state = state.copyWith(useSystemFont: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useSystemFontKey, value);
  }

  Future<void> setTransparency(double value) async {
    final clamped = value.clamp(0.10, 0.95);
    state = state.copyWith(transparency: clamped);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_transparencyKey, clamped);
  }

  Future<void> setShowBorders(bool value) async {
    state = state.copyWith(showBorders: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showBordersKey, value);
  }

  Future<void> setEnableBlur(bool value) async {
    state = state.copyWith(enableBlur: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enableBlurKey, value);
  }

  Future<void> setBlurSigma(double value) async {
    final clamped = value.clamp(4.0, 20.0);
    state = state.copyWith(blurSigma: clamped);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_blurSigmaKey, clamped);
  }
}
