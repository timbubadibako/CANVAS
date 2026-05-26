import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/app_constants.dart';

class GeminiClient {
  static final GeminiClient _instance = GeminiClient._internal();
  factory GeminiClient() => _instance;
  GeminiClient._internal();

  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;

  void init() {
    _model = GenerativeModel(
      model: 	'gemini-2.5-flash',
      apiKey: AppConstants.geminiApiKey,
    );

    _visionModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppConstants.geminiApiKey,
    );
  }

  /// Menangani chat teks dengan Bot
  Future<String> getChatResponse(String prompt) async {
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text ?? "I couldn't process that masterpiece.";
  }

  /// Menangani analisis gambar makanan
  Future<String> analyzeFoodImage(List<int> imageBytes, String prompt) async {
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', Uint8List.fromList(imageBytes)),
      ]),
    ];
    final response = await _visionModel.generateContent(content);
    return response.text ?? "Detection failed.";
  }
}
