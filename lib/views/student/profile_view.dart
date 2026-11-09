import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
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

          // Preferencias (Modo Oscuro / Claro)
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: AppColors.primary,
                ),
                title: const Text(
                  'Modo Oscuro',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  isDark ? 'Tema oscuro activado' : 'Tema claro activado',
                  style: const TextStyle(fontSize: 12, color: AppColors.slateMuted),
                ),
                value: themeMode == ThemeMode.dark,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Botón de Cerrar Sesión
          OutlinedButton.icon(
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
          const SizedBox(height: 20),
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
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

