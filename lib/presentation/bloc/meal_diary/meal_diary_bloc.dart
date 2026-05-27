import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/food_repository_impl.dart';

// --- Events ---
abstract class MealDiaryEvent {}
class LoadMealDiaryRequested extends MealDiaryEvent {
  final String userId;
  final String? filter;
  LoadMealDiaryRequested(this.userId, {this.filter});
}

// --- States ---
abstract class MealDiaryState {}
class MealDiaryInitial extends MealDiaryState {}
class MealDiaryLoading extends MealDiaryState {}
class MealDiaryLoaded extends MealDiaryState {
  final List<FoodLogEntry> logs;
  MealDiaryLoaded(this.logs);
}
class MealDiaryFailure extends MealDiaryState {
  final String message;
  MealDiaryFailure(this.message);
}

// --- BLoC ---
class MealDiaryBloc extends Bloc<MealDiaryEvent, MealDiaryState> {
  final FoodRepository _foodRepository;

  MealDiaryBloc(this._foodRepository) : super(MealDiaryInitial()) {
    on<LoadMealDiaryRequested>((event, emit) async {
      emit(MealDiaryLoading());
      try {
        // Logika sorting sederhana berdasarkan filter
        List<FoodLogEntry> logs;
        if (event.filter == 'High Protein') {
          final allLogs = await _foodRepository.getRecentLogs(event.userId, limit: 50);
          logs = allLogs.where((log) => log.proteinG > 30).toList(); // Contoh filter pro > 30g
        } else if (event.filter == 'Low Carbs') {
          final allLogs = await _foodRepository.getRecentLogs(event.userId, limit: 50);
          logs = allLogs.where((log) => log.carbsG < 20).toList(); // Contoh filter carbs < 20g
        } else {
          logs = await _foodRepository.getRecentLogs(event.userId, limit: 50);
        }
        emit(MealDiaryLoaded(logs));
      } catch (e) {
        emit(MealDiaryFailure(e.toString()));
      }
    });
  }
}
