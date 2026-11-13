import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../theme/app_theme.dart';

enum GlassToastType { info, success, warning, error }

/// Sistema de notificaciones / toasts flotantes con estética pura Liquid Glass:
/// completamente transparentes, con desenfoque de cristal y contorno reflectante.
class AppGlassToast {
  AppGlassToast._();

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    GlassToastType type = GlassToastType.info,
    Duration duration = const Duration(seconds: 3),
    IconData? customIcon,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        padding: EdgeInsets.zero,
        duration: duration,
        content: _GlassToastWidget(
          title: title,
          message: message,
          type: type,
          customIcon: customIcon,
        ),
      ),
    );
  }
}

class _GlassToastWidget extends StatelessWidget {
  final String? title;
  final String message;
  final GlassToastType type;
  final IconData? customIcon;

  const _GlassToastWidget({
    this.title,
    required this.message,
    required this.type,
    this.customIcon,
  });

  IconData get _icon {
    if (customIcon != null) return customIcon!;
    switch (type) {
      case GlassToastType.success:
        return Icons.check_circle_outline_rounded;
      case GlassToastType.warning:
        return Icons.warning_amber_rounded;
      case GlassToastType.error:
        return Icons.error_outline_rounded;
      case GlassToastType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : AppColors.mineralInk;
    final subtitleColor = isDark ? Colors.white.withValues(alpha: 0.75) : AppColors.slateMuted;
    final iconColor = isDark ? Colors.white.withValues(alpha: 0.90) : AppColors.mineralInk;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            // Fondo de cristal óptico ultra translúcido (máxima transparencia vítrea)
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.22),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.38),
                      Colors.white.withValues(alpha: 0.14),
                    ],
            ),
            // Contorno de cristal biselado y reflectante
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.30)
                  : Colors.white.withValues(alpha: 0.70),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.38 : 0.08),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(_icon, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null && title!.isNotEmpty) ...[
                      Text(
                        title!,
                        style: TextStyle(
                          fontFamily: AppTheme.brandFont,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      message,
                      style: TextStyle(
                        fontFamily: AppTheme.brandFont,
                        fontSize: 12,
                        color: subtitleColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
