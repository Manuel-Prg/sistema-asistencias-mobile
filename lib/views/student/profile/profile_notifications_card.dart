import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/skippy_quotes.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../providers/notification_provider.dart';
import '../../../services/report_notification_service.dart';

class ProfileNotificationsCard extends ConsumerWidget {
  const ProfileNotificationsCard({super.key});

  void _showNotificationTestingCenter(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return DefaultTabController(
          length: 2,
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 20),
            child: GlassSurface(
              borderRadius: BorderRadius.circular(24),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              tintColor: isDark ? const Color(0xFF141418) : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: themePrimary.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_active_rounded,
                          color: themePrimary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Centro de Pruebas: Nuty',
                              style: TextStyle(
                                fontFamily: AppTheme.brandFont,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.mineralInk,
                              ),
                            ),
                            Text(
                              'Prueba cómo suenan y se ven las notificaciones en tu teléfono',
                              style: TextStyle(
                                fontSize: 11.5,
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
                  const SizedBox(height: 14),
                  Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: themePrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: isDark
                          ? Colors.white70
                          : AppColors.slateMuted,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      tabs: const [
                        Tab(text: '1-5 Días (Llenado)'),
                        Tab(text: 'Fin de Mes (Subida)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 380),
                    child: TabBarView(
                      children: [
                        // TAB 1: Inicio de mes (5 días hábiles)
                        ListView.separated(
                          shrinkWrap: true,
                          itemCount: 5,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final dayNumber = i + 1;
                            final title = SkippyQuotes.getStartOfMonthTitle(
                              dayNumber,
                            );
                            final body = SkippyQuotes.getStartOfMonthBody(
                              dayNumber,
                            );

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : Colors.black.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: themePrimary.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: themePrimary.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Día Hábil $dayNumber de 5',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: themePrimary,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      FilledButton.tonalIcon(
                                        onPressed: () async {
                                          HapticFeedback.selectionClick();
                                          await ref
                                              .read(
                                                notificationProvider.notifier,
                                              )
                                              .sendSpecificTestReminder(
                                                isStartOfMonth: true,
                                                index: dayNumber,
                                              );
                                          if (ctx.mounted) {
                                            ScaffoldMessenger.of(
                                              ctx,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '🔔 Notificación del Día $dayNumber disparada. ¡Baja tu barra de notificaciones!',
                                                ),
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.send_rounded,
                                          size: 14,
                                        ),
                                        label: const Text(
                                          'Disparar',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                        style: FilledButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontFamily: AppTheme.brandFont,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.mineralInk,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    body,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      height: 1.3,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.slateMuted,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        // TAB 2: Fin de mes (3 días hábiles antes)
                        ListView.separated(
                          shrinkWrap: true,
                          itemCount: 3,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final daysLeft = 3 - i; // 3, 2, 1
                            final title = SkippyQuotes.getEndOfMonthTitle(
                              daysLeft,
                            );
                            final body = SkippyQuotes.getEndOfMonthBody(
                              daysLeft,
                            );

                            final label = daysLeft == 1
                                ? '¡Último día de entrega!'
                                : '$daysLeft días antes del cierre';

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : Colors.black.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B)
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF59E0B)
                                              .withValues(alpha: 0.18),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          label,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFF59E0B),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      FilledButton.tonalIcon(
                                        onPressed: () async {
                                          HapticFeedback.selectionClick();
                                          await ref
                                              .read(
                                                notificationProvider.notifier,
                                              )
                                              .sendSpecificTestReminder(
                                                isStartOfMonth: false,
                                                index: daysLeft,
                                              );
                                          if (ctx.mounted) {
                                            ScaffoldMessenger.of(
                                              ctx,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '🔔 Notificación de cierre ($label) disparada. ¡Baja tu barra de notificaciones!',
                                                ),
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.send_rounded,
                                          size: 14,
                                        ),
                                        label: const Text(
                                          'Disparar',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                        style: FilledButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontFamily: AppTheme.brandFont,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.mineralInk,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    body,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      height: 1.3,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.slateMuted,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showScheduledDatesSheet(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).colorScheme.primary;
    final reminders = ReportNotificationService.getUpcomingReminders();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: GlassSurface(
            borderRadius: BorderRadius.circular(24),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            tintColor: isDark ? const Color(0xFF141418) : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      color: themePrimary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Próximas Alertas Programadas',
                        style: TextStyle(
                          fontFamily: AppTheme.brandFont,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.mineralInk,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Calculado automáticamente según días hábiles en Villahermosa, Tabasco (sin fines de semana ni festivos).',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.slateMuted,
                  ),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 340),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: reminders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = reminders[index];
                      final dateFormatted = DateFormat(
                        "EEEE d 'de' MMMM, h:mm a",
                        'es_MX',
                      ).format(item.scheduledDate);

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: item.isStartOfMonth
                                ? themePrimary.withValues(alpha: 0.30)
                                : const Color(0xFFF59E0B)
                                      .withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    (item.isStartOfMonth
                                            ? themePrimary
                                            : const Color(0xFFF59E0B))
                                        .withValues(alpha: 0.15),
                              ),
                              child: Icon(
                                item.isStartOfMonth
                                    ? Icons.edit_note_rounded
                                    : Icons.upload_file_rounded,
                                size: 18,
                                color: item.isStartOfMonth
                                    ? themePrimary
                                    : const Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontFamily: AppTheme.brandFont,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.mineralInk,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    dateFormatted,
                                    style: TextStyle(
                                      fontSize: 11.5,
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
                    },
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Entendido'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
                      'Alertas de Nuty: Reportes',
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
                      'Recordatorios estilo Skippy para tus reportes',
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
                  onPressed: () => _showScheduledDatesSheet(context, ref),
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
                  onPressed: () => _showNotificationTestingCenter(context, ref),
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
