import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_coach_app/data/services/ingestion_service.dart';
import 'package:fitness_coach_app/domain/repositories/exercise_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockExerciseRepository extends Mock implements ExerciseRepository {}

void main() {
  late IngestionService service;
  late MockExerciseRepository mockRepository;

  setUp(() {
    mockRepository = MockExerciseRepository();
    service = IngestionService(mockRepository);
  });

  group('IngestionService', () {
    test('should successfully ingest exercises from file', () async {
      // Arrange
      final testFile = File('test/data/fixtures/exercises_test.json');
      final results = <IngestionProgress>[];

      // Act
      await for (final progress in service.ingestExercisesFromFilePath(
        testFile.path,
        batchSize: 50,
      )) {
        results.add(progress);
      }

      // Assert
      expect(results.isNotEmpty, true);
      final finalProgress = results.last;
      expect(finalProgress.total, 5);
      expect(finalProgress.completed, 5);
      expect(finalProgress.failed, 0);
    });

    test('should handle file not found gracefully', () async {
      // Arrange
      final nonExistentFile = '/path/that/does/not/exist.json';
      final results = <IngestionProgress>[];

      // Act
      await for (final progress in service.ingestExercisesFromFilePath(
        nonExistentFile,
        batchSize: 50,
      )) {
        results.add(progress);
      }

      // Assert
      expect(results.isNotEmpty, true);
      final finalProgress = results.last;
      expect(finalProgress.failed, 1);
      expect(finalProgress.status, contains('File not found'));
    });

    test('should handle duplicate IDs gracefully', () async {
      // Arrange
      final testFile = File('test/data/fixtures/exercises_test.json');
      final results = <IngestionProgress>[];

      // Mock repository to allow duplicate inserts
      when(() => mockRepository.insertExercise(any())).thenAnswer(
        (_) async => 'test-id',
      );

      // Act
      await for (final progress in service.ingestExercisesFromFilePath(
        testFile.path,
        batchSize: 50,
      )) {
        results.add(progress);
      }

      // Assert
      final finalProgress = results.last;
      expect(finalProgress.completed, 5);
    });

    test('should handle empty JSON array', () async {
      // Arrange
      final testFile = File('test/data/fixtures/empty_exercises.json');
      final results = <IngestionProgress>[];

      // Act
      await for (final progress in service.ingestExercisesFromFilePath(
        testFile.path,
        batchSize: 50,
      )) {
        results.add(progress);
      }

      // Assert
      expect(results.isNotEmpty, true);
      final finalProgress = results.last;
      expect(finalProgress.total, 0);
      expect(finalProgress.completed, 0);
      expect(finalProgress.failed, 0);
      expect(finalProgress.status, 'Completed');
    });

    test('should process in batches', () async {
      // Arrange
      final testFile = File('test/data/fixtures/exercises_test.json');
      final results = <IngestionProgress>[];

      // Act
      await for (final progress in service.ingestExercisesFromFilePath(
        testFile.path,
        batchSize: 2, // Small batch size to test batching
      )) {
        results.add(progress);
      }

      // Assert
      expect(results.length, greaterThan(1)); // Should have multiple progress updates
      final finalProgress = results.last;
      expect(finalProgress.total, 5);
      expect(finalProgress.completed, 5);
    });
  });
}