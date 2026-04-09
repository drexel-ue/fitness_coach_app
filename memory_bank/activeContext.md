# Active Context - Ingestion Feature

**Date:** April 9, 2026
**Data Source:** https://github.com/yuhonas/free-exercise-db

## Current State

The ingestion feature implementation is approximately **90% complete**. Phase 1 (Infrastructure) and Phase 2 (Unit Testing) are complete. Phase 3 (UI Components) is the next major milestone.

## Architecture Overview

### Core Components

```
lib/
├── core/
│   ├── database/
│   │   └── database_service.dart      # SQLite database operations
│   └── extensions/
│       ├── iterable_extensions.dart   # firstWhereOrNull extension
│       └── string_extensions.dart     # replaceFirstCharUpperCase extension
├── data/
│   ├── dtos/
│   │   └── exercise_dto.dart          # Free-exercise-db DTO
│   ├── repositories/
│   │   └── exercise_repository_impl.dart
│   └── services/
│       └── ingestion_service.dart     # Main ingestion logic
├── domain/
│   ├── entities/
│   │   └── exercise.dart              # Exercise entity
│   └── repositories/
│   │   └── exercise_repository.dart
├── usecases/
│   └── ingestion_usecase.dart         # Business logic use cases
└── presentation/
    └── ...                            # UI components (pending)
```

## Data Flow

1. **Free-exercise-db JSON** → `ExerciseDTO` → `Exercise` entity → SQLite database
2. **IngestionService** fetches JSON (asset or remote) → `IngestionUseCase` → `ExerciseRepository` → Database

## Key Design Decisions

### 1. Source Tracking
- All exercises from the free-exercise-db are marked with `source = ExerciseSource.ingestion`
- `sourceId` is set to the original exercise ID from the source
- This allows distinguishing between user-created and imported exercises

### 2. Deduplication
- Exercises are deduplicated by `sourceId` to prevent duplicates
- Only new exercises are added during batch ingestion

### 3. Image Handling
- Images are stored as URLs in the database
- On-demand image download service can cache images locally if needed
- Future optimization: bundle images with the app (see roadmap)

### 4. Schema Alignment
- New fields added: `force`, `level`, `mechanic`, `category`
- Enum mappings handle null/unknown values gracefully
- Default values provided for missing data

## Known Issues

No major known issues. Analyzer warnings have been resolved.

## Future Roadmap

### Phase 3: UI Components (Pending)
- IngestionProgressDialog widget
- IngestionScreen for user interaction
- Local notification integration
- Scaffold message integration
- ExerciseImageCacheService

### Future Optimizations
1. **Image Bundling:** Bundle exercise images with the app to reduce download time
2. **Offline-First:** Cache all data for offline access
3. **Incremental Sync:** Only download new/updated exercises
4. **User Preferences:** Allow users to filter exercises by muscle group, equipment, etc.

## Testing Status

- ✅ **Phase 2 (Unit Tests) is COMPLETE.**
- All core ingestion components (Entity, DTO, Service, UseCase) have passing unit tests.

## Next Immediate Tasks

1. Begin Phase 3: UI Integration
2. Implement `IngestionProgressDialog`
3. Implement `IngestionScreen`
4. Integrate local notifications for background ingestion progress