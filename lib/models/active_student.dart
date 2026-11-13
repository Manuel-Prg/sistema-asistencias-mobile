class ActiveStudent {
  final String id;
  final String fullName;
  final String room;
  final String shift;
  final DateTime checkIn;
  final String? avatarUrl;

  ActiveStudent({
    required this.id,
    required this.fullName,
    required this.room,
    required this.shift,
    required this.checkIn,
    this.avatarUrl,
  });

  factory ActiveStudent.fromJson(Map<String, dynamic> json) {
    return ActiveStudent(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'Estudiante',
      room: json['room'] as String? ?? 'Sala',
      shift: json['shift'] as String? ?? 'matutino',
      checkIn: json['check_in'] != null
          ? DateTime.parse(json['check_in'] as String)
          : DateTime.now(),
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
