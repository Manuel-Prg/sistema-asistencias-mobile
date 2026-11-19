import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/color_theme_provider.dart';
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
    final colorPalette = ref.read(colorThemeProvider);
    final bitacoraColor = isDark ? colorPalette.accent : colorPalette.primary;
    final activeShift =
        hasActiveShift ?? ref.read(studentProvider).hasActiveSession;
    final confirmAction =
        onConfirmSignOut ?? () => ref.read(authProvider.notifier).signOut();

    // Colores de texto de alta legibilidad sobre Liquid Glass
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.mineralInk;
    final bodyTextColor =
        isDark ? const Color(0xFFD6E3E9) : const Color(0xFF1B323C);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.50),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: GlassSurface(
          borderRadius: BorderRadius.circular(26),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
          enableRefraction: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Distintivo superior con ícono en cristal líquido
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.terracottaRule.withValues(
                    alpha: isDark ? 0.22 : 0.12,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.terracottaRule.withValues(
                      alpha: isDark ? 0.45 : 0.30,
                    ),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.logout_rounded,
                    color: AppColors.terracottaRule,
                    size: 26,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Título con tipografía nítida
              Text(
                '¿Cerrar Sesión?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.brandFont,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: titleColor,
                ),
              ),

              const SizedBox(height: 8),

              // Mensaje informativo con alto contraste
              Text(
                'Recuerda registrar las actividades del día en tu bitácora de servicio para mantener tu progreso al corriente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.brandFont,
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: bodyTextColor,
                ),
              ),

              const SizedBox(height: 16),

              // Advertencia de turno en curso si aplica
              if (activeShift) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.amberTolerance.withValues(
                      alpha: isDark ? 0.22 : 0.14,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.amberTolerance.withValues(
                        alpha: isDark ? 0.55 : 0.40,
                      ),
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

              // Botón Flat para Llenar Bitácora
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse('https://xurl.es/bitacora');
                    try {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (_) {
                      await launchUrl(uri, mode: LaunchMode.platformDefault);
                    }
                  },
                  icon: Icon(
                    Icons.edit_note_rounded,
                    size: 20,
                    color: bitacoraColor,
                  ),
                  label: Text(
                    'Llenar Bitácora del Día',
                    style: TextStyle(
                      fontFamily: AppTheme.brandFont,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: bitacoraColor,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    // Fondo flat sólido/opaco para que las letras contrasten nítidamente según el tema
                    backgroundColor: isDark
                        ? const Color(0xFF1E1E26)
                        : Colors.white,
                    side: BorderSide(
                      color: bitacoraColor.withValues(
                        alpha: isDark ? 0.60 : 0.45,
                      ),
                      width: 1.4,
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Fila de acciones (Cancelar y Cerrar Sesión)
              Row(
                children: [
                  // Cancelar
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.04),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.20)
                              : AppColors.stoneBorder,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontFamily: AppTheme.brandFont,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.mineralInk,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Cerrar Sesión
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        confirmAction();
                      },
                      icon: const Icon(Icons.logout_rounded, size: 17),
                      label: const Text('Cerrar Sesión'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.terracottaRule,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: TextStyle(
                          fontFamily: AppTheme.brandFont,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
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
