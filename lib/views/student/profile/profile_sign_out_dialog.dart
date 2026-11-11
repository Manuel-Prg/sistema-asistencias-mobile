import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/student_provider.dart';

class ProfileSignOutDialog {
  ProfileSignOutDialog._();

  static void show(
    BuildContext context,
    WidgetRef ref, {
    bool? hasActiveShift,
    VoidCallback? onConfirmSignOut,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeShift =
        hasActiveShift ?? ref.read(studentProvider).hasActiveSession;
    final confirmAction =
        onConfirmSignOut ?? () => ref.read(authProvider.notifier).signOut();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: GlassSurface(
          tintColor: isDark ? const Color(0xFF141418) : Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Antes de salir',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.brandFont,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                ),
              ),
              const SizedBox(height: 14),
              if (activeShift) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.amberTolerance.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.amberTolerance.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.amberTolerance,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Tienes un turno en curso. Si cierras sesión ahora, tu tiempo seguirá corriendo hasta que marques salida.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFFFEF3C7)
                                : const Color(0xFF78350F),
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Text(
                'Recuerda registrar las actividades del día en tu bitácora de servicio para mantener tu progreso al corriente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.brandFont,
                  fontSize: 13,
                  color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse('https://xurl.es/bitacora');
                  try {
                    await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                  } catch (_) {
                    await launchUrl(uri, mode: LaunchMode.platformDefault);
                  }
                },
                icon: Icon(
                  Icons.edit_note_rounded,
                  size: 18,
                  color: isDark ? Colors.white : Theme.of(ctx).colorScheme.primary,
                ),
                label: Text(
                  'Llenar Bitácora',
                  style: TextStyle(
                    color: isDark ? Colors.white : Theme.of(ctx).colorScheme.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      isDark ? Colors.white : Theme.of(ctx).colorScheme.primary,
                  iconColor:
                      isDark ? Colors.white : Theme.of(ctx).colorScheme.primary,
                  side: BorderSide(
                    color: (isDark ? Colors.white38 : Theme.of(ctx).colorScheme.primary)
                        .withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.stoneBorder,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontFamily: AppTheme.brandFont,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.mineralInk,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        confirmAction();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.terracottaRule,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
