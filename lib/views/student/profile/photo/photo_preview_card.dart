import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Vista previa de la foto seleccionada con botón de descarte e indicador de peso optimizado.
class PhotoPreviewCard extends StatelessWidget {
  final Uint8List bytes;
  final int fileSizeBytes;
  final bool isDark;
  final VoidCallback onClear;

  const PhotoPreviewCard({
    super.key,
    required this.bytes,
    required this.fileSizeBytes,
    required this.isDark,
    required this.onClear,
  });

  String _formatFileSize(int size) {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? AppColors.signalAqua : AppColors.primary,
                      width: 2,
                    ),
                  ),
                  child: Image.memory(bytes, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: IconButton(
                  icon: const CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.terracottaRule,
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: onClear,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.signalAqua.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: AppColors.accentLimnological,
                ),
                const SizedBox(width: 6),
                Text(
                  'Optimizada: ${_formatFileSize(fileSizeBytes)} (Límite: 1 MB)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
