class UserProfile {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? gender;
  final int? age;
  final int? heightCm;
  final double? weightKg;
  final String? primaryGoal;
  final String? dietaryPalette;
  final String? activityLevel;
  final String? motivation;
  final String? fitnessStrategy;
  final int dailyCalorieTarget;
  final double? dailyProteinTarget;
  final double? dailyCarbsTarget;
  final double? dailyFatTarget;

  UserProfile({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.gender,
    this.age,
    this.heightCm,
    this.weightKg,
    this.primaryGoal,
    this.dietaryPalette,
    this.activityLevel,
    this.motivation,
    this.fitnessStrategy,
    this.dailyCalorieTarget = 2000,
    this.dailyProteinTarget,
    this.dailyCarbsTarget,
    this.dailyFatTarget,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      gender: json['gender'],
      age: json['age'],
      heightCm: json['height_cm'],
      weightKg: json['weight_kg']?.toDouble(),
      primaryGoal: json['primary_goal'],
      dietaryPalette: json['dietary_palette'],
      activityLevel: json['activity_level'],
      motivation: json['motivation'],
      fitnessStrategy: json['fitness_strategy'],
      dailyCalorieTarget: json['daily_calorie_target'] ?? 2000,
      dailyProteinTarget: json['daily_protein_target']?.toDouble(),
      dailyCarbsTarget: json['daily_carbs_target']?.toDouble(),
      dailyFatTarget: json['daily_fat_target']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (gender != null) 'gender': gender,
      if (age != null) 'age': age,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (primaryGoal != null) 'primary_goal': primaryGoal,
      if (dietaryPalette != null) 'dietary_palette': dietaryPalette,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (motivation != null) 'motivation': motivation,
      if (fitnessStrategy != null) 'fitness_strategy': fitnessStrategy,
      'daily_calorie_target': dailyCalorieTarget,
      if (dailyProteinTarget != null) 'daily_protein_target': dailyProteinTarget,
      if (dailyCarbsTarget != null) 'daily_carbs_target': dailyCarbsTarget,
      if (dailyFatTarget != null) 'daily_fat_target': dailyFatTarget,
    };
  }
}
