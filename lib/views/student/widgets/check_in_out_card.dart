import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../models/attendance_record.dart';
import 'check_in/active_session_section.dart';
import 'check_in/check_in_form_section.dart';
import 'early_departure_dialog.dart';

class CheckInOutCard extends StatefulWidget {
  final AttendanceRecord? activeRecord;
  final bool isLoading;
  final Function(String room, String shift) onCheckIn;
  final Function(String? earlyDepartureReason) onCheckOut;

  const CheckInOutCard({
    super.key,
    required this.activeRecord,
    required this.isLoading,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  @override
  State<CheckInOutCard> createState() => _CheckInOutCardState();
}

class _CheckInOutCardState extends State<CheckInOutCard> {
  String _selectedRoom = AppConstants.rooms.first;
  String _selectedShift = AppConstants.shiftMatutino;
  Timer? _timer;
  final ValueNotifier<Duration> _elapsedNotifier = ValueNotifier<Duration>(
    Duration.zero,
  );

  @override
  void initState() {
    super.initState();
    _startTimerIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CheckInOutCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeRecord?.id != oldWidget.activeRecord?.id) {
      _startTimerIfNeeded();
    }
  }

  void _startTimerIfNeeded() {
    _timer?.cancel();
    if (widget.activeRecord != null) {
      _updateElapsed();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _updateElapsed();
      });
    }
  }

  void _updateElapsed() {
    if (widget.activeRecord == null) return;
    final now = DateTime.now().toUtc();
    final checkIn = widget.activeRecord!.checkIn.toUtc();
    final diff = now.difference(checkIn);
    _elapsedNotifier.value = diff.isNegative ? Duration.zero : diff;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _elapsedNotifier.dispose();
    super.dispose();
  }

  void _handleCheckOut() {
    final now = DateTime.now().toUtc();
    final checkIn = widget.activeRecord?.checkIn.toUtc() ?? now;
    final diff = now.difference(checkIn);
    final hoursWorked =
        (diff.isNegative ? 0 : diff.inMilliseconds) / (1000 * 60 * 60);

    if (hoursWorked < AppConstants.minShiftHours) {
      EarlyDepartureDialog.show(
        context,
        hoursWorked: hoursWorked,
        onConfirm: (reason) {
          widget.onCheckOut(reason);
        },
      );
    } else {
      widget.onCheckOut(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasActive = widget.activeRecord != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).colorScheme.primary;

    return GlassSurface(
      tintColor: isDark ? const Color(0xFF141418) : themePrimary,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(22),
      enableRefraction: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: hasActive
                      ? (isDark ? Colors.white : themePrimary)
                      : (isDark
                            ? Colors.white54
                            : themePrimary.withValues(alpha: 0.5)),
                  shape: BoxShape.circle,
                  boxShadow: hasActive
                      ? [
                          BoxShadow(
                            color: (isDark ? Colors.white : themePrimary)
                                .withValues(alpha: 0.6),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  hasActive ? 'SESIÓN EN CURSO' : 'REGISTRO DE ASISTENCIA',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.mineralInk,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (!hasActive)
            CheckInFormSection(
              selectedRoom: _selectedRoom,
              selectedShift: _selectedShift,
              isLoading: widget.isLoading,
              onRoomChanged: (room) => setState(() => _selectedRoom = room),
              onShiftChanged: (shift) => setState(() => _selectedShift = shift),
              onSubmit: () => widget.onCheckIn(_selectedRoom, _selectedShift),
            )
          else
            ActiveSessionSection(
              record: widget.activeRecord!,
              elapsedNotifier: _elapsedNotifier,
              isLoading: widget.isLoading,
              onCheckOut: _handleCheckOut,
            ),
        ],
      ),
    );
  }
}
