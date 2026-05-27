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
    final file = File(filePath);
    final fileExt = filePath.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final path = '$userId/$fileName';

    await _supabase.storage.from('avatars').upload(path, file);
    
    final imageUrl = _supabase.storage.from('avatars').getPublicUrl(path);
    await _supabase.from('profiles').update({'avatar_url': imageUrl}).eq('id', userId);
  }
}
