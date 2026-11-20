import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_surface.dart';

/// Diapositiva 1: Bienvenida y resumen rápido de novedades.
class OnboardingWelcomeStep extends StatelessWidget {
  final Color activeAccent;
  final bool isDark;

  const OnboardingWelcomeStep({
    super.key,
    required this.activeAccent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.mineralInk;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.slateMuted;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          const SizedBox(height: 6),
          // Mascota oficial del museo: Nuty dándote la bienvenida
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 152,
                height: 152,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      activeAccent.withValues(alpha: isDark ? 0.28 : 0.16),
                      activeAccent.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              Image.asset(
                'assets/images/nuty/nuty-pose-2.webp',
                height: 148,
                cacheHeight: 300,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Image.asset(
                  'assets/logo/logo_remove_background.png',
                  height: 92,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: activeAccent.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'NOVEDADES · v1.0.8',
              style: TextStyle(
                fontFamily: AppTheme.brandFont,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: activeAccent,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Bienvenido a\n${AppConstants.appName}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.brandFont,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.4,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Renovamos la experiencia para que sea más rápida, personalizable y cómoda en cualquier celular.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.brandFont,
              fontSize: 13.5,
              height: 1.45,
              color: subColor,
            ),
          ),
          const SizedBox(height: 24),
          _HighlightRow(
            icon: Icons.bolt_rounded,
            title: 'Hasta 3× más fluida',
            subtitle: 'Optimizaciones de GPU y nuevo modo Material 3 ligero.',
            accent: activeAccent,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _HighlightRow(
            icon: Icons.palette_rounded,
            title: 'Personalización total',
            subtitle: 'Cambia de estilo visual, colores, modo oscuro y fuente.',
            accent: activeAccent,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _HighlightRow(
            icon: Icons.verified_user_rounded,
            title: 'Todo tu servicio en orden',
            subtitle: 'Asistencias, horarios, eventos dobles y calendarios PDF.',
            accent: activeAccent,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _HighlightRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final bool isDark;

  const _HighlightRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enableRefraction: false,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isDark ? 0.22 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTheme.brandFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.mineralInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.slateMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
