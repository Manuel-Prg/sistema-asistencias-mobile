import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';

class QuickResourceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconEmoji;
  final Color accentColor;
  final String url;
  final void Function(String url) onOpen;

  const QuickResourceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconEmoji,
    required this.accentColor,
    required this.url,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => onOpen(url),
      borderRadius: BorderRadius.circular(16),
      child: GlassSurface(
        padding: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(16),
        tintColor: accentColor.withValues(alpha: isDark ? 0.20 : 0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(iconEmoji, style: const TextStyle(fontSize: 22)),
                Icon(
                  Icons.arrow_outward_rounded,
                  size: 15,
                  color: isDark ? Colors.white : Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                fontFamily: AppTheme.brandFont,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                color:
                    isDark ? AppColors.darkTextSecondary : AppColors.slateMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

