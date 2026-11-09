import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NotificationService {
  static const MethodChannel _channel =
      MethodChannel('com.casauniversitariadelagua/notifications');

  /// Verifica si las notificaciones están habilitadas a nivel del sistema operativo.
  static Future<bool> areNotificationsEnabled() async {
    try {
      final bool? enabled =
          await _channel.invokeMethod<bool>('areNotificationsEnabled');
      return enabled ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error comprobando permisos de notificación: $e');
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Solicita el permiso en tiempo de ejecución (Android 13+ / POST_NOTIFICATIONS).
  static Future<bool> requestNotificationPermission() async {
    try {
      final bool? granted =
          await _channel.invokeMethod<bool>('requestNotificationPermission');
      return granted ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error solicitando permisos de notificación: $e');
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Abre la pantalla de configuración de notificaciones de la app en el dispositivo.
  static Future<void> openNotificationSettings() async {
    try {
      await _channel.invokeMethod('openNotificationSettings');
    } on PlatformException catch (e) {
      debugPrint('Error abriendo configuración de notificaciones: $e');
    }
  }
}
