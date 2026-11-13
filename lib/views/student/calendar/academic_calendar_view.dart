import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../../../core/widgets/glass_surface.dart';

class AcademicCalendarDoc {
  final String id;
  final String title;
  final String subtitle;
  final String assetPath;
  final String cycle;
  final bool isCurrent;

  const AcademicCalendarDoc({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.cycle,
    this.isCurrent = false,
  });
}

class AcademicCalendarView extends StatefulWidget {
  final int initialIndex;

  const AcademicCalendarView({super.key, this.initialIndex = 0});

  static const List<AcademicCalendarDoc> calendars = [
    AcademicCalendarDoc(
      id: 'cal-2026-2027',
      title: 'Calendario Escolar 2026 - 2027',
      subtitle: 'Licenciatura con Internado (Vigente)',
      assetPath: 'assets/docs/calendario_escolar_2026_2027.pdf',
      cycle: '2026 - 2027',
      isCurrent: true,
    ),
    AcademicCalendarDoc(
      id: 'cal-2025-2026',
      title: 'Calendario Escolar 2025 - 2026',
      subtitle: 'Licenciatura y TSU (Ciclo Previo)',
      assetPath: 'assets/docs/calendario_escolar_2025_2026.pdf',
      cycle: '2025 - 2026',
      isCurrent: false,
    ),
  ];

  static void open(BuildContext context, {int initialIndex = 0}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AcademicCalendarView(initialIndex: initialIndex),
      ),
    );
  }

  @override
  State<AcademicCalendarView> createState() => _AcademicCalendarViewState();
}

