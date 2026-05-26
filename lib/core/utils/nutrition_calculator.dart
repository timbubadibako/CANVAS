class NutritionCalculator {
  /// 1. Menghitung BMR (Mifflin-St Jeor)
  static double calculateBMR({
    required double weightKg,
    required int heightCm,
    required int age,
    required String gender,
  }) {
    double bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    if (gender == 'Male') {
      return bmr + 5;
    } else {
      return bmr - 161;
    }
  }

  /// 2. Menghitung TDEE berdasarkan BMR dan Activity Level
  static double calculateTDEE({
    required double bmr,
    required String activityLevel,
  }) {
    switch (activityLevel) {
      case 'Sedentary': return bmr * 1.2;
      case 'Moderate': return bmr * 1.55;
      case 'Active': return bmr * 1.725;
      default: return bmr * 1.2;
    }
  }

  /// 3. Menghitung Target Kalori berdasarkan Strategy
  static int calculateTargetCalories({
    required double tdee,
    required String fitnessStrategy,
  }) {
    switch (fitnessStrategy.toLowerCase()) {
      case 'cutting': return (tdee - 500).round(); // Defisit 500 kcal
      case 'bulking': return (tdee + 300).round(); // Surplus 300 kcal
      case 'maintenance':
      default: return tdee.round();
    }
  }

  /// 4. Menghitung Rasio Makronutrien (Gram)
  static Map<String, double> calculateMacros({
    required int targetCalories,
    required double weightKg,
    required String fitnessStrategy,
  }) {
    double proteinGramPerKg = (fitnessStrategy.toLowerCase() == 'cutting') ? 2.2 : 2.0;
    double targetProtein = weightKg * proteinGramPerKg;

    // Sisa kalori
    double remainingKcal = targetCalories - (targetProtein * 4);

    // Lemak dialokasikan 25% dari total kalori
    double targetFatKcal = targetCalories * 0.25;
    double targetFat = targetFatKcal / 9;

    // Karbohidrat mengambil sisa kalori
    double targetCarbsKcal = remainingKcal - targetFatKcal;
    double targetCarbs = targetCarbsKcal / 4;

    // Jika karbohidrat negatif (kalori terlalu ekstrem), set ke 0
    if (targetCarbs < 0) targetCarbs = 0;

    return {
      'protein': targetProtein,
      'fat': targetFat,
      'carbs': targetCarbs,
    };
  }
}
