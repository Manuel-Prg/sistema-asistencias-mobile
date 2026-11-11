import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import 'early_departure/early_departure_hours_summary.dart';
import 'early_departure/early_departure_reason_model.dart';
import 'early_departure/early_departure_reason_tile.dart';

export 'early_departure/early_departure_reason_model.dart';

class EarlyDepartureDialog extends StatefulWidget {
  final double hoursWorked;
  final Future<void> Function(String reason)? onConfirmAsync;
  final ValueChanged<String>? onConfirm;

  const EarlyDepartureDialog({
    super.key,
    required this.hoursWorked,
    this.onConfirmAsync,
    this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    Duration? elapsedTime,
    double? hoursWorked,
    ValueChanged<String>? onConfirm,
    Future<void> Function(String reason)? onConfirmAsync,
  }) {
    final computedHours = hoursWorked ??
        (elapsedTime != null ? elapsedTime.inSeconds / 3600.0 : 0.0);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EarlyDepartureDialog(
        hoursWorked: computedHours,
        onConfirm: onConfirm,
        onConfirmAsync: onConfirmAsync,
      ),
    );
  }

  @override
  State<EarlyDepartureDialog> createState() => _EarlyDepartureDialogState();
}

class _EarlyDepartureDialogState extends State<EarlyDepartureDialog> {
  String? _selectedReason;
  final TextEditingController _otherReasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  bool get _isValid {
    if (_selectedReason == null || _selectedReason!.isEmpty) return false;
    if (_selectedReason == 'otra') {
      return _otherReasonController.text.trim().isNotEmpty;
    }
    return true;
  }

  Future<void> _handleConfirm() async {
    if (!_isValid || _isLoading) return;

    final String finalReason;
    if (_selectedReason == 'otra') {
      finalReason = 'Otra: ${_otherReasonController.text.trim()}';
    } else {
      final match = kEarlyDepartureReasons.firstWhere(
        (r) => r.value == _selectedReason,
        orElse: () => kEarlyDepartureReasons.first,
      );
      finalReason = match.label;
    }

    setState(() => _isLoading = true);
    try {
      if (widget.onConfirmAsync != null) {
        await widget.onConfirmAsync!(finalReason);
      } else if (widget.onConfirm != null) {
        widget.onConfirm!(finalReason);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const double minHoursRequired = 3.0;
    final remainingHours =
        (minHoursRequired - widget.hoursWorked).clamp(0.0, minHoursRequired);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: GlassSurface(
          tintColor: isDark ? const Color(0xFF141418) : Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF451A03).withValues(alpha: 0.6)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFFB45309).withValues(alpha: 0.4)
                              : const Color(0xFFFDE68A),
                        ),
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.amberTolerance,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aún no completas tus horas',
                            style: TextStyle(
                              fontFamily: AppTheme.brandFont,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Para registrar tu salida temprana, necesitamos conocer el motivo',
                            style: TextStyle(
                              fontFamily: AppTheme.brandFont,
                              fontSize: 13,
                              color: isDark
                                  ? const Color(0xFFC5D7DF)
                                  : AppColors.slateMuted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                EarlyDepartureHoursSummary(
                  hoursWorked: widget.hoursWorked,
                  remainingHours: remainingHours,
                ),
                const SizedBox(height: 18),
                Text(
                  'Selecciona el motivo',
                  style: TextStyle(
                    fontFamily: AppTheme.brandFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color:
                        isDark ? AppColors.darkTextPrimary : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                ...kEarlyDepartureReasons.map((reason) {
                  return EarlyDepartureReasonTile(
                    reason: reason,
                    isSelected: _selectedReason == reason.value,
                    onTap: () =>
                        setState(() => _selectedReason = reason.value),
                  );
                }),
                if (_selectedReason == 'otra') ...[
                  const SizedBox(height: 6),
                  Text(
                    'Especifica la razón',
                    style: TextStyle(
                      fontFamily: AppTheme.brandFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _otherReasonController,
                    maxLines: 2,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Describe brevemente el motivo...',
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF0F2631).withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.stoneBorder,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.stoneBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontFamily: AppTheme.brandFont,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.mineralInk,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (_isValid && !_isLoading)
                            ? _handleConfirm
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.terracottaRule,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Confirmar Salida',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
