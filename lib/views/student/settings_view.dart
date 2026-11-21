import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_surface.dart';
import '../onboarding/onboarding_view.dart';
import 'profile/profile_footer.dart';
import 'profile/profile_notifications_card.dart';
import 'profile/profile_sign_out_dialog.dart';
import 'profile/profile_theme_card.dart';
import 'settings/settings_security_card.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GlassScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.darkTextPrimary : primaryColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Configuraciones',
          style: TextStyle(
            fontFamily: AppTheme.brandFont,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: isDark ? AppColors.darkTextPrimary : primaryColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 100),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 14),
            child: Text(
              'Notificaciones, seguridad de acceso y personalización visual',
              style: TextStyle(
                fontSize: 13,
                fontFamily: AppTheme.brandFont,
                color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
              ),
            ),
          ),

          // 1. Notificaciones y Alertas de Asistencia
          const ProfileNotificationsCard(),
          const SizedBox(height: 16),

          // 2. Seguridad y Autenticación Biométrica
          const SettingsSecurityCard(),
          const SizedBox(height: 16),

          // 3. Tema, Colores y Estilos de Barra
          const ProfileThemeCard(),
          const SizedBox(height: 16),

          // 3. Guía interactiva y Novedades
          GlassSurface(
            borderRadius: BorderRadius.circular(20),
            padding: EdgeInsets.zero,
            enableRefraction: false,
            child: ListTile(
              onTap: () => OnboardingView.show(context),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 6,
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: isDark ? 0.24 : 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              title: Text(
                'Guía y Novedades',
                style: TextStyle(
                  fontFamily: AppTheme.brandFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.mineralInk,
                ),
              ),
              subtitle: Text(
                'Repasa las funciones, temas y personalización de la app',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.slateMuted,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: isDark ? Colors.white54 : AppColors.slateMuted,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 4. Cerrar sesión y versión
          ProfileFooter(
            onSignOut: () => ProfileSignOutDialog.show(context, ref),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
