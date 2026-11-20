import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';

/// Paso 1 de recuperación: capturar código OTP (o enlace verificado) y nueva contraseña.
class ConfirmResetStep extends StatelessWidget {
  final String email;
  final TextEditingController tokenController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool obscureNewPassword;
  final bool obscureConfirmPassword;
  final bool isLoading;
  final bool isRecovery;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onToggleNewPassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onConfirm;
  final VoidCallback onCancelRecovery;
  final VoidCallback onChangeEmail;
  final VoidCallback onResendCode;

  const ConfirmResetStep({
    super.key,
    required this.email,
    required this.tokenController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.obscureNewPassword,
    required this.obscureConfirmPassword,
    required this.isLoading,
    required this.isRecovery,
    required this.isDark,
    required this.primaryColor,
    required this.onToggleNewPassword,
    required this.onToggleConfirmPassword,
    required this.onConfirm,
    required this.onCancelRecovery,
    required this.onChangeEmail,
    required this.onResendCode,
  });

  InputDecoration _fieldDecoration({
    required String label,
    String? hint,
    required Widget prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.white.withValues(alpha: 0.65),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.signalAqua.withValues(
                  alpha: isDark ? 0.22 : 0.12,
                ),
                border: Border.all(
                  color: AppColors.signalAqua.withValues(
                    alpha: isDark ? 0.45 : 0.30,
                  ),
                  width: 1.2,
                ),
              ),
              child: Icon(
                isRecovery
                    ? Icons.lock_reset_rounded
                    : Icons.mark_email_read_rounded,
                size: 38,
                color: AppColors.signalAqua,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isRecovery ? 'Nueva Contraseña' : 'Ingresa el Código',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.brandFont,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : primaryColor,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isRecovery
                ? 'Accediste a través del enlace de tu correo. Ingresa tu nueva contraseña para completar el restablecimiento de tu cuenta.'
                : 'Revisa tu bandeja de entrada en $email. Introduce el código recibido y tu nueva contraseña.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontFamily: AppTheme.brandFont,
              color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          if (isRecovery) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.statusOnTime.withValues(
                  alpha: isDark ? 0.15 : 0.10,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.statusOnTime.withValues(
                    alpha: isDark ? 0.40 : 0.25,
                  ),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.statusOnTime,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Enlace de correo verificado correctamente',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFB5EAD7)
                            : const Color(0xFF0E6251),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            TextField(
              controller: tokenController,
              decoration: _fieldDecoration(
                label: 'Código de Recuperación',
                hint: 'Ingresa el código o token del correo',
                prefixIcon: const Icon(
                  Icons.pin_outlined,
                  color: AppColors.signalAqua,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          TextField(
            controller: newPasswordController,
            obscureText: obscureNewPassword,
            decoration: _fieldDecoration(
              label: 'Nueva Contraseña',
              hint: 'Mínimo 6 caracteres',
              prefixIcon: Icon(Icons.lock_outline_rounded, color: primaryColor),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureNewPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: isDark ? Colors.white60 : AppColors.slateMuted,
                ),
                onPressed: onToggleNewPassword,
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: confirmPasswordController,
            obscureText: obscureConfirmPassword,
            decoration: _fieldDecoration(
              label: 'Confirmar Nueva Contraseña',
              prefixIcon: Icon(Icons.lock_reset_rounded, color: primaryColor),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: isDark ? Colors.white60 : AppColors.slateMuted,
                ),
                onPressed: onToggleConfirmPassword,
              ),
            ),
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: isLoading ? null : onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'ESTABLECER NUEVA CONTRASEÑA',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(height: 14),
          if (isRecovery)
            Center(
              child: TextButton(
                onPressed: onCancelRecovery,
                child: Text(
                  'Cancelar y volver al inicio',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? Colors.white70 : AppColors.slateMuted,
                  ),
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: onChangeEmail,
                  child: Text(
                    'Cambiar correo',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? Colors.white70 : AppColors.slateMuted,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: isLoading ? null : onResendCode,
                  child: Text(
                    'Reenviar código',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
