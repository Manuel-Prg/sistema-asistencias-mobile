import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_surface.dart';

class ResourcesEmptyState extends StatelessWidget {
  const ResourcesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassSurface(
      padding: const EdgeInsets.all(32),
      borderRadius: BorderRadius.circular(16),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.folder_open_rounded,
              size: 44,
              color: AppColors.signalAqua,
            ),
            const SizedBox(height: 10),
            Text(
              'No se encontraron recursos',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.mineralInk,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Prueba con otro término de búsqueda o cambia de categoría.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
