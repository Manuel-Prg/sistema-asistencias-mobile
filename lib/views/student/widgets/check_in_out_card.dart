import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/attendance_record.dart';
import 'early_departure_dialog.dart';

class CheckInOutCard extends StatefulWidget {
  final AttendanceRecord? activeRecord;
  final bool isLoading;
  final Function(String room, String shift) onCheckIn;
  final Function(String? earlyDepartureReason) onCheckOut;
  final VoidCallback onOpenActiveStudents;

  const CheckInOutCard({
    super.key,
    required this.activeRecord,
    required this.isLoading,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onOpenActiveStudents,
  });

  @override
  State<CheckInOutCard> createState() => _CheckInOutCardState();
}

class _CheckInOutCardState extends State<CheckInOutCard> {
  String _selectedRoom = AppConstants.rooms.first;
  String _selectedShift = AppConstants.shiftMatutino;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

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
    setState(() {
      _elapsed = DateTime.now().difference(widget.activeRecord!.checkIn);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleCheckOut() {
    // Si la sesión tiene menos de 3 horas, solicitar motivo de salida temprana
    if (_elapsed.inHours < AppConstants.minShiftHours) {
      EarlyDepartureDialog.show(
        context,
        elapsedTime: _elapsed,
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

    // Placa invertida en azul estanque `#0c3c4c` (punto focal del Design System)
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.primaryDeep,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header de la tarjeta
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: hasActive ? AppColors.signalAqua : Colors.white54,
                        shape: BoxShape.circle,
                        boxShadow: hasActive
                            ? [
                                BoxShadow(
                                  color: AppColors.signalAqua.withOpacity(0.6),
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
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.signalAqua,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Botón para ver activos en recinto
              GestureDetector(
                onTap: widget.onOpenActiveStudents,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.people_outline_rounded,
                          size: 14, color: AppColors.limestoneGround),
                      SizedBox(width: 6),
                      Text(
                        'Activos en Recinto',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.limestoneGround,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          if (!hasActive) ...[
            // ─── MODO ENTRADA ──────────────────────────────────────────
            const Text(
              'Selecciona tu sala asignada:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRoom,
                  dropdownColor: AppColors.primaryDeep,
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.signalAqua),
                  isExpanded: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  items: AppConstants.rooms.map((room) {
                    return DropdownMenuItem(
                      value: room,
                      child: Text(room),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRoom = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Turno de trabajo:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ShiftButton(
                    label: 'Matutino',
                    timeRange: '11:00 - 14:00',
                    isSelected: _selectedShift == AppConstants.shiftMatutino,
                    onTap: () => setState(() => _selectedShift = AppConstants.shiftMatutino),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ShiftButton(
                    label: 'Vespertino',
                    timeRange: '14:00 - 18:00',
                    isSelected: _selectedShift == AppConstants.shiftVespertino,
                    onTap: () => setState(() => _selectedShift = AppConstants.shiftVespertino),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.isLoading
                  ? null
                  : () => widget.onCheckIn(_selectedRoom, _selectedShift),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.limestoneGround,
                foregroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'REGISTRAR ENTRADA',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ] else ...[
            // ─── MODO SALIDA ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
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
                              widget.activeRecord!.cleanEventName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Turno ${widget.activeRecord!.shift.toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.signalAqua,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Entrada:',
                            style: TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                          Text(
                            AppDateUtils.formatTime(widget.activeRecord!.checkIn),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 14),
                  // Tiempo transcurrido
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined, color: AppColors.signalAqua, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${_elapsed.inHours}h ${(_elapsed.inMinutes % 60).toString().padLeft(2, '0')}m ${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')}s transcurridos',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.activeRecord!.isLate) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.amberTolerance.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.amberTolerance),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule_rounded,
                              size: 16, color: Colors.amberAccent),
                          const SizedBox(width: 6),
                          Text(
                            'Entrada con retardo (${widget.activeRecord!.lateMinutes ?? 0} min)',
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
              onPressed: widget.isLoading ? null : _handleCheckOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.terracottaRule,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: widget.isLoading
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
        ],
      ),
    );
  }
}

class _ShiftButton extends StatelessWidget {
  final String label;
  final String timeRange;
  final bool isSelected;
  final VoidCallback onTap;

  const _ShiftButton({
    required this.label,
    required this.timeRange,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.signalAqua : Colors.white.withOpacity(0.15),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.signalAqua : Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              timeRange,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white : Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

