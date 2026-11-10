import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_surface.dart';

class NotificationBanner extends StatelessWidget {
  final VoidCallback onActivate;
  final VoidCallback onClose;

  const NotificationBanner({
    super.key,
    required this.onActivate,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: BorderRadius.circular(14),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            color: AppColors.accentLimnological,
            size: 22,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Activa las notificaciones para recordatorios de turnos y avisos.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: onActivate,
            child: const Text(
              'Activar',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.signalAqua,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