class _AcademicCalendarViewState extends State<AcademicCalendarView> {
  late int _selectedCalendarIndex;
  late PdfViewerController _pdfViewerController;
  Uint8List? _pdfBytes;
  int _pageCount = 1;
  int _currentPage = 1;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedCalendarIndex = widget.initialIndex.clamp(
      0,
      AcademicCalendarView.calendars.length - 1,
    );
    _pdfViewerController = PdfViewerController();
    _loadPdf();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  Future<void> _loadPdf() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _pdfBytes = null;
    });

    try {
      final activeDoc = AcademicCalendarView.calendars[_selectedCalendarIndex];
      final byteData = await rootBundle.load(activeDoc.assetPath);
      final bytes = byteData.buffer.asUint8List();

      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'No se pudo cargar el archivo desde el dispositivo:\n$e';
        });
      }
    }
  }

  void _onCalendarChanged(int index) {
    if (_selectedCalendarIndex != index) {
      HapticFeedback.selectionClick();
      setState(() {
        _selectedCalendarIndex = index;
        _currentPage = 1;
        _pageCount = 1;
      });
      _loadPdf();
    }
  }

  void _zoomIn() {
    HapticFeedback.lightImpact();
    final newZoom = (_pdfViewerController.zoomLevel + 0.4).clamp(1.0, 4.0);
    _pdfViewerController.zoomLevel = newZoom;
  }

  void _zoomOut() {
    HapticFeedback.lightImpact();
    final newZoom = (_pdfViewerController.zoomLevel - 0.4).clamp(1.0, 4.0);
    _pdfViewerController.zoomLevel = newZoom;
  }

  void _resetZoom() {
    HapticFeedback.lightImpact();
    _pdfViewerController.zoomLevel = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = Theme.of(context).colorScheme.primary;
    final activeDoc = AcademicCalendarView.calendars[_selectedCalendarIndex];

    return GlassScaffold(
      extendBodyBehindAppBar: false,
      appBar: GlassAppBar(
        showBrandHeader: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Volver',
        ),
        title: Text(
          'Calendario Escolar',
          style: TextStyle(
            fontFamily: AppTheme.brandFont,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_rounded, size: 22),
            onPressed: _zoomOut,
            tooltip: 'Alejar',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in_rounded, size: 22),
            onPressed: _zoomIn,
            tooltip: 'Acercar',
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded, size: 22),
            onPressed: _resetZoom,
            tooltip: 'Restablecer zoom',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          // Selector de ciclo lectivo (2026-2027 vs 2025-2026)
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: GlassSurface(
              borderRadius: BorderRadius.circular(24),
              padding: const EdgeInsets.all(4),
              tintColor: isDark ? const Color(0xFF141418) : null,
              child: Row(
                children: List.generate(AcademicCalendarView.calendars.length, (
                  index,
                ) {
                  final item = AcademicCalendarView.calendars[index];
                  final isSelected = _selectedCalendarIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _onCalendarChanged(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? activeColor.withValues(
                                  alpha: isDark ? 0.25 : 0.15,
                                )
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? Border.all(
                                  color: activeColor.withValues(
                                    alpha: isDark ? 0.45 : 0.30,
                                  ),
                                  width: 1.2,
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 14,
                                  color: isSelected
                                      ? activeColor
                                      : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.slateMuted),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.cycle,
                                  style: TextStyle(
                                    fontFamily: AppTheme.brandFont,
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? activeColor
                                        : (isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.slateMuted),
                                  ),
                                ),
                                if (item.isCurrent) ...[
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: activeColor.withValues(
                                        alpha: isDark ? 0.35 : 0.20,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Vigente',
                                      style: TextStyle(
                                        fontFamily: AppTheme.brandFont,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected
                                            ? activeColor
                                            : (isDark
                                                  ? Colors.white70
                                                  : activeColor),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Contenedor principal con el visor de PDF
          Positioned.fill(
            top: 74,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 84),
              child: ClipRRect(
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
                      // Visor de PDF nativo con pinch-to-zoom alimentado con bytes en memoria
                      if (_pdfBytes != null)
                        SfPdfViewer.memory(
                          _pdfBytes!,
                          key: ValueKey(
                            '${activeDoc.assetPath}_$_selectedCalendarIndex',
                          ),
                          controller: _pdfViewerController,
                          enableDoubleTapZooming: true,
                          pageLayoutMode: PdfPageLayoutMode.continuous,
                          canShowScrollHead: true,
                          canShowScrollStatus: true,
                          onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                                _pageCount = details.document.pages.count;
                                _currentPage = 1;
                              });
                            }
                          },
                          onDocumentLoadFailed:
                              (PdfDocumentLoadFailedDetails details) {
                                if (mounted) {
                                  setState(() {
                                    _isLoading = false;
                                    _errorMessage = details.description;
                                  });
                                }
                              },
                          onPageChanged: (PdfPageChangedDetails details) {
                            if (mounted) {
                              setState(() {
                                _currentPage = details.newPageNumber;
                              });
                            }
                          },
                        ),

                      // Indicador de carga
                      if (_isLoading)
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
                                  color: isDark
                                      ? Colors.white70
                                      : AppColors.slateMuted,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Mensaje en caso de error con botón de reintentar
                      if (_errorMessage != null)
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
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.mineralInk,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white60
                                        : AppColors.slateMuted,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _loadPdf,
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    size: 18,
                                  ),
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
              ),
            ),
          ),

          // Barra flotante inferior con información de página y título del documento
          Positioned(
            left: 24,
            right: 24,
            bottom: 18,
            child: GlassSurface(
              borderRadius: BorderRadius.circular(28),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              tintColor: isDark ? const Color(0xFF141418) : null,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeColor.withValues(alpha: 0.15),
                    ),
                    child: Icon(
                      Icons.description_rounded,
                      size: 16,
                      color: activeColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeDoc.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTheme.brandFont,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.mineralInk,
                          ),
                        ),
                        Text(
                          activeDoc.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.slateMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_pageCount > 1) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: activeColor.withValues(
                          alpha: isDark ? 0.22 : 0.12,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: activeColor.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Pág $_currentPage / $_pageCount',
                        style: TextStyle(
                          fontFamily: AppTheme.brandFont,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          color: activeColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
