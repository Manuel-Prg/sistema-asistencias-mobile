import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Transparencia del vidrio: 0.10 (muy sólido) a 0.85 (máxima transparencia)
  final double transparency;

  /// Contornos y bordes decorativos de cristal
  final bool showBorders;

  /// Intensidad del desenfoque gaussiano (optimizado a 7.0 para fluidez a 60-120 FPS)
  final double blurSigma;

  /// Habilitar desenfoque gaussiano en tiempo real (si está desactivado, usa modo alto rendimiento)
  final bool? _enableBlur;

  const GlassSettings({
    this.visualStyle = AppVisualStyle.liquidGlass,
    this.transparency = 0.60,
    this.showBorders = true,
    this.blurSigma = 7.0,
    bool this._enableBlur = true,
  });

  bool get enableBlur => _enableBlur ?? true;
  bool get isMaterial3 => visualStyle == AppVisualStyle.material3;
  bool get isLiquidGlass => visualStyle == AppVisualStyle.liquidGlass;

  GlassSettings copyWith({
    AppVisualStyle? visualStyle,
    double? transparency,
    bool? showBorders,
    double? blurSigma,
    bool? enableBlur,
  }) {
    return GlassSettings(
      visualStyle: visualStyle ?? this.visualStyle,
      transparency: transparency ?? this.transparency,
      showBorders: showBorders ?? this.showBorders,
      blurSigma: blurSigma ?? this.blurSigma,
      enableBlur: enableBlur ?? this.enableBlur,
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
    final prefs = await SharedPreferences.getInstance();
    final savedStyle = prefs.getString(_visualStyleKey);
    final savedTransparency = prefs.getDouble(_transparencyKey);
    final savedShowBorders = prefs.getBool(_showBordersKey);
    final savedEnableBlur = prefs.getBool(_enableBlurKey);
    final savedBlurSigma = prefs.getDouble(_blurSigmaKey);
    // Optimización de rendimiento: Si el valor guardado es muy alto (ej. 16.0 de versiones previas),
    // normalizar a 7.0 para garantizar 60-120 FPS en todos los dispositivos.
    final effectiveBlur = (savedBlurSigma == null || savedBlurSigma > 10.0)
        ? 7.0
        : savedBlurSigma;

    final resolvedStyle = savedStyle == 'material3'
        ? AppVisualStyle.material3
        : AppVisualStyle.liquidGlass;

    state = state.copyWith(
      visualStyle: resolvedStyle,
      transparency: savedTransparency ?? 0.60,
      showBorders: savedShowBorders ?? true,
      enableBlur: savedEnableBlur ?? true,
      blurSigma: effectiveBlur,
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
