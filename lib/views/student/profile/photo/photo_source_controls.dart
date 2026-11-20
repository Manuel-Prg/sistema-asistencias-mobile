import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Controles para elegir la foto desde galería, cámara o enlace web directo.
class PhotoSourceControls extends StatelessWidget {
  final TextEditingController urlController;
  final bool isSaving;
  final bool showUrlField;
  final bool isDark;
  final Color themePrimary;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final VoidCallback onToggleUrlField;
  final VoidCallback onPasteUrl;

  const PhotoSourceControls({
    super.key,
    required this.urlController,
    required this.isSaving,
    required this.showUrlField,
    required this.isDark,
    required this.themePrimary,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onToggleUrlField,
    required this.onPasteUrl,
  });

  @override
  Widget build(BuildContext context) {
    final currentText = urlController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : onPickGallery,
                icon: const Icon(
                  Icons.photo_library_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'Galería',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themePrimary,
                  foregroundColor: Colors.white,
                  iconColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isSaving ? null : onPickCamera,
                icon: Icon(
                  Icons.photo_camera_rounded,
                  size: 18,
                  color: isDark ? Colors.white : themePrimary,
                ),
                label: Text(
                  'Cámara',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : themePrimary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : themePrimary,
                  iconColor: isDark ? Colors.white : themePrimary,
                  side: BorderSide(
                    color: (isDark ? Colors.white38 : themePrimary).withValues(
                      alpha: 0.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Las fotos se optimizan y comprimen automáticamente a < 1 MB antes de subir.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkTextSecondary : AppColors.slateMuted,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onToggleUrlField,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  showUrlField
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: isDark ? AppColors.signalAqua : AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  showUrlField
                      ? 'Ocultar opción de enlace web'
                      : 'O ingresar enlace web directo (URL)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.signalAqua : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showUrlField) ...[
          const SizedBox(height: 8),
          TextField(
            controller: urlController,
            keyboardType: TextInputType.url,
            autocorrect: false,
            enableSuggestions: false,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextPrimary : AppColors.mineralInk,
            ),
            decoration: InputDecoration(
              hintText: 'https://ejemplo.com/mifoto.jpg',
              prefixIcon: const Icon(Icons.link_rounded, size: 18),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (currentText.isNotEmpty)
                    IconButton(
                      tooltip: 'Limpiar',
                      icon: const Icon(Icons.clear_rounded, size: 16),
                      onPressed: urlController.clear,
                    ),
                  IconButton(
                    tooltip: 'Pegar',
                    icon: const Icon(Icons.content_paste_rounded, size: 16),
                    onPressed: onPasteUrl,
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
