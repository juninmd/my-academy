# Jules - Living Memory

This file serves as a living memory for AI agents (Jules, etc.) working on this repository. It documents architectural decisions, patterns, learnings, and critical information.

## Project Structure

- **Frontend:** Flutter application (`lib/`).
- **Backend:** NestJS application (`backend/`).
- **Architecture:** Feature-first architecture (`lib/features/`). State management with Riverpod (`flutter_riverpod`, `hooks_riverpod`).
- **Dependencies:**
  - `flutter_riverpod`: State management.
  - `flutter_hooks`: React-like hooks for ephemeral state.
  - `go_router`: Navigation.
  - `fl_chart`: Charts (ProgressChart).
  - `flutter_animate`: Animations.
  - `firebase_auth`, `google_sign_in`: Authentication.
  - `cached_network_image`: Image loading.

## Learnings & Patterns

- **Mocking:** Use manual mocks or `mockito` for tests. Remember to close streams/listeners in tests.
- **Linting:** The project uses `flutter_lints`. We enforce additional rules like `unnecessary_underscores` and `prefer_single_quotes`.
- **Testing:**
  - Use `tester.pumpAndSettle()` for animations, unless they are infinite (use `tester.pump(duration)`).
  - Use `TestWidgetsFlutterBinding.ensureInitialized()` for tests needing plugin binding.
  - Mock `GlobalMaterialLocalizations` for widget tests.
- **State Management:** Riverpod providers are used extensively. `HookConsumerWidget` is the standard for widgets needing both hooks and providers.
- **Routing:** `GoRouter` handles navigation. Route arguments are passed via `extra`. Ensure type safety when reading `state.extra`.

## Recent Actions (Jules - 2025-02-18)

- **Antigravity Audit:**
  - Fixed 25 lint issues (`prefer_single_quotes`, `unnecessary_import`, `unnecessary_underscores`, etc.).
  - Standardized documentation (`README.md`, `CONTRIBUTING.md`, `AGENTS.md`, `GEMINI.md`).
  - Verified CI/CD pipeline.
  - Checked security (no hardcoded secrets found).
## Design Session (2026 Redesign)
- Stitch Project ID: projects/11307668159439376223
- Theme: 2026 Futuristic, Dark Mode, Glassmorphism, Neon.

- **Performance Optimization (ProgressChart):**
  - Converted `ProgressChart` to `HookWidget` and used `useMemoized` to cache sorted logs and chart points.
  - Reduced rebuild time by ~17% in high-load scenarios (5000 logs) by avoiding redundant sorting and calculation.

## 🏗️ Architectural Decisions (Session Update)
- **Monolithic Refactor:** Identified `WorkoutPlayerPage.dart` as a violation of the 150-line rule (currently ~1026 lines).
- **Strategy:** Extracting UI components (`SetRow`, `HistoryView`, `WarmupList`) into dedicated widgets in `lib/features/workouts/presentation/widgets/workout_player/`.
- **Goal:** Improve maintainability and testability of the workout player feature.
- **Refactor Status:** Successfully extracted `WorkoutSetRow`, `WorkoutHistoryView`, and `WorkoutWarmupList` from `WorkoutPlayerPage`.
- **Result:** Reduced `WorkoutPlayerPage` size by ~32%. Tests passed.
