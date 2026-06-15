import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'food_repository_impl.dart';

class LocalFoodRepositoryImpl implements FoodRepository {
  final String _key = 'food_logs_guest';

  @override
  Future<List<FoodLogEntry>> getTodayLogs(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? logsJson = prefs.getString(_key);
    if (logsJson == null) return [];
    
    final List<dynamic> logsList = jsonDecode(logsJson);
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    return logsList
        .map((json) => FoodLogEntry.fromJson(json))
        .where((entry) => entry.createdAt.isAfter(todayStart))
        .toList();
  }

  @override
  Future<List<FoodLogEntry>> getRecentLogs(String userId, {int limit = 5}) async {
    final prefs = await SharedPreferences.getInstance();
    final String? logsJson = prefs.getString(_key);
    if (logsJson == null) return [];
    
    final List<dynamic> logsList = jsonDecode(logsJson);
    final logs = logsList.map((json) => FoodLogEntry.fromJson(json)).toList();
    logs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return logs.take(limit).toList();
  }

  @override
  Future<void> saveFoodLog(FoodLogEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final String? logsJson = prefs.getString(_key);
    List<FoodLogEntry> logs = [];
    
    if (logsJson != null) {
      logs = (jsonDecode(logsJson) as List).map((json) => FoodLogEntry.fromJson(json)).toList();
    }
    
    logs.add(entry);
    await prefs.setString(_key, jsonEncode(logs.map((e) => e.toJson()).toList()));
  }

  @override
  Future<void> deleteFoodLog(String logId, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? logsJson = prefs.getString(_key);
    if (logsJson == null) return;
    
    List<FoodLogEntry> logs = (jsonDecode(logsJson) as List).map((json) => FoodLogEntry.fromJson(json)).toList();
    logs.removeWhere((log) => log.id == logId);
    await prefs.setString(_key, jsonEncode(logs.map((e) => e.toJson()).toList()));
  }
}
