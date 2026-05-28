import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<UserProfile> getProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return UserProfile.fromJson(response);
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    await _supabase
        .from('profiles')
        .upsert(profile.toJson());
  }

  @override
  Future<void> updateAvatar(String userId, String filePath) async {
    try {
      final file = File(filePath);
      final fileExt = filePath.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = '$userId/$fileName';

      print('[ProfileRepo] Attempting to upload avatar to storage: $path');
      await _supabase.storage.from('avatars').upload(path, file);
      print('[ProfileRepo] Upload successful.');
      
      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(path);
      print('[ProfileRepo] Public URL generated: $imageUrl');
      
      print('[ProfileRepo] Updating profiles table for user: $userId');
      await _supabase.from('profiles').update({'avatar_url': imageUrl}).eq('id', userId);
      print('[ProfileRepo] Database update successful.');
    } catch (e) {
      print('[ProfileRepo] FATAL ERROR in updateAvatar: $e');
      rethrow;
    }
  }
}
