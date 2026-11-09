class StudentSchedule {
  final String id;
  final String studentId;
  final int dayOfWeek; // 0=Lun, 1=Mar, 2=Mié, 3=Jue, 4=Vie, 5=Sáb, 6=Dom
  final String startTime; // "HH:mm"
  final String endTime; // "HH:mm"
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StudentSchedule({
    required this.id,
    required this.studentId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  String get dayName {
    switch (dayOfWeek) {
      case 0:
        return 'Lunes';
      case 1:
        return 'Martes';
      case 2:
        return 'Miércoles';
      case 3:
        return 'Jueves';
      case 4:
        return 'Viernes';
      case 5:
        return 'Sábado';
      case 6:
        return 'Domingo';
      default:
        return 'Día $dayOfWeek';
    }
  }

  factory StudentSchedule.fromJson(Map<String, dynamic> json) {
    return StudentSchedule(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      dayOfWeek: json['day_of_week'] as int? ?? 1,
      startTime: json['start_time'] as String? ?? '11:00',
      endTime: json['end_time'] as String? ?? '14:00',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'is_active': isActive,
    };
  }
}

