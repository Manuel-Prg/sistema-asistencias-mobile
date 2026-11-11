import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../providers/color_theme_provider.dart';
import '../../../providers/glass_settings_provider.dart';
import '../../../providers/theme_provider.dart';

class ProfileThemeCard extends ConsumerStatefulWidget {
  const ProfileThemeCard({super.key});

  @override
  ConsumerState<ProfileThemeCard> createState() => _ProfileThemeCardState();
}

class _ProfileThemeCardState extends ConsumerState<ProfileThemeCard> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentThemeMode = ref.watch(themeModeProvider);
    final selectedPalette = ref.watch(colorThemeProvider);
    final glassSettings = ref.watch(glassSettingsProvider);

    final activeAccent = isDark
        ? (selectedPalette.isDefault
            ? AppColors.signalAqua
            : selectedPalette.accent)
        : selectedPalette.primary;

    return GlassSurface(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: activeAccent.withValues(alpha: isDark ? 0.25 : 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.palette_rounded,
                  color: isDark ? Colors.white : activeAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tema y Personalización',
                  style: TextStyle(
                    fontFamily: AppTheme.brandFont,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : activeAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ─── 1. Selector de Colores de Tema ─────────────────────────────────
          Text(
            'Colores',
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppTheme.brandFont,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : activeAccent,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: AppPalettes.all.map((palette) {
              final isSelected = palette.id == selectedPalette.id;
              return GestureDetector(
                onTap: () => ref
                    .read(colorThemeProvider.notifier)
                    .setColorTheme(palette),
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

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // ─── 2. Transparencia del vidrio ───────────────────────────────────
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

          // Mini reproductor / chip de cristal interactivo (Live Preview)
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
                    (selectedPalette.isDefault
                            ? AppColors.accentLimnological
                            : selectedPalette.accent)
                        .withValues(
                      alpha: (0.25 + (1.0 - glassSettings.transparency) * 0.40)
                          .clamp(0.20, 0.85),
                    ),
                  ],
                ),
                border: glassSettings.showBorders
                    ? Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
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
              max: 0.85,
              onChanged: (val) => ref
                  .read(glassSettingsProvider.notifier)
                  .setTransparency(val),
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
                  onTap: () => ref
                      .read(glassSettingsProvider.notifier)
                      .setTransparency(0.50),
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

          // ─── 3. Contornos de vidrio ─────────────────────────────────────────
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
                color: isDark ? AppColors.darkTextSecondary : AppColors.slateMuted,
                height: 1.35,
              ),
            ),
            value: glassSettings.showBorders,
            activeTrackColor: activeAccent,
            onChanged: (show) => ref
                .read(glassSettingsProvider.notifier)
                .setShowBorders(show),
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // ─── 4. Modo de Tema (Claro / Oscuro / Auto) ────────────────────────
          Text(
            'Modo de Tema',
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppTheme.brandFont,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : activeAccent,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ThemeChip(
                  label: 'Claro',
                  icon: Icons.light_mode_rounded,
                  isSelected: currentThemeMode == ThemeMode.light,
                  activeColor: activeAccent,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setTheme(ThemeMode.light),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ThemeChip(
                  label: 'Oscuro',
                  icon: Icons.dark_mode_rounded,
                  isSelected: currentThemeMode == ThemeMode.dark,
                  activeColor: activeAccent,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setTheme(ThemeMode.dark),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ThemeChip(
                  label: 'Auto',
                  icon: Icons.brightness_auto_rounded,
                  isSelected: currentThemeMode == ThemeMode.system,
                  activeColor: activeAccent,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setTheme(ThemeMode.system),
                ),
              ),
            ],
          ),
        ],
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
                  ? (isDark ? Colors.white : activeColor)
                  : (isDark ? Colors.white60 : AppColors.slateMuted),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : activeColor)
                    : (isDark ? Colors.white70 : AppColors.slateMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
