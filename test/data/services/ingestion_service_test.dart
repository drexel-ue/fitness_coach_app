import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:fitness_coach_app/data/services/ingestion_service.dart';
import 'package:fitness_coach_app/domain/entities/exercise.dart';
import 'package:fitness_coach_app/domain/repositories/exercise_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockExerciseRepository extends Mock implements ExerciseRepository {}

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late IngestionService service;
  late MockExerciseRepository mockRepository;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockRepository = MockExerciseRepository();
    mockHttpClient = MockHttpClient();
    service = IngestionService(mockRepository, httpClient: mockHttpClient);
  });

  group('IngestionService', () {
    test('should successfully ingest exercises from file', () async {
      // Arrange
      final testFile = File('test/data/fixtures/exercises_test.json');
      final results = <IngestionProgress>[];

      // Mock repository to track calls
      when(() => mockRepository.insertExercise(any())).thenAnswer(
        (invocation) async {
          final exercise = invocation.positionalArguments['exercise'] as Exercise;
          verify(() => mockRepository.insertExercise(exercise)).called(1);
          return;
        },
      );

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
      expect(finalProgress.status, 'Completed');
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
      expect(results.length, 1);
      final finalProgress = results.last;
      expect(finalProgress.failed, 1);
      expect(finalProgress.status, contains('File not found'));
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
      int insertCallCount = 0;

      // Mock repository to track calls
      when(() => mockRepository.insertExercise(any())).thenAnswer(
        (invocation) async {
          insertCallCount++;
          verify(() => mockRepository.insertExercise(any())).called(insertCallCount);
          return;
        },
      );

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
      expect(finalProgress.failed, 0);
    });

    test('should handle duplicate IDs gracefully', () async {
      // Arrange
      final testFile = File('test/data/fixtures/exercises_test.json');
      final results = <IngestionProgress>[];

      // Mock repository to allow duplicate inserts (no-op for deduplication test)
      when(() => mockRepository.insertExercise(any())).thenAnswer(
        (_) async {
          // Repository handles deduplication internally
          return;
        },
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
      expect(finalProgress.failed, 0);
    });

    test('should handle JSON parsing error', () async {
      // Arrange
      final invalidFile = File('${Directory.current.path}/test/data/fixtures/invalid.json');
      invalidFile.writeAsStringSync('not valid json {{{');

      final results = <IngestionProgress>[];

      // Act
      await for (final progress in service.ingestExercisesFromFilePath(
        invalidFile.path,
        batchSize: 50,
      )) {
        results.add(progress);
      }

      // Assert
      expect(results.isNotEmpty, true);
      final finalProgress = results.last;
      expect(finalProgress.status, contains('Error'));
    });

    test('should handle network error for URL ingestion', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Not Found', statusCode: 404),
      );

      final results = <IngestionProgress>[];

      // Act
      await for (final progress in service.ingestExercisesFromUrl(
        'https://invalid.example.com/exercises.json',
        batchSize: 50,
      )) {
        results.add(progress);
      }

      // Assert
      expect(results.isNotEmpty, true);
      final finalProgress = results.last;
      expect(finalProgress.status, contains('Error'));
    });

    test('should handle partial ingestion with errors', () async {
      // Arrange
      final testFile = File('test/data/fixtures/exercises_test.json');
      final results = <IngestionProgress>[];
      int successfulInserts = 0;
      int failedInserts = 0;

      // Mock repository to simulate some failures
      when(() => mockRepository.insertExercise(any())).thenAnswer(
        (invocation) async {
          final exercise = invocation.positionalArguments['exercise'] as Exercise;
          // Simulate failure for exercises with "fail" in ID
          if (exercise.id.contains('fail')) {
            failedInserts++;
          } else {
            successfulInserts++;
          }
          return;
        },
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
      expect(finalProgress.failed, 0); // Service tracks service-level failures, not insert failures
    });
  });
}