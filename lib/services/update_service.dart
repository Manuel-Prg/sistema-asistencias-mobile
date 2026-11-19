import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_version_info.dart';
import 'supabase_service.dart';

class UpdateCheckResult {
  final bool hasUpdate;
  final String currentVersion;
  final int currentBuildNumber;
  final AppVersionInfo? updateInfo;
  final int versionsBehind;
  final bool isCriticalOutdated;

  const UpdateCheckResult({
    required this.hasUpdate,
    required this.currentVersion,
    required this.currentBuildNumber,
    this.updateInfo,
    this.versionsBehind = 0,
    this.isCriticalOutdated = false,
  });
}

class UpdateService {
  UpdateService._();

  /// Compara dos cadenas semver ("1.0.1" vs "1.0.0")
  static bool isVersionHigher(String remote, String current) {
    try {
      final rParts = remote
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      final cParts = current
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();

      while (rParts.length < 3) {
        rParts.add(0);
      }
      while (cParts.length < 3) {
        cParts.add(0);
      }

      for (var i = 0; i < 3; i++) {
        if (rParts[i] > cParts[i]) return true;
        if (rParts[i] < cParts[i]) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Calcula cuántas versiones o builds de diferencia hay entre la versión instalada y la remota
  static int calculateVersionsBehind({
    required String currentVersion,
    required int currentBuild,
    required String remoteVersion,
    required int remoteBuild,
  }) {
    // 1. Diferencia directa por número de compilación (build_number)
    final buildDiff = remoteBuild - currentBuild;
    if (buildDiff > 0) {
      return buildDiff;
    }

    // 2. Si no hay diferencia por build_number, comparar partes semver
    try {
      final cParts = currentVersion
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      final rParts = remoteVersion
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();

      while (cParts.length < 3) {
        cParts.add(0);
      }
      while (rParts.length < 3) {
        rParts.add(0);
      }

      if (rParts[0] > cParts[0]) {
        return (rParts[0] - cParts[0]) * 10;
      }
      if (rParts[1] > cParts[1]) {
        return (rParts[1] - cParts[1]) * 5;
      }
      if (rParts[2] > cParts[2]) {
        return rParts[2] - cParts[2];
      }
    } catch (_) {}

    return 0;
  }

  /// Comprueba en Supabase si existe una versión más reciente que la instalada
  static Future<UpdateCheckResult> checkForUpdates() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 1;

      // Consulta la tabla app_versions en Supabase ordenada por número de compilación
      final response = await SupabaseService.client
          .from('app_versions')
          .select()
          .order('build_number', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return UpdateCheckResult(
          hasUpdate: false,
          currentVersion: currentVersion,
          currentBuildNumber: currentBuildNumber,
        );
      }

      final latest = AppVersionInfo.fromJson(response);

      final isBuildHigher = latest.buildNumber > currentBuildNumber;
      final isSemverHigher = isVersionHigher(latest.version, currentVersion);

      final hasUpdate =
          (isBuildHigher || isSemverHigher) && latest.apkUrl.isNotEmpty;

      final versionsBehind = hasUpdate
          ? calculateVersionsBehind(
              currentVersion: currentVersion,
              currentBuild: currentBuildNumber,
              remoteVersion: latest.version,
              remoteBuild: latest.buildNumber,
            )
          : 0;

      // Si tiene 2 o más versiones de retraso, la actualización es crítica y obligatoria
      final isCriticalOutdated = versionsBehind >= 2;
      final effectiveUpdateInfo = (hasUpdate && isCriticalOutdated)
          ? latest.copyWith(isMandatory: true)
          : latest;

      return UpdateCheckResult(
        hasUpdate: hasUpdate,
        currentVersion: currentVersion,
        currentBuildNumber: currentBuildNumber,
        updateInfo: hasUpdate ? effectiveUpdateInfo : null,
        versionsBehind: versionsBehind,
        isCriticalOutdated: isCriticalOutdated,
      );
    } catch (e) {
      debugPrint(
        'UpdateService: Error comprobando actualizaciones en Supabase: $e',
      );
      return const UpdateCheckResult(
        hasUpdate: false,
        currentVersion: '1.0.0',
        currentBuildNumber: 1,
      );
    }
  }

  /// Descarga el APK e inicia el instalador nativo de Android
  /// [onProgress]: Recibe el porcentaje de descarga (0 a 100)
  /// [onError]: Notifica si ocurrió un error para permitir descarga manual
  static StreamSubscription<OtaEvent>? startDownloadAndInstall({
    required String apkUrl,
    required void Function(int progress) onProgress,
    required void Function(OtaStatus status) onStatusChange,
    required void Function(String errorMessage) onError,
  }) {
    try {
      return OtaUpdate()
          .execute(apkUrl, destinationFilename: 'sistema_asistencia_update.apk')
          .listen(
            (OtaEvent event) {
              onStatusChange(event.status);

              if (event.status == OtaStatus.DOWNLOADING) {
                final progressInt = int.tryParse(event.value ?? '0') ?? 0;
                onProgress(progressInt.clamp(0, 100));
              } else if (event.status == OtaStatus.INSTALLING) {
                onProgress(100);
              } else if (event.status == OtaStatus.ALREADY_RUNNING_ERROR) {
                onError('Ya hay una descarga de actualización en curso.');
              } else if (event.status ==
                  OtaStatus.PERMISSION_NOT_GRANTED_ERROR) {
                onError(
                  'No se concedieron permisos para instalar la actualización.',
                );
              } else if (event.status == OtaStatus.INTERNAL_ERROR) {
                onError('Error interno al descargar el instalador.');
              }
            },
            onError: (err) {
              onError('Fallo de conexión al descargar actualización: $err');
            },
          );
    } catch (e) {
      onError('No se pudo iniciar el instalador OTA: $e');
      return null;
    }
  }

  /// Fallback: Abrir enlace directo en el navegador del dispositivo
  static Future<bool> openDirectDownloadUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
