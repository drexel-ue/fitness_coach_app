import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_coach_app/domain/entities/exercise.dart';
import 'package:fitness_coach_app/domain/repositories/exercise_repository.dart';
import 'package:fitness_coach_app/data/repositories/exercise_repository_impl.dart';

class IngestionService {
  final ExerciseRepository _repository;

  IngestionService(this._repository);

  Future<void> ingestExercisesFromAsset(String assetPath) async {
    try {
      final String response = await rootBundle.loadString(assetPath);
      final List<dynamic> data = json.decode(response);

      for (var item in data) {
        final exercise = Exercise.fromJson(item as Map<String, dynamic>);
        await _repository.insertExercise(exercise);
      }
      debugPrint('Successfully ingested exercises from $assetPath');
    } catch (e) {
      debugPrint('Error during ingestion: $e');
      rethrow;
    }
  }
}

/// Provider for the IngestionService.
final ingestionServiceProvider = Provider<IngestionService>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return IngestionService(repository);
});