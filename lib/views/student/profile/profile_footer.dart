import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class ProfileFooter extends StatelessWidget {
  final VoidCallback onSignOut;

  const ProfileFooter({super.key, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const ValueKey('profile_sign_out_button'),
            onPressed: onSignOut,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.terracottaRule,
              side: const BorderSide(
                color: AppColors.terracottaRule,
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: Text(
              'CERRAR SESIÓN',
              style: TextStyle(
                fontFamily: AppTheme.brandFont,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            '${AppConstants.appName} · ${AppConstants.appVersion}',
            style: TextStyle(
              fontSize: 11,
              fontFamily: AppTheme.brandFont,
              color: isDark ? Colors.white38 : AppColors.slateMuted,
            ),
          ),
        ),
      ],
    );
  }
}

