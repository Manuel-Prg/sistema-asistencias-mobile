import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// Selector de tipografía: fuente oficial de la app (Archer) vs fuente del sistema.
class FontFamilySection extends StatelessWidget {
  final bool useSystemFont;
  final Color activeAccent;
  final bool isDark;
  final bool isMaterial3;
  final ValueChanged<bool> onUseSystemFontChanged;

  const FontFamilySection({
    super.key,
    required this.useSystemFont,
    required this.activeAccent,
    required this.isDark,
    this.isMaterial3 = false,
    required this.onUseSystemFontChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipografía',
          style: TextStyle(
            fontSize: 14,
            fontFamily: AppTheme.brandFont,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : activeAccent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Elige entre la fuente institucional de la app o la fuente nativa de tu dispositivo.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.slateMuted,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _FontOptionCard(
                label: 'Fuente de la app',
                subtitle: 'Archer',
                previewFontFamily: AppTheme.defaultBrandFont,
                isSelected: !useSystemFont,
                activeAccent: activeAccent,
                isDark: isDark,
                isMaterial3: isMaterial3,
                onTap: () => onUseSystemFontChanged(false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FontOptionCard(
                label: 'Sistema',
                subtitle: 'Nativa',
                previewFontFamily: null,
                isSelected: useSystemFont,
                activeAccent: activeAccent,
                isDark: isDark,
                isMaterial3: isMaterial3,
                onTap: () => onUseSystemFontChanged(true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FontOptionCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final String? previewFontFamily;
  final bool isSelected;
  final Color activeAccent;
  final bool isDark;
  final bool isMaterial3;
  final VoidCallback onTap;

  const _FontOptionCard({
    required this.label,
    required this.subtitle,
    required this.previewFontFamily,
    required this.isSelected,
    required this.activeAccent,
    required this.isDark,
    required this.isMaterial3,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bgColor = isMaterial3
        ? (isSelected ? scheme.primaryContainer : scheme.surfaceContainerHigh)
        : (isSelected
              ? activeAccent.withValues(alpha: 0.18)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFEFECE6)));

    final fgColor = isMaterial3
        ? (isSelected
              ? scheme.onPrimaryContainer
              : (isDark ? AppColors.darkTextPrimary : AppColors.mineralInk))
        : (isSelected
              ? activeAccent
              : (isDark ? Colors.white70 : AppColors.mineralInk));

    final subColor = isMaterial3
        ? (isSelected
              ? scheme.onPrimaryContainer.withValues(alpha: 0.8)
              : scheme.onSurfaceVariant)
        : (isDark ? AppColors.darkTextSecondary : AppColors.slateMuted);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isMaterial3 ? 16 : 14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(isMaterial3 ? 16 : 14),
          border: Border.all(
            color: isSelected ? activeAccent : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Column(
          children: [
            Text(
              'Aa',
              style: TextStyle(
                fontFamily: previewFontFamily,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: fgColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: previewFontFamily,
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: fgColor,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: previewFontFamily,
                fontSize: 10.5,
                color: subColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
