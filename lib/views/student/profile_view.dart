import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_surface.dart';
import '../../providers/auth_provider.dart';
import '../../providers/glass_settings_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracottaRule,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final studentState = ref.watch(studentProvider);
    final themeMode = ref.watch(themeModeProvider);
    final glassSettings = ref.watch(glassSettingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final profile = authState.profile;
    final student = studentState.student;

    final fullName = profile?.fullName ?? 'Estudiante';
    final email = profile?.email ?? authState.user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header del perfil
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : 'E',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    fullName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.slateMuted,
                    ),
                  ),
                  if (student != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentLimnological.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        student.studentTypeFormatted,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentLimnological,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Información académica
          if (student != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalles del Programa',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Selector de Tema (Claro / Oscuro / Sistema)
          GlassSurface(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.palette_outlined, color: AppColors.accentLimnological, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Tema de la Aplicación',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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

          // Efectos de Vidrio y Cristal (iOS Glass)
          GlassSurface(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.blur_on_rounded, color: AppColors.accentLimnological, size: 22),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Efecto de Vidrio (iOS Glass)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
                const Text(
                  'Ajusta la transparencia en los menús y la navegación de la app. Se conserva el contraste del texto.',
                  style: TextStyle(fontSize: 12, color: AppColors.slateMuted, height: 1.35),
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
                        ? AppColors.accentLimnological
                        : AppColors.slateMuted,
                  ),
                  title: const Text(
                    'Contornos de Vidrio',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Mostrar bordes decorativos alrededor del cristal de la app. Si desactivas esta opción, se mantendrán el desenfoque y la refracción.',
                    style: TextStyle(fontSize: 12, color: AppColors.slateMuted, height: 1.35),
                  ),
                  value: glassSettings.showBorders,
                  activeColor: isDark ? AppColors.signalAqua : AppColors.primary,
                  onChanged: (val) {
                    ref.read(glassSettingsProvider.notifier).setShowBorders(val);
                  },
                ),
                const SizedBox(height: 12),
                // Muestra de cristal en tiempo real
                const Text(
                  'Vista previa en tiempo real:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slateMuted,
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
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              glassSettings.showBorders
                                  ? 'Contornos de cristal activos'
                                  : 'Sin contornos (solo desenfoque y refracción)',
                              style: const TextStyle(fontSize: 11, color: AppColors.slateMuted),
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

          // Botón de Cerrar Sesión
          OutlinedButton.icon(
            key: const ValueKey('profile_sign_out_button'),
            onPressed: () => _confirmSignOut(context, ref),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.terracottaRule,
              side: const BorderSide(color: AppColors.terracottaRule, width: 1.5),
            ),
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: const Text('CERRAR SESIÓN'),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              '${AppConstants.institutionName} • ${AppConstants.appVersion}',
              style: TextStyle(fontSize: 11, color: AppColors.slateMuted),
            ),
          ),
          const SizedBox(height: 90),
        ],
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
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.accentLimnological),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.slateMuted),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

