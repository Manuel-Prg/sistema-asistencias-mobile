import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassSurface(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(22),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 46,
                backgroundColor: isDark
                    ? AppColors.primaryDeep
                    : AppColors.signalAqua.withValues(alpha: 0.18),
                backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: (avatarUrl == null || avatarUrl!.isEmpty)
                    ? Icon(
                        Icons.person_rounded,
                        size: 46,
                        color: isDark ? AppColors.signalAqua : AppColors.primary,
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: isDark ? AppColors.signalAqua : AppColors.primary,
                  shape: const CircleBorder(),
                  elevation: 3,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: isUpdatingPhoto ? null : onUploadPhoto,
                    child: const Padding(
                      padding: EdgeInsets.all(7),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
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
                  color: (isDark ? AppColors.signalAqua : AppColors.primary)
                      .withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (isDark ? AppColors.signalAqua : AppColors.primary)
                        .withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.school_rounded,
                      size: 13,
                      color: isDark ? AppColors.signalAqua : AppColors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      studentType,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.signalAqua : AppColors.primary,
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
          if (avatarUrl != null && avatarUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: isUpdatingPhoto ? null : onDeletePhoto,
              icon: const Icon(Icons.delete_outline,
                  size: 16, color: AppColors.terracottaRule),
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

