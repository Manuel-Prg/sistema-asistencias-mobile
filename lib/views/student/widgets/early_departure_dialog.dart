import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';

class EarlyDepartureReason {
  final String value;
  final String label;
  final String emoji;

  const EarlyDepartureReason({
    required this.value,
    required this.label,
    required this.emoji,
  });
}

const List<EarlyDepartureReason> kEarlyDepartureReasons = [
  EarlyDepartureReason(value: 'enfermedad', label: 'Enfermedad', emoji: '🤒'),
  EarlyDepartureReason(
      value: 'imprevisto', label: 'Imprevisto personal', emoji: '⚡'),
  EarlyDepartureReason(
      value: 'familiar', label: 'Emergencia familiar', emoji: '👨‍👩‍👧'),
  EarlyDepartureReason(value: 'otra', label: 'Otra razón', emoji: '📝'),
];

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
    final remainingHours = (minHoursRequired - widget.hoursWorked).clamp(0.0, minHoursRequired);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: GlassSurface(
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabecera con Icono de Alerta
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
                              color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Para registrar tu salida temprana, necesitamos conocer el motivo',
                            style: TextStyle(
                              fontFamily: AppTheme.brandFont,
                              fontSize: 13,
                              color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Tarjeta de Resumen de Horas (Hours Summary Card)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? const [
                              Color(0xFF2E1705),
                              Color(0xFF1E0E03),
                            ]
                          : const [
                              Color(0xFFFFFBEB),
                              Color(0xFFFFF7ED),
                            ],
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
                                      text: widget.hoursWorked.toStringAsFixed(2),
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
                                      style: TextStyle(
                                        fontFamily: AppTheme.brandFont,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFFEA580C),
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' hrs',
                                      style: TextStyle(
                                        fontFamily: AppTheme.brandFont,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFFF97316),
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
                ),
                const SizedBox(height: 18),

                // Lista de Motivos (Radio Cards)
                Text(
                  'Selecciona el motivo',
                  style: TextStyle(
                    fontFamily: AppTheme.brandFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                ...kEarlyDepartureReasons.map((reason) {
                  final isSelected = _selectedReason == reason.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedReason = reason.value);
                      },
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
                                      : (isDark ? const Color(0xFF536E7B) : AppColors.slateMuted),
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
                                  fontWeight:
                                      isSelected ? FontWeight.w700 : FontWeight.w500,
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
                }),

                // Área de texto si se seleccionó "Otra razón"
                if (_selectedReason == 'otra') ...[
                  const SizedBox(height: 6),
                  Text(
                    'Especifica la razón',
                    style: TextStyle(
                      fontFamily: AppTheme.brandFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _otherReasonController,
                    maxLength: 200,
                    maxLines: 3,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(
                      fontFamily: AppTheme.brandFont,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Por favor, describe brevemente el motivo de tu salida temprana...',
                      hintStyle: TextStyle(
                        fontFamily: AppTheme.brandFont,
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF7A93A0)
                            : AppColors.slateMuted.withValues(alpha: 0.7),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF0F2631).withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.8),
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.signalAqua : AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),

                // Botones de Acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontFamily: AppTheme.brandFont,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isValid && !_isLoading ? _handleConfirm : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark ? AppColors.signalAqua : AppColors.primary,
                          foregroundColor:
                              isDark ? const Color(0xFF07161D) : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: isDark
                              ? const Color(0xFF132F3C)
                              : AppColors.stoneBorder.withValues(alpha: 0.6),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark ? const Color(0xFF07161D) : Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Confirmar Salida',
                                style: TextStyle(
                                  fontFamily: AppTheme.brandFont,
                                  fontSize: 14,
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
