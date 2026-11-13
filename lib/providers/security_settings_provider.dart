import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/biometric_auth_service.dart';

class SecuritySettingsState {
  final bool isBiometricAvailable;
  final bool isBiometricEnabled;
  final bool isRememberEnabled;
  final String? savedEmail;
  final String? savedPassword;
  final bool isReady;

  const SecuritySettingsState({
    this.isBiometricAvailable = false,
    this.isBiometricEnabled = false,
    this.isRememberEnabled = false,
    this.savedEmail,
    this.savedPassword,
    this.isReady = false,
  });

  bool get hasSavedCredentials =>
      savedEmail != null &&
      savedPassword != null &&
      savedEmail!.isNotEmpty &&
      savedPassword!.isNotEmpty;

  SecuritySettingsState copyWith({
    bool? isBiometricAvailable,
    bool? isBiometricEnabled,
    bool? isRememberEnabled,
    String? savedEmail,
    String? savedPassword,
    bool? isReady,
  }) {
    return SecuritySettingsState(
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isRememberEnabled: isRememberEnabled ?? this.isRememberEnabled,
      savedEmail: savedEmail ?? this.savedEmail,
      savedPassword: savedPassword ?? this.savedPassword,
      isReady: isReady ?? this.isReady,
    );
  }
}

final securitySettingsProvider =
    NotifierProvider<SecuritySettingsNotifier, SecuritySettingsState>(
      SecuritySettingsNotifier.new,
    );

class SecuritySettingsNotifier extends Notifier<SecuritySettingsState> {
  @override
  SecuritySettingsState build() {
    _init();
    return const SecuritySettingsState();
  }

  Future<void> _init() async {
    final available = await BiometricAuthService.canUseBiometrics();
    final biometricEnabled = await BiometricAuthService.isBiometricEnabled();
    final rememberEnabled = await BiometricAuthService.isRememberEnabled();
    final creds = await BiometricAuthService.getSavedCredentials();

    state = SecuritySettingsState(
      isBiometricAvailable: available,
      isBiometricEnabled: available && biometricEnabled,
      isRememberEnabled: rememberEnabled,
      savedEmail: creds?['email'],
      savedPassword: creds?['password'],
      isReady: true,
    );
  }

  Future<void> setRememberEnabled(bool enabled) async {
    await BiometricAuthService.setRememberEnabled(enabled);
    if (!enabled) {
      // Si se desactiva recordar credenciales, también se debe apagar la biometría
      await BiometricAuthService.setBiometricEnabled(false);
      state = state.copyWith(
        isRememberEnabled: false,
        isBiometricEnabled: false,
        savedEmail: null,
        savedPassword: null,
      );
    } else {
      state = state.copyWith(isRememberEnabled: true);
    }
  }

  Future<bool> setBiometricEnabled(bool enabled) async {
    if (enabled) {
      final authenticated = await BiometricAuthService.authenticate();
      if (!authenticated) return false;
      await BiometricAuthService.setBiometricEnabled(true);
      state = state.copyWith(isBiometricEnabled: true);
      return true;
    } else {
      await BiometricAuthService.setBiometricEnabled(false);
      state = state.copyWith(isBiometricEnabled: false);
      return true;
    }
  }

  Future<void> onSuccessfulLogin({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    if (rememberMe) {
      await BiometricAuthService.saveCredentials(email, password);
      state = state.copyWith(
        isRememberEnabled: true,
        savedEmail: email,
        savedPassword: password,
      );
    } else {
      await BiometricAuthService.clearCredentials();
      state = state.copyWith(
        isRememberEnabled: false,
        savedEmail: null,
        savedPassword: null,
      );
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    return await BiometricAuthService.authenticate();
  }
}
