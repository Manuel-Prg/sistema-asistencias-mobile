class Student {
  final String id;
  final String studentType; // "servicio_social" | "practicas" | "convenio_dual"
  final double requiredHours;
  final String assignedRoom;
  final double accumulatedHours;
  final String? status; // 'active' | 'completed'
  final DateTime? completedAt;
  final DateTime? createdAt;

  Student({
    required this.id,
    required this.studentType,
    required this.requiredHours,
    required this.assignedRoom,
    required this.accumulatedHours,
    this.status,
    this.completedAt,
    this.createdAt,
  });

  bool get isCompleted =>
      status == 'completed' || accumulatedHours >= requiredHours;

  double get progressPercentage {
    if (requiredHours <= 0) return 0.0;
    final percent = (accumulatedHours / requiredHours) * 100;
    return percent > 100 ? 100 : percent;
  }

  double get remainingHours {
    final remaining = requiredHours - accumulatedHours;
    return remaining < 0 ? 0 : remaining;
  }

  String get studentTypeFormatted {
    switch (studentType) {
      case 'servicio_social':
        return 'Servicio Social';
      case 'practicas':
        return 'Prácticas Profesionales';
      case 'convenio_dual':
        return 'Convenio Dual';
      default:
        return studentType;
    }
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      studentType: json['student_type'] as String? ?? 'servicio_social',
      requiredHours: (json['required_hours'] as num?)?.toDouble() ?? 480.0,
      assignedRoom: json['assigned_room'] as String? ?? 'Sala 1',
      accumulatedHours: (json['accumulated_hours'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_type': studentType,
      'required_hours': requiredHours,
      'assigned_room': assignedRoom,
      'accumulated_hours': accumulatedHours,
      'status': status,
    };
  }
}
