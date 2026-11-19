import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// Selector de modo de tema (Claro / Oscuro / Automático).
/// En Material 3 usa una cápsula segmentada tonal; en Liquid Glass usa chips individuales.
class ThemeModeSection extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final Color activeAccent;
  final bool isDark;
  final bool isMaterial3;
  final ValueChanged<ThemeMode> onThemeChanged;

  const ThemeModeSection({
    super.key,
    required this.currentThemeMode,
    required this.activeAccent,
    required this.isDark,
    this.isMaterial3 = false,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tema',
          style: TextStyle(
            fontSize: 14,
            fontFamily: AppTheme.brandFont,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : activeAccent,
          ),
        ),
        const SizedBox(height: 10),
        if (isMaterial3)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                _M3SegmentedPill(
                  label: 'Sistema',
                  icon: Icons.brightness_auto_rounded,
                  isSelected: currentThemeMode == ThemeMode.system,
                  onTap: () => onThemeChanged(ThemeMode.system),
                ),
                _M3SegmentedPill(
                  label: 'Claro',
                  icon: Icons.light_mode_rounded,
                  isSelected: currentThemeMode == ThemeMode.light,
                  onTap: () => onThemeChanged(ThemeMode.light),
                ),
                _M3SegmentedPill(
                  label: 'Oscuro',
                  icon: Icons.dark_mode_rounded,
                  isSelected: currentThemeMode == ThemeMode.dark,
                  onTap: () => onThemeChanged(ThemeMode.dark),
                ),
              ],
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: _ThemeChip(
                  label: 'Claro',
                  icon: Icons.light_mode_rounded,
                  isSelected: currentThemeMode == ThemeMode.light,
                  activeColor: activeAccent,
                  onTap: () => onThemeChanged(ThemeMode.light),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ThemeChip(
                  label: 'Oscuro',
                  icon: Icons.dark_mode_rounded,
                  isSelected: currentThemeMode == ThemeMode.dark,
                  activeColor: activeAccent,
                  onTap: () => onThemeChanged(ThemeMode.dark),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ThemeChip(
                  label: 'Auto',
                  icon: Icons.brightness_auto_rounded,
                  isSelected: currentThemeMode == ThemeMode.system,
                  activeColor: activeAccent,
                  onTap: () => onThemeChanged(ThemeMode.system),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _M3SegmentedPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _M3SegmentedPill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = isSelected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? scheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.brandFont,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.18)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFEFECE6)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? activeColor
                  : (isDark ? Colors.white60 : AppColors.slateMuted),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? activeColor
                    : (isDark ? Colors.white70 : AppColors.slateMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
