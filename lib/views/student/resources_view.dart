import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class ResourcesView extends StatelessWidget {
  const ResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recursos y Reglamentos'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner de bienvenida
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(18),
            ),
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
                        'Consulta las normas, tolerancias y directivas de la Casa Universitaria del Agua.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tarjetas de lineamientos
          _RegulationCard(
            icon: Icons.timer_outlined,
            iconColor: AppColors.amberTolerance,
            title: 'Regla de Puntualidad y Tolerancia',
            description:
                'Cuentas con 15 minutos de tolerancia con respecto al horario que definiste en "Tu Horario". Ingresar después de este lapso genera automáticamente un retardo en el sistema.',
          ),
          const SizedBox(height: 12),
          _RegulationCard(
            icon: Icons.gavel_rounded,
            iconColor: AppColors.terracottaRule,
            title: 'Conversión de Retardos e Infracciones',
            description:
                '3 retardos sin justificar se convierten en 1 falta injustificada. Acumular 3 faltas injustificadas (equivalente a 9 retardos) activa el protocolo de baja administrativa del programa.',
          ),
          const SizedBox(height: 12),
          _RegulationCard(
            icon: Icons.hourglass_top_rounded,
            iconColor: AppColors.accentLimnological,
            title: 'Límites de Horas y Salidas Tempranas',
            description:
                'El turno mínimo acreditable es de 3 horas. Si debes retirarte antes, es obligatorio declarar el motivo para auditoría. El tope máximo de horas acreditables por jornada es de 10 horas normales y 20 horas en eventos.',
          ),
          const SizedBox(height: 12),
          _RegulationCard(
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
          const SizedBox(height: 90),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.slateMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
