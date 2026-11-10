import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_surface.dart';

class ResourceSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const ResourceSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      borderRadius: BorderRadius.circular(16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          icon: const Icon(
            Icons.search_rounded,
            color: AppColors.signalAqua,
            size: 22,
          ),
          hintText: 'Buscar por nombre o descripción...',
          hintStyle: TextStyle(
            fontSize: 13,
            color: isDark
                ? const Color(0xFF8FA7B2)
                : AppColors.slateMuted.withValues(alpha: 0.8),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          fillColor: Colors.transparent,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: onClear,
                )
              : null,
        ),
      ),
    );
  }
}

