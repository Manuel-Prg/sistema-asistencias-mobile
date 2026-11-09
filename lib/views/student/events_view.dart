import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos Especiales'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Placa destacada de Acreditación Doble
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.accentLimnological,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.stars_rounded,
                    color: AppColors.signalAqua,
                    size: 36,
                  ),
                  SizedBox(width: 14),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.amberTolerance.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.amberTolerance),
                ),
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Evento',
                        hintText: 'Ej. Noche de Museos, Taller del Agua...',
                        prefixIcon: Icon(Icons.event_note_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Sugerencias de eventos rápidos
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _popularEvents.map((ev) {
                        return ActionChip(
                          label: Text(ev, style: const TextStyle(fontSize: 11)),
                          backgroundColor: isDark ? const Color(0xFF142B36) : AppColors.limestoneGround,
                          onPressed: hasActiveSession
                              ? null
                              : () {
                                  _eventNameController.text = ev;
                                },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Turno asignado:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF142B36) : AppColors.limestoneGround,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedShift,
                          isExpanded: true,
                          items: AppConstants.shifts.map((shift) {
                            return DropdownMenuItem(
                              value: shift,
                              child: Text(
                                'Turno ${shift[0].toUpperCase()}${shift.substring(1)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: hasActiveSession
                              ? null
                              : (val) {
                                  if (val != null) setState(() => _selectedShift = val);
                                },
                        ),
                      ),
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

