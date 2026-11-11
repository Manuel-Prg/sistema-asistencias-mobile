import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import 'profile/profile_footer.dart';
import 'profile/profile_hero_card.dart';
import 'profile/profile_personal_data_card.dart';
import 'profile/profile_photo_dialog.dart';
import 'profile/profile_progress_card.dart';
import 'profile/profile_sign_out_dialog.dart';
import 'profile/profile_theme_card.dart';

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
    final success =
        await ref.read(authProvider.notifier).updateProfileName(newName);
    if (!mounted) return;
    setState(() => _isSavingName = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(child: Text('¡Nombre actualizado con éxito!')),
            ],
          ),
          backgroundColor: AppColors.primary,
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
    final success =
        await ref.read(authProvider.notifier).updateProfileAvatar(null);
    if (!mounted) return;
    setState(() => _isUpdatingPhoto = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Foto de perfil eliminada.'
              : 'No fue posible eliminar la foto.',
        ),
        backgroundColor:
            success ? AppColors.primary : AppColors.terracottaRule,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final studentState = ref.watch(studentProvider);
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

    return GlassScaffold(
      appBar: const GlassAppBar(),
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
                color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                letterSpacing: -0.4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 14),
            child: Text(
              'Administra tus datos personales y preferencias de la aplicación',
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
          ),
          const SizedBox(height: 16),
          ProfilePersonalDataCard(
            nameController: _nameController,
            isSavingName: _isSavingName,
            onSaveName: _handleSaveName,
          ),
          const SizedBox(height: 16),
          const ProfileThemeCard(),
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
