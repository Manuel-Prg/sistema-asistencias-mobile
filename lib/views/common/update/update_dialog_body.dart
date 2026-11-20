import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Cuerpo y acciones del modal de actualización: changelog, progreso de descarga,
/// manejo de errores y botones de descarga o cierre.
class UpdateDialogBody extends StatelessWidget {
  final String? changelog;
  final bool isDownloading;
  final int downloadProgress;
  final String? statusMessage;
  final String? errorMessage;
  final bool isMandatory;
  final Color actionColor;
  final bool isDark;
  final VoidCallback onStartUpdate;
  final VoidCallback onOpenBrowserFallback;
  final VoidCallback onDismiss;

  const UpdateDialogBody({
    super.key,
    required this.changelog,
    required this.isDownloading,
    required this.downloadProgress,
    required this.statusMessage,
    required this.errorMessage,
    required this.isMandatory,
    required this.actionColor,
    required this.isDark,
    required this.onStartUpdate,
    required this.onOpenBrowserFallback,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (changelog != null && changelog!.trim().isNotEmpty) ...[
          Text(
            'Novedades de esta versión:',
            style: TextStyle(
              fontFamily: AppTheme.brandFont,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.mineralInk,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 140),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
              ),
            ),
            child: SingleChildScrollView(
              child: Text(
                changelog!.replaceAll(r'\n', '\n'),
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.slateMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(fontSize: 11.5, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (isDownloading) ...[
          Column(
            children: [
              LinearProgressIndicator(
                value: downloadProgress > 0 ? downloadProgress / 100.0 : null,
                backgroundColor: isDark ? Colors.white12 : Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(actionColor),
                borderRadius: BorderRadius.circular(6),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                statusMessage ?? 'Descargando...',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.slateMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (!isDownloading && errorMessage == null)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onStartUpdate,
              icon: const Icon(Icons.download_rounded, size: 20),
              label: Text(
                isMandatory ? 'Actualizar Ahora' : 'Descargar e Instalar',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: actionColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        if (errorMessage != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onOpenBrowserFallback,
              icon: const Icon(Icons.open_in_browser_rounded, size: 18),
              label: const Text('Descargar desde el navegador'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        if (!isMandatory && !isDownloading) ...[
          const SizedBox(height: 6),
          Center(
            child: TextButton(
              onPressed: onDismiss,
              child: Text(
                'Más tarde',
                style: TextStyle(
                  color: isDark ? Colors.white60 : AppColors.slateMuted,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
