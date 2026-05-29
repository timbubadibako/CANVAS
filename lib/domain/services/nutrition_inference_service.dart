import 'dart:io';

class NutritionInferenceResult {
  final double calories;
  final double mass;
  final double fat;
  final double carb;
  final double protein;
  final String source; // 'cloud_fastapi' or 'local_onnx'

  NutritionInferenceResult({
    required this.calories,
    required this.mass,
    required this.fat,
    required this.carb,
    required this.protein,
    required this.source,
  });

  factory NutritionInferenceResult.fromJson(Map<String, dynamic> json) {
    return NutritionInferenceResult(
      calories: (json['calories'] as num).toDouble(),
      mass: (json['mass'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carb: (json['carb'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      source: json['source'] as String,
    );
  }
}

abstract class NutritionInferenceService {
  Future<NutritionInferenceResult> predict({
    required File imageTop,
    required File imageSide1,
    required File imageSide2,
  });
}
