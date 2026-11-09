import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlassSettings {
  /// Transparencia del vidrio: 0.10 (muy sólido) a 0.85 (máxima transparencia)
  final double transparency;

  /// Contornos y bordes decorativos de cristal
  final bool showBorders;

  /// Intensidad del desenfoque gaussiano
  final double blurSigma;

  const GlassSettings({
    this.transparency = 0.50,
    this.showBorders = true,
    this.blurSigma = 20.0,
  });

  GlassSettings copyWith({
    double? transparency,
    bool? showBorders,
    double? blurSigma,
  }) {
    return GlassSettings(
      transparency: transparency ?? this.transparency,
      showBorders: showBorders ?? this.showBorders,
      blurSigma: blurSigma ?? this.blurSigma,
    );
  }

  /// Nivel de opacidad derivado para el fondo matérico
  double get effectiveOpacity => (1.0 - transparency).clamp(0.15, 0.92);
}

final glassSettingsProvider =
    NotifierProvider<GlassSettingsNotifier, GlassSettings>(
  GlassSettingsNotifier.new,
);

class GlassSettingsNotifier extends Notifier<GlassSettings> {
  static const _transparencyKey = 'glass_transparency';
  static const _showBordersKey = 'glass_show_borders';

  @override
  GlassSettings build() {
    _loadSettings();
    return const GlassSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTransparency = prefs.getDouble(_transparencyKey);
    final savedShowBorders = prefs.getBool(_showBordersKey);

    state = state.copyWith(
      transparency: savedTransparency ?? 0.50,
      showBorders: savedShowBorders ?? true,
    );
  }

  Future<void> setTransparency(double value) async {
    final clamped = value.clamp(0.10, 0.85);
    state = state.copyWith(transparency: clamped);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_transparencyKey, clamped);
  }

  Future<void> setShowBorders(bool value) async {
    state = state.copyWith(showBorders: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showBordersKey, value);
  }
}
