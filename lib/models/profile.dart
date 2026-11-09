class Profile {
  final String id;
  final String email;
  final String fullName;
  final String role; // "student" | "supervisor"
  final String? realName;
  final String? guardianName;
  final String? avatarUrl;
  final DateTime? createdAt;

  Profile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.realName,
    this.guardianName,
    this.avatarUrl,
    this.createdAt,
  });

  bool get isStudent => role == 'student';
  bool get isSupervisor => role == 'supervisor';

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      role: json['role'] as String? ?? 'student',
      realName: json['real_name'] as String?,
      guardianName: json['guardian_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'real_name': realName,
      'guardian_name': guardianName,
      'avatar_url': avatarUrl,
    };
  }
}

