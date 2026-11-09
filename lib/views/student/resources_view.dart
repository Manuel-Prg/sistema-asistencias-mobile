import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_surface.dart';

class ResourcesView extends StatelessWidget {
  const ResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: const GlassAppBar(
        title: Text('Recursos y Reglamentos'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner de bienvenida
          GlassSurface(
            padding: const EdgeInsets.all(18),
            borderRadius: BorderRadius.circular(18),
            tintColor: AppColors.primary,
            child: const Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.signalAqua,
                  size: 32,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lineamientos Operativos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Reglas oficiales de asistencia, tolerancia y convivencia de la Casa Universitaria del Agua.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Tarjetas de Reglamentos con vidrio esmerilado
          const _RegulationCard(
            icon: Icons.timer_outlined,
            iconColor: AppColors.amberTolerance,
            title: 'Regla de Tolerancia y Retardos',
            description:
                'Tienes 15 minutos de tolerancia tras tu hora pactada de inicio. Entrar con más de 15 minutos se registra como retardo automático. Cada 3 retardos se transforman en 1 falta injustificada.',
          ),
          const SizedBox(height: 12),
          const _RegulationCard(
            icon: Icons.warning_rounded,
            iconColor: AppColors.terracottaRule,
            title: 'Límite de Faltas y Riesgo de Baja',
            description:
                'Acumular 3 faltas injustificadas (directas o derivadas de retardos) activa el protocolo de baja institucional de tu programa de servicio social o prácticas.',
          ),
          const SizedBox(height: 12),
          const _RegulationCard(
            icon: Icons.stars_rounded,
            iconColor: AppColors.signalAqua,
            title: 'Eventos Especiales y Horas Dobles',
            description:
                'Las actividades especiales en fin de semana, talleres comunitarios y eventos acreditados otorgan horas al doble (2x). Debes registrarlos seleccionando el turno correspondiente.',
          ),
          const SizedBox(height: 12),
          const _RegulationCard(
            icon: Icons.hourglass_bottom_rounded,
            iconColor: AppColors.accentLimnological,
            title: 'Límites de Horas y Salidas Tempranas',
            description:
                'El turno mínimo acreditable es de 3 horas. Si debes retirarte antes, es obligatorio declarar el motivo para auditoría. El tope máximo de horas acreditables por jornada es de 10 horas normales y 20 horas en eventos.',
          ),
          const SizedBox(height: 12),
          const _RegulationCard(
            icon: Icons.meeting_room_outlined,
            iconColor: AppColors.primary,
            title: 'Asignación de Salas',
            description:
                'Salas activas autorizadas en el recinto: Sala 1, Sala 2, Sala 2 y Galería, Sala 3, Sala 4, Sala 4 y 5, Todas y Site. Coordina con tu supervisor antes de cambiar de sala.',
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              '${AppConstants.appName} • ${AppConstants.appVersion}',
              style: TextStyle(fontSize: 12, color: AppColors.slateMuted),
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

class _RegulationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _RegulationCard({
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
                    color: isDark ? AppColors.darkTextPrimary : AppColors.mineralInk,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
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
