class AttendanceRecord {
  final String id;
  final String studentId;
  final String? studentType;
  final DateTime checkIn;
  final DateTime? checkOut;
  final String shift; // "matutino" | "vespertino" | "completo"
  final String room;
  final double? hoursWorked;
  final String? earlyDepartureReason;
  final bool isLate;
  final bool isJustified;
  final int? lateMinutes;
  final DateTime? createdAt;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    this.studentType,
    required this.checkIn,
    this.checkOut,
    required this.shift,
    required this.room,
    this.hoursWorked,
    this.earlyDepartureReason,
    this.isLate = false,
    this.isJustified = false,
    this.lateMinutes,
    this.createdAt,
  });

  bool get isActive => checkOut == null;
  bool get isEvent => room.startsWith('[EVENTO]');

  /// Nombre limpio del evento si aplica
  String get cleanEventName {
    if (isEvent) {
      return room.replaceFirst('[EVENTO]', '').trim();
    }
    return room;
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      studentType: json['student_type'] as String?,
      checkIn: DateTime.parse(json['check_in'] as String),
      checkOut: json['check_out'] != null
          ? DateTime.parse(json['check_out'] as String)
          : null,
      shift: json['shift'] as String? ?? 'matutino',
      room: json['room'] as String? ?? 'Sala 1',
      hoursWorked: (json['hours_worked'] as num?)?.toDouble(),
      earlyDepartureReason: json['early_departure_reason'] as String?,
      isLate: json['is_late'] as bool? ?? false,
      isJustified: json['is_justified'] as bool? ?? false,
      lateMinutes: json['late_minutes'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_type': studentType,
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut?.toIso8601String(),
      'shift': shift,
      'room': room,
      'hours_worked': hoursWorked,
      'early_departure_reason': earlyDepartureReason,
      'is_late': isLate,
      'is_justified': isJustified,
      'late_minutes': lateMinutes,
    };
  }
}

