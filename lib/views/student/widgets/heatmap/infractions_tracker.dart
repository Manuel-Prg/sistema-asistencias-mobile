import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../models/infraction_models.dart';

class InfractionsTracker extends StatelessWidget {
  final StudentInfractions infractions;

  const InfractionsTracker({super.key, required this.infractions});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Límite de Faltas Injustificadas (Baja al llegar a 3):',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(3, (index) {
            final isReached = infractions.faltasCount > index;
            final isLast = index == 2;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isReached
                      ? (isLast
                            ? AppColors.statusFalta
                            : AppColors.terracottaRule)
                      : (isDark
                            ? const Color(0xFF162E3B)
                            : AppColors.stoneBorder.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isReached
                        ? (isLast ? Colors.redAccent : AppColors.terracottaRule)
                        : (isDark
                              ? AppColors.darkBorder
                              : AppColors.stoneBorder),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'FALTA ${index + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isReached
                            ? Colors.white
                            : (isDark
                                  ? const Color(0xFFC5D7DF)
                                  : AppColors.slateMuted),
                      ),
                    ),
                    if (isLast)
                      Text(
                        'Límite de Baja',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isReached
                              ? Colors.white70
                              : (isDark
                                    ? const Color(0xFFC5D7DF)
                                    : AppColors.slateMuted),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        const Text(
          'Retardos acumulados (3 retardos = 1 falta):',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(9, (index) {
            final isMarked = infractions.retardosCount > index;
            final isGroupEnd = (index + 1) % 3 == 0;
            return Expanded(
              child: Container(
                height: 24,
                margin: EdgeInsets.only(right: isGroupEnd && index < 8 ? 8 : 4),
                decoration: BoxDecoration(
                  color: isMarked
                      ? AppColors.statusLate
                      : (isDark
                            ? const Color(0xFF162E3B)
                            : AppColors.stoneBorder.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isMarked
                        ? AppColors.terracottaRule
                        : (isDark
                              ? AppColors.darkBorder
                              : AppColors.stoneBorder),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isMarked ? Colors.white : AppColors.slateMuted,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
