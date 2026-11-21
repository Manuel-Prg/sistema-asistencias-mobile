import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../providers/notification_provider.dart';
import 'notifications/notification_testing_center_sheet.dart';
import 'notifications/scheduled_dates_sheet.dart';

class ProfileNotificationsCard extends ConsumerWidget {
  const ProfileNotificationsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).colorScheme.primary;

    return GlassSurface(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(20),
      tintColor: isDark ? const Color(0xFF141418) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: themePrimary.withValues(alpha: isDark ? 0.22 : 0.12),
                  border: Border.all(
                    color: themePrimary.withValues(alpha: isDark ? 0.40 : 0.25),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.notifications_active_rounded,
                    size: 22,
                    color: themePrimary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alertas de Nuty: Asistencia y Reportes',
                      style: TextStyle(
                        fontFamily: AppTheme.brandFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.mineralInk,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tolerancia de 15 min y recordatorios de reportes',
                      style: TextStyle(
                        fontFamily: AppTheme.brandFont,
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.slateMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: notificationState.isEnabled,
                activeTrackColor: themePrimary,
                onChanged: (val) async {
                  HapticFeedback.lightImpact();
                  await ref
                      .read(notificationProvider.notifier)
                      .setNotificationsEnabled(val);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⏰ ', style: TextStyle(fontSize: 13)),
                    Expanded(
                      child: Text(
                        'Tolerancia de Entrada (+15 min): Aviso automático si no has checado entrada 15 minutos después de tu hora de inicio según tu horario pactado.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.slateMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📝 ', style: TextStyle(fontSize: 13)),
                    Expanded(
                      child: Text(
                        'Primeros 5 días hábiles (09:00 AM): Llenado del reporte mensual (sin contar fines de semana ni festivos).',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.slateMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📤 ', style: TextStyle(fontSize: 13)),
                    Expanded(
                      child: Text(
                        'Últimos 3 días hábiles (10:00 AM): Subida de tu reporte firmado a la plataforma de la universidad.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.slateMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 13,
                      color: themePrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Horario oficial: Villahermosa, Tabasco (UTC-6)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: themePrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ScheduledDatesSheet.show(context, ref),
                  icon: const Icon(Icons.calendar_month_rounded, size: 16),
                  label: const Text('Ver fechas'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () =>
                      NotificationTestingCenterSheet.show(context, ref),
                  icon: const Icon(Icons.science_rounded, size: 16),
                  label: const Text('Probar alertas'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
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
