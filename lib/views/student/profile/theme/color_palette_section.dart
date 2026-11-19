import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../providers/color_theme_provider.dart';

/// Selector de paletas de color del tema de la aplicación.
class ColorPaletteSection extends StatelessWidget {
  final AppColorPalette selectedPalette;
  final Color activeAccent;
  final ValueChanged<AppColorPalette> onPaletteSelected;

  const ColorPaletteSection({
    super.key,
    required this.selectedPalette,
    required this.activeAccent,
    required this.onPaletteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Colores',
          style: TextStyle(
            fontSize: 14,
            fontFamily: AppTheme.brandFont,
            fontWeight: FontWeight.w700,
            color: activeAccent,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: AppPalettes.all.map((palette) {
            final isSelected = palette.id == selectedPalette.id;
            return GestureDetector(
              onTap: () => onPaletteSelected(palette),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: palette.previewColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: palette.previewColor.withValues(alpha: 0.45),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                  ],
                  border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : Colors.black.withValues(alpha: 0.12),
                    width: isSelected ? 2.5 : 1.2,
                  ),
                ),
                child: isSelected
                    ? const Center(
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: activeAccent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            selectedPalette.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: activeAccent,
            ),
          ),
        ),
      ],
    );
  }
}
