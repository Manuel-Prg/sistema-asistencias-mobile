import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_surface.dart';

class PunctualityWarningDialog {
  static void show(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return GlassDialog(
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.amberTolerance,
                size: 28,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Aviso de Puntualidad',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }
}

