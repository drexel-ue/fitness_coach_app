import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_coach_app/domain/entities/exercise.dart';
import 'package:fitness_coach_app/data/dtos/exercise_dto.dart';
import 'package:fitness_coach_app/domain/services/ingestion_service.dart';
import 'package:fitness_coach_app/usecases/ingestion_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockIngestionService extends Mock implements IngestionService {}

void main() {
  late IngestionUseCase usecase;
  late MockIngestionService mockIngestionService;

  setUp(() {
    mockIngestionService = MockIngestionService();
    usecase = IngestionUseCase(mockIngestionService);
  });

  group('IngestionUseCase', () {
    test('should call ingestExercisesFromFilePath when ingestFromFile is called', () async {
      // Arrange
      const testPath = 'test/data/fixtures/exercises_test.json';
      final progressStream = Stream.fromIterable([
        IngestionProgress(total: 10, completed: 5),
        IngestionProgress(total: 10, completed: 10),
      ]);
      when(
        () => mockIngestionService.ingestExercisesFromFilePath(testPath),
      ).thenAnswer((_) => progressStream);

      // Act
      final results = <IngestionProgress>[];
      await for (final progress in usecase.ingestFromFile(testPath)) {
        results.add(progress);
      }

      // Assert
      verify(() => mockIngestionService.ingestExercisesFromFilePath(testPath)).called(1);
      expect(results.length, 2);
      expect(results.last.completed, 10);
    });

    test('should call ingestExercisesFromAsset when ingestFromAsset is called', () async {
      // Arrange
      const testPath = 'assets/data/exercises.json';
      when(
        () => mockIngestionService.ingestExercisesFromAsset(testPath),
      ).thenAnswer((_) => const Stream.empty());

      // Act
      usecase.ingestFromAsset(testPath);

      // Assert
      verify(() => mockIngestionService.ingestExercisesFromAsset(testPath)).called(1);
    });

    test('should call ingestExercisesFromUrl when ingestFromUrl is called', () async {
      // Arrange
      const testUrl = 'https://example.com/exercises.json';
      when(
        () => mockIngestionService.ingestExercisesFromUrl(testUrl),
      ).thenAnswer((_) => const Stream.empty());

      // Act
      usecase.ingestFromUrl(testUrl);

      // Assert
      verify(() => mockIngestionService.ingestExercisesFromUrl(testUrl)).called(1);
    });

    test('should call ingestFromFreeExerciseDb when ingestFromFreeExerciseDb is called', () async {
      // Arrange
      when(
        () => mockIngestionService.ingestFromFreeExerciseDb(batchSize: any(named: 'batchSize')),
      ).thenAnswer((_) => const Stream.empty());

      // Act
      usecase.ingestFromFreeExerciseDb(batchSize: 10);

      // Assert
      verify(() => mockIngestionService.ingestFromFreeExerciseDb(batchSize: 10)).called(1);
    });

    test('should call ingestExercisesFromDtoList when ingestFromDtoList is called', () async {
      // Arrange
      final dtos = <ExerciseDTO>[];
      when(
        () => mockIngestionService.ingestExercisesFromDtoList(
          dtos,
          batchSize: any(named: 'batchSize'),
        ),
      ).thenAnswer((_) => const Stream.empty());

      // Act
      usecase.ingestFromDtoList(dtos, batchSize: 10);

      // Assert
      verify(() => mockIngestionService.ingestExercisesFromDtoList(dtos, batchSize: 10)).called(1);
    });

    test('should call downloadAndCacheImage when fetchAndCacheImage is called', () async {
      // Arrange
      const url = 'https://example.com/image.png';
      const id = 'ex123';
      when(
        () => mockIngestionService.downloadAndCacheImage(url, id),
      ).thenAnswer((_) async => 'path/to/image.png');

      // Act
      final result = await usecase.fetchAndCacheImage(url, id);

      // Assert
      expect(result, 'path/to/image.png');
      verify(() => mockIngestionService.downloadAndCacheImage(url, id)).called(1);
    });

    test('should call prefetchImages when prefetchImages is called', () async {
      // Arrange
      final exercises = <Exercise>[];
      when(() => mockIngestionService.prefetchImages(exercises)).thenAnswer((_) async => {});

      // Act
      await usecase.prefetchImages(exercises);

      // Assert
      verify(() => mockIngestionService.prefetchImages(exercises)).called(1);
    });
  });
}