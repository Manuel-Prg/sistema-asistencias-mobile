import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_surface.dart';

class RegulationsSection extends StatelessWidget {
  const RegulationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        leading: const Icon(
          Icons.gavel_rounded,
          color: AppColors.accentLimnological,
        ),
        title: Text(
          'Ver Reglamentos y Lineamientos',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.mineralInk,
          ),
        ),
        children: const [
          SizedBox(height: 8),
          RegulationCard(
            icon: Icons.timer_outlined,
            iconColor: AppColors.amberTolerance,
            title: 'Regla de Tolerancia y Retardos',
            description: 'Tienes 15 minutos de tolerancia tras tu hora pactada de inicio. Entrar con más de 15 minutos se registra como retardo automático. Cada 3 retardos se transforman en 1 falta injustificada.',
          ),
          SizedBox(height: 10),
          RegulationCard(
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.terracottaRule,
            title: 'Límite de Faltas y Riesgo de Baja',
            description: 'Acumular 3 faltas injustificadas (directas o derivadas de retardos) activa el protocolo de baja institucional de tu programa de servicio social o prácticas.',
          ),
          SizedBox(height: 10),
          RegulationCard(
            icon: Icons.stars_rounded,
            iconColor: Color(0xFFC26D2D),
            title: 'Eventos Especiales y Horas Dobles',
            description: 'Las actividades especiales en fin de semana, talleres comunitarios y eventos acreditados otorgan horas al doble (2x). Debes registrarlos seleccionando el turno correspondiente.',
          ),
          SizedBox(height: 10),
          RegulationCard(
            icon: Icons.hourglass_bottom_rounded,
            iconColor: AppColors.accentLimnological,
            title: 'Límites de Horas y Salidas Tempranas',
            description: 'El turno mínimo acreditable es de 3 horas. Si debes retirarte antes, es obligatorio declarar el motivo para auditoría. El tope máximo de horas acreditables por jornada es de 10 horas normales y 20 horas en eventos.',
          ),
        ],
      ),
    );
  }
}

class RegulationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const RegulationCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassSurface(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.22 : 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.mineralInk,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFFC5D7DF)
                        : AppColors.slateMuted,
                    height: 1.45,
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
