import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_surface.dart';

class EventsBannerCard extends StatelessWidget {
  const EventsBannerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(18),
      tintColor: AppColors.accentLimnological,
      child: Row(
        children: [
          Icon(
            Icons.stars_rounded,
            color: AppColors.signalAqua,
            size: 38,
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.14, 1.14),
                duration: 1500.ms,
                curve: Curves.easeInOut,
              )
              .shimmer(duration: 2200.ms, color: Colors.white60),
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

