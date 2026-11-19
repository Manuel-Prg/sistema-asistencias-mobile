import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

import '../../providers/glass_settings_provider.dart';
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

class _GlassToastWidget extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final isMaterial3 = ref.watch(
      glassSettingsProvider.select((s) => s.isMaterial3),
    );

    final textColor = isDark ? Colors.white : AppColors.mineralInk;
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.75)
        : AppColors.slateMuted;
    final iconColor = isDark
        ? Colors.white.withValues(alpha: 0.90)
        : AppColors.mineralInk;

    final innerContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isMaterial3 ? scheme.surfaceContainerHigh : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isMaterial3
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
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
    );

    if (isMaterial3) {
      return innerContent;
    }

    return LiquidGlassLens(
      style: LiquidGlassStyle(
        shape: const LiquidGlassShape.continuousRoundedRectangle(
          cornerRadius: 20,
        ),
        refractionIndex: 1.28,
        refractionWidth: 28,
        magnification: 1.04,
        dispersion: 4.5,
        blur: 3.5,
        color: isDark
            ? const Color(0x0A000000)
            : const Color(0x0EFFFFFF),
        specular: const LiquidGlassLight.specular(thickness: 0),
        glow: const LiquidGlassLight.glow(thickness: 0),
      ),
      child: innerContent,
    );
  }
}
