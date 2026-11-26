import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/profile.dart';
import '../../models/student.dart';

/// Operaciones de perfil, datos del estudiante y subida de avatar en Supabase.
class SupabaseProfileService {
  SupabaseProfileService._();

  static SupabaseClient get _client => Supabase.instance.client;

  static Future<Profile?> getProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return Profile.fromJson(response);
  }

  static Future<Student?> getStudentData(String userId) async {
    final response = await _client
        .from('students')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return Student.fromJson(response);
  }

  static Future<void> updateProfile({
    required String userId,
    required String fullName,
    String? realName,
    String? guardianName,
    String? avatarUrl,
    bool updateAvatar = false,
  }) async {
    final Map<String, dynamic> data = {
      'full_name': fullName,
      'real_name': realName ?? fullName,
      'guardian_name': guardianName ?? fullName,
    };
    if (updateAvatar) {
      data['avatar_url'] = avatarUrl;
    }
    await _client.from('profiles').update(data).eq('id', userId);
  }

  static Future<String> uploadProfileAvatar({
    required String userId,
    required Uint8List bytes,
    String? currentAvatarUrl,
  }) async {
    String bucket = 'avatars';
    if (currentAvatarUrl != null && currentAvatarUrl.isNotEmpty) {
      final uri = Uri.tryParse(currentAvatarUrl);
      if (uri != null) {
        final segments = uri.pathSegments;
        final publicIdx = segments.indexOf('public');
        if (publicIdx != -1 && publicIdx + 1 < segments.length) {
          bucket = segments[publicIdx + 1];
        }
      }
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '$userId/avatar_$timestamp.jpg';

    try {
      await _client.storage
          .from(bucket)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );
      return _client.storage.from(bucket).getPublicUrl(filePath);
    } catch (_) {
      if (bucket != 'avatars') {
        await _client.storage
            .from('avatars')
            .uploadBinary(
              filePath,
              bytes,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: true,
              ),
            );
        return _client.storage.from('avatars').getPublicUrl(filePath);
      }
      rethrow;
    }
  }
}
