import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/services/nutrition_inference_service.dart';

class CloudInferenceService implements NutritionInferenceService {
  // --- ISI URL FASTAPI KAMU DISINI ---
  final String _baseUrl = "https://xvcs1ml0-8000.asse.devtunnels.ms";

  @override
  Future<NutritionInferenceResult> predict({
    required File imageTop,
    required File imageSide1,
    required File imageSide2,
  }) async {
    final url = Uri.parse("$_baseUrl/api/v1/predict/multimodal");
    final request = http.MultipartRequest('POST', url);

    request.files.add(
      await http.MultipartFile.fromPath('image_top', imageTop.path),
    );
    request.files.add(
      await http.MultipartFile.fromPath('image_side_1', imageSide1.path),
    );
    request.files.add(
      await http.MultipartFile.fromPath('image_side_2', imageSide2.path),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(responseBody);
      return NutritionInferenceResult.fromJson(data);
    } else {
      throw Exception("Cloud Inference Failed: ${response.statusCode}");
    }
  }
}
