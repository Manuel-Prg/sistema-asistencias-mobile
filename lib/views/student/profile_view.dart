import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_surface.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_bar_style_provider.dart';
import '../../providers/student_provider.dart';
import 'profile/profile_footer.dart';
import 'profile/profile_hero_card.dart';
import 'profile/profile_personal_data_card.dart';
import 'profile/profile_photo_dialog.dart';
import 'profile/profile_progress_card.dart';
import 'profile/profile_sign_out_dialog.dart';
import 'settings_view.dart';

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
    final success = await ref
        .read(authProvider.notifier)
        .updateProfileName(newName);
    if (!mounted) return;
    setState(() => _isSavingName = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(child: Text('¡Nombre actualizado con éxito!')),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final error =
          ref.read(authProvider).errorMessage ?? 'Error al actualizar nombre.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.terracottaRule,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleDeletePhoto() async {
    setState(() => _isUpdatingPhoto = true);
    final success = await ref
        .read(authProvider.notifier)
        .updateProfileAvatar(null);
    if (!mounted) return;
    setState(() => _isUpdatingPhoto = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Foto de perfil eliminada.'
              : 'No fue posible eliminar la foto.',
        ),
        backgroundColor: success ? AppColors.primary : AppColors.terracottaRule,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final studentState = ref.watch(studentProvider);
    final barStyle = ref.watch(progressBarStyleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final profile = authState.profile;
    final student = studentState.student;

    final fullName = profile?.fullName ?? 'Estudiante';
    final email = authState.user?.email ?? '';
    final avatarUrl = profile?.avatarUrl;
    final studentType = student?.studentTypeFormatted ?? 'Servicio Social';
    final assignedRoom = student?.assignedRoom ?? 'Por asignar';
    final requiredHours = student?.requiredHours ?? 480;
    final accumulatedHours = student?.accumulatedHours ?? 0.0;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GlassScaffold(
      appBar: GlassAppBar(
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? AppColors.darkTextPrimary : primaryColor,
              size: 22,
            ),
            tooltip: 'Configuraciones',
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SettingsView())),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 130),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 2),
            child: Text(
              'Mi Perfil',
              style: TextStyle(
                fontSize: 24,
                fontFamily: AppTheme.brandFont,
                fontWeight: FontWeight.w800,
                color: primaryColor,
                letterSpacing: -0.4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 14),
            child: Text(
              'Información de servicio social y datos de tu cuenta',
              style: TextStyle(
                fontSize: 13,
                fontFamily: AppTheme.brandFont,
                color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
              ),
            ),
          ),
          ProfileHeroCard(
            fullName: fullName,
            email: email,
            avatarUrl: avatarUrl,
            studentType: studentType,
            assignedRoom: assignedRoom,
            isUpdatingPhoto: _isUpdatingPhoto,
            onUploadPhoto: () => ProfilePhotoDialog.show(
              context,
              ref,
              currentAvatarUrl: avatarUrl,
              onStartUpdate: () => setState(() => _isUpdatingPhoto = true),
              onFinishUpdate: () {
                if (mounted) setState(() => _isUpdatingPhoto = false);
              },
            ),
            onDeletePhoto: _handleDeletePhoto,
          ),
          const SizedBox(height: 16),
          ProfileProgressCard(
            accumulatedHours: accumulatedHours,
            requiredHours: requiredHours,
            barStyle: barStyle,
          ),
          const SizedBox(height: 16),
          ProfilePersonalDataCard(
            nameController: _nameController,
            isSavingName: _isSavingName,
            onSaveName: _handleSaveName,
          ),
          const SizedBox(height: 16),

          // Enlace directo a la nueva ventana exclusiva de Configuraciones
          GlassSurface(
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            enableRefraction: true,
            child: InkWell(
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsView())),
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(
                        alpha: isDark ? 0.25 : 0.12,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configuraciones del Sistema',
                          style: TextStyle(
                            fontFamily: AppTheme.brandFont,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.mineralInk,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tema, huella dactilar, notificaciones y preferencias',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.slateMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color: isDark ? Colors.white54 : AppColors.slateMuted,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ProfileFooter(
            onSignOut: () => ProfileSignOutDialog.show(context, ref),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
