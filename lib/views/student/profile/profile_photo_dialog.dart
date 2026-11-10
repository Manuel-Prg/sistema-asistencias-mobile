import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../providers/auth_provider.dart';

class ProfilePhotoDialog {
  static void show(
    BuildContext context,
    WidgetRef ref, {
    required VoidCallback onStartUpdate,
    required VoidCallback onFinishUpdate,
  }) {
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => GlassDialog(
        title: const Text('Actualizar foto de perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingresa el enlace directo a tu fotografía (WebP, JPG o PNG):',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                hintText: 'https://ejemplo.com/mifoto.jpg',
                prefixIcon: const Icon(Icons.link_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final url = urlController.text.trim();
              if (url.isEmpty) return;
              Navigator.of(ctx).pop();
              onStartUpdate();
              final success = await ref
                  .read(authProvider.notifier)
                  .updateProfileAvatar(url);
              onFinishUpdate();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '¡Foto de perfil actualizada!'
                          : 'No fue posible guardar la foto.',
                    ),
                    backgroundColor:
                        success ? AppColors.primary : AppColors.terracottaRule,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

