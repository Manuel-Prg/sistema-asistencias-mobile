import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_surface.dart';

class BitacoraBannerCard extends StatelessWidget {
  final void Function(String url) onOpen;

  const BitacoraBannerCard({super.key, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassSurface(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: isDark ? 0.35 : 0.12,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.assignment_turned_in_rounded,
                  color: isDark ? AppColors.signalAqua : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Necesitas llenar tu bitácora ahora?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.mineralInk,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'El sistema te la recordará automáticamente al registrar tu salida o cerrar sesión, pero también puedes acceder directamente.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFFC5D7DF)
                            : AppColors.slateMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => onOpen('https://xurl.es/bitacora'),
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text('Ir a Bitácora'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark
                  ? AppColors.signalAqua
                  : AppColors.primary,
              side: BorderSide(
                color: isDark ? AppColors.signalAqua : AppColors.primary,
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
