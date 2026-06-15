import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user_profile.dart';

class LocalProfileRepository {
  static const String _key = 'user_profile_local';

  Future<UserProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString(_key);
    
    if (profileJson == null) {
      // Return default guest profile
      return UserProfile(
        id: 'guest',
        fullName: 'Guest User',
        dailyCalorieTarget: 2000,
        dailyProteinTarget: 150,
        dailyCarbsTarget: 200,
        dailyFatTarget: 65,
        fitnessStrategy: 'maintenance',
        weightKg: 70,
        heightCm: 170,
        age: 25,
        gender: 'Male',
      );
    }
    
    return UserProfile.fromJson(jsonDecode(profileJson));
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }
}
