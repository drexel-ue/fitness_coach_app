import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_coach_app/domain/entities/exercise.dart';
import 'package:fitness_coach_app/domain/repositories/exercise_repository.dart';
import 'package:fitness_coach_app/data/services/ingestion_service.dart';
import 'package:fitness_coach_app/usecases/ingestion_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockExerciseRepository extends Mock implements ExerciseRepository {
  @override
  Future<void> insertExercise(Exercise exercise) async {
    // Silently ignore inserts for testing use case orchestration
  }

  @override
  Future<List<Exercise>> getAllExercises() async {
    return [];
  }

  @override
  Future<List<Exercise>> getExercisesByMuscleGroup(MuscleGroup group) async {
    return [];
  }

  @override
  Future<List<Exercise>> getExercisesByEquipment(EquipmentType equipment) async {
    return [];
  }

  @override
  Future<void> deleteExercise(String id) async {
    // No-op
  }

  @override
  Future<List<Exercise>> getExercisesBySource(ExerciseSource source) async {
    return [];
  }

  @override
  Future<List<Exercise>> getExercisesByForce(Force force) async {
    return [];
  }

  @override
  Future<List<Exercise>> getExercisesByLevel(ExerciseLevel level) async {
    return [];
  }
}

void main() {
  late IngestionUseCase usecase;
  late MockExerciseRepository mockRepository;
  late IngestionService ingestionService;

  setUp(() {
    mockRepository = MockExerciseRepository();
    ingestionService = IngestionService(mockRepository);
    usecase = IngestionUseCase(ingestionService);
  });

  group('IngestionUseCase', () {
    test('should call repository to ingest exercises', () async {
      // Arrange
      final testFile = File('test/data/fixtures/exercises_test.json');

      // Act
      await for (final _ in usecase.ingestFromFile(testFile.path)) {
        // Collect progress
      }

      // Assert
      verify(() => mockRepository.insertExercise(any())).called(5);
    });

    test('should handle empty JSON array', () async {
      // Arrange
      final testFile = File('test/data/fixtures/empty_exercises.json');

      // Act
      await for (final _ in usecase.ingestFromFile(testFile.path)) {
        // Collect progress
      }

      // Assert
      verifyNever(() => mockRepository.insertExercise(any()));
    });

    test('should handle file not found', () async {
      // Arrange
      const nonExistentFile = '/path/that/does/not/exist.json';

      // Act
      final results = <IngestionProgress>[];
      await for (final progress in usecase.ingestFromFile(nonExistentFile)) {
        results.add(progress);
      }

      // Assert
      expect(results.isNotEmpty, true);
      final finalProgress = results.last;
      expect(finalProgress.failed, 1);
      expect(finalProgress.status, contains('File not found'));
    });
  });
}