import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_food_repository_impl.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'food_name': foodName,
      'image_url': imageUrl,
      'total_mass_g': totalMassG,
      'calories_kcal': caloriesKcal,
      'protein_g': proteinG,
      'carbs_g': carbsG,
      'fat_g': fatG,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

abstract class FoodRepository {
  Future<List<FoodLogEntry>> getTodayLogs(String userId);
  Future<List<FoodLogEntry>> getRecentLogs(String userId, {int limit = 5});
  Future<void> saveFoodLog(FoodLogEntry entry);
  Future<void> deleteFoodLog(String logId, String userId); // Tambah method hapus
}

class FoodRepositoryImpl implements FoodRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<FoodLogEntry>> getTodayLogs(String userId) async {
    if (userId == 'guest') {
      return await LocalFoodRepositoryImpl().getTodayLogs(userId);
    }
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
    if (userId == 'guest') {
      return await LocalFoodRepositoryImpl().getRecentLogs(userId, limit: limit);
    }
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
    if (entry.userId == 'guest') {
      await LocalFoodRepositoryImpl().saveFoodLog(entry);
      return;
    }
    await _supabase.from('food_logs').insert(entry.toJson());
  }

  @override
  Future<void> deleteFoodLog(String logId, String userId) async {
    if (userId == 'guest') {
      await LocalFoodRepositoryImpl().deleteFoodLog(logId, userId);
      return;
    }
    await _supabase.from('food_logs').delete().eq('id', logId);
  }
}
