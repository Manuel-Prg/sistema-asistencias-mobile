import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../../../services/pdf_compression_service.dart';
import 'widgets/calendar_bottom_bar.dart';
import 'widgets/calendar_cycle_selector.dart';
import 'widgets/calendar_pdf_viewer_card.dart';

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
  File? _pdfFile;
  bool _useAssetFallback = false;
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
      _pdfFile = null;
      _useAssetFallback = false;
    });

    try {
      final activeDoc = AcademicCalendarView.calendars[_selectedCalendarIndex];

      try {
        final file = await PdfCompressionService.getCompressedPdf(
          activeDoc.assetPath,
        );
        if (mounted) {
          setState(() => _pdfFile = file);
        }
      } catch (_) {
        // Fallback directo a asset sin duplicar bytes en RAM
        if (mounted) {
          setState(() => _useAssetFallback = true);
        }
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
    _pdfViewerController.zoomLevel =
        (_pdfViewerController.zoomLevel + 0.4).clamp(1.0, 4.0);
  }

  void _zoomOut() {
    HapticFeedback.lightImpact();
    _pdfViewerController.zoomLevel =
        (_pdfViewerController.zoomLevel - 0.4).clamp(1.0, 4.0);
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
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: CalendarCycleSelector(
              calendars: AcademicCalendarView.calendars,
              selectedIndex: _selectedCalendarIndex,
              activeColor: activeColor,
              isDark: isDark,
              onChanged: _onCalendarChanged,
            ),
          ),
          Positioned.fill(
            top: 74,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 84),
              child: CalendarPdfViewerCard(
                activeDoc: activeDoc,
                selectedIndex: _selectedCalendarIndex,
                pdfFile: _pdfFile,
                useAssetFallback: _useAssetFallback,
                controller: _pdfViewerController,
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                activeColor: activeColor,
                isDark: isDark,
                onDocumentLoaded: (details) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                      _pageCount = details.document.pages.count;
                      _currentPage = 1;
                    });
                  }
                },
                onDocumentLoadFailed: (details) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                      _errorMessage = details.description;
                    });
                  }
                },
                onPageChanged: (details) {
                  if (mounted) {
                    setState(() => _currentPage = details.newPageNumber);
                  }
                },
                onRetry: _loadPdf,
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 18,
            child: CalendarBottomBar(
              activeDoc: activeDoc,
              currentPage: _currentPage,
              pageCount: _pageCount,
              activeColor: activeColor,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}
