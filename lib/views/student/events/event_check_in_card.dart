import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import 'event_shift_selector.dart';

class EventCheckInCard extends StatelessWidget {
  final TextEditingController eventNameController;
  final String selectedShift;
  final List<String> popularEvents;
  final bool hasActiveSession;
  final bool isLoading;
  final ValueChanged<String> onSelectShift;
  final ValueChanged<String> onSelectPopularEvent;
  final VoidCallback onSubmit;

  const EventCheckInCard({
    super.key,
    required this.eventNameController,
    required this.selectedShift,
    required this.popularEvents,
    required this.hasActiveSession,
    required this.isLoading,
    required this.onSelectShift,
    required this.onSelectPopularEvent,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).colorScheme.primary;

    return GlassSurface(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_available_rounded,
                color: themePrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Registrar Entrada a Evento',
                style: TextStyle(
                  fontFamily: AppTheme.brandFont,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: themePrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: eventNameController,
            enabled: !hasActiveSession,
            decoration: InputDecoration(
              labelText: 'Nombre del Evento',
              hintText: 'Ej. Noche de Museos, Taller del Agua...',
              prefixIcon: Icon(
                Icons.event_note_rounded,
                size: 20,
                color: themePrimary,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.65),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sugerencias rápidas:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.slateMuted,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: popularEvents.map((ev) {
              final isSelected = eventNameController.text == ev;
              return InkWell(
                onTap: hasActiveSession ? null : () => onSelectPopularEvent(ev),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                              ? themePrimary.withValues(alpha: 0.35)
                              : themePrimary.withValues(alpha: 0.12))
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : const Color(0xFFF0ECE6)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? (isDark ? Colors.white70 : themePrimary)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    ev,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? Colors.white : themePrimary)
                          : (isDark ? Colors.white70 : AppColors.slateMuted),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'Turno de trabajo:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.slateMuted,
            ),
          ),
          const SizedBox(height: 8),
          EventShiftSelector(
            selectedShift: selectedShift,
            enabled: !hasActiveSession,
            onSelectShift: onSelectShift,
          ),
          if (hasActiveSession) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.amberTolerance.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.amberTolerance.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.amberTolerance,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tienes un turno activo en curso. Registra tu salida en Inicio antes de entrar a un evento.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? const Color(0xFFFEF3C7)
                            : const Color(0xFF92400E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: hasActiveSession || isLoading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: themePrimary,
              foregroundColor: Colors.white,
              iconColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.how_to_reg_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'REGISTRAR ENTRADA A EVENTO',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
