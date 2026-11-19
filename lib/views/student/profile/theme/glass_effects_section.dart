import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../providers/color_theme_provider.dart';
import '../../../../providers/glass_settings_provider.dart';

/// Controles exclusivos del estilo Liquid Glass:
/// transparencia del vidrio, contornos decorativos y modo alto rendimiento.
class GlassEffectsSection extends StatelessWidget {
  final GlassSettings glassSettings;
  final AppColorPalette selectedPalette;
  final Color activeAccent;
  final bool isDark;
  final ValueChanged<double> onTransparencyChanged;
  final ValueChanged<bool> onShowBordersChanged;
  final ValueChanged<bool> onHighPerformanceChanged;

  const GlassEffectsSection({
    super.key,
    required this.glassSettings,
    required this.selectedPalette,
    required this.activeAccent,
    required this.isDark,
    required this.onTransparencyChanged,
    required this.onShowBordersChanged,
    required this.onHighPerformanceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transparencia del vidrio',
          style: TextStyle(
            fontSize: 14,
            fontFamily: AppTheme.brandFont,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : activeAccent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ajusta la transparencia en los menús y la navegación de la app. Se conserva el contraste del texto.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.slateMuted,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),

        // Chip interactivo de vista previa
        Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  activeAccent.withValues(
                    alpha: (0.35 + (1.0 - glassSettings.transparency) * 0.45)
                        .clamp(0.25, 0.90),
                  ),
                  selectedPalette.primary.withValues(
                    alpha: (0.50 + (1.0 - glassSettings.transparency) * 0.35)
                        .clamp(0.35, 0.95),
                  ),
                ],
              ),
              border: glassSettings.showBorders
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.45),
                      width: 1.2,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: activeAccent.withValues(alpha: 0.25),
                  blurRadius: 18,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.water_drop_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Casa del Agua • ${selectedPalette.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Slider de transparencia
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: activeAccent,
            thumbColor: activeAccent,
            overlayColor: activeAccent.withValues(alpha: 0.2),
            inactiveTrackColor: isDark
                ? Colors.white12
                : AppColors.stoneBorder.withValues(alpha: 0.5),
          ),
          child: Slider(
            value: glassSettings.transparency,
            min: 0.10,
            max: 0.95,
            onChanged: onTransparencyChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tintado sólido',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.slateMuted,
                ),
              ),
              GestureDetector(
                onTap: () => onTransparencyChanged(0.50),
                child: Text(
                  'Restablecer',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: activeAccent,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 12),

        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Contornos de vidrio',
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppTheme.brandFont,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : activeAccent,
            ),
          ),
          subtitle: Text(
            'Mostrar bordes decorativos alrededor del cristal. Si desactivas esta opción, se mantendrán el desenfoque y la refracción.',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.slateMuted,
              height: 1.35,
            ),
          ),
          value: glassSettings.showBorders,
          activeTrackColor: activeAccent,
          onChanged: onShowBordersChanged,
        ),

        const SizedBox(height: 10),
        const Divider(height: 1),
        const SizedBox(height: 10),

        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Modo Alto Rendimiento',
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppTheme.brandFont,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : activeAccent,
            ),
          ),
          subtitle: Text(
            'Desactiva desenfoques intensivos de GPU para máxima fluidez, menor consumo de batería y transiciones a 60-120 FPS.',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.slateMuted,
              height: 1.35,
            ),
          ),
          value: !glassSettings.enableBlur,
          activeTrackColor: activeAccent,
          onChanged: onHighPerformanceChanged,
        ),
      ],
    );
  }
}
