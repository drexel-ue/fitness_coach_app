# System Patterns - Ingestion Feature

**Date:** April 7, 2026
**Data Source:** https://github.com/yuhonas/free-exercise-db

## Architecture Patterns

### 1. Clean Architecture

The project follows Clean Architecture principles with clear separation of concerns:

```
┌─────────────────┐
│  Presentation   │  (UI, Widgets, Screens)
├─────────────────┤
│    UseCases     │  (Business Logic)
├─────────────────┤
│     Domain      │  (Entities, Repositories)
├─────────────────┤
│      Data       │  (DTOs, Repositories, Services)
├─────────────────┤
│      Core       │  (Database, Extensions)
└─────────────────┘
```

### 2. Repository Pattern

**ExerciseRepository** interface defines the contract:
```dart
abstract class ExerciseRepository {
  Future<List<Exercise>> getAllExercises();
  Future<List<Exercise>> getExercisesByMuscleGroup(MuscleGroup muscleGroup);
  Future<List<Exercise>> getExercisesBySource(ExerciseSource source);
  Future<int> getExerciseCount();
  Future<void> insertExercise(Exercise exercise);
  Future<void> batchInsertExercises(List<Exercise> exercises);
  Future<void> deleteExercise(String id);
  Future<void> deleteAllExercises();
}
```

**ExerciseRepositoryImpl** implements the interface with SQLite operations.

### 3. DTO Pattern

**ExerciseDTO** transforms external data (free-exercise-db JSON) to domain entities:
```dart
class ExerciseDTO {
  // External data fields
  final String id;
  final String name;
  final String? force;
  // ...
  
  // Conversion method
  Exercise toEntity({
    ExerciseSource source = ExerciseSource.ingestion,
    String? sourceId,
    DateTime? timestamp,
    DateTime? updatedAt,
  })
}
```

### 4. UseCase Pattern

Each use case represents a single business rule:
```dart
class IngestionUseCase {
  final IngestionService _ingestionService;
  final ExerciseRepository _exerciseRepository;
  
  // Dev flow: ingest from bundled asset
  Future<Stream<IngestionProgress>> ingestFromAsset();
  
  // User flow: ingest from remote URL
  Future<Stream<IngestionProgress>> ingestFromRemote(String url);
  
  // Check for updates
  Future<bool> checkForUpdates();
  
  // Import only new exercises
  Future<Stream<IngestionProgress>> importNewExercisesOnly();
  
  // Query ingestion source exercises
  Future<List<Exercise>> getIngestionExercises();
}
```

### 5. Stream-Based Progress

The ingestion process uses `Stream<IngestionProgress>` to provide real-time feedback:
```dart
class IngestionProgress {
  final int total;
  final int processed;
  final int skipped;
  final int failed;
  final String? errorMessage;
  
  double get progress => total == 0 ? 0.0 : processed / total;
}
```

### 6. Null-Safe Enum Parsing

Extensions and helper methods handle null/unknown values gracefully:
```dart
// Iterable extension for null-safe firstWhere
extension IterableExtensions<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

// Enum parsing with null handling
static Force? _parseForce(String? forceValue) {
  if (forceValue == null || forceValue.isEmpty) return null;
  try {
    return Force.values.firstWhereOrNull(
      (e) => e.name == forceValue.toLowerCase(),
    );
  } catch (_) {
    return null;
  }
}
```

## Data Flow

```
[Free-Exercise-DB JSON]
         ↓
[ExerciseDTO.fromJson()]
         ↓
[ExerciseDTO.toEntity()]
         ↓
[ExerciseRepository.insertExercise()]
         ↓
[SQLite Database]
```

## Database Schema

### Exercises Table
```sql
CREATE TABLE exercises (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  primaryMuscleGroup TEXT NOT NULL,
  secondaryMuscleGroups TEXT NOT NULL,
  equipment TEXT NOT NULL,
  instructions TEXT NOT NULL,
  imageUrl TEXT,
  localImagePath TEXT,
  force TEXT,
  level TEXT,
  mechanic TEXT,
  category TEXT,
  source TEXT NOT NULL DEFAULT 'user',
  sourceId TEXT,
  timestamp TEXT NOT NULL,
  updatedAt TEXT NOT NULL
);
```

### Indexes
- `idx_muscle_group` on `primaryMuscleGroup`
- `idx_equipment` on `equipment`
- `idx_source` on `source`

## State Management

The project uses **Riverpod** for state management:
- `flutter_riverpod` package
- `signals` and `signals_flutter` packages
- Provider-based architecture for reactive UI updates

## Error Handling

1. **Try-Catch Blocks:** All parsing operations wrapped in try-catch
2. **Default Values:** Null/unknown values mapped to sensible defaults
3. **Retry Logic:** Network operations have retry mechanisms
4. **Progress Reporting:** Errors reported via stream without stopping ingestion

## Future Patterns to Implement

1. **Observer Pattern:** For UI updates when exercises are added/updated
2. **Factory Pattern:** For creating exercise entities from different sources
3. **Strategy Pattern:** For different ingestion strategies (asset, remote, manual)
4. **Circuit Breaker Pattern:** For handling repeated failures in network operations