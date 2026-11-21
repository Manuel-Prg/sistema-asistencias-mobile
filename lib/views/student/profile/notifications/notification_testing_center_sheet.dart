import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/skippy_quotes.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../../../providers/notification_provider.dart';

class NotificationTestingCenterSheet {
  static void show(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return DefaultTabController(
          length: 3,
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
                        fontSize: 11.5,
                      ),
                      tabs: const [
                        Tab(text: 'Días 1-5'),
                        Tab(text: 'Fin de Mes'),
                        Tab(text: 'Retardo 15m'),
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
                        // TAB 3: Tolerancia de Entrada (15 min de retraso)
                        ListView(
                          shrinkWrap: true,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : Colors.black.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.35),
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
                                          color: const Color(0xFFEF4444)
                                              .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Tolerancia 15 min Superada',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFEF4444),
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
                                              .sendTestToleranceReminder(
                                                scheduledStart: '11:00 AM',
                                              );
                                          if (ctx.mounted) {
                                            ScaffoldMessenger.of(
                                              ctx,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  '🚨 Alerta de tolerancia (15 min) disparada. ¡Baja tu barra de notificaciones!',
                                                ),
                                                duration: Duration(
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
                                  const SizedBox(height: 8),
                                  Text(
                                    SkippyQuotes.getEntryToleranceTitle(0),
                                    style: TextStyle(
                                      fontFamily: AppTheme.brandFont,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.mineralInk,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    SkippyQuotes.getEntryToleranceBody(
                                      scheduledStart: '11:00 AM',
                                    ),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      height: 1.35,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.slateMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: themePrimary.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline_rounded,
                                          size: 15,
                                          color: themePrimary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Se activa automáticamente 15 min después de tu hora de entrada si aún no has registrado asistencia según tu horario.',
                                            style: TextStyle(
                                              fontSize: 11,
                                              height: 1.3,
                                              color: isDark
                                                  ? AppColors.darkTextSecondary
                                                  : AppColors.slateMuted,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
}
