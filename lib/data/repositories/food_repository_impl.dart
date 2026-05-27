import 'package:supabase_flutter/supabase_flutter.dart';

class FoodLogEntry {
  final String id;
  final String userId;
  final String foodName;
  final String? imageUrl;
  final double totalMassG;
  final double caloriesKcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final DateTime createdAt;

  FoodLogEntry({
    required this.id,
    required this.userId,
    required this.foodName,
    this.imageUrl,
    required this.totalMassG,
    required this.caloriesKcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.createdAt,
  });

  factory FoodLogEntry.fromJson(Map<String, dynamic> json) {
    return FoodLogEntry(
      id: json['id'],
      userId: json['user_id'],
      foodName: json['food_name'],
      imageUrl: json['image_url'],
      totalMassG: json['total_mass_g']?.toDouble() ?? 0.0,
      caloriesKcal: json['calories_kcal']?.toDouble() ?? 0.0,
      proteinG: json['protein_g']?.toDouble() ?? 0.0,
      carbsG: json['carbs_g']?.toDouble() ?? 0.0,
      fatG: json['fat_g']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

abstract class FoodRepository {
  Future<List<FoodLogEntry>> getTodayLogs(String userId);
  Future<List<FoodLogEntry>> getRecentLogs(String userId, {int limit = 5});
  Future<void> saveFoodLog(FoodLogEntry entry);
}

class FoodRepositoryImpl implements FoodRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<FoodLogEntry>> getTodayLogs(String userId) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
    
    final response = await _supabase
        .from('food_logs')
        .select()
        .eq('user_id', userId)
        .gte('created_at', todayStart)
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => FoodLogEntry.fromJson(json)).toList();
  }

  @override
  Future<List<FoodLogEntry>> getRecentLogs(String userId, {int limit = 5}) async {
    final response = await _supabase
        .from('food_logs')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);
    
    return (response as List).map((json) => FoodLogEntry.fromJson(json)).toList();
  }

  @override
  Future<void> saveFoodLog(FoodLogEntry entry) async {
    await _supabase.from('food_logs').insert({
      'user_id': entry.userId,
      'food_name': entry.foodName,
      'image_url': entry.imageUrl,
      'total_mass_g': entry.totalMassG,
      'calories_kcal': entry.caloriesKcal,
      'protein_g': entry.proteinG,
      'carbs_g': entry.carbsG,
      'fat_g': entry.fatG,
      'created_at': entry.createdAt.toIso8601String(),
    });
  }
}
