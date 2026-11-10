import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import 'early_departure_reason_model.dart';

class EarlyDepartureReasonTile extends StatelessWidget {
  final EarlyDepartureReason reason;
  final bool isSelected;
  final VoidCallback onTap;

  const EarlyDepartureReasonTile({
    super.key,
    required this.reason,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? AppColors.signalAqua.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.08))
                : (isDark
                    ? const Color(0xFF0F2631).withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.7)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? (isDark ? AppColors.signalAqua : AppColors.primary)
                  : (isDark ? AppColors.darkBorder : AppColors.stoneBorder),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? (isDark ? AppColors.signalAqua : AppColors.primary)
                        : (isDark
                            ? const Color(0xFF536E7B)
                            : AppColors.slateMuted),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? AppColors.signalAqua
                                : AppColors.primary,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                reason.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  reason.label,
                  style: TextStyle(
                    fontFamily: AppTheme.brandFont,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.white : AppColors.primary)
                        : (isDark
                            ? const Color(0xFFC5D7DF)
                            : AppColors.slateMuted),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

