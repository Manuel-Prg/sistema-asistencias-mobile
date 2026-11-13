import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../core/widgets/glass_toast.dart';
import '../../../providers/color_theme_provider.dart';
import '../../../providers/security_settings_provider.dart';

class SettingsSecurityCard extends ConsumerWidget {
  const SettingsSecurityCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedPalette = ref.watch(colorThemeProvider);
    final securityState = ref.watch(securitySettingsProvider);

    final activeAccent = isDark
        ? (selectedPalette.isDefault
              ? AppColors.signalAqua
              : selectedPalette.accent)
        : selectedPalette.primary;

    return GlassSurface(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(22),
      enableRefraction: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: activeAccent.withValues(alpha: isDark ? 0.25 : 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: activeAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Seguridad y Acceso',
                  style: TextStyle(
                    fontFamily: AppTheme.brandFont,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: activeAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Recordar credenciales
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Recordar credenciales',
              style: TextStyle(
                fontFamily: AppTheme.brandFont,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : activeAccent,
              ),
            ),
            subtitle: Text(
              'Guarda tu correo y contraseña cifrados en este dispositivo para no tener que escribirlos en cada inicio.',
              style: TextStyle(
                fontSize: 11.5,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.slateMuted,
                height: 1.35,
              ),
            ),
            value: securityState.isRememberEnabled,
            activeTrackColor: activeAccent,
            onChanged: (val) async {
              await ref
                  .read(securitySettingsProvider.notifier)
                  .setRememberEnabled(val);
              if (context.mounted) {
                AppGlassToast.show(
                  context,
                  message: val
                      ? 'Credenciales recordadas para el próximo inicio.'
                      : 'Se han eliminado las credenciales guardadas.',
                  type: val ? GlassToastType.success : GlassToastType.info,
                );
              }
            },
          ),

          // 2. Acceso con Huella / Biometría
          if (securityState.isBiometricAvailable) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  Icon(
                    Icons.fingerprint_rounded,
                    size: 18,
                    color: activeAccent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Acceso con huella dactilar',
                    style: TextStyle(
                      fontFamily: AppTheme.brandFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : activeAccent,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                'Inicia sesión al instante tocando el sensor biométrico de tu teléfono.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.slateMuted,
                  height: 1.35,
                ),
              ),
              value: securityState.isBiometricEnabled,
              activeTrackColor: activeAccent,
              onChanged: (val) async {
                if (val && !securityState.isRememberEnabled) {
                  // Debe recordar credenciales primero
                  await ref
                      .read(securitySettingsProvider.notifier)
                      .setRememberEnabled(true);
                }
                final ok = await ref
                    .read(securitySettingsProvider.notifier)
                    .setBiometricEnabled(val);
                if (context.mounted) {
                  AppGlassToast.show(
                    context,
                    message: ok && val
                        ? 'Acceso con huella dactilar activado.'
                        : (val
                              ? 'No se pudo verificar la huella.'
                              : 'Huella dactilar desactivada.'),
                    type: ok && val
                        ? GlassToastType.success
                        : GlassToastType.warning,
                  );
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
