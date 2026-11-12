import 'package:flutter/material.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).colorScheme.primary;

    return GlassSurface(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: BorderRadius.circular(14),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active_outlined,
            color: isDark ? Colors.white : themePrimary,
            size: 22,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Activa las notificaciones para avisarte del llenado de reporte en los primeros 5 días hábiles y su entrega a fin de mes.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: onActivate,
            child: Text(
              'Activar',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : themePrimary,
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

