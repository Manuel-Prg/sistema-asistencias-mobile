import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../models/profile.dart';
import '../services/supabase_service.dart';

class AppAuthState {
  final bool isLoading;
  final User? user;
  final Profile? profile;
  final String? errorMessage;
  final bool isInitialCheckDone;

  AppAuthState({
    this.isLoading = false,
    this.user,
    this.profile,
    this.errorMessage,
    this.isInitialCheckDone = false,
  });

  bool get isAuthenticated =>
      user != null && profile != null && profile!.isStudent;

  AppAuthState copyWith({
    bool? isLoading,
    User? user,
    Profile? profile,
    String? errorMessage,
    bool? isInitialCheckDone,
    bool clearError = false,
  }) {
    return AppAuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isInitialCheckDone: isInitialCheckDone ?? this.isInitialCheckDone,
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AppAuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AppAuthState> {
  StreamSubscription? _authSubscription;

  @override
  AppAuthState build() {
    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    // Escuchar cambios de autenticación en el siguiente microtask para garantizar
    // que el Notifier ya esté completamente montado
    Future.microtask(() {
      _authSubscription = SupabaseService.client.auth.onAuthStateChange.listen((
        data,
      ) async {
        final session = data.session;
        if (session != null) {
          if (state.user?.id != session.user.id || state.profile == null) {
            await _loadUserProfile(session.user);
          }
        } else {
          state = AppAuthState(isInitialCheckDone: true);
        }
      });
    });

    final currentSession = SupabaseService.client.auth.currentSession;
    if (currentSession != null) {
      Future.microtask(() => _loadUserProfile(currentSession.user));
      return AppAuthState(
        isLoading: true,
        user: currentSession.user,
        isInitialCheckDone: false,
      );
    }

    // Si no hay sesión iniciada, pasar directo a la pantalla de login
    return AppAuthState(isLoading: false, isInitialCheckDone: true);
  }

  Future<void> _loadUserProfile(User user) async {
    try {
      // 1. Refrescar sesión proactivamente si está expirada
      final session = SupabaseService.client.auth.currentSession;
      if (session != null && session.isExpired) {
        try {
          await SupabaseService.client.auth.refreshSession();
        } catch (_) {
          await SupabaseService.signOut();
          state = AppAuthState(
            isInitialCheckDone: true,
            errorMessage: 'Tu sesión ha expirado por inactividad. Por favor, ingresa nuevamente.',
          );
          return;
        }
      }

      var profile = await SupabaseService.getProfile(user.id);

      // Si fue nulo, dar un breve margen por reconexión de sockets del sistema tras reposo
      if (profile == null) {
        await Future.delayed(const Duration(milliseconds: 650));
        try {
          await SupabaseService.client.auth.refreshSession();
        } catch (_) {}
        profile = await SupabaseService.getProfile(user.id);
      }

      if (profile == null) {
        // Si el usuario ya tenía sesión activa anteriormente, fue una expiración de token
        final hadActiveSession = state.profile != null;
        if (hadActiveSession) {
          await SupabaseService.signOut();
          state = AppAuthState(
            isInitialCheckDone: true,
            errorMessage: 'Tu sesión ha expirado. Por favor, ingresa nuevamente.',
          );
          return;
        }

        await Future.delayed(const Duration(milliseconds: 650));
        try {
          await SupabaseService.client.auth.refreshSession();
        } catch (_) {}
        profile = await SupabaseService.getProfile(user.id);
      }

      if (profile == null) {
        // Si el usuario ya tenía sesión activa anteriormente, fue una expiración de token
        final hadActiveSession = state.profile != null;
        if (hadActiveSession) {
          await SupabaseService.signOut();
          state = AppAuthState(
            isInitialCheckDone: true,
            errorMessage:
                'Tu sesión ha expirado. Por favor, ingresa nuevamente.',
          );
          return;
        }

        state = state.copyWith(
          isLoading: false,
          user: user,
          profile: null,
          isInitialCheckDone: true,
          errorMessage:
              'No se encontró perfil de estudiante asociado a esta cuenta.',
        );
        return;
      }

      if (!profile.isStudent) {
        await SupabaseService.signOut();
        state = AppAuthState(
          isInitialCheckDone: true,
          errorMessage: 'El rol de Supervisor solo está disponible en la versión Web. Accede desde tu navegador.',
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        user: user,
        profile: profile,
        isInitialCheckDone: true,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isInitialCheckDone: true,
        errorMessage: 'Error de conexión con el servidor. Revisa tu conexión a internet.',
      );
    }
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await SupabaseService.signInWithEmail(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No fue posible iniciar sesión.',
        );
        return false;
      }

      final profile = await SupabaseService.getProfile(user.id);
      if (profile == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              'Tu cuenta no tiene un perfil configurado en el sistema.',
        );
        return false;
      }

      if (!profile.isStudent) {
        await SupabaseService.signOut();
        state = state.copyWith(
          isLoading: false,
          user: null,
          profile: null,
          errorMessage: 'El rol de Supervisor se gestiona exclusivamente en la plataforma Web.',
        );
        return false;
      }

      state = state.copyWith(
        isLoading: false,
        user: user,
        profile: profile,
        clearError: true,
      );
      return true;
    } on AuthException catch (e) {
      String msg = e.message;
      if (msg.contains('Invalid login credentials')) {
        msg = 'Correo o contraseña incorrectos.';
      } else if (msg.contains('Email not confirmed')) {
        msg = 'Tu correo aún no ha sido confirmado. Revisa tu bandeja de entrada.';
      } else if (msg.contains('SocketException') ||
          msg.contains('Failed host lookup') ||
          msg.contains('ClientException') ||
          msg.contains('Network') ||
          msg.contains('connection') ||
          msg.contains('errno = 7')) {
        msg = 'Sin conexión a internet: No fue posible conectar con el servidor. Verifica que tu teléfono tenga Wi-Fi o datos móviles activos.';
      }
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sin conexión a internet: Verifica que tu teléfono tenga acceso a internet.',
      );
      return false;
    }
  }

  Future<bool> updateProfileName(String newName) async {
    final current = state.profile;
    if (current == null) return false;
    try {
      await SupabaseService.updateProfile(
        userId: current.id,
        fullName: newName.trim(),
        realName: newName.trim(),
        guardianName: newName.trim(),
      );
      final updated = await SupabaseService.getProfile(current.id);
      if (updated != null) {
        state = state.copyWith(profile: updated);
      }
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al actualizar nombre: $e');
      return false;
    }
  }

  Future<bool> updateProfileAvatar(String? avatarUrl) async {
    final current = state.profile;
    if (current == null) return false;
    try {
      await SupabaseService.updateProfile(
        userId: current.id,
        fullName: current.fullName,
        realName: current.realName,
        guardianName: current.guardianName,
        avatarUrl: avatarUrl,
        updateAvatar: true,
      );
      final updated = await SupabaseService.getProfile(current.id);
      if (updated != null) {
        state = state.copyWith(profile: updated);
      }
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al actualizar foto: $e');
      return false;
    }
  }

  Future<bool> uploadAndSetProfileAvatar(Uint8List bytes) async {
    final current = state.profile;
    if (current == null) return false;
    try {
      final publicUrl = await SupabaseService.uploadProfileAvatar(
        userId: current.id,
        bytes: bytes,
        currentAvatarUrl: current.avatarUrl,
      );
      return await updateProfileAvatar(publicUrl);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al subir foto: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await SupabaseService.signOut();
    state = AppAuthState(isInitialCheckDone: true);
  }

  Future<bool> resetPassword(String email) async {
    try {
      await SupabaseService.resetPassword(email);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error al enviar correo de recuperación: $e',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
