import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../models/attendance_record.dart';
import 'live_session_timer.dart';

class ActiveSessionSection extends StatelessWidget {
  final AttendanceRecord record;
  final ValueNotifier<Duration> elapsedNotifier;
  final bool isLoading;
  final VoidCallback onCheckOut;

  const ActiveSessionSection({
    super.key,
    required this.record,
    required this.elapsedNotifier,
    required this.isLoading,
    required this.onCheckOut,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : themePrimary.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.cleanEventName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.mineralInk,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Turno ${record.shift.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : themePrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Entrada:',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white70 : AppColors.slateMuted,
                        ),
                      ),
                      Text(
                        AppDateUtils.formatTime(record.checkIn),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.mineralInk,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(
                color: isDark ? Colors.white24 : AppColors.stoneBorder,
                height: 1,
              ),
              const SizedBox(height: 14),
              LiveSessionTimer(elapsedNotifier: elapsedNotifier),
              if (record.isLate) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.amberTolerance.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.amberTolerance),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: Colors.amberAccent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Entrada con retardo (${record.lateMinutes ?? 0} min)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.amberAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: isLoading ? null : onCheckOut,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.terracottaRule,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'REGISTRAR SALIDA',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
