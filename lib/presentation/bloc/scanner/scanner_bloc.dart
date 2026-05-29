import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/services/nutrition_inference_service.dart';

// --- Events ---
abstract class ScannerEvent {}

class ScannerCaptureStepRequested extends ScannerEvent {
  final File image;
  ScannerCaptureStepRequested(this.image);
}

class ScannerResetRequested extends ScannerEvent {}

// --- States ---
abstract class ScannerState {}

class ScannerInitial extends ScannerState {}

class ScannerCapturing extends ScannerState {
  final int step; // 0, 1, 2
  final List<File> capturedImages;
  ScannerCapturing(this.step, this.capturedImages);
}

class ScannerProcessing extends ScannerState {}

class ScannerSuccess extends ScannerState {
  final NutritionInferenceResult result;
  ScannerSuccess(this.result);
}

class ScannerFailure extends ScannerState {
  final String message;
  ScannerFailure(this.message);
}

// --- BLoC ---
class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final NutritionInferenceService _cloudService;
  final NutritionInferenceService _localService;

  ScannerBloc({
    required NutritionInferenceService cloudService,
    required NutritionInferenceService localService,
  })  : _cloudService = cloudService,
        _localService = localService,
        super(ScannerInitial()) {
    
    on<ScannerCaptureStepRequested>((event, emit) async {
      final currentState = state;
      List<File> images = [];

      if (currentState is ScannerCapturing) {
        images = List.from(currentState.capturedImages);
      }

      images.add(event.image);
      
      if (images.length < 3) {
        emit(ScannerCapturing(images.length, images));
      } else {
        // All 3 images captured, start inference
        emit(ScannerProcessing());
        try {
          print('[ScannerBloc] Attempting Cloud Inference (FastAPI)...');
          try {
            final result = await _cloudService.predict(
              imageTop: images[0],
              imageSide1: images[1],
              imageSide2: images[2],
            );
            emit(ScannerSuccess(result));
          } catch (cloudError) {
            print('[ScannerBloc] Cloud Failed: $cloudError. Falling back to Local AI...');
            
            // FALLBACK TO LOCAL
            final localResult = await _localService.predict(
              imageTop: images[0],
              imageSide1: images[1],
              imageSide2: images[2],
            );
            emit(ScannerSuccess(localResult));
          }
        } catch (finalError) {
          print('[ScannerBloc] BOTH AI ENGINES FAILED: $finalError');
          emit(ScannerFailure("Both Cloud and Local AI failed to process. Check your model and connection."));
        }
      }
    });

    on<ScannerResetRequested>((event, emit) {
      emit(ScannerInitial());
    });
  }
}
