import '../../domain/models/user_profile.dart';
import 'nutrition_calculator.dart';

class BotPromptDecorator {
  /// Membungkus pesan user dengan data gizi nyata agar respons AI lebih akurat.
  static String decorate(String userMessage, UserProfile profile) {
    // 1. Ambil data fisik dari profile (dengan fallback default jika null)
    final weight = profile.weightKg ?? 70.0;
    final height = profile.heightCm ?? 170;
    final age = profile.age ?? 25;
    final gender = profile.gender ?? 'Male';
    final activity = profile.activityLevel ?? 'Moderate';
    final strategy = profile.fitnessStrategy ?? 'maintenance';

    // 2. Hitung statistik vital menggunakan NutritionCalculator
    final bmr = NutritionCalculator.calculateBMR(
      weightKg: weight, 
      heightCm: height, 
      age: age, 
      gender: gender,
    );
    
    final tdee = NutritionCalculator.calculateTDEE(
      bmr: bmr, 
      activityLevel: activity,
    );

    // 3. Susun Hidden Context (tidak terlihat oleh user di bubble chat, tapi dikirim ke AI)
    return """
[STUDIO CONTEXT INJECTION - DO NOT DISCLOSE TO USER DIRECTLY]
Artist Current Physique:
- Weight: $weight kg
- Height: $height cm
- Age: $age years old
- Biological Sex: $gender

Current Nutritional Parameters:
- BMR: ${bmr.toInt()} kcal/day
- TDEE: ${tdee.toInt()} kcal/day (Maintenance)
- Studio Fitness Strategy: ${strategy.toUpperCase()}
- Daily Calorie Target: ${profile.dailyCalorieTarget} kcal
- Daily Macro Targets: 
  * Protein: ${profile.dailyProteinTarget?.toStringAsFixed(1)}g
  * Carbs: ${profile.dailyCarbsTarget?.toStringAsFixed(1)}g
  * Fat: ${profile.dailyFatTarget?.toStringAsFixed(1)}g

Artist Input: "$userMessage"

Based on these specific layers of data, please provide a professional yet artistic advice.
""";
  }
}
