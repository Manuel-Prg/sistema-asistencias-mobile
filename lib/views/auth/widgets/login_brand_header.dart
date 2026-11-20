import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_surface.dart';

/// Cabecera institucional de la pantalla de inicio de sesión.
class LoginBrandHeader extends StatelessWidget {
  const LoginBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
                'assets/logo/iconoFavicon.webp',
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
      ],
    );
  }
}
