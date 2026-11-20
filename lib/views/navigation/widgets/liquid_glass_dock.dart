import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'nav_tab_item.dart';

/// Barra inferior flotante estilo Liquid Glass con animación de división
/// en dos islas (pestaña activa + búsqueda rápida) al hacer scroll.
class LiquidGlassDock extends StatelessWidget {
  final List<NavTabItem> tabs;
  final int currentIndex;
  final Animation<double> splitAnimation;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onUnsplit;

  const LiquidGlassDock({
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
    final activeColor = Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: SizedBox(
          height: 58,
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
                          child: _buildFullDock(isDark),
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
                                child: _buildActiveTabPod(activeColor, isDark),
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(-(1.0 - t) * 44, 0),
                              child: Transform.scale(
                                scale: 0.65 + t * 0.35,
                                child: _buildSearchPod(isDark),
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

  Widget _buildFullDock(bool isDark) {
    return RepaintBoundary(
      child: SizedBox(
        height: 58,
        child: LiquidGlassLens(
          style: LiquidGlassStyle(
            shape: const LiquidGlassShape.continuousRoundedRectangle(
              cornerRadius: 29,
            ),
            refractionIndex: 1.28,
            refractionWidth: 28,
            magnification: 1.04,
            dispersion: 4.5,
            blur: 3.5,
            color: isDark ? const Color(0x0A000000) : const Color(0x0EFFFFFF),
            specular: const LiquidGlassLight.specular(thickness: 0),
            glow: const LiquidGlassLight.glow(thickness: 0),
          ),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(29)),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (index) {
                final tab = tabs[index];
                return _GlassNavItem(
                  icon: tab.icon,
                  selectedIcon: tab.selectedIcon,
                  label: tab.label,
                  isSelected: currentIndex == index,
                  onTap: () => onTabSelected(index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabPod(Color activeColor, bool isDark) {
    final currentTab = tabs[currentIndex];

    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          onUnsplit();
        },
        child: Tooltip(
          message: currentTab.label,
          child: SizedBox(
            width: 54,
            height: 54,
            child: LiquidGlassLens(
              style: LiquidGlassStyle(
                shape: const LiquidGlassShape.continuousRoundedRectangle(
                  cornerRadius: 27,
                ),
                refractionIndex: 1.28,
                refractionWidth: 20,
                magnification: 1.05,
                dispersion: 4.5,
                blur: 3.5,
                color: isDark
                    ? const Color(0x0E000000)
                    : const Color(0x12FFFFFF),
                specular: const LiquidGlassLight.specular(thickness: 0),
                glow: const LiquidGlassLight.glow(thickness: 0),
              ),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor.withValues(alpha: isDark ? 0.22 : 0.12),
                ),
                child: Center(
                  child: Icon(
                    currentTab.selectedIcon,
                    size: 24,
                    color: activeColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchPod(bool isDark) {
    final isRecursos = currentIndex == 3;

    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          if (!isRecursos) {
            onTabSelected(3);
          } else {
            onUnsplit();
          }
        },
        child: Tooltip(
          message: 'Buscar recursos',
          child: SizedBox(
            width: 54,
            height: 54,
            child: LiquidGlassLens(
              style: LiquidGlassStyle(
                shape: const LiquidGlassShape.continuousRoundedRectangle(
                  cornerRadius: 27,
                ),
                refractionIndex: 1.28,
                refractionWidth: 20,
                magnification: 1.05,
                dispersion: 4.5,
                blur: 3.5,
                color: isDark
                    ? const Color(0x0E000000)
                    : const Color(0x12FFFFFF),
                specular: const LiquidGlassLight.specular(thickness: 0),
                glow: const LiquidGlassLight.glow(thickness: 0),
              ),
              child: Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Center(
                  child: Icon(
                    Icons.search_rounded,
                    size: 23,
                    color: isDark ? Colors.white : AppColors.mineralInk,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassNavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GlassNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = Theme.of(context).colorScheme.primary;
    final inactiveColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.slateMuted;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                      ? Colors.white.withValues(alpha: 0.14)
                      : activeColor.withValues(alpha: 0.14))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutBack,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isSelected ? selectedIcon : icon,
                    key: ValueKey<bool>(isSelected),
                    size: 22,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: AppTheme.brandFont,
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? activeColor : inactiveColor,
                  letterSpacing: 0.1,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
