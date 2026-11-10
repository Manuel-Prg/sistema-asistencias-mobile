import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_surface.dart';
import '../../providers/student_provider.dart';

class EventsView extends ConsumerStatefulWidget {
  const EventsView({super.key});

  @override
  ConsumerState<EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends ConsumerState<EventsView> {
  final _eventNameController = TextEditingController();
  String _selectedShift = AppConstants.shiftMatutino;

  final List<String> _popularEvents = [
    'Noche de Museos',
    'Taller Infantil del Agua',
    'Conferencia Magistral',
    'Festival Cultural del Agua',
    'Visita Guiada Especial',
  ];

  @override
  void dispose() {
    _eventNameController.dispose();
    super.dispose();
  }

  Future<void> _handleEventCheckIn() async {
    final eventName = _eventNameController.text.trim();
    if (eventName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor escribe el nombre del evento.'),
          backgroundColor: AppColors.terracottaRule,
        ),
      );
      return;
    }

    final result = await ref.read(studentProvider.notifier).checkIn(
          room: eventName,
          shift: _selectedShift,
          isEvent: true,
        );

    if (mounted) {
      if (result.success) {
        _eventNameController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Entrada al evento registrada! (Acreditación doble activada)'),
            backgroundColor: AppColors.statusOnTime,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Error al registrar evento'),
            backgroundColor: AppColors.terracottaRule,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentState = ref.watch(studentProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasActiveSession = studentState.hasActiveSession;

    return GlassScaffold(
      appBar: const GlassAppBar(
        title: Text('Eventos Especiales'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Placa destacada de Acreditación Doble
            GlassSurface(
              padding: const EdgeInsets.all(18),
              borderRadius: BorderRadius.circular(18),
              tintColor: AppColors.accentLimnological,
              child: Row(
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    color: AppColors.signalAqua,
                    size: 36,
                  )
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.14, 1.14),
                        duration: 1500.ms,
                        curve: Curves.easeInOut,
                      )
                      .shimmer(duration: 2200.ms, color: Colors.white60),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Acreditación de Horas Dobles (2x)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Las horas registradas en eventos especiales autorizados se duplican automáticamente en tu acumulado.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (hasActiveSession) ...[
              GlassSurface(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(14),
                tintColor: AppColors.amberTolerance.withValues(alpha: 0.16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.amberTolerance,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Actualmente tienes una sesión activa en "${studentState.activeRecord?.cleanEventName}". Debes registrar tu salida en la pestaña de Inicio antes de ingresar a un evento.',
                        style: const TextStyle(fontSize: 13, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Formulario de registro a evento
            GlassSurface(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(18),
              enableRefraction: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Registrar Entrada a Evento',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _eventNameController,
                    enabled: !hasActiveSession,
                    decoration: InputDecoration(
                      labelText: 'Nombre del Evento',
                      hintText: 'Ej. Noche de Museos, Taller del Agua...',
                      prefixIcon: const Icon(Icons.event_note_rounded),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.white.withValues(alpha: 0.55),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Sugerencias rápidas:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slateMuted),
                  ),
                  const SizedBox(height: 8),
                  // Sugerencias de eventos rápidos en pastillas de cristal
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _popularEvents.map((ev) {
                      final isSelected = _eventNameController.text == ev;
                      return GestureDetector(
                        onTap: hasActiveSession
                            ? null
                            : () {
                                setState(() {
                                  _eventNameController.text = ev;
                                });
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? AppColors.signalAqua.withValues(alpha: 0.22)
                                    : AppColors.primary.withValues(alpha: 0.12))
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.white.withValues(alpha: 0.55)),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? AppColors.signalAqua : AppColors.primary)
                                  : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.primary.withValues(alpha: 0.15)),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            ev,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? (isDark ? AppColors.signalAqua : AppColors.primary)
                                  : (isDark ? AppColors.darkTextPrimary : AppColors.mineralInk),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Turno asignado:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _EventShiftOption(
                          label: 'Matutino',
                          hours: '11:00 - 14:00',
                          isSelected: _selectedShift == 'matutino',
                          onTap: hasActiveSession
                              ? () {}
                              : () => setState(() => _selectedShift = 'matutino'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _EventShiftOption(
                          label: 'Vespertino',
                          hours: '14:00 - 18:00',
                          isSelected: _selectedShift == 'vespertino',
                          onTap: hasActiveSession
                              ? () {}
                              : () => setState(() => _selectedShift = 'vespertino'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _EventShiftOption(
                          label: 'Completo',
                          hours: '11:00 - 18:00',
                          isSelected: _selectedShift == 'completo',
                          onTap: hasActiveSession
                              ? () {}
                              : () => setState(() => _selectedShift = 'completo'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: hasActiveSession || studentState.isLoading
                        ? null
                        : _handleEventCheckIn,
                    icon: const Icon(Icons.how_to_reg_rounded, size: 20),
                    label: const Text(
                      'REGISTRAR ENTRADA A EVENTO',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.signalAqua : AppColors.primary,
                      foregroundColor: isDark ? AppColors.abyssalGroundDark : Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _EventShiftOption extends StatelessWidget {
  final String label;
  final String hours;
  final bool isSelected;
  final VoidCallback onTap;

  const _EventShiftOption({
    required this.label,
    required this.hours,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppColors.signalAqua.withValues(alpha: 0.20)
                  : AppColors.primary.withValues(alpha: 0.12))
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.55)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.signalAqua : AppColors.primary)
                : (isDark
                    ? AppColors.darkBorder
                    : AppColors.primary.withValues(alpha: 0.14)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? AppColors.signalAqua : AppColors.primary)
                    : (isDark ? AppColors.darkTextPrimary : AppColors.mineralInk),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              hours,
              style: TextStyle(
                fontSize: 10,
                color:
                    isDark ? AppColors.darkTextSecondary : AppColors.slateMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

