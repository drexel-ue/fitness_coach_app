import 'dart:async';
import 'package:fitness_coach_app/data/dtos/exercise_dto.dart';
import 'package:fitness_coach_app/data/services/ingestion_service.dart';
import 'package:fitness_coach_app/domain/entities/exercise.dart';

/// Use case for ingesting exercises from various sources.
/// Provides progress tracking via [Stream<IngestionProgress>].
class IngestionUseCase {
  final IngestionService _ingestionService;

  IngestionUseCase(this._ingestionService);

  /// Ingests exercises from a bundled asset file.
  /// Returns a [Stream<IngestionProgress>] for tracking progress.
  Stream<IngestionProgress> ingestFromAsset(String assetPath) {
    return _ingestionService.ingestExercisesFromAsset(assetPath);
  }

  /// Ingests exercises from a local file path.
  /// Returns a [Stream<IngestionProgress>] for tracking progress.
  Stream<IngestionProgress> ingestFromFile(String filePath) {
    return _ingestionService.ingestExercisesFromFilePath(filePath);
  }

  /// Ingests exercises from a remote URL.
  /// Returns a [Stream<IngestionProgress>] for tracking progress.
  Stream<IngestionProgress> ingestFromUrl(String url) {
    return _ingestionService.ingestExercisesFromUrl(url);
  }

  /// Ingests exercises from the free-exercise-db GitHub repository.
  /// Returns a [Stream<IngestionProgress>] for tracking progress.
  Stream<IngestionProgress> ingestFromFreeExerciseDb({int batchSize = 50}) {
    return _ingestionService.ingestFromFreeExerciseDb(batchSize: batchSize);
  }

  /// Ingests a list of ExerciseDTOs.
  /// Returns a [Stream<IngestionProgress>] for tracking progress.
  Stream<IngestionProgress> ingestFromDtoList(List<ExerciseDTO> dtos) {
    return _ingestionService.ingestExercisesFromDtoList(dtos);
  }

  /// Downloads and caches an image for an exercise.
  Future<String?> fetchAndCacheImage(String url, String exerciseId) {
    return _ingestionService.downloadAndCacheImage(url, exerciseId);
  }

  /// Prefetches images for a list of exercises.
  Future<Map<String, String?>> prefetchImages(List<Exercise> exercises) {
    return _ingestionService.prefetchImages(exercises);
  }
}
