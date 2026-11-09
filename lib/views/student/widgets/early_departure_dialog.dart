import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class EarlyDepartureDialog extends StatefulWidget {
  final Duration elapsedTime;
  final ValueChanged<String> onConfirm;

  const EarlyDepartureDialog({
    super.key,
    required this.elapsedTime,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required Duration elapsedTime,
    required ValueChanged<String> onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EarlyDepartureDialog(
        elapsedTime: elapsedTime,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<EarlyDepartureDialog> createState() => _EarlyDepartureDialogState();
}

class _EarlyDepartureDialogState extends State<EarlyDepartureDialog> {
  String _selectedReason = AppConstants.earlyDepartureReasons.first;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = widget.elapsedTime.inHours;
    final minutes = widget.elapsedTime.inMinutes % 60;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.pondCardDark : AppColors.sillarCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.stoneBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.amberTolerance.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.amberTolerance,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Salida Anticipada de Turno',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF142C38) : AppColors.limestoneGround,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
                ),
              ),
              child: Text(
                'Llevas ${hours}h ${minutes}m de sesión activa. Para registrar tu salida antes de cumplir el mínimo de 3 horas, el reglamento de la Casa Universitaria del Agua solicita declarar el motivo para auditoría.',
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Selecciona el motivo:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...AppConstants.earlyDepartureReasons.map((reason) {
              final isSelected = _selectedReason == reason;
              return RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  reason,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                value: reason,
                groupValue: _selectedReason,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedReason = value);
                  }
                },
              );
            }),
            if (_selectedReason == 'Otra razón') ...[
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Describe brevemente la razón...',
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String finalReason = _selectedReason;
                if (_selectedReason == 'Otra razón' &&
                    _noteController.text.trim().isNotEmpty) {
                  finalReason = 'Otra: ${_noteController.text.trim()}';
                }
                Navigator.of(context).pop();
                widget.onConfirm(finalReason);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.terracottaRule,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar Salida Temprana'),
            ),
          ],
        ),
      ),
    );
  }
}

