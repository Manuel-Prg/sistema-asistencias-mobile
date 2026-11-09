import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_surface.dart';
import '../../providers/auth_provider.dart';
import '../../providers/glass_settings_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  late TextEditingController _nameController;
  bool _isSavingName = false;
  bool _isUpdatingPhoto = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authProvider).profile;
    _nameController = TextEditingController(text: profile?.fullName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un nombre válido.'),
          backgroundColor: AppColors.terracottaRule,
        ),
      );
      return;
    }

    setState(() => _isSavingName = true);
    final success = await ref.read(authProvider.notifier).updateProfileName(newName);
    if (!mounted) return;
    setState(() => _isSavingName = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(child: Text('¡Nombre guardado con éxito!')),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final error = ref.read(authProvider).errorMessage ?? 'Error al actualizar el nombre.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.terracottaRule,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showUploadPhotoDialog(BuildContext context) {
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => GlassDialog(
        title: const Text('Subir foto de perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingresa el enlace directo de tu fotografía (formato WebP, JPG o PNG):',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                hintText: 'https://ejemplo.com/foto.jpg',
                prefixIcon: const Icon(Icons.link_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final url = urlController.text.trim();
              if (url.isEmpty) return;
              Navigator.of(ctx).pop();
              setState(() => _isUpdatingPhoto = true);
              final success = await ref.read(authProvider.notifier).updateProfileAvatar(url);
              if (!mounted) return;
              setState(() => _isUpdatingPhoto = false);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? '¡Foto de perfil actualizada!' : 'No fue posible guardar la foto.',
                  ),
                  backgroundColor: success ? AppColors.primary : AppColors.terracottaRule,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar Foto'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePhoto(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => GlassDialog(
        title: const Text('Eliminar foto'),
        content: const Text('¿Estás seguro de que deseas eliminar tu foto de perfil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() => _isUpdatingPhoto = true);
              final success = await ref.read(authProvider.notifier).updateProfileAvatar(null);
              if (!mounted) return;
              setState(() => _isUpdatingPhoto = false);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? 'Foto de perfil eliminada.' : 'Error al eliminar la foto.',
                  ),
                  backgroundColor: success ? AppColors.terracottaRule : AppColors.terracottaRule,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracottaRule,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: GlassSurface(
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Antes de salir',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.brandFont,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'No olvides llenar tu bitácora del día. Puedes ir al formulario ahora y después continuar con tu cierre de sesión.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  fontFamily: AppTheme.brandFont,
                  color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
                ),
              ),
              const SizedBox(height: 24),

              // Botón 1: Cancelar (Outlined)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
                      width: 1.2,
                    ),
                    foregroundColor: isDark ? Colors.white : AppColors.primary,
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      fontFamily: AppTheme.brandFont,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Botón 2: Ir a bitácora (Filled Primary)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final uri = Uri.parse('https://xurl.es/bitacora');
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (_) {}
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? AppColors.signalAqua : AppColors.primary,
                    foregroundColor:
                        isDark ? const Color(0xFF07161D) : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Ir a bitácora',
                    style: TextStyle(
                      fontFamily: AppTheme.brandFont,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Botón 3: Solo cerrar sesión (Soft Tonal)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    ref.read(authProvider.notifier).signOut();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFEFECE6),
                    foregroundColor:
                        isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
                  ),
                  child: Text(
                    'Solo cerrar sesión',
                    style: TextStyle(
                      fontFamily: AppTheme.brandFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => GlassDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications_off_outlined, color: AppColors.amberTolerance, size: 24),
            SizedBox(width: 10),
            Expanded(child: Text('Permiso de Notificaciones')),
          ],
        ),
        content: const Text(
          'Para recibir alertas de retardos y avisos de tus turnos, debes autorizar las notificaciones en los ajustes del sistema de tu dispositivo.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Ahora no'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(notificationProvider.notifier).openSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Abrir Ajustes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final studentState = ref.watch(studentProvider);
    final themeMode = ref.watch(themeModeProvider);
    final glassSettings = ref.watch(glassSettingsProvider);
    final notificationState = ref.watch(notificationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final profile = authState.profile;
    final student = studentState.student;

    final fullName = profile?.fullName ?? 'Estudiante';
    final hasAvatar = profile?.avatarUrl != null && profile!.avatarUrl!.trim().isNotEmpty;

    // Sincronizar campo si cambió desde provider y no se está editando activamente
    if (!_isSavingName && _nameController.text != fullName && fullName.isNotEmpty) {
      _nameController.text = fullName;
    }

    final secondaryTextColor = isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted;

    return GlassScaffold(
      appBar: const GlassAppBar(
        title: Text('Mi Perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Subtítulo de cabecera
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              'Administra tus datos personales y foto de perfil',
              style: TextStyle(
                fontSize: 13,
                fontFamily: AppTheme.brandFont,
                color: secondaryTextColor,
                height: 1.35,
              ),
            ),
          ),

          // ─── Tarjeta 1: Foto de Perfil ─────────────────────────────────────────
          GlassSurface(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Foto de perfil',
                    style: TextStyle(
                      fontFamily: AppTheme.brandFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sube una foto para identificarte\n(200x200px, WebP, máx 1 MB)',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: AppTheme.brandFont,
                      color: secondaryTextColor,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Avatar circular
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.signalAqua.withValues(alpha: 0.4)
                              : AppColors.primary.withValues(alpha: 0.2),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: hasAvatar
                            ? Image.network(
                                profile!.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => _buildAvatarFallback(fullName),
                                loadingBuilder: (ctx, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  );
                                },
                              )
                            : _buildAvatarFallback(fullName),
                      ),
                    ),
                    if (_isUpdatingPhoto)
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Botones Subir Foto y Eliminar Foto
                OutlinedButton.icon(
                  onPressed: _isUpdatingPhoto ? null : () => _showUploadPhotoDialog(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
                      width: 1.2,
                    ),
                    backgroundColor: isDark
                        ? const Color(0xFF133644).withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  label: const Text(
                    'Subir foto',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                if (hasAvatar) ...[
                  const SizedBox(height: 6),
                  TextButton.icon(
                    onPressed: _isUpdatingPhoto ? null : () => _confirmDeletePhoto(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.terracottaRule,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text(
                      'Eliminar foto',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ─── Tarjeta 2: Datos Personales ───────────────────────────────────────
          GlassSurface(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Datos personales',
                  style: TextStyle(
                    fontFamily: AppTheme.brandFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tu nombre real o nombre de guardian',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: AppTheme.brandFont,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nombre completo o de guardian',
                  style: TextStyle(
                    fontFamily: AppTheme.brandFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFE2EFF5) : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: TextStyle(
                    fontFamily: AppTheme.brandFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF0F2631).withValues(alpha: 0.55)
                        : Colors.white.withValues(alpha: 0.8),
                    hintText: 'Ingresa tu nombre completo',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.signalAqua : AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSavingName ? null : _handleSaveName,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    icon: _isSavingName
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined, size: 18),
                    label: Text(
                      _isSavingName ? 'Guardando...' : 'Guardar cambios',
                      style: TextStyle(
                        fontFamily: AppTheme.brandFont,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ─── Tarjeta 3: Detalles del Programa ──────────────────────────────────
          if (student != null) ...[
            GlassSurface(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        color: AppColors.accentLimnological,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Detalles del Programa',
                        style: TextStyle(
                          fontFamily: AppTheme.brandFont,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ProfileInfoRow(
                    icon: Icons.timer_outlined,
                    label: 'Horas Requeridas',
                    value: '${student.requiredHours.toStringAsFixed(0)} hrs',
                  ),
                  const Divider(height: 16),
                  _ProfileInfoRow(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Horas Acumuladas',
                    value: '${student.accumulatedHours.toStringAsFixed(1)} hrs',
                  ),
                  const Divider(height: 16),
                  _ProfileInfoRow(
                    icon: Icons.meeting_room_outlined,
                    label: 'Sala Asignada',
                    value: student.assignedRoom,
                  ),
                  const Divider(height: 16),
                  _ProfileInfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Modalidad',
                    value: student.studentTypeFormatted,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ─── Tarjeta 4: Tema de la Aplicación ─────────────────────────────────
          GlassSurface(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.palette_outlined,
                      color: AppColors.accentLimnological,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Tema de la Aplicación',
                      style: TextStyle(
                        fontFamily: AppTheme.brandFont,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded, size: 18),
                        label: Text('Claro'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded, size: 18),
                        label: Text('Oscuro'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.settings_suggest_rounded, size: 18),
                        label: Text('Sistema'),
                      ),
                    ],
                    selected: {themeMode},
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: isDark
                          ? AppColors.signalAqua.withValues(alpha: 0.25)
                          : AppColors.primary.withValues(alpha: 0.15),
                      selectedForegroundColor: isDark ? AppColors.signalAqua : AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onSelectionChanged: (Set<ThemeMode> newSelection) {
                      ref.read(themeModeProvider.notifier).setTheme(newSelection.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ─── Tarjeta: Notificaciones Push ─────────────────────────────────────
          GlassSurface(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.notifications_active_outlined,
                      color: AppColors.accentLimnological,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Notificaciones Push',
                        style: TextStyle(
                          fontFamily: AppTheme.brandFont,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: notificationState.isEnabled
                            ? AppColors.signalAqua.withValues(alpha: 0.18)
                            : AppColors.slateMuted.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: notificationState.isEnabled
                              ? AppColors.signalAqua.withValues(alpha: 0.4)
                              : AppColors.slateMuted.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        notificationState.isEnabled ? 'Activadas' : 'Inactivas',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: notificationState.isEnabled
                              ? (isDark ? AppColors.signalAqua : AppColors.primary)
                              : secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Recibe recordatorios de tus turnos, avisos de retardos, registro de asistencia y convocatorias a eventos especiales.',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: AppTheme.brandFont,
                    color: secondaryTextColor,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Permitir mensajes y alertas push',
                    style: TextStyle(
                      fontFamily: AppTheme.brandFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    notificationState.isEnabled
                        ? 'Notificaciones permitidas en este dispositivo'
                        : 'Toca para permitir alertas y recordatorios',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: AppTheme.brandFont,
                      color: secondaryTextColor,
                    ),
                  ),
                  value: notificationState.isEnabled,
                  activeColor: isDark ? AppColors.signalAqua : AppColors.primary,
                  onChanged: (val) async {
                    final success = await ref
                        .read(notificationProvider.notifier)
                        .setNotificationsEnabled(val);
                    if (!mounted) return;
                    if (val && !success) {
                      _showNotificationSettingsDialog(context);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ─── Tarjeta 5: Efecto de Vidrio (iOS Glass) ──────────────────────────
          GlassSurface(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.blur_on_rounded,
                      color: AppColors.accentLimnological,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Efecto de Vidrio (iOS Glass)',
                        style: TextStyle(
                          fontFamily: AppTheme.brandFont,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.signalAqua.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.signalAqua.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        '${(glassSettings.transparency * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.signalAqua : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Ajusta la transparencia en los menús y la navegación de la app. Se conserva el contraste del texto.',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: AppTheme.brandFont,
                    color: secondaryTextColor,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: isDark ? AppColors.signalAqua : AppColors.primary,
                    thumbColor: isDark ? AppColors.signalAqua : AppColors.primary,
                    inactiveTrackColor: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: glassSettings.transparency,
                    min: 0.10,
                    max: 0.85,
                    divisions: 15,
                    onChanged: (val) {
                      ref.read(glassSettingsProvider.notifier).setTransparency(val);
                    },
                  ),
                ),
                const Divider(height: 20),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(
                    Icons.border_style_rounded,
                    color: glassSettings.showBorders
                        ? (isDark ? AppColors.signalAqua : AppColors.accentLimnological)
                        : secondaryTextColor,
                  ),
                  title: Text(
                    'Contornos de Vidrio',
                    style: TextStyle(
                      fontFamily: AppTheme.brandFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Mostrar bordes decorativos alrededor del cristal de la app. Si desactivas esta opción, se mantendrán el desenfoque y la refracción.',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: AppTheme.brandFont,
                      color: secondaryTextColor,
                      height: 1.35,
                    ),
                  ),
                  value: glassSettings.showBorders,
                  activeColor: isDark ? AppColors.signalAqua : AppColors.primary,
                  onChanged: (val) {
                    ref.read(glassSettingsProvider.notifier).setShowBorders(val);
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Vista previa en tiempo real:',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: AppTheme.brandFont,
                    fontWeight: FontWeight.w600,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                GlassSurface(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: AppColors.signalAqua, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cristal a ${(glassSettings.transparency * 100).toInt()}% de transparencia',
                              style: TextStyle(
                                fontFamily: AppTheme.brandFont,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              glassSettings.showBorders
                                  ? 'Contornos de cristal activos'
                                  : 'Sin contornos (solo desenfoque y refracción)',
                              style: TextStyle(
                                fontFamily: AppTheme.brandFont,
                                fontSize: 11,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ─── Tarjeta 6: Cerrar Sesión y Pie de Página ─────────────────────────
          OutlinedButton.icon(
            key: const ValueKey('profile_sign_out_button'),
            onPressed: () => _confirmSignOut(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.terracottaRule,
              side: const BorderSide(color: AppColors.terracottaRule, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: Text(
              'CERRAR SESIÓN',
              style: TextStyle(
                fontFamily: AppTheme.brandFont,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '${AppConstants.institutionName} • ${AppConstants.appVersion}',
              style: TextStyle(
                fontSize: 11,
                fontFamily: AppTheme.brandFont,
                color: secondaryTextColor,
              ),
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'G';
    return Container(
      color: AppColors.primary,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 38,
          fontFamily: AppTheme.brandFont,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 20, color: isDark ? AppColors.signalAqua : AppColors.accentLimnological),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontFamily: AppTheme.brandFont,
              color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppTheme.brandFont,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
