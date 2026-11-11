import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/widgets/glass_surface.dart';

class EventsBannerCard extends StatelessWidget {
  const EventsBannerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).colorScheme.primary;

    return GlassSurface(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(18),
      tintColor: isDark ? const Color(0xFF141418) : themePrimary,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: Color(0xFFFFB800),
              size: 30,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(0.96, 0.96),
                end: const Offset(1.08, 1.08),
                duration: 1500.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Acreditación de Horas Dobles (2x)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Las horas registradas en eventos especiales autorizados se duplican automáticamente en tu acumulado.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
