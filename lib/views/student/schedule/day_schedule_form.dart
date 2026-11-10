class DayScheduleForm {
  final int dayOfWeek;
  String startTime;
  String endTime;
  bool isActive;

  DayScheduleForm({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });
}

