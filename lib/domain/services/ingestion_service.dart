import 'package:fitness_coach_app/domain/entities/exercise.dart';
import 'package:fitness_coach_app/data/dtos/exercise_dto.dart';

/// Progress update for ingestion operations.
class IngestionProgress {
  final int total;
  final int completed;
  final int failed;
  final String status;

  IngestionProgress({
    required this.total,
    required this.completed,
    this.failed = 0,
    this.status = 'In progress',
  });

  double get percentage => total > 0 ? completed / total : 0.0;
}

/// Interface for the Ingestion Service, defining the contract for
/// exercise data ingestion.
abstract class IngestionService {
  /// Ingests exercises from a bundled asset path.
  Stream<IngestionProgress> ingestExercisesFromAsset(
    String assetPath, {
    int batchSize = 50,
  });

  /// Ingests exercises from a local file path.
  Stream<IngestionProgress> ingestExercisesFromFilePath(
    String filePath, {
    int batchSize = 50,
  });

  /// Ingests exercises from a remote URL.
  Stream<IngestionProgress> ingestExercisesFromUrl(
    String url, {
    int batchSize = 50,
  });

  /// Ingests exercises from the free-exercise-db GitHub repository.
  Stream<IngestionProgress> ingestFromFreeExerciseDb({int batchSize = 50});

  /// Ingests a list of ExerciseDTOs.
  Stream<IngestionProgress> ingestExercisesFromDtoList(
    List<ExerciseDTO> dtos, {
    int batchSize = 50,
  });

  /// Downloads and caches an image for an exercise.
  Future<String?> downloadAndCacheImage(String url, String exerciseId);

  /// Prefetches images for a list of exercises.
  Future<Map<String, String?>> prefetchImages(List<Exercise> exercises);
}