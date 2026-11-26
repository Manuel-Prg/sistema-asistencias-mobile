import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../academic_calendar_view.dart';

/// Contenedor del visor de PDF con estados de carga y reintento ante errores.
/// Lee directamente desde disco (`SfPdfViewer.file` / `SfPdfViewer.asset`)
/// para evitar duplicar el PDF completo en la memoria RAM de Dart.
class CalendarPdfViewerCard extends StatelessWidget {
  final AcademicCalendarDoc activeDoc;
  final int selectedIndex;
  final File? pdfFile;
  final bool useAssetFallback;
  final PdfViewerController controller;
  final bool isLoading;
  final String? errorMessage;
  final Color activeColor;
  final bool isDark;
  final PdfDocumentLoadedCallback onDocumentLoaded;
  final PdfDocumentLoadFailedCallback onDocumentLoadFailed;
  final PdfPageChangedCallback onPageChanged;
  final VoidCallback onRetry;

  const CalendarPdfViewerCard({
    super.key,
    required this.activeDoc,
    required this.selectedIndex,
    required this.pdfFile,
    this.useAssetFallback = false,
    required this.controller,
    required this.isLoading,
    required this.errorMessage,
    required this.activeColor,
    required this.isDark,
    required this.onDocumentLoaded,
    required this.onDocumentLoadFailed,
    required this.onPageChanged,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF101014)
              : Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : activeColor.withValues(alpha: 0.15),
            width: 1.2,
          ),
        ),
        child: Stack(
          children: [
            if (pdfFile != null)
              SfPdfViewer.file(
                pdfFile!,
                key: ValueKey('${activeDoc.assetPath}_file_$selectedIndex'),
                controller: controller,
                enableDoubleTapZooming: true,
                pageLayoutMode: PdfPageLayoutMode.continuous,
                canShowScrollHead: true,
                canShowScrollStatus: true,
                onDocumentLoaded: onDocumentLoaded,
                onDocumentLoadFailed: onDocumentLoadFailed,
                onPageChanged: onPageChanged,
              )
            else if (useAssetFallback)
              SfPdfViewer.asset(
                activeDoc.assetPath,
                key: ValueKey('${activeDoc.assetPath}_asset_$selectedIndex'),
                controller: controller,
                enableDoubleTapZooming: true,
                pageLayoutMode: PdfPageLayoutMode.continuous,
                canShowScrollHead: true,
                canShowScrollStatus: true,
                onDocumentLoaded: onDocumentLoaded,
                onDocumentLoadFailed: onDocumentLoadFailed,
                onPageChanged: onPageChanged,
              ),
            if (isLoading)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 3,
                      color: activeColor,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Cargando ${activeDoc.cycle}...',
                      style: TextStyle(
                        fontFamily: AppTheme.brandFont,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppColors.slateMuted,
                      ),
                    ),
                  ],
                ),
              ),
            if (errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.terracottaRule,
                        size: 42,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No se pudo abrir el documento',
                        style: TextStyle(
                          fontFamily: AppTheme.brandFont,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.mineralInk,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : AppColors.slateMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Reintentar lectura'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(180, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
