# Project Ledger: Fitness Coach App

## 1. Project Vision & Core Objective
**Summary:** A privacy-first, local-LLM-powered fitness coaching application designed for complete user autonomy.
**Core Value:** Delivering personalized, offline-capable coaching that evolves alongside the user's physical progress, without ever compromising data privacy.

## 2. Technical Manifesto (The "How")
### Architecture
The project adheres to **Clean Architecture** principles, strictly separating concerns into three distinct layers:
*   **Data Layer:** Handles data retrieval, persistence (SQLite), and external API interactions.
*   **Domain Layer:** Contains the core business logic, entities, and use cases, remaining agnostic of external frameworks.
*   **Presentation Layer:** Manages the user interface and user interaction, implementing the tiered state management strategy.

### Tiered State Management Strategy
To optimize performance and maintainability, a dual-engine approach is utilized:
*   **Global Engine (Riverpod):** Serves as the backbone for Dependency Injection (DI), SQLite database orchestration, and complex business logic/repository management. It handles the "source of truth" for the application state.
*   **High-Frequency UI (Signals):** Utilized for **"Surgical Rendering."** This is applied to real-time, high-frequency UI elements—such as active workout timers, rep counters, and weight trackers—to ensure maximum frame rates and minimal UI rebuild overhead.

### Primary Stack
*   **Framework:** Flutter (Dart)
*   **Inference Engine:** `llamadart` (running Gemma)
*   **Local Persistence:** SQLite (`sqflite`)

## 3. Current Project Status (The "Now")
**Phase:** **Phase 1 (Native Data Ingestion) Complete.**

**Achievements:**
*   [x] Project initialization and environment configuration.
*   [x] Implementation of Clean Architecture folder structure.
*   [x] Configuration of tiered state management dependencies (Rivertro + Signals).
*   [x] Foundation of the `DatabaseService` for persistent local storage.
*   [x] Implementation of a type-safe Domain Layer for Exercises.
*   [x] Development of a native Dart Ingestion Engine for JSON/CSV data.
*   [x] Implementation of the Exercise Repository for SQLite persistence.

## 4. Development Roadmap (The "Future")
*   **Phase 2: LLM Integration:** Integration of the local Gemma inference engine via `llamadart` to enable intelligent, context-aware coaching.
*   **Phase 3: Reactive UI Development:** Construction of advanced active workout and session screens, leveraging the Signals-based surgical rendering pattern for peak performance.
*   **Phase 4: [Placeholder for future expansion]**

## 5. Engineering Principles
1.  **Rule 1: Prioritize Surgical Rendering.** In the presentation layer, all high-frequency UI updates must utilize the Signals pattern to prevent unnecessary widget rebuilds.
2.  **Rule 2: Strict Layered Separation.** Maintain an impenetrable boundary between the Data and Domain layers; the Domain layer must never depend on implementation details of the Data layer.
3.  **Rule 3: Schema Integrity.** All user-generated or imported exercises must strictly adhere to the established database schema to ensure seamless compatibility with the LLM-driven coaching engine.