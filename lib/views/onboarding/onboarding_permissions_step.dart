import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_surface.dart';
import '../../core/widgets/glass_toast.dart';
import '../../providers/security_settings_provider.dart';
import '../../services/notification_service.dart';
import '../../services/report_notification_service.dart';

/// Diapositiva 4: Solicitud interactiva de permisos (notificaciones, alarmas
/// puntuales y acceso rápido con huella si el dispositivo lo soporta).
class OnboardingPermissionsStep extends ConsumerStatefulWidget {
  final Color activeAccent;
  final bool isDark;

  const OnboardingPermissionsStep({
    super.key,
    required this.activeAccent,
    required this.isDark,
  });

  @override
  ConsumerState<OnboardingPermissionsStep> createState() =>
      _OnboardingPermissionsStepState();
}

class _OnboardingPermissionsStepState
    extends ConsumerState<OnboardingPermissionsStep>
    with WidgetsBindingObserver {
  bool _notificationsGranted = false;
  bool _exactAlarmsGranted = false;
  bool _loadingStatus = true;
  bool _requestingNotifications = false;
  bool _requestingAlarms = false;
  bool _requestingBiometric = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissions();
    }
  }

  Future<void> _refreshPermissions() async {
    final results = await Future.wait([
      NotificationService.areNotificationsEnabled(),
      ReportNotificationService.canScheduleExactAlarms(),
    ]);
    if (!mounted) return;
    setState(() {
      _notificationsGranted = results[0];
      _exactAlarmsGranted = results[1];
      _loadingStatus = false;
    });
  }

  Future<void> _handleRequestNotifications() async {
    if (_requestingNotifications) return;
    HapticFeedback.selectionClick();
    setState(() => _requestingNotifications = true);

    try {
      final granted = await NotificationService.requestNotificationPermission();
      if (!mounted) return;

      if (granted) {
        await ReportNotificationService.scheduleMonthlyReportReminders();
        if (!mounted) return;
        setState(() => _notificationsGranted = true);
        AppGlassToast.show(
          context,
          message: 'Notificaciones activadas y recordatorios programados.',
          type: GlassToastType.success,
        );
      } else {
        // Si Android ya no muestra el diálogo nativo, abrimos los ajustes
        await NotificationService.openNotificationSettings();
      }
    } finally {
      if (mounted) {
        setState(() => _requestingNotifications = false);
      }
    }
  }

  Future<void> _handleRequestExactAlarms() async {
    if (_requestingAlarms) return;
    HapticFeedback.selectionClick();
    setState(() => _requestingAlarms = true);

    try {
      final granted =
          await ReportNotificationService.requestExactAlarmPermission();
      if (!mounted) return;

      if (granted) {
        await ReportNotificationService.scheduleMonthlyReportReminders();
        if (!mounted) return;
        setState(() => _exactAlarmsGranted = true);
        AppGlassToast.show(
          context,
          message: 'Recordatorios puntuales activados.',
          type: GlassToastType.success,
        );
      } else {
        await _refreshPermissions();
      }
    } finally {
      if (mounted) {
        setState(() => _requestingAlarms = false);
      }
    }
  }

  Future<void> _handleToggleBiometric(bool currentEnabled) async {
    if (_requestingBiometric) return;
    HapticFeedback.selectionClick();
    setState(() => _requestingBiometric = true);

    try {
      final target = !currentEnabled;
      final notifier = ref.read(securitySettingsProvider.notifier);
      final securityState = ref.read(securitySettingsProvider);

      if (target && !securityState.isRememberEnabled) {
        await notifier.setRememberEnabled(true);
      }
      final ok = await notifier.setBiometricEnabled(target);
      if (!mounted) return;

      AppGlassToast.show(
        context,
        message: ok && target
            ? 'Acceso con huella dactilar activado.'
            : (target
                  ? 'No se pudo verificar la huella.'
                  : 'Acceso con huella desactivado.'),
        type: ok && target ? GlassToastType.success : GlassToastType.info,
      );
    } finally {
      if (mounted) {
        setState(() => _requestingBiometric = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final activeAccent = widget.activeAccent;
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.mineralInk;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.slateMuted;
    final securityState = ref.watch(securitySettingsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 124,
                height: 124,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      activeAccent.withValues(alpha: isDark ? 0.24 : 0.14),
                      activeAccent.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              Image.asset(
                'assets/images/nuty/nuty-pose-2.webp',
                height: 118,
                cacheHeight: 240,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Icon(
                  Icons.notifications_active_rounded,
                  size: 42,
                  color: activeAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Permisos y Recordatorios',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.brandFont,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Activa lo que necesites para que Nuty te avise a tiempo y entres más rápido a la app.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.brandFont,
              fontSize: 13,
              height: 1.4,
              color: subColor,
            ),
          ),
          const SizedBox(height: 18),

          // 1. Notificaciones
          _PermissionCard(
            icon: Icons.notifications_active_rounded,
            title: 'Notificaciones de Reportes',
            description:
                'Recibe avisos en los primeros 5 días hábiles y al cierre de mes para entregar tus reportes a tiempo.',
            granted: _notificationsGranted,
            loading: _loadingStatus || _requestingNotifications,
            actionLabel: 'Permitir',
            accent: activeAccent,
            isDark: isDark,
            onAction: _handleRequestNotifications,
          ),
          const SizedBox(height: 10),

          // 2. Recordatorios puntuales (Alarmas exactas)
          _PermissionCard(
            icon: Icons.alarm_on_rounded,
            title: 'Recordatorios Puntuales',
            description:
                'Asegura que las alertas de reportes lleguen a la hora exacta sin retrasos del sistema.',
            granted: _exactAlarmsGranted,
            loading: _loadingStatus || _requestingAlarms,
            actionLabel: 'Activar',
            accent: activeAccent,
            isDark: isDark,
            onAction: _handleRequestExactAlarms,
          ),

          // 3. Acceso con Huella (solo si el dispositivo cuenta con biometría)
          if (securityState.isBiometricAvailable) ...[
            const SizedBox(height: 10),
            _PermissionCard(
              icon: Icons.fingerprint_rounded,
              title: 'Acceso con Huella',
              description:
                  'Inicia sesión al instante usando el sensor biométrico de tu teléfono.',
              granted: securityState.isBiometricEnabled,
              loading: _requestingBiometric,
              actionLabel: 'Activar',
              accent: activeAccent,
              isDark: isDark,
              allowToggleWhenGranted: true,
              onAction: () =>
                  _handleToggleBiometric(securityState.isBiometricEnabled),
            ),
          ],

          const SizedBox(height: 14),
          Text(
            'Todos los permisos son opcionales y puedes cambiarlos después en Configuración.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.35,
              color: subColor.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool granted;
  final bool loading;
  final String actionLabel;
  final Color accent;
  final bool isDark;
  final bool allowToggleWhenGranted;
  final VoidCallback onAction;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.granted,
    required this.loading,
    required this.actionLabel,
    required this.accent,
    required this.isDark,
    required this.onAction,
    this.allowToggleWhenGranted = false,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = granted ? AppColors.leafGreen : accent;

    return GlassSurface(
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      enableRefraction: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 21, color: badgeColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTheme.brandFont,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.mineralInk,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.8,
                    height: 1.35,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.slateMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (loading)
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: accent,
              ),
            )
          else if (granted && !allowToggleWhenGranted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.leafGreen.withValues(
                  alpha: isDark ? 0.22 : 0.14,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: AppColors.leafGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Activo',
                    style: TextStyle(
                      fontFamily: AppTheme.brandFont,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.leafGreen,
                    ),
                  ),
                ],
              ),
            )
          else
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: granted
                    ? AppColors.leafGreen.withValues(
                        alpha: isDark ? 0.22 : 0.14,
                      )
                    : accent,
                foregroundColor: granted ? AppColors.leafGreen : Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const StadiumBorder(),
              ),
              child: Text(
                granted ? 'Activo' : actionLabel,
                style: TextStyle(
                  fontFamily: AppTheme.brandFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
