import '../../domain/models/user_profile.dart';

class BotPromptDecorator {
  /// Membungkus pesan user dengan data gizi nyata agar respons AI lebih akurat.
  static String decorate(String userMessage, UserProfile profile, {
    double consumedKcal = 0,
    double consumedProtein = 0,
    double consumedCarbs = 0,
    double consumedFat = 0,
  }) {
    // 1. Data Fisik
    final weight = profile.weightKg ?? 70.0;
    final height = profile.heightCm ?? 170;
    final age = profile.age ?? 25;
    final gender = profile.gender ?? 'Male';
    final strategy = profile.fitnessStrategy ?? 'maintenance';

    // 2. Kalkulasi BMI & Status
    final heightM = height / 100;
    final bmi = weight / (heightM * heightM);
    String bmiStatus = "Healthy";
    if (bmi < 18.5) {
      bmiStatus = "Underweight";
    } else if (bmi >= 25 && bmi < 30) {
      bmiStatus = "Overweight";
    } else if (bmi >= 30) {
      bmiStatus = "Obese";
    }

    // 3. Sisa Kuota Gizi
    final remainingKcal = profile.dailyCalorieTarget - consumedKcal;

    return """
[STUDIO REAL-TIME CONTEXT INJECTION]
Artist ID: ${profile.id}
Current Physique: $weight kg, $height cm, $age yrs ($gender)
BMI Analysis: ${bmi.toStringAsFixed(1)} ($bmiStatus)

Studio Progress Today:
- Consumed: ${consumedKcal.toInt()} / ${profile.dailyCalorieTarget} kcal (Remaining: ${remainingKcal.toInt()} kcal)
- Macros (Current/Target):
  * Protein: ${consumedProtein.toInt()}g / ${profile.dailyProteinTarget?.toInt()}g
  * Carbs: ${consumedCarbs.toInt()}g / ${profile.dailyCarbsTarget?.toInt()}g
  * Fat: ${consumedFat.toInt()}g / ${profile.dailyFatTarget?.toInt()}g

Current Fitness Strategy: ${strategy.toUpperCase()}
User Message: "$userMessage"

Operational Command: Use the parameters above to provide precise, supportive, and coach-like advice in Indonesian.
""";
  }
}
