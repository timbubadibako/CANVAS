import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:onnxruntime/onnxruntime.dart';
import '../../domain/services/nutrition_inference_service.dart';

class LocalOnnxService implements NutritionInferenceService {
  OrtSession? _session;
  final String _assetPath = 'assets/models/canvas_multiview_premium_fp16.onnx';

  Future<void> _initSession() async {
    try {
      if (_session != null) return;
      
      print('[LocalOnnx] Exporting asset model to local filesystem...');
      final byteData = await rootBundle.load(_assetPath);
      final bytes = byteData.buffer.asUint8List();
      
      final dir = await getApplicationDocumentsDirectory();
      final localModelFile = File('${dir.path}/model.onnx');
      await localModelFile.writeAsBytes(bytes);

      print('[LocalOnnx] Initializing session with physical path: ${localModelFile.path}');
      final sessionOptions = OrtSessionOptions();
      _session = OrtSession.fromFile(localModelFile, sessionOptions);
      print('[LocalOnnx] Session initialized successfully.');
    } catch (e) {
      print('[LocalOnnx] FATAL SESSION INIT ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<NutritionInferenceResult> predict({
    required File imageTop,
    required File imageSide1,
    required File imageSide2,
  }) async {
    try {
      print('[LocalOnnx] Starting FP16 predict workflow...');
      await _initSession();

      final res1 = await _runInference(imageTop);
      final res2 = await _runInference(imageSide1);
      final res3 = await _runInference(imageSide2);

      final results = [res1, res2, res3];

      double avgKcal = 0, avgMass = 0, avgFat = 0, avgCarb = 0, avgPro = 0;
      for (var res in results) {
        avgKcal += res.calories;
        avgMass += res.mass;
        avgFat += res.fat;
        avgCarb += res.carb;
        avgPro += res.protein;
      }

      final count = results.length;
      return NutritionInferenceResult(
        calories: avgKcal / count,
        mass: avgMass / count,
        fat: avgFat / count,
        carb: avgCarb / count,
        protein: avgPro / count,
        source: 'local_onnx',
      );
    } catch (e) {
      print('[LocalOnnx] FATAL PREDICT ERROR: $e');
      rethrow;
    }
  }

  Future<NutritionInferenceResult> _runInference(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception("Failed to decode image");
    final resized = img.copyResize(image, width: 224, height: 224);

    // PREPROCESSING FP16
    final totalPixels = 3 * 224 * 224;
    final float16Bits = Uint16List(totalPixels);

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        
        // ImageNet Normalization (Float32)
        double r = ((pixel.r / 255.0) - 0.485) / 0.229;
        double g = ((pixel.g / 255.0) - 0.456) / 0.224;
        double b = ((pixel.b / 255.0) - 0.406) / 0.225;

        // Convert to FP16 Bits and store in Uint16List
        float16Bits[0 * 224 * 224 + y * 224 + x] = _doubleToFloat16(r);
        float16Bits[1 * 224 * 224 + y * 224 + x] = _doubleToFloat16(g);
        float16Bits[2 * 224 * 224 + y * 224 + x] = _doubleToFloat16(b);
      }
    }

    final inputName = _session!.inputNames.first;
    // Use createTensorWithDataList which is available in gtbluesky plugin
    final inputTensor = OrtValueTensor.createTensorWithDataList(
      float16Bits,
      [1, 3, 224, 224],
    );

    final runOptions = OrtRunOptions();
    final outputs = _session!.run(runOptions, {inputName: inputTensor});
    
    if (outputs.isEmpty) throw Exception("Model returned no results");

    final rawOutput = outputs.first?.value;
    List<double> finalValues = [];

    if (rawOutput is List<double>) {
      finalValues = rawOutput;
    } else if (rawOutput is List<num>) {
      finalValues = rawOutput.map((e) => e.toDouble()).toList();
    } else if (rawOutput is Uint16List) {
      // Output is also FP16, convert back to double
      finalValues = rawOutput.map((bits) => _float16ToDouble(bits)).toList();
    }

    inputTensor.release();
    
    return NutritionInferenceResult(
      calories: finalValues[0],
      mass: finalValues[1],
      fat: finalValues[2],
      carb: finalValues[3],
      protein: finalValues[4],
      source: 'local_onnx',
    );
  }

  /// IEEE 754 Half-Precision Conversion (Float32 to Bits)
  int _doubleToFloat16(double value) {
    final bdata = ByteData(4)..setFloat32(0, value, Endian.little);
    int f32 = bdata.getUint32(0, Endian.little);
    int sign = (f32 >> 16) & 0x8000;
    int exponent = ((f32 >> 23) & 0xff) - 127;
    int mantissa = f32 & 0x007fffff;
    if (exponent <= -15) return sign;
    if (exponent >= 16) return sign | 0x7c00;
    return sign | ((exponent + 15) << 10) | (mantissa >> 13);
  }

  /// IEEE 754 Half-Precision Conversion (Bits to Double)
  double _float16ToDouble(int bits) {
    int sign = (bits & 0x8000) != 0 ? -1 : 1;
    int exponent = (bits & 0x7c00) >> 10;
    int mantissa = bits & 0x03ff;
    if (exponent == 0) return sign * math.pow(2, -14) * (mantissa / 1024.0);
    if (exponent == 0x1f) return mantissa != 0 ? double.nan : (sign * double.infinity);
    return sign * math.pow(2, exponent - 15) * (1 + mantissa / 1024.0);
  }
}
