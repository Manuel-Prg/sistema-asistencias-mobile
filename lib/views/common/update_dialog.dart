import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ota_update/ota_update.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_surface.dart';
import '../../models/app_version_info.dart';
import '../../services/update_service.dart';

class UpdateDialog extends StatefulWidget {
  final AppVersionInfo updateInfo;
  final String currentVersion;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    required this.currentVersion,
  });

  static Future<void> show(
    BuildContext context, {
    required AppVersionInfo updateInfo,
    required String currentVersion,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: !updateInfo.isMandatory,
      builder: (ctx) => PopScope(
        canPop: !updateInfo.isMandatory,
        child: UpdateDialog(
          updateInfo: updateInfo,
          currentVersion: currentVersion,
        ),
      ),
    );
  }

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  StreamSubscription<OtaEvent>? _subscription;
  bool _isDownloading = false;
  int _downloadProgress = 0;
  String? _statusMessage;
  String? _errorMessage;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _startUpdate() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
      _errorMessage = null;
      _statusMessage = 'Iniciando descarga...';
    });

    _subscription = UpdateService.startDownloadAndInstall(
      apkUrl: widget.updateInfo.apkUrl,
      onProgress: (progress) {
        if (!mounted) return;
        setState(() {
          _downloadProgress = progress;
          _statusMessage = 'Descargando paquete ($progress%)...';
        });
      },
      onStatusChange: (status) {
        if (!mounted) return;
        setState(() {
          if (status == OtaStatus.DOWNLOADING) {
            _statusMessage = 'Descargando actualización...';
          } else if (status == OtaStatus.INSTALLING) {
            _statusMessage = '¡Descarga completa! Abriendo instalador...';
          }
        });
      },
      onError: (err) {
        if (!mounted) return;
        setState(() {
          _isDownloading = false;
          _errorMessage = err;
        });
      },
    );
  }

  void _openBrowserFallback() {
    HapticFeedback.lightImpact();
    UpdateService.openDirectDownloadUrl(widget.updateInfo.apkUrl);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).colorScheme.primary;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Material(
          color: Colors.transparent,
          child: GlassSurface(
            borderRadius: BorderRadius.circular(24),
            padding: const EdgeInsets.all(22),
            tintColor: isDark ? const Color(0xFF141418) : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: themePrimary.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: themePrimary.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.system_update_alt_rounded,
                          color: themePrimary,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Actualización Disponible',
                            style: TextStyle(
                              fontFamily: AppTheme.brandFont,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.mineralInk,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'v${widget.currentVersion} ➔ ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.slateMuted,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: themePrimary.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'v${widget.updateInfo.version}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: themePrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.updateInfo.changelog != null &&
                    widget.updateInfo.changelog!.trim().isNotEmpty) ...[
                  Text(
                    'Novedades de esta versión:',
                    style: TextStyle(
                      fontFamily: AppTheme.brandFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.mineralInk,
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
                        widget.updateInfo.changelog!,
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
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
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
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                if (_isDownloading) ...[
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: _downloadProgress > 0 ? _downloadProgress / 100.0 : null,
                        backgroundColor: isDark ? Colors.white12 : Colors.black12,
                        valueColor: AlwaysStoppedAnimation<Color>(themePrimary),
                        borderRadius: BorderRadius.circular(6),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _statusMessage ?? 'Descargando...',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!widget.updateInfo.isMandatory && !_isDownloading)
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Más tarde',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : AppColors.slateMuted,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (_errorMessage != null)
                      OutlinedButton.icon(
                        onPressed: _openBrowserFallback,
                        icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                        label: const Text('Descargar vía web'),
                      ),
                    if (!_isDownloading && _errorMessage == null)
                      ElevatedButton.icon(
                        onPressed: _startUpdate,
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text('Descargar e Instalar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themePrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
