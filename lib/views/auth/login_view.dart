import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_toast.dart';
import '../../providers/auth_provider.dart';
import '../../providers/security_settings_provider.dart';
import 'forgot_password_view.dart';
import 'widgets/login_brand_header.dart';
import 'widgets/login_form_card.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _hasAutoFilled = false;
  bool _hasTriggeredAutoBiometrics = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      AppGlassToast.show(
        context,
        message: 'Por favor ingresa tu correo y contraseña.',
        type: GlassToastType.warning,
      );
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .signIn(email, password);
    if (success) {
      await ref
          .read(securitySettingsProvider.notifier)
          .onSuccessfulLogin(
            email: email,
            password: password,
            rememberMe: _rememberMe,
          );
    }
  }

  Future<void> _handleBiometricLogin() async {
    final security = ref.read(securitySettingsProvider);
    if (!security.hasSavedCredentials) {
      AppGlassToast.show(
        context,
        message:
            'No hay credenciales recordadas. Ingresa primero con tu contraseña.',
        type: GlassToastType.info,
      );
      return;
    }

    final ok = await ref
        .read(securitySettingsProvider.notifier)
        .authenticateWithBiometrics();
    if (!ok) return;

    final success = await ref
        .read(authProvider.notifier)
        .signIn(security.savedEmail!, security.savedPassword!);
    if (success) {
      await ref
          .read(securitySettingsProvider.notifier)
          .onSuccessfulLogin(
            email: security.savedEmail!,
            password: security.savedPassword!,
            rememberMe: true,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final securityState = ref.watch(securitySettingsProvider);

    if (securityState.isReady && !_hasAutoFilled) {
      _hasAutoFilled = true;
      if (securityState.isRememberEnabled) {
        _rememberMe = true;
        if (securityState.savedEmail != null) {
          _emailController.text = securityState.savedEmail!;
        }
        if (securityState.savedPassword != null) {
          _passwordController.text = securityState.savedPassword!;
        }
      }
    }

    if (securityState.isReady &&
        securityState.isBiometricEnabled &&
        securityState.hasSavedCredentials &&
        !authState.isManualSignOut &&
        !_hasTriggeredAutoBiometrics &&
        !authState.isLoading &&
        authState.errorMessage == null) {
      _hasTriggeredAutoBiometrics = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleBiometricLogin();
        }
      });
    }

    return GlassScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LoginBrandHeader(),
                const SizedBox(height: 24),
                LoginFormCard(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  obscurePassword: _obscurePassword,
                  rememberMe: _rememberMe,
                  isLoading: authState.isLoading,
                  showBiometricButton:
                      securityState.isBiometricEnabled &&
                      securityState.hasSavedCredentials,
                  errorMessage: authState.errorMessage,
                  isDark: isDark,
                  onToggleObscurePassword: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  onRememberMeChanged: (val) =>
                      setState(() => _rememberMe = val),
                  onClearError: () =>
                      ref.read(authProvider.notifier).clearError(),
                  onForgotPassword: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ForgotPasswordView(
                        initialEmail: _emailController.text.trim(),
                      ),
                    ),
                  ),
                  onLogin: _handleLogin,
                  onBiometricLogin: _handleBiometricLogin,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
