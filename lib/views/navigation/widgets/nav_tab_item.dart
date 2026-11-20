import 'package:flutter/material.dart';

/// Modelo de pestaña para la barra de navegación principal.
class NavTabItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const NavTabItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// Ícono animado con rebote suave para la barra de navegación Material 3.
class M3AnimatedNavIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const M3AnimatedNavIcon({
    super.key,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSelected) {
      return Icon(icon);
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey<IconData>(icon),
      tween: Tween<double>(begin: 0.78, end: 1.12),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Icon(icon),
    );
  }
}
