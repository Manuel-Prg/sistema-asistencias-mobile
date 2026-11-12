import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/update_service.dart';
import '../../common/update_dialog.dart';

class ProfileFooter extends StatefulWidget {
  final VoidCallback onSignOut;

  const ProfileFooter({super.key, required this.onSignOut});

  @override
  State<ProfileFooter> createState() => _ProfileFooterState();
}

class _ProfileFooterState extends State<ProfileFooter> {
  bool _isCheckingUpdate = false;

  Future<void> _handleCheckUpdate() async {
    HapticFeedback.lightImpact();
    setState(() => _isCheckingUpdate = true);

    try {
      final result = await UpdateService.checkForUpdates();
      if (!mounted) return;
      setState(() => _isCheckingUpdate = false);

      if (result.hasUpdate && result.updateInfo != null) {
        UpdateDialog.show(
          context,
          updateInfo: result.updateInfo!,
          currentVersion: result.currentVersion,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Estás en la versión más reciente (v${result.currentVersion})!',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _isCheckingUpdate = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const ValueKey('profile_sign_out_button'),
            onPressed: widget.onSignOut,
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
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _isCheckingUpdate ? null : _handleCheckUpdate,
          icon: _isCheckingUpdate
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: themePrimary,
                  ),
                )
              : Icon(
                  Icons.sync_rounded,
                  size: 16,
                  color: isDark ? Colors.white70 : AppColors.slateMuted,
                ),
          label: Text(
            _isCheckingUpdate
                ? 'Buscando actualizaciones...'
                : 'Buscar actualizaciones',
            style: TextStyle(
              fontSize: 12,
              fontFamily: AppTheme.brandFont,
              color: isDark ? Colors.white70 : AppColors.slateMuted,
            ),
          ),
        ),
        const SizedBox(height: 6),
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
