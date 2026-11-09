import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class NotificationState {
  final bool isEnabled;
  final bool isDeviceGranted;
  final bool isChecking;

  const NotificationState({
    this.isEnabled = false,
    this.isDeviceGranted = false,
    this.isChecking = false,
  });

  NotificationState copyWith({
    bool? isEnabled,
    bool? isDeviceGranted,
    bool? isChecking,
  }) {
    return NotificationState(
      isEnabled: isEnabled ?? this.isEnabled,
      isDeviceGranted: isDeviceGranted ?? this.isDeviceGranted,
      isChecking: isChecking ?? this.isChecking,
    );
  }
}

class NotificationNotifier extends Notifier<NotificationState> {
  static const String _prefKey = 'app_push_notifications_enabled';

  @override
  NotificationState build() {
    _init();
    return const NotificationState(isChecking: true);
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEnabled = prefs.getBool(_prefKey) ?? false;
    final deviceGranted = await NotificationService.areNotificationsEnabled();

    state = NotificationState(
      isEnabled: savedEnabled && deviceGranted,
      isDeviceGranted: deviceGranted,
      isChecking: false,
    );
  }

  /// Cambia el estado de activación de notificaciones push
  Future<bool> setNotificationsEnabled(bool enable) async {
    final prefs = await SharedPreferences.getInstance();

    if (!enable) {
      await prefs.setBool(_prefKey, false);
      state = state.copyWith(isEnabled: false);
      return true;
    }

    // Si el usuario quiere activarlas, solicitar permiso nativo al sistema operativo
    final granted = await NotificationService.requestNotificationPermission();
    if (granted) {
      await prefs.setBool(_prefKey, true);
      state = state.copyWith(isEnabled: true, isDeviceGranted: true);
      return true;
    } else {
      // El permiso fue denegado a nivel de sistema
      final stillGranted = await NotificationService.areNotificationsEnabled();
      state = state.copyWith(isEnabled: stillGranted, isDeviceGranted: stillGranted);
      return stillGranted;
    }
  }

  Future<void> openSettings() async {
    await NotificationService.openNotificationSettings();
    // Volver a comprobar el estado tras regresar de ajustes
    final deviceGranted = await NotificationService.areNotificationsEnabled();
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_prefKey) ?? false;
    state = state.copyWith(
      isDeviceGranted: deviceGranted,
      isEnabled: saved && deviceGranted,
    );
  }

  Future<void> refreshStatus() async {
    final deviceGranted = await NotificationService.areNotificationsEnabled();
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_prefKey) ?? false;
    state = state.copyWith(
      isDeviceGranted: deviceGranted,
      isEnabled: saved && deviceGranted,
    );
  }
}

final notificationProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(() {
  return NotificationNotifier();
});

