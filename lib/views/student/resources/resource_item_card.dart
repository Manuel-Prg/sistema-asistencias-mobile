import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_surface.dart';
import 'student_resource_model.dart';

class ResourceItemCard extends StatelessWidget {
  final StudentResource resource;
  final bool isCopied;
  final void Function(String url) onOpen;
  final void Function(String id, String url, String title) onCopy;

  const ResourceItemCard({
    super.key,
    required this.resource,
    required this.isCopied,
    required this.onOpen,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassSurface(
      margin: const EdgeInsets.only(bottom: 14),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: resource.accentColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.stoneBorder,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        resource.iconEmoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: resource.accentColor.withValues(
                          alpha: isDark ? 0.22 : 0.12,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: resource.accentColor.withValues(
                            alpha: 0.40,
                          ),
                        ),
                      ),
                      child: Text(
                        resource.category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.signalAqua
                              : resource.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  resource.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.mineralInk,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  resource.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFFC5D7DF)
                        : AppColors.slateMuted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => onOpen(resource.url),
                        icon: const Icon(
                          Icons.open_in_new_rounded,
                          size: 16,
                        ),
                        label: const Text(
                          'Abrir recurso',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.signalAqua
                              : AppColors.primary,
                          foregroundColor: isDark
                              ? AppColors.abyssalGroundDark
                              : Colors.white,
                          minimumSize: const Size.fromHeight(42),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Tooltip(
                      message: 'Copiar enlace',
                      child: OutlinedButton(
                        onPressed: () => onCopy(
                          resource.id,
                          resource.url,
                          resource.title,
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(44, 42),
                          padding: EdgeInsets.zero,
                          side: BorderSide(
                            color: isCopied
                                ? AppColors.signalAqua
                                : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.stoneBorder),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Icon(
                          isCopied
                              ? Icons.check_rounded
                              : Icons.copy_rounded,
                          size: 18,
                          color: isCopied
                              ? AppColors.signalAqua
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.mineralInk),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

