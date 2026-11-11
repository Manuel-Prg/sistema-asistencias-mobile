import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';

class ProfilePersonalDataCard extends StatelessWidget {
  final TextEditingController nameController;
  final bool isSavingName;
  final VoidCallback onSaveName;

  const ProfilePersonalDataCard({
    super.key,
    required this.nameController,
    required this.isSavingName,
    required this.onSaveName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).colorScheme.primary;

    return GlassSurface(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.badge_rounded,
                color: isDark ? Colors.white : themePrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Datos Personales',
                style: TextStyle(
                  fontFamily: AppTheme.brandFont,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : themePrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Nombre completo o de guardián:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.slateMuted,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.edit_rounded,
                size: 18,
                color: isDark ? Colors.white70 : themePrimary,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.65),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSavingName ? null : onSaveName,
              icon: isSavingName
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded, size: 18, color: Colors.white),
              label: Text(
                isSavingName ? 'Guardando...' : 'Guardar Cambios',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: themePrimary,
                foregroundColor: Colors.white,
                iconColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

