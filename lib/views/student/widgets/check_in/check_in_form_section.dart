import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class CheckInFormSection extends StatelessWidget {
  final String selectedRoom;
  final String selectedShift;
  final bool isLoading;
  final ValueChanged<String> onRoomChanged;
  final ValueChanged<String> onShiftChanged;
  final VoidCallback onSubmit;

  const CheckInFormSection({
    super.key,
    required this.selectedRoom,
    required this.selectedShift,
    required this.isLoading,
    required this.onRoomChanged,
    required this.onShiftChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Selecciona tu sala asignada:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.88),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedRoom,
              dropdownColor: AppColors.primaryDeep,
              icon: const Icon(
                Icons.arrow_drop_down,
                color: AppColors.signalAqua,
              ),
              isExpanded: true,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              items: AppConstants.rooms.map((room) {
                return DropdownMenuItem(value: room, child: Text(room));
              }).toList(),
              onChanged: (val) {
                if (val != null) onRoomChanged(val);
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Turno de trabajo:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.88),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ShiftButton(
                label: 'Matutino',
                timeRange: '11:00 - 14:00',
                isSelected: selectedShift == AppConstants.shiftMatutino,
                onTap: () => onShiftChanged(AppConstants.shiftMatutino),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ShiftButton(
                label: 'Vespertino',
                timeRange: '14:00 - 18:00',
                isSelected: selectedShift == AppConstants.shiftVespertino,
                onTap: () => onShiftChanged(AppConstants.shiftVespertino),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ShiftButton(
                label: 'Completo',
                timeRange: '11:00 - 18:00',
                isSelected: selectedShift == AppConstants.shiftCompleto,
                onTap: () => onShiftChanged(AppConstants.shiftCompleto),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: isLoading ? null : onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            iconColor: Colors.white,
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
                    Icon(Icons.login_rounded, size: 20, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'REGISTRAR ENTRADA',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ],
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
          color: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.15),
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
                color: Colors.white,
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

