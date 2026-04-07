import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:fitness_coach_app/core/database/database_service.dart';
import 'package:fitness_coach_app/data/repositories/exercise_repository_impl.dart';
import 'package:fitness_coach_app/data/services/ingestion_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationSupportPath() async => '';
  @override
  Future<String?> getApplicationCachePath() async => '';
  @override
  Future<String?> getTemporaryPath() async => '';
  @override
  Future<String?> getApplicationDocumentsPath() async => '';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    PathProviderPlatform.instance = FakePathProviderPlatform();
  });

  test('IngestionService should successfully ingest exercises from asset', () async {
    final databaseService = container.read(databaseServiceProvider);
    final repository = container.read(exerciseRepositoryProvider);
    final ingestionService = IngestionService(
      repository,
    );

    // Ensure database is initialized
    await databaseService.database;

    // Run ingestion
    ingestionService.ingestExercisesFromAsset('assets/data/exercises.json');

    // Verify exercises are in the database
    final allExercises = await repository.getAllExercises();

    expect(allExercises.length, 2);
    expect(allExercises.any((e) => e.name == 'Bench Press'), isTrue);
    expect(allExercises.any((e) => e.name == 'Bicep Curl'), isTrue);
  });
}
