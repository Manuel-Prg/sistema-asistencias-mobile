import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_scaffold.dart';
import 'profile/profile_footer.dart';
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
              'Personalización visual, temas y seguridad de acceso',
              style: TextStyle(
                fontSize: 13,
                fontFamily: AppTheme.brandFont,
                color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
              ),
            ),
          ),

          // 1. Seguridad y Autenticación Biométrica
          const SettingsSecurityCard(),
          const SizedBox(height: 16),

          // 2. Tema, Colores y Estilos de Barra
          const ProfileThemeCard(),
          const SizedBox(height: 24),

          // 3. Cerrar sesión y versión
          ProfileFooter(
            onSignOut: () => ProfileSignOutDialog.show(context, ref),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
