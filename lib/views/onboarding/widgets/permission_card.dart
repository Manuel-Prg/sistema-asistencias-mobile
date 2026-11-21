import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';

class PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool granted;
  final bool loading;
  final String actionLabel;
  final Color accent;
  final bool isDark;
  final bool allowToggleWhenGranted;
  final VoidCallback onAction;

  const PermissionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.granted,
    required this.loading,
    required this.actionLabel,
    required this.accent,
    required this.isDark,
    required this.onAction,
    this.allowToggleWhenGranted = false,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = granted ? AppColors.statusOnTime : accent;

    return GlassSurface(
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      enableRefraction: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 21, color: badgeColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTheme.brandFont,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.mineralInk,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.8,
                    height: 1.35,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.slateMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (loading)
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2, color: accent),
            )
          else if (granted && !allowToggleWhenGranted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.statusOnTime.withValues(
                  alpha: isDark ? 0.22 : 0.14,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: AppColors.statusOnTime,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Activo',
                    style: TextStyle(
                      fontFamily: AppTheme.brandFont,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.statusOnTime,
                    ),
                  ),
                ],
              ),
            )
          else
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: granted
                    ? AppColors.statusOnTime.withValues(
                        alpha: isDark ? 0.22 : 0.14,
                      )
                    : accent,
                foregroundColor: granted
                    ? AppColors.statusOnTime
                    : Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const StadiumBorder(),
              ),
              child: Text(
                granted ? 'Activo' : actionLabel,
                style: TextStyle(
                  fontFamily: AppTheme.brandFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
