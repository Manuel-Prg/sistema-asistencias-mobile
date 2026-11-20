import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_surface.dart';

/// Diapositiva 4: guía rápida de las 4 funciones principales de la app.
class OnboardingUsageStep extends StatelessWidget {
  final Color activeAccent;
  final bool isDark;

  const OnboardingUsageStep({
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
          const SizedBox(height: 4),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 124,
                height: 124,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      activeAccent.withValues(alpha: isDark ? 0.24 : 0.14),
                      activeAccent.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              Image.asset(
                'assets/images/nuty/nuty-pose-3.webp',
                height: 118,
                cacheHeight: 240,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Icon(
                  Icons.explore_rounded,
                  size: 42,
                  color: activeAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Cómo usar la app',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.brandFont,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Todo lo que necesitas para llevar tu servicio social o prácticas al día:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.brandFont,
              fontSize: 13,
              height: 1.4,
              color: subColor,
            ),
          ),
          const SizedBox(height: 18),
          _UsageGuideTile(
            icon: Icons.login_rounded,
            title: '1. Inicio · Registro de Asistencia',
            description:
                'Elige tu sala y turno para marcar entrada. Al terminar, marca tu salida y revisa tu avance de horas.',
            accent: activeAccent,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _UsageGuideTile(
            icon: Icons.calendar_month_rounded,
            title: '2. Horario · Días y Turnos',
            description:
                'Activa los días que asistes y guarda tu horario para evitar falsos retardos y recibir recordatorios.',
            accent: activeAccent,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _UsageGuideTile(
            icon: Icons.stars_rounded,
            title: '3. Eventos · Horas Dobles (2x)',
            description:
                'Registra tu participación en eventos especiales y talleres para acumular el doble de horas.',
            accent: activeAccent,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _UsageGuideTile(
            icon: Icons.menu_book_rounded,
            title: '4. Recursos y Perfil',
            description:
                'Consulta el calendario escolar en PDF, llena tu bitácora y ajusta tu huella o tema desde Perfil ⚙️.',
            accent: activeAccent,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _UsageGuideTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accent;
  final bool isDark;

  const _UsageGuideTile({
    required this.icon,
    required this.title,
    required this.description,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(12),
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
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.mineralInk,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.slateMuted,
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
