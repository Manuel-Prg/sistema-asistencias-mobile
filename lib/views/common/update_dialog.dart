import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ota_update/ota_update.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_surface.dart';
import '../../models/app_version_info.dart';
import '../../services/update_service.dart';
import 'update/update_dialog_body.dart';
import 'update/update_dialog_header.dart';

class UpdateDialog extends StatefulWidget {
  final AppVersionInfo updateInfo;
  final String currentVersion;
  final int versionsBehind;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    required this.currentVersion,
    this.versionsBehind = 0,
  });

  bool get isStrictMandatory => updateInfo.isMandatory || versionsBehind >= 2;

  static Future<void> show(
    BuildContext context, {
    required AppVersionInfo updateInfo,
    required String currentVersion,
    int versionsBehind = 0,
  }) {
    final isMandatory = updateInfo.isMandatory || versionsBehind >= 2;
    return showDialog(
      context: context,
      barrierDismissible: !isMandatory,
      builder: (ctx) => PopScope(
        canPop: !isMandatory,
        child: UpdateDialog(
          updateInfo: updateInfo,
          currentVersion: currentVersion,
          versionsBehind: versionsBehind,
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
    final isMandatory = widget.isStrictMandatory;
    final actionColor = isMandatory ? AppColors.terracottaRule : themePrimary;

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
                UpdateDialogHeader(
                  updateInfo: widget.updateInfo,
                  currentVersion: widget.currentVersion,
                  versionsBehind: widget.versionsBehind,
                  isMandatory: isMandatory,
                  actionColor: actionColor,
                  isDark: isDark,
                ),
                UpdateDialogBody(
                  changelog: widget.updateInfo.changelog,
                  isDownloading: _isDownloading,
                  downloadProgress: _downloadProgress,
                  statusMessage: _statusMessage,
                  errorMessage: _errorMessage,
                  isMandatory: isMandatory,
                  actionColor: actionColor,
                  isDark: isDark,
                  onStartUpdate: _startUpdate,
                  onOpenBrowserFallback: _openBrowserFallback,
                  onDismiss: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
