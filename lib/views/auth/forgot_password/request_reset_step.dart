import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';

/// Paso 0 de recuperación: solicitar el envío de código o enlace al correo.
class RequestResetStep extends StatelessWidget {
  final TextEditingController emailController;
  final bool isLoading;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onSendEmail;
  final VoidCallback onAlreadyHaveCode;

  const RequestResetStep({
    super.key,
    required this.emailController,
    required this.isLoading,
    required this.isDark,
    required this.primaryColor,
    required this.onSendEmail,
    required this.onAlreadyHaveCode,
  });

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
                color: primaryColor.withValues(alpha: isDark ? 0.22 : 0.12),
                border: Border.all(
                  color: primaryColor.withValues(alpha: isDark ? 0.45 : 0.30),
                  width: 1.2,
                ),
              ),
              child: Icon(
                Icons.lock_reset_rounded,
                size: 38,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '¿Olvidaste tu contraseña?',
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
            'Ingresa tu correo institucional registrado y te enviaremos un código de seguridad para restablecer tu contraseña dentro de la aplicación.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontFamily: AppTheme.brandFont,
              color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Correo Electrónico',
              hintText: 'alumno@ejemplo.com',
              prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
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
            ),
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: isLoading ? null : onSendEmail,
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
                    'ENVIAR CÓDIGO AL CORREO',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: onAlreadyHaveCode,
              child: Text(
                '¿Ya tienes un código? Ingresar código',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
