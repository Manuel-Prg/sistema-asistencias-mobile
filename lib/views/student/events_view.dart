import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../providers/student_provider.dart';
import 'events/event_check_in_card.dart';
import 'events/event_history_card.dart';
import 'events/events_banner_card.dart';

class EventsView extends ConsumerStatefulWidget {
  const EventsView({super.key});

  @override
  ConsumerState<EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends ConsumerState<EventsView> {
  final TextEditingController _eventNameController = TextEditingController();
  String _selectedShift = 'matutino';

  final List<String> _popularEvents = [
    'Noche de Museos',
    'Taller del Agua',
    'Feria Ambiental',
    'Casita del Agua Móvil',
    'El Agua es Extraterrestre',
  ];

  @override
  void dispose() {
    _eventNameController.dispose();
    super.dispose();
  }

  void _handleEventCheckIn() {
    final eventName = _eventNameController.text.trim();
    if (eventName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa o selecciona el nombre del evento.'),
          backgroundColor: AppColors.terracottaRule,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref
        .read(studentProvider.notifier)
        .checkIn(room: eventName, shift: _selectedShift, isEvent: true);

    _eventNameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final studentState = ref.watch(studentProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final eventHistory = studentState.history.where((r) => r.isEvent).toList();
    final double totalEventHours = eventHistory.fold(
      0.0,
      (sum, r) => sum + (r.hoursWorked ?? 0.0),
    );

    return GlassScaffold(
      appBar: const GlassAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 130),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 2),
            child: Text(
              'Eventos Especiales',
              style: TextStyle(
                fontSize: 24,
                fontFamily: AppTheme.brandFont,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: -0.4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 14),
            child: Text(
              'Participa en actividades institucionales y acredita horas dobles',
              style: TextStyle(
                fontSize: 13,
                fontFamily: AppTheme.brandFont,
                color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
              ),
            ),
          ),
          const EventsBannerCard(),
          const SizedBox(height: 16),
          EventCheckInCard(
            eventNameController: _eventNameController,
            selectedShift: _selectedShift,
            popularEvents: _popularEvents,
            hasActiveSession: studentState.hasActiveSession,
            isLoading: studentState.isLoading,
            onSelectShift: (shift) => setState(() => _selectedShift = shift),
            onSelectPopularEvent: (ev) =>
                setState(() => _eventNameController.text = ev),
            onSubmit: _handleEventCheckIn,
          ),
          const SizedBox(height: 16),
          EventHistoryCard(
            eventHistory: eventHistory,
            totalEventHours: totalEventHours,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
