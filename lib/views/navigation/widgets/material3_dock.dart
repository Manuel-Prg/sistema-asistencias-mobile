import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'nav_tab_item.dart';

/// Barra de navegación flotante estilo dock para Material 3.
/// Ofrece diseño flotante con curvatura pronunciada (pill dock),
/// indicador activo animado con tokens de Material You e interacción
/// de división fluida al hacer scroll vertical.
class Material3Dock extends StatelessWidget {
  final List<NavTabItem> tabs;
  final int currentIndex;
  final Animation<double> splitAnimation;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onUnsplit;

  const Material3Dock({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.splitAnimation,
    required this.onTabSelected,
    required this.onUnsplit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: SizedBox(
          height: 64,
          child: AnimatedBuilder(
            animation: splitAnimation,
            builder: (context, child) {
              final t = splitAnimation.value;

              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  if (t < 0.99)
                    Opacity(
                      opacity: (1.0 - t * 1.8).clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: 1.0 - t * 0.10,
                        child: IgnorePointer(
                          ignoring: t > 0.4,
                          child: _buildFullDock(context, isDark, colorScheme),
                        ),
                      ),
                    ),
                  if (t > 0.01)
                    Opacity(
                      opacity: ((t - 0.20) * 1.25).clamp(0.0, 1.0),
                      child: IgnorePointer(
                        ignoring: t < 0.6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Transform.translate(
                              offset: Offset((1.0 - t) * 44, 0),
                              child: Transform.scale(
                                scale: 0.65 + t * 0.35,
                                child: _buildActiveTabPod(isDark, colorScheme),
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(-(1.0 - t) * 44, 0),
                              child: Transform.scale(
                                scale: 0.65 + t * 0.35,
                                child: _buildSearchPod(isDark, colorScheme),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFullDock(
    BuildContext context,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.48)
                : Colors.black.withValues(alpha: 0.09),
            blurRadius: 22,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xE8171720)
                  : const Color(0xF2FFFFFF),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.08),
                width: 1.1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (index) {
                final tab = tabs[index];
                return _M3NavItem(
                  icon: tab.icon,
                  selectedIcon: tab.selectedIcon,
                  label: tab.label,
                  isSelected: currentIndex == index,
                  colorScheme: colorScheme,
                  isDark: isDark,
                  onTap: () => onTabSelected(index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabPod(bool isDark, ColorScheme colorScheme) {
    final currentTab = tabs[currentIndex];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onUnsplit();
      },
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.45)
                  : colorScheme.primary.withValues(alpha: 0.15),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(27),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xE8171720)
                    : const Color(0xF2FFFFFF),
                borderRadius: BorderRadius.circular(27),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.14)
                      : colorScheme.primary.withValues(alpha: 0.20),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? colorScheme.secondaryContainer
                        : colorScheme.primary.withValues(alpha: 0.14),
                  ),
                  child: Center(
                    child: Icon(
                      currentTab.selectedIcon,
                      size: 22,
                      color: isDark
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchPod(bool isDark, ColorScheme colorScheme) {
    final isRecursos = currentIndex == 3;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        if (!isRecursos) {
          onTabSelected(3);
        } else {
          onUnsplit();
        }
      },
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.45)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(27),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xE8171720)
                    : const Color(0xF2FFFFFF),
                borderRadius: BorderRadius.circular(27),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.search_rounded,
                  size: 22,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.mineralInk,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _M3NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final ColorScheme colorScheme;
  final bool isDark;
  final VoidCallback onTap;

  const _M3NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.colorScheme,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.slateMuted;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          splashColor: colorScheme.primary.withValues(alpha: 0.12),
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  width: isSelected ? 52 : 36,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? colorScheme.secondaryContainer
                            : colorScheme.primary.withValues(alpha: 0.16))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: AnimatedScale(
                      scale: isSelected ? 1.08 : 1.0,
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutBack,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          isSelected ? selectedIcon : icon,
                          key: ValueKey<bool>(isSelected),
                          size: 21,
                          color: isSelected
                              ? (isDark
                                  ? colorScheme.onSecondaryContainer
                                  : colorScheme.primary)
                              : inactiveColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontFamily: AppTheme.brandFont,
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected
                        ? (isDark
                            ? AppColors.darkTextPrimary
                            : colorScheme.primary)
                        : inactiveColor,
                    letterSpacing: isSelected ? -0.1 : 0.0,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
