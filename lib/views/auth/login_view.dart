import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_surface.dart';
import '../../core/widgets/glass_toast.dart';
import '../../providers/auth_provider.dart';
import '../../providers/security_settings_provider.dart';
import 'forgot_password_view.dart';

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
        message: 'No hay credenciales recordadas. Ingresa primero con tu contraseña.',
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

    // Cargar credenciales guardadas si están disponibles
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

    // Disparar autenticación biométrica automática enseguida si está configurada
    // No disparar automáticamente si el usuario cerró sesión voluntariamente o si hay un error visible
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
                Center(
                  child: GlassSurface(
                    shape: BoxShape.circle,
                    width: 92,
                    height: 92,
                    padding: const EdgeInsets.all(14),
                    enableRefraction: true,
                    child: Image.asset(
                      'assets/logo/logo_remove_background.png',
                      cacheWidth: 180,
                      errorBuilder: (_, _, _) => Image.asset(
                        'assets/logo/iconoFavicon.png',
                        cacheWidth: 180,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.water_drop_rounded,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  AppConstants.appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Casa Universitaria del Agua • Portal Alumnos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentLimnological,
                  ),
                ),
                const SizedBox(height: 24),
                GlassSurface(
                  borderRadius: BorderRadius.circular(24),
                  padding: const EdgeInsets.all(22),
                  enableRefraction: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (authState.errorMessage != null) ...[
                        GlassSurface(
                          borderRadius: BorderRadius.circular(12),
                          padding: const EdgeInsets.all(12),
                          tintColor: AppColors.terracottaRule.withValues(
                            alpha: 0.16,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.terracottaRule,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  authState.errorMessage!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.terracottaRule,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => ref
                                    .read(authProvider.notifier)
                                    .clearError(),
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: AppColors.terracottaRule,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo Electrónico',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Fila: Recordar credenciales & ¿Olvidaste tu contraseña?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () =>
                                setState(() => _rememberMe = !_rememberMe),
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (val) => setState(
                                        () => _rememberMe = val ?? false,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Recordar datos',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.mineralInk,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordView(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.accentLimnological,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Botón Ingresar y botón Huella Dactilar
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : _handleLogin,
                              child: authState.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'INGRESAR AL SISTEMA',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                          if (securityState.isBiometricEnabled &&
                              securityState.hasSavedCredentials) ...[
                            const SizedBox(width: 10),
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: AppColors.signalAqua.withValues(
                                  alpha: isDark ? 0.20 : 0.12,
                                ),
                                border: Border.all(
                                  color: AppColors.signalAqua.withValues(
                                    alpha: isDark ? 0.45 : 0.35,
                                  ),
                                  width: 1.2,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.fingerprint_rounded,
                                  color: AppColors.signalAqua,
                                  size: 28,
                                ),
                                onPressed: authState.isLoading
                                    ? null
                                    : _handleBiometricLogin,
                                tooltip: 'Ingresar con huella dactilar',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
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
