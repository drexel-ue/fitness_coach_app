import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:fitness_coach_app/domain/entities/exercise.dart';
import 'package:fitness_coach_app/domain/repositories/exercise_repository.dart';
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

class IngestionService {
  final ExerciseRepository _repository;
  final http.Client _httpClient;

  IngestionService(this._repository, {http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Fetches JSON content from a bundled asset path.
  Future<String> fetchAssetJson(String assetPath) async {
    try {
      return await rootBundle.loadString(assetPath);
    } catch (e) {
      debugPrint('Error loading asset $assetPath: $e');
      rethrow;
    }
  }

  /// Fetches JSON content from a remote URL.
  Future<String> fetchRemoteJson(String url) async {
    try {
      final response = await _httpClient.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to load data from $url: ${response.statusCode}');
      }
      return response.body;
    } catch (e) {
      debugPrint('Error fetching JSON from $url: $e');
      rethrow;
    }
  }

  /// Fetches free-exercise-db JSON from the GitHub repository.
  Future<String> fetchFreeExerciseDbJson() async {
    return fetchRemoteJson(
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json',
    );
  }

  /// Parses a JSON string into a list of ExerciseDTOs.
  Future<List<ExerciseDTO>> parseExercisesFromJson(String jsonString) async {
    try {
      final List<dynamic> data = json.decode(jsonString);
      return data
          .map((item) => ExerciseDTO.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error parsing exercises from JSON: $e');
      rethrow;
    }
  }

  /// Ingests exercises from a local asset path and saves them to the repository.
  /// Returns a [Stream<IngestionProgress>] for tracking progress.
  Stream<IngestionProgress> ingestExercisesFromAsset(
    String assetPath, {
    int batchSize = 50,
  }) async* {
    int total = 0;
    int completed = 0;
    int failed = 0;

    try {
      final jsonString = await fetchAssetJson(assetPath);
      final dtos = await parseExercisesFromJson(jsonString);
      total = dtos.length;

      for (int i = 0; i < dtos.length; i += batchSize) {
        final batch = dtos.skip(i).take(batchSize).toList();
        final batchResults = await _ingestBatch(batch);

        completed += batchResults.completed;
        failed += batchResults.failed;

        yield IngestionProgress(
          total: total,
          completed: completed,
          failed: failed,
          status: 'Processing batch ${i ~/ batchSize + 1}',
        );
      }

      yield IngestionProgress(
        total: total,
        completed: completed,
        failed: failed,
        status: completed == total ? 'Completed' : 'Completed with errors',
      );
    } catch (e, stackTrace) {
      debugPrint('Error ingesting exercises from asset $assetPath: $e');
      debugPrint('Stack trace: $stackTrace');
      yield IngestionProgress(
        total: total,
        completed: completed,
        failed: failed + 1,
        status: 'Error: $e',
      );
    }
  }

  /// Ingests exercises from a remote URL and saves them to the repository.
  Stream<IngestionProgress> ingestExercisesFromUrl(
    String url, {
    int batchSize = 50,
  }) async* {
    int total = 0;
    int completed = 0;
    int failed = 0;

    try {
      final jsonString = await fetchRemoteJson(url);
      final dtos = await parseExercisesFromJson(jsonString);
      total = dtos.length;

      for (int i = 0; i < dtos.length; i += batchSize) {
        final batch = dtos.skip(i).take(batchSize).toList();
        final batchResults = await _ingestBatch(batch);

        completed += batchResults.completed;
        failed += batchResults.failed;

        yield IngestionProgress(
          total: total,
          completed: completed,
          failed: failed,
          status: 'Processing batch ${i ~/ batchSize + 1}',
        );
      }

      yield IngestionProgress(
        total: total,
        completed: completed,
        failed: failed,
        status: completed == total ? 'Completed' : 'Completed with errors',
      );
    } catch (e, stackTrace) {
      debugPrint('Error ingesting exercises from URL $url: $e');
      debugPrint('Stack trace: $stackTrace');
      yield IngestionProgress(
        total: total,
        completed: completed,
        failed: failed + 1,
        status: 'Error: $e',
      );
    }
  }

  /// Ingests exercises from the free-exercise-db GitHub repository.
  Stream<IngestionProgress> ingestFromFreeExerciseDb({
    int batchSize = 50,
  }) async* {
    yield IngestionProgress(
      total: 0,
      completed: 0,
      status: 'Fetching exercises from GitHub...',
    );

    final jsonString = await fetchFreeExerciseDbJson();
    yield IngestionProgress(
      total: 0,
      completed: 0,
      status: 'Parsing exercises...',
    );

    final dtos = await parseExercisesFromJson(jsonString);
    yield IngestionProgress(
      total: dtos.length,
      completed: 0,
      status: 'Ingesting ${dtos.length} exercises...',
    );

    yield* ingestExercisesFromDtoList(dtos, batchSize: batchSize);
  }

  /// Ingests a list of ExerciseDTOs.
  Stream<IngestionProgress> ingestExercisesFromDtoList(
    List<ExerciseDTO> dtos, {
    int batchSize = 50,
  }) async* {
    int total = dtos.length;
    int completed = 0;
    int failed = 0;

    for (int i = 0; i < dtos.length; i += batchSize) {
      final batch = dtos.skip(i).take(batchSize).toList();
      final batchResults = await _ingestBatch(batch);

      completed += batchResults.completed;
      failed += batchResults.failed;

      yield IngestionProgress(
        total: total,
        completed: completed,
        failed: failed,
        status: 'Processing batch ${i ~/ batchSize + 1}',
      );
    }

    yield IngestionProgress(
      total: total,
      completed: completed,
      failed: failed,
      status: completed == total ? 'Completed' : 'Completed with errors',
    );
  }

  /// Downloads an image from a URL and saves it to the local documents directory.
  /// Returns the local path of the saved image.
  Future<String?> downloadAndCacheImage(String url, String exerciseId) async {
    try {
      final response = await _httpClient.get(Uri.parse(url));
      if (response.statusCode != 200) {
        debugPrint('Failed to download image for $exerciseId: ${response.statusCode}');
        return null;
      }

      final directory = await getApplicationDocumentsDirectory();
      final extension = p.extension(Uri.parse(url).path);
      final fileName = '${exerciseId}_$exerciseId$extension';
      final filePath = p.join(directory.path, fileName);

      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }

      await file.writeAsBytes(response.bodyBytes);

      debugPrint('Image cached for $exerciseId: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('Error caching image for $exerciseId: $e');
      return null;
    }
  }

  /// Prefetches images for a list of exercises.
  Future<Map<String, String?>> prefetchImages(List<Exercise> exercises) async {
    final results = <String, String?>{};
    for (final exercise in exercises) {
      if (exercise.imageUrl != null) {
        results[exercise.id] = await downloadAndCacheImage(
          exercise.imageUrl!,
          exercise.id,
        );
      }
    }
    return results;
  }

  /// Ingests a batch of DTOs and returns results.
  Future<_BatchIngestionResult> _ingestBatch(List<ExerciseDTO> dtos) async {
    int completed = 0;
    int failed = 0;

    for (final dto in dtos) {
      try {
        final exercise = dto.toEntity(
          source: ExerciseSource.ingestion,
          sourceId: dto.id,
        );
        await _repository.insertExercise(exercise);
        completed++;
      } catch (e) {
        debugPrint('Error ingesting exercise ${dto.id}: $e');
        failed++;
      }
    }

    return _BatchIngestionResult(completed: completed, failed: failed);
  }
}

class _BatchIngestionResult {
  final int completed;
  final int failed;

  _BatchIngestionResult({required this.completed, required this.failed});
}
