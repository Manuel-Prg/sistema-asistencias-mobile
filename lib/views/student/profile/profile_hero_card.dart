import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import 'profile_photo_viewer_dialog.dart';

class ProfileHeroCard extends StatelessWidget {
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String studentType;
  final String assignedRoom;
  final bool isUpdatingPhoto;
  final VoidCallback onUploadPhoto;
  final VoidCallback onDeletePhoto;

  const ProfileHeroCard({
    super.key,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    required this.studentType,
    required this.assignedRoom,
    required this.isUpdatingPhoto,
    required this.onUploadPhoto,
    required this.onDeletePhoto,
  });

  void _handlePhotoLongPress(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      HapticFeedback.mediumImpact();
      ProfilePhotoViewerDialog.show(
        context,
        imageUrl: avatarUrl!,
        fullName: fullName,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aún no tienes una foto de perfil asignada.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeThemeColor = Theme.of(context).colorScheme.primary;
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return GlassSurface(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(22),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomRight,
            children: [
              // Avatar con soporte de Tap (cambiar foto) y LongPress (expandir foto)
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: isUpdatingPhoto ? null : onUploadPhoto,
                  onLongPress: () => _handlePhotoLongPress(context),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: isDark
                        ? AppColors.primaryDeep
                        : AppColors.signalAqua.withValues(alpha: 0.18),
                    backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
                    child: isUpdatingPhoto
                        ? const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.signalAqua,
                            ),
                          )
                        : (!hasAvatar)
                            ? Icon(
                                Icons.person_rounded,
                                size: 48,
                                color: isDark
                                    ? AppColors.signalAqua
                                    : AppColors.primary,
                              )
                            : null,
                  ),
                ),
              ),

              // Botón flotante de cámara para cambiar foto
              Positioned(
                right: -2,
                bottom: -2,
                child: Material(
                  color: activeThemeColor,
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: isUpdatingPhoto ? null : onUploadPhoto,
                    child: const Padding(
                      padding: EdgeInsets.all(9),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            fullName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.brandFont,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              fontSize: 12,
              fontFamily: AppTheme.brandFont,
              color: isDark ? AppColors.darkTextSecondary : AppColors.slateMuted,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: activeThemeColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: activeThemeColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.school_rounded,
                      size: 13,
                      color: activeThemeColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      studentType,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: activeThemeColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white12 : AppColors.stoneBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.meeting_room_rounded,
                      size: 13,
                      color: AppColors.accentLimnological,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      assignedRoom,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasAvatar) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: isUpdatingPhoto ? null : onDeletePhoto,
              icon: const Icon(
                Icons.delete_outline,
                size: 16,
                color: AppColors.terracottaRule,
              ),
              label: const Text(
                'Eliminar foto',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.terracottaRule,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
