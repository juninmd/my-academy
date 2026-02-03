# My Academy (Minha Academia)

A Flutter application for managing and tracking your workout progress, built with clean architecture and Riverpod.

## Features

*   **Workout Management:** Create, edit, and delete workouts.
*   **Exercise Library:** Searchable database of exercises with detailed instructions.
*   **Progress Tracking:** Visualize your 1RM progression and volume trends.
*   **Calendar:** View workout history and schedule.
*   **Body Composition:** Track body measurements and calculate fat percentage.
*   **Social:** Connect with students or coaches (feature in progress).

## Getting Started

### Prerequisites

*   Flutter SDK (version >= 3.7.0 < 4.0.0)
*   Dart SDK (version >= 3.0.0 < 4.0.0)
*   Firebase Project (setup `google-services.json` and `GoogleService-Info.plist`)
*   NestJS Backend (optional for local dev, see `backend/README.md`)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/my-academy.git
    cd my-academy
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the application:**
    ```bash
    flutter run
    ```

## Testing

To run the tests:

```bash
flutter test
```

To run integration tests:

```bash
flutter test integration_test
```

## Architecture

This project follows a Clean Architecture approach with Feature-First organization:

*   **lib/core:** Core utilities, widgets, and base classes.
*   **lib/features:** Feature modules (auth, workouts, profile, etc.). Each feature contains:
    *   **domain:** Entities, use cases, repository interfaces.
    *   **data:** Data sources (remote/local), repository implementations, DTOs.
    *   **presentation:** Pages, widgets, providers (Riverpod), state management.

## State Management

We use [Riverpod](https://riverpod.dev/) for state management and dependency injection. [flutter_hooks](https://pub.dev/packages/flutter_hooks) is used for ephemeral UI state.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
