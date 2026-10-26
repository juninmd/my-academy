# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

My Academy is a fitness/gym management platform with two sub-projects:
- **`api/`** — NestJS 12 backend (TypeScript 6, ESM, Bun runtime + package manager)
- **`app/`** — Flutter frontend (Dart, targets Web/Android/iOS)

The API uses PostgreSQL via Prisma and Firebase for authentication. The Flutter app is deployed to Netlify.

---

## API (`api/`)

### Commands

```bash
# Install dependencies
bun install

# Development (watch mode)
bun run start:dev

# Build / typecheck / lint (auto-fix)
bun run build
bun run typecheck
bun run lint

# Unit tests (Vitest, max 2 workers) — single file, coverage
bun run test
bun run test -- src/users/users.service.spec.ts
bun run test:cov

# E2E: mocked suites, then personas against real Postgres + Redis (needs docker compose up)
bun run test:e2e
bun run test:e2e:db

# Prisma
bun run prisma:generate   # regenerate client after schema changes
bun run prisma:push       # push schema to DB
bun run prisma:seed       # seed initial data + homologation personas
```

### Local stack (Docker)

```bash
# From the repo root: Postgres :5433, Redis :6380, API :9000 (seeded, mock auth)
docker compose up -d --build
curl -fsS http://localhost:9000/health
```

Homologation personas (mock auth, `Authorization: Bearer mock-token:<uid>`):
`hml-student` (aluno@myacademy.dev), `hml-personal` (personal@myacademy.dev),
`hml-owner` (dono@myacademy.dev, OWNER, owns "Academia Homologação"), `hml-newbie` (novo@myacademy.dev).

### Architecture

- **NestJS modules** — each domain (exercises, workouts, users, personals, etc.) is a self-contained module under `src/<domain>/`.
- **Auth** — Firebase ID token verification via `PreauthMiddleware` (`src/auth/firebase.auth.ts`). Applied globally when `FIREBASE_ENABLED=true`. For local dev, mock auth via `AUTH_MOC_ENABLED=true` + `AUTH_MOC_JSON=<decoded token JSON or array of them>`; `Bearer <AUTH_MOC_TOKEN>:<uid>` picks a user from the array.
- **Authorization** — `AccessService` (`src/access/`) + `@CurrentUserId()`: users act on their own data, personals on their contracted students, gym owners on their gyms; catalog writes (exercises, methods) are ADMIN-only. Self-service roles are STUDENT/PERSONAL/OWNER; ADMIN is granted only in the DB. `NODE_ENV=production` refuses to boot without `FIREBASE_ENABLED=true` or with `AUTH_MOC_ENABLED=true`.
- **Cache** — global `CacheModule` backed by Redis when `REDIS_URL` is set (TTL in ms); services evict list keys on writes.
- **Prisma** — single `PrismaService` (`src/prisma.service.ts`) injected into repositories. Schema is at `prisma/schema.prisma`.
- **Swagger/Scalar** — API docs auto-generated via `@nestjs/swagger`; served by `@scalar/nestjs-api-reference`.
- **Coverage threshold** — Vitest is configured to require **100% coverage** (branches, functions, lines, statements). All new code must have tests.

### Key env vars

| Var | Purpose |
|-----|---------|
| `FIREBASE_ENABLED` | Enable Firebase auth middleware |
| `AUTH_MOC_ENABLED` | Bypass Firebase for local dev |
| `AUTH_MOC_JSON` | Decoded Firebase token JSON for mock auth |
| `SA_*` | Firebase service account fields |
| `TELEGRAM_TOKEN` | Telegram bot token |

---

## App (`app/`)

### Commands

```bash
# Install dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome

# Local homologation against the Docker API with persona login (any password)
flutter run -d chrome --dart-define=USE_MOCK_AUTH=true --dart-define=API_BASE_URL=http://localhost:9000/api/

# Build for web (production)
flutter build web

# Run unit/widget tests
flutter test

# Run a single test file
flutter test test/features/workouts/workouts_test.dart

# Run integration tests
flutter test integration_test/

# Regenerate Riverpod/JSON code (after annotations change)
dart run build_runner build --delete-conflicting-outputs
```

### Architecture

Follows Clean Architecture with three layers per feature under `lib/features/<feature>/`:
- **`data/`** — repositories (implementation), data sources, DTOs/models
- **`domain/`** — entities, repository interfaces, use cases
- **`presentation/`** — pages, widgets, Riverpod providers

Shared infrastructure lives in `lib/core/`:
- **`network/`** — `ApiClient` (Dio wrapper with auth token injection) and `dio_provider.dart` (Riverpod provider)
- **`router/`** — `app_router.dart` (GoRouter, generated with `@riverpod`)
- **`exceptions/`** — typed `Failure` classes (`NetworkFailure`, `ServerFailure`, `AuthFailure`)
- **`theme/`**, **`widgets/`**, **`utils/`** — shared UI and utilities

### State management

Riverpod (`flutter_riverpod` + `hooks_riverpod`). Code generation via `riverpod_annotation` — run `build_runner` after adding or changing `@riverpod` annotations to regenerate `.g.dart` files.

### Routing

GoRouter with auth-based redirects. Unauthenticated users land on `/login`; unboarded users redirect to `/onboarding`; authenticated users go to `/home`. Routes are defined in `lib/core/router/app_router.dart`.

### Linting

Enforced by `analysis_options.yaml` (extends `flutter_lints`). Key rules: `prefer_single_quotes`, `prefer_const_constructors`, `always_declare_return_types`. Run `flutter analyze` to check.

### Code conventions

- Max **150 lines per file/widget** — refactor if exceeded.
- No `dynamic` types unless strictly necessary.
- Use `dartz` `Either` for functional error handling in domain/data layers.
