import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';

/// Paso 2 de recuperación: confirmación visual de contraseña actualizada.
class ResetSuccessStep extends StatelessWidget {
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onReturnToLogin;

  const ResetSuccessStep({
    super.key,
    required this.isDark,
    required this.primaryColor,
    required this.onReturnToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      padding: const EdgeInsets.all(28),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.statusOnTime.withValues(
                  alpha: isDark ? 0.22 : 0.14,
                ),
                border: Border.all(
                  color: AppColors.statusOnTime.withValues(
                    alpha: isDark ? 0.55 : 0.40,
                  ),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 46,
                color: AppColors.statusOnTime,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            '¡Contraseña Actualizada!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.brandFont,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.statusOnTime,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tu nueva contraseña ha sido configurada correctamente en el sistema. Ya puedes iniciar sesión con tus nuevas credenciales.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontFamily: AppTheme.brandFont,
              color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 26),
          ElevatedButton(
            onPressed: onReturnToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'INICIAR SESIÓN',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
