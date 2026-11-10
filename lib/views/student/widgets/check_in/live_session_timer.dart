import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';

class LiveSessionTimer extends StatelessWidget {
  final ValueNotifier<Duration> elapsedNotifier;

  const LiveSessionTimer({super.key, required this.elapsedNotifier});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.timer_outlined,
          color: AppColors.signalAqua,
          size: 20,
        )
            .animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            )
            .scale(
              begin: const Offset(0.92, 0.92),
              end: const Offset(1.18, 1.18),
              duration: 1000.ms,
              curve: Curves.easeInOut,
            ),
        const SizedBox(width: 8),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ValueListenableBuilder<Duration>(
              valueListenable: elapsedNotifier,
              builder: (context, elapsed, _) {
                return Text(
                  '${elapsed.inHours}h ${(elapsed.inMinutes % 60).toString().padLeft(2, '0')}m ${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}s transcurridos',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

