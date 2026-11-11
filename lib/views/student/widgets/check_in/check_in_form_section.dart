import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_surface.dart';

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

  void _showGlassRoomPicker(
    BuildContext context,
    String currentRoom,
    ValueChanged<String> onSelected,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).colorScheme.primary;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.50),
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: GlassSurface(
            borderRadius: BorderRadius.circular(24),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            tintColor: isDark ? const Color(0xFF141418) : themePrimary,
            enableRefraction: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white30 : Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : themePrimary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.meeting_room_rounded,
                        size: 18,
                        color: isDark ? Colors.white : themePrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Selecciona tu sala asignada',
                      style: TextStyle(
                        fontFamily: AppTheme.brandFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.mineralInk,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 340),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: AppConstants.rooms.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final room = AppConstants.rooms[index];
                      final isSelected = room == currentRoom;
                      return InkWell(
                        onTap: () {
                          onSelected(room);
                          Navigator.of(ctx).pop();
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? themePrimary.withValues(
                                    alpha: isDark ? 0.35 : 0.18,
                                  )
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.white.withValues(alpha: 0.65)),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? Colors.white70 : themePrimary)
                                  : (isDark
                                      ? Colors.white12
                                      : AppColors.stoneBorder),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.door_sliding_outlined,
                                size: 18,
                                color: isSelected
                                    ? (isDark ? Colors.white : themePrimary)
                                    : (isDark
                                        ? Colors.white60
                                        : AppColors.slateMuted),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  room,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? (isDark ? Colors.white : themePrimary)
                                        : (isDark
                                            ? Colors.white
                                            : AppColors.mineralInk),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 18,
                                  color: isDark ? Colors.white : themePrimary,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Selecciona tu sala asignada:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark
                ? Colors.white.withValues(alpha: 0.90)
                : AppColors.mineralInk,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showGlassRoomPicker(
            context,
            selectedRoom,
            onRoomChanged,
          ),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.22)
                    : themePrimary.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.meeting_room_rounded,
                  size: 18,
                  color: isDark ? Colors.white70 : themePrimary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedRoom,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.mineralInk,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isDark ? Colors.white70 : themePrimary,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Turno de trabajo:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark
                ? Colors.white.withValues(alpha: 0.90)
                : AppColors.mineralInk,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? themePrimary.withValues(alpha: 0.35)
                  : themePrimary.withValues(alpha: 0.20))
              : (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.65)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isDark ? Colors.white : themePrimary)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : AppColors.stoneBorder),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : themePrimary)
                    : (isDark ? Colors.white : AppColors.mineralInk),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              timeRange,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : themePrimary)
                    : (isDark ? Colors.white60 : AppColors.slateMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

