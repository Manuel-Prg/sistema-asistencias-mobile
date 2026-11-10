import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';

class ScheduleDayCard extends StatelessWidget {
  final String dayName;
  final bool isActive;
  final String startTime;
  final String endTime;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndTime;

  const ScheduleDayCard({
    super.key,
    required this.dayName,
    required this.isActive,
    required this.startTime,
    required this.endTime,
    required this.onToggleActive,
    required this.onPickStartTime,
    required this.onPickEndTime,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassSurface(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: BorderRadius.circular(16),
      tintColor: isActive
          ? (isDark
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.signalAqua.withValues(alpha: 0.10))
          : null,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isActive
                          ? (isDark ? AppColors.signalAqua : AppColors.primary)
                          : (isDark ? Colors.white10 : const Color(0xFFE5E2DC)),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        dayName.substring(0, 3).toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isActive
                              ? (isDark
                                  ? const Color(0xFF07161D)
                                  : Colors.white)
                              : (isDark ? Colors.white54 : AppColors.slateMuted),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTheme.brandFont,
                          color: isActive
                              ? (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.primary)
                              : (isDark ? Colors.white54 : AppColors.slateMuted),
                        ),
                      ),
                      Text(
                        isActive ? 'Asistencia programada' : 'Descanso / Sin turno',
                        style: TextStyle(
                          fontSize: 11,
                          color: isActive
                              ? (isDark
                                  ? AppColors.signalAqua
                                  : AppColors.accentLimnological)
                              : (isDark ? Colors.white38 : AppColors.slateMuted),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch.adaptive(
                value: isActive,
                activeTrackColor: AppColors.signalAqua,
                onChanged: onToggleActive,
              ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _TimePickerButton(
                    label: 'Entrada',
                    time: startTime,
                    onTap: onPickStartTime,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded,
                      size: 16, color: AppColors.slateMuted),
                ),
                Expanded(
                  child: _TimePickerButton(
                    label: 'Salida',
                    time: endTime,
                    onTap: onPickEndTime,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TimePickerButton extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;

  const _TimePickerButton({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? Colors.white12 : AppColors.stoneBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.access_time_rounded,
                size: 14, color: AppColors.signalAqua),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.slateMuted,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

