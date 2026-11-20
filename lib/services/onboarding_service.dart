import 'package:shared_preferences/shared_preferences.dart';

/// Servicio ligero para controlar la visualización del Onboarding / Novedades.
/// Al cambiar [currentOnboardingVersion] en futuras versiones mayores, volverá
/// a mostrarse una sola vez a los usuarios que actualicen.
class OnboardingService {
  OnboardingService._();

  static const String _seenVersionKey = 'onboarding_seen_version';
  static const String currentOnboardingVersion = '1.0.8';

  static Future<bool> shouldShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final seenVersion = prefs.getString(_seenVersionKey);
    return seenVersion != currentOnboardingVersion;
  }

  static Future<void> markAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_seenVersionKey, currentOnboardingVersion);
  }
}
