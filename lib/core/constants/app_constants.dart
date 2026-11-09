class AppConstants {
  AppConstants._();

  static const String appName = 'Sistema de Asistencia';
  static const String institutionName = 'Casa Universitaria del Agua';
  static const String appVersion = '4.3.0 (Mobile)';

  // Salas oficiales
  static const List<String> rooms = [
    'Sala 1',
    'Sala 2',
    'Sala 2 y Galería',
    'Sala 3',
    'Sala 4',
    'Sala 4 y 5',
    'Todas',
    'Site',
  ];

  // Turnos oficiales
  static const String shiftMatutino = 'matutino';
  static const String shiftVespertino = 'vespertino';
  static const String shiftCompleto = 'completo';

  static const List<String> shifts = [
    shiftMatutino,
    shiftVespertino,
    shiftCompleto,
  ];

  // Horarios de turnos para referencia
  static const String scheduleMatutinoDesc = '11:00 AM - 2:00 PM';
  static const String scheduleVespertinoDesc = '2:00 PM - 6:00 PM';

  // Tolerancia de retardo (minutos)
  static const int lateToleranceMinutes = 15;

  // Límite de horas por sesión
  static const double maxStandardHours = 10.0;
  static const double maxEventHours = 20.0;
  static const double minShiftHours = 3.0; // Salida temprana si < 3h

  // Motivos de salida temprana
  static const List<String> earlyDepartureReasons = [
    'Enfermedad',
    'Imprevisto personal',
    'Emergencia familiar',
    'Otra razón',
  ];

  // Días de la semana del horario del estudiante (Martes a Domingo)
  // Schema en student_schedules: 0=Lun, 1=Mar, 2=Mié, 3=Jue, 4=Vie, 5=Sáb, 6=Dom
  static const Map<int, String> scheduleDaysMap = {
    1: 'Martes',
    2: 'Miércoles',
    3: 'Jueves',
    4: 'Viernes',
    5: 'Sábado',
    6: 'Domingo',
  };
}

