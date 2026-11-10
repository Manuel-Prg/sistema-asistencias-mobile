import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'student_resource_model.dart';

class ResourceCategoryChips extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;

  const ResourceCategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: kResourceCategories.map((cat) {
          final isSelected = selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelectCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? AppColors.signalAqua
                          : AppColors.primary)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.white.withValues(alpha: 0.65)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? (isDark
                            ? AppColors.signalAqua
                            : AppColors.primary)
                        : (isDark
                            ? AppColors.darkBorder
                            : AppColors.primary.withValues(alpha: 0.15)),
                    width: 1,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? (isDark
                            ? AppColors.abyssalGroundDark
                            : Colors.white)
                        : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.mineralInk),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

