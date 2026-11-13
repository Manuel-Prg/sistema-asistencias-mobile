import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  BiometricAuthService._();

  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static const _keyEmail = 'cua_saved_email';
  static const _keyPassword = 'cua_saved_password';
  static const _keyRemember = 'cua_remember_credentials';
  static const _keyBiometric = 'cua_biometric_enabled';

  /// Verifica si el hardware del dispositivo soporta biometría y tiene huella registrada
  static Future<bool> canUseBiometrics() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!isSupported || !canCheck) return false;

      final available = await _localAuth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Ejecuta la autenticación biométrica en el dispositivo
  static Future<bool> authenticate() async {
    try {
      final can = await canUseBiometrics();
      if (!can) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Confirma tu huella dactilar para acceder a tu cuenta',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Guarda las credenciales de forma encriptada
  static Future<void> saveCredentials(String email, String password) async {
    await _secureStorage.write(key: _keyEmail, value: email);
    await _secureStorage.write(key: _keyPassword, value: password);
    await _secureStorage.write(key: _keyRemember, value: 'true');
  }

  /// Obtiene las credenciales guardadas si existen
  static Future<Map<String, String>?> getSavedCredentials() async {
    final email = await _secureStorage.read(key: _keyEmail);
    final password = await _secureStorage.read(key: _keyPassword);

    if (email != null && password != null && email.isNotEmpty && password.isNotEmpty) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  /// Borra las credenciales encriptadas
  static Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _keyEmail);
    await _secureStorage.delete(key: _keyPassword);
    await _secureStorage.write(key: _keyRemember, value: 'false');
  }

  /// Indica si el usuario seleccionó "Recordar credenciales"
  static Future<bool> isRememberEnabled() async {
    final val = await _secureStorage.read(key: _keyRemember);
    return val == 'true';
  }

  /// Guarda el estado de la preferencia "Recordar credenciales"
  static Future<void> setRememberEnabled(bool enabled) async {
    await _secureStorage.write(key: _keyRemember, value: enabled ? 'true' : 'false');
    if (!enabled) {
      await clearCredentials();
    }
  }

  /// Indica si el usuario tiene activo el inicio con huella dactilar
  static Future<bool> isBiometricEnabled() async {
    final val = await _secureStorage.read(key: _keyBiometric);
    return val == 'true';
  }

  /// Activa o desactiva la opción de inicio con huella
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(key: _keyBiometric, value: enabled ? 'true' : 'false');
  }
}

