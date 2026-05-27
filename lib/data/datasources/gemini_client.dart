// import 'dart:convert';
import 'dart:typed_data';
// import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/app_constants.dart';

class GeminiClient {
  static final GeminiClient _instance = GeminiClient._internal();
  factory GeminiClient() => _instance;
  GeminiClient._internal();

  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;
  late final GenerativeModel _insightModel;

  void init() {
    print("[GeminiClient] Initializing...");
    // _listAvailableModels(); 
    
    try {
      _model = GenerativeModel(
        model: AppConstants.botModelName,
        apiKey: AppConstants.geminiApiKey,
        systemInstruction: Content.system(AppConstants.botSystemInstruction),
      );
      
      _visionModel = GenerativeModel(
        model: AppConstants.botModelName,
        apiKey: AppConstants.geminiApiKey,
        systemInstruction: Content.system(AppConstants.botSystemInstruction),
      );

      _insightModel = GenerativeModel(
        model: AppConstants.botModelName,
        apiKey: AppConstants.geminiApiKey,
        systemInstruction: Content.system(AppConstants.insightSystemInstruction),
      );
    } catch (e) {
      print("[GeminiClient] Init Error: $e");
    }
  }

  // Future<void> _listAvailableModels() async {
  //   final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=${AppConstants.geminiApiKey}');
  //   try {
  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       print("--- [GeminiClient] AVAILABLE MODELS ---");
  //       for (var m in data['models']) {
  //         print("Model: ${m['name']}");
  //       }
  //     }
  //   } catch (e) {
  //     print("[GeminiClient] listModels error: $e");
  //   }
  // }

  Future<String> getChatResponse(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? "I couldn't process that masterpiece.";
    } catch (e) {
      print("[GeminiClient] Chat Error: $e");
      rethrow;
    }
  }

  Future<String> getStudioInsight(String dataContext) async {
    try {
      final content = [Content.text("Analyze this: $dataContext")];
      final response = await _insightModel.generateContent(content);
      return response.text?.trim() ?? "Your progress canvas is expanding.";
    } catch (e) {
      print("[GeminiClient] Insight Error: $e");
      return "Keep the nutritional balance stable for a better masterpiece.";
    }
  }

  Future<String> analyzeFoodImage(List<int> imageBytes, String prompt) async {
    try {
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', Uint8List.fromList(imageBytes)),
        ])
      ];
      final response = await _visionModel.generateContent(content);
      return response.text ?? "Detection failed.";
    } catch (e) {
      print("[GeminiClient] Vision Error: $e");
      rethrow;
    }
  }
}
