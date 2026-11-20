import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/app_version_info.dart';

/// Cabecera del modal de actualización con ícono, versiones, etiqueta OBLIGATORIA
/// y tarjeta de advertencia preventiva cuando el usuario está 2+ versiones atrás.
class UpdateDialogHeader extends StatelessWidget {
  final AppVersionInfo updateInfo;
  final String currentVersion;
  final int versionsBehind;
  final bool isMandatory;
  final Color actionColor;
  final bool isDark;

  const UpdateDialogHeader({
    super.key,
    required this.updateInfo,
    required this.currentVersion,
    required this.versionsBehind,
    required this.isMandatory,
    required this.actionColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = versionsBehind >= 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: actionColor.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(
                  color: actionColor.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Icon(
                  isMandatory
                      ? Icons.security_update_warning_rounded
                      : Icons.system_update_alt_rounded,
                  color: actionColor,
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
                    isMandatory
                        ? 'Actualización Requerida'
                        : 'Actualización Disponible',
                    style: TextStyle(
                      fontFamily: AppTheme.brandFont,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.mineralInk,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'v$currentVersion ➔ ',
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
                          color: actionColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'v${updateInfo.version}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: actionColor,
                          ),
                        ),
                      ),
                      if (isMandatory) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.terracottaRule.withValues(
                              alpha: 0.18,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'OBLIGATORIA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.terracottaRule,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (isMandatory)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.terracottaRule.withValues(
                alpha: isDark ? 0.20 : 0.10,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.terracottaRule.withValues(
                  alpha: isDark ? 0.55 : 0.35,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.terracottaRule,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCritical
                            ? 'Versión obsoleta ($versionsBehind versiones de retraso)'
                            : 'Actualización obligatoria',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: AppColors.terracottaRule,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isCritical
                            ? 'Para prevenir errores de incompatibilidad, fallas al registrar asistencias y pérdida de datos en horarios, es obligatorio actualizar ahora para continuar usando la aplicación.'
                            : 'Esta versión contiene correcciones críticas requeridas para el funcionamiento del sistema.',
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.35,
                          color: isDark
                              ? const Color(0xFFFCA5A5)
                              : const Color(0xFF7F1D1D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
