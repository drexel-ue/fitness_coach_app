# Context & VRAM Guardrails
- **Max Context Budget:** 131K tokens.
- **Search Limit:** Max 2 SearXNG queries per task. Summarize results immediately; do not keep full HTML in context.
- **File Access:** Never read files >500 lines in full. Use `grep` or `sed` to read specific blocks/functions.
- **Tool Efficiency:** If tool output exceeds 2,000 tokens, truncate and ask for "read_slice" if necessary.
- **Memory Bank Management:** Document significant project decisions in `memory_bank/activeContext.md`, `memory_bank/progress.md`, and `memory_bank/systemPatterns.md`. Each entry must include date, action, and description.
- **Progress Tracking:** After each planning session, update `memory_bank/progress.md` with intended plan. Note progress as tasks are worked through. Mark tasks completed upon successful execution.
- **System Patterns Protocol:** When instructed to prefer specific coding styles or architectures, explicitly ask "Should this be added to `systemPatterns.md`?" before implementation.

# Flutter & Firebase (2026 Standards)
- **Architecture:** Follow "Uni directional flow" structure.
- **Classes:** Prefer constructors at top of class.
- **Providers:** Prefer providers above classes.
- **Imports:** Prefer full import paths.
- **Performance:** Use Isolates for data processing >8ms to avoid UI jank.
- **Multi-modal Interaction:** Implement seamless text-to-voice and voice-to-text transitions using local STT/TTS (e.g., `speech_to_text`, `flutter_tts`), with state management preserving context across modalities.
- **Extensibility:** Design all modules with clear interfaces to allow future integration of features like computer vision (form analysis) without major refactoring.
- **Local-first:** All data sources must be local-first (e.g., free-exercise-db JSON) unless explicitly documented as optional cloud sync.
- **LlamaDart:** Use `llamadart` for local LLM capabilities; ensure `inference_service.dart` interfaces support local model integration.

# Commit Standards
- **Conventional Commits:** Prefix commit messages with "docs:", "feat:", "fix:", etc. (e.g., "docs: Update vision standards...").