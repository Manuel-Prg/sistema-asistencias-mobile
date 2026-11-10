import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class EarlyDepartureHoursSummary extends StatelessWidget {
  final double hoursWorked;
  final double remainingHours;

  const EarlyDepartureHoursSummary({
    super.key,
    required this.hoursWorked,
    required this.remainingHours,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF2E1705), Color(0xFF1E0E03)]
              : const [Color(0xFFFFFBEB), Color(0xFFFFF7ED)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF9A3412).withValues(alpha: 0.5)
              : const Color(0xFFFDE68A),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Horas trabajadas',
                    style: TextStyle(
                      fontFamily: AppTheme.brandFont,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFFCD34D)
                          : const Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: hoursWorked.toStringAsFixed(2),
                          style: TextStyle(
                            fontFamily: AppTheme.brandFont,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? const Color(0xFFFEF3C7)
                                : const Color(0xFF78350F),
                          ),
                        ),
                        TextSpan(
                          text: ' hrs',
                          style: TextStyle(
                            fontFamily: AppTheme.brandFont,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFFFCD34D)
                                : const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Horas faltantes',
                    style: TextStyle(
                      fontFamily: AppTheme.brandFont,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFFCD34D)
                          : const Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: remainingHours.toStringAsFixed(2),
                          style: const TextStyle(
                            fontFamily: AppTheme.brandFont,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFEA580C),
                          ),
                        ),
                        const TextSpan(
                          text: ' hrs',
                          style: TextStyle(
                            fontFamily: AppTheme.brandFont,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFF97316),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? const Color(0xFF7C2D12).withValues(alpha: 0.6)
                      : const Color(0xFFFCD34D),
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: AppColors.amberTolerance,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Se requieren 3 horas mínimas por turno',
                    style: TextStyle(
                      fontFamily: AppTheme.brandFont,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFFCD34D)
                          : const Color(0xFF92400E),
                    ),
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

