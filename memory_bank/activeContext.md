# Fitness Coach App Vision

**Core Principles:**
- **Local-First:** All data sources (e.g., `free-exercise-db JSON`) are local, ensuring privacy and offline capability. Cloud sync is optional and documented.
- **Multi-Modal Interaction:** Seamlessly integrate text-to-voice and voice-to-text using local packages (`speech_to_text`, `flutter_tts`), preserving state across modalities.
- **LLM Integration:** Utilize `llamadart` for local LLM capabilities, with `inference_service.dart` designed for future extensibility (e.g., computer vision via clear interfaces).
- **Architecture:** Follow unidirectional data flow; ensure reactive streams in `DatabaseService` and `ExerciseRepository`.

**Key Implementation Path:**
1. Complete local-first data layer (using `free-exercise-db`)
2. Integrate `llamadart` into `inference_service.dart`
3. Implement reactive streams for database/repository
4. Verify end-to-end ingestion flow