import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_surface.dart';

/// Tarjeta principal del formulario de inicio de sesión con soporte biométrico.
class LoginFormCard extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberMe;
  final bool isLoading;
  final bool showBiometricButton;
  final String? errorMessage;
  final bool isDark;
  final VoidCallback onToggleObscurePassword;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onClearError;
  final VoidCallback onForgotPassword;
  final VoidCallback onLogin;
  final VoidCallback onBiometricLogin;

  const LoginFormCard({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.isLoading,
    required this.showBiometricButton,
    required this.errorMessage,
    required this.isDark,
    required this.onToggleObscurePassword,
    required this.onRememberMeChanged,
    required this.onClearError,
    required this.onForgotPassword,
    required this.onLogin,
    required this.onBiometricLogin,
  });

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(22),
      enableRefraction: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (errorMessage != null) ...[
            GlassSurface(
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.all(12),
              tintColor: AppColors.terracottaRule.withValues(alpha: 0.16),
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
                      errorMessage!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.terracottaRule,
                        height: 1.3,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onClearError,
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
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo Electrónico',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: onToggleObscurePassword,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: InkWell(
                  onTap: () => onRememberMeChanged(!rememberMe),
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
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: rememberMe,
                            onChanged: (val) =>
                                onRememberMeChanged(val ?? false),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Recordar',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.mineralInk,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: TextButton(
                  onPressed: onForgotPassword,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.accentLimnological,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : onLogin,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
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
              if (showBiometricButton) ...[
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
                    onPressed: isLoading ? null : onBiometricLogin,
                    tooltip: 'Ingresar con huella dactilar',
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
