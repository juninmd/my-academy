<div align="center">

# 🏋️ My Academy

**Workouts, personal trainers and gyms in one app.**
Students log their training, personal trainers follow their students, and gym owners run memberships and payments.

[![Flutter](https://img.shields.io/badge/Flutter-Web%20·%20Android%20·%20iOS-02569B?logo=flutter&logoColor=white)](app/)
[![NestJS](https://img.shields.io/badge/NestJS-12-E0234E?logo=nestjs&logoColor=white)](api/)
[![Bun](https://img.shields.io/badge/Bun-1.4-000000?logo=bun&logoColor=white)](api/)
[![Prisma](https://img.shields.io/badge/Prisma-7-2D3748?logo=prisma&logoColor=white)](api/prisma/schema.prisma)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql&logoColor=white)](docker-compose.yml)
[![Redis](https://img.shields.io/badge/Redis-7-DC382D?logo=redis&logoColor=white)](docker-compose.yml)
[![Coverage](https://img.shields.io/badge/API%20coverage-100%25-brightgreen)](api/vitest.config.ts)

<img src="docs/screenshots/login-desktop.png" alt="My Academy login screen on desktop" width="820">

</div>

---

## ✨ One app, three roles

| 🧑‍🎓 Student | 🧑‍🏫 Personal trainer | 🏢 Gym owner |
|---|---|---|
| Build workout plans from an exercise catalog with GIFs | Contract students and see them in one list | Create a gym and its membership plans |
| Guided workout player: sets, fractional loads (22.5 kg), RPE, rest timer | Prescribe workouts and record physical assessments | Enroll students and track their memberships |
| Dashboard with weekly goal, volume, streak and charts | Uses every student feature for their own training | Record payments: pending → paid → overdue |
| Calendar, progress analytics and personal records | | Dashboard: active members, monthly revenue, overdue payments |

Onboarding asks for the role once and saves it on the server, so a new device skips it.

## 📸 Screenshots

### Student (mobile)

<table>
  <tr>
    <td align="center"><img src="docs/screenshots/login.png" width="200" alt="Login"><br><sub>Login</sub></td>
    <td align="center"><img src="docs/screenshots/student-home.png" width="200" alt="Home dashboard"><br><sub>Home dashboard</sub></td>
    <td align="center"><img src="docs/screenshots/workout-details.png" width="200" alt="Workout details"><br><sub>Workout plan</sub></td>
    <td align="center"><img src="docs/screenshots/workout-player.png" width="200" alt="Workout player"><br><sub>Workout player</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/workout-summary.png" width="200" alt="Workout summary"><br><sub>Workout summary</sub></td>
    <td align="center"><img src="docs/screenshots/calendar.png" width="200" alt="Calendar"><br><sub>Calendar</sub></td>
    <td align="center"><img src="docs/screenshots/progress.png" width="200" alt="Progress analytics"><br><sub>Progress</sub></td>
    <td align="center"><img src="docs/screenshots/personal-students.png" width="200" alt="Personal trainer students"><br><sub>Personal trainer · students</sub></td>
  </tr>
</table>

### Desktop

On wide screens the bottom bar becomes a side navigation rail and content is centered.

<img src="docs/screenshots/student-home-desktop.png" alt="Student dashboard on desktop" width="820">

<table>
  <tr>
    <td align="center"><img src="docs/screenshots/owner-gym-desktop.png" alt="Gym owner members"><br><sub>Gym owner · members</sub></td>
    <td align="center"><img src="docs/screenshots/owner-payments-desktop.png" alt="Gym owner payments"><br><sub>Gym owner · payments</sub></td>
  </tr>
</table>

## 🧱 Architecture

```mermaid
flowchart LR
  subgraph Client
    APP["Flutter app<br/>Riverpod · GoRouter · Dio"]
  end
  subgraph Server["API · NestJS 12 on Bun"]
    AUTH["Firebase / mock auth<br/>middleware"]
    ACCESS["AccessService<br/>ownership rules"]
    MODS["Domain modules<br/>workouts · sessions · gyms · personals · …"]
  end
  APP -- "Bearer token" --> AUTH --> ACCESS --> MODS
  MODS -- Prisma --> PG[(PostgreSQL 16)]
  MODS -- "catalog cache" --> RD[(Redis 7)]
```

| Path | What lives there |
|---|---|
| [`api/`](api/) | NestJS 12 (ESM, TypeScript 6) on Bun, Prisma 7 + `@prisma/adapter-pg`, Redis cache, OpenAPI docs |
| [`app/`](app/) | Flutter with Clean Architecture per feature (`data` / `domain` / `presentation`) and Riverpod |
| [`docker-compose.yml`](docker-compose.yml) | Local stack: Postgres, Redis and the seeded API |

**Authorization:** users act on their own data, personal trainers on their contracted students, gym owners on their gyms. Catalog writes (exercises, methods) are ADMIN-only.

## 🚀 Quick start

**Requirements:** Docker, plus Flutter (stable) to run the app.

```bash
# 1. API + Postgres + Redis, seeded with test personas and mock auth
docker compose up -d --build
curl -fsS http://localhost:9000/health        # {"status":"ok"}

# 2. Flutter app pointing to the local API, with persona login
cd app
flutter pub get
flutter run -d chrome \
  --dart-define=USE_MOCK_AUTH=true \
  --dart-define=API_BASE_URL=http://localhost:9000/api/
```

API docs: <http://localhost:9000/reference> (Scalar) · <http://localhost:9000/docs> (Swagger UI).

### Test personas

With mock auth, sign in with any password:

| Email | Role | What to try |
|---|---|---|
| `aluno@myacademy.dev` | Student | Create a workout, run the player, check the dashboard and calendar |
| `personal@myacademy.dev` | Personal trainer | Students tab, prescriptions, assessments |
| `dono@myacademy.dev` | Gym owner (ADMIN) | Owns "Academia Homologação": plans, enrollments, payments |
| `novo@myacademy.dev` | New user | Full onboarding flow |

Direct API calls use `Authorization: Bearer mock-token:<uid>`, where the uid is one of `hml-student`, `hml-personal`, `hml-owner` or `hml-newbie`.

## 🧪 Quality gates

| Scope | Command | Gate |
|---|---|---|
| API unit | `cd api && bun run test:cov` | Vitest, **100 %** coverage threshold |
| API types + lint | `bun run typecheck && bun run lint` | tsc + ESLint 10 |
| API e2e (mocked) | `bun run test:e2e` | Controllers and pipes end to end |
| API e2e (real DB) | `bun run test:e2e:db` | Persona journeys against Docker Postgres + Redis |
| App | `cd app && flutter analyze && flutter test` | Lints + widget/unit tests |

Tests run with at most 2 workers so they don't overload the machine.

## 📚 More docs

- [`api/README.md`](api/README.md): API setup, environment variables, Prisma
- [`BUSINESS_RULES.md`](BUSINESS_RULES.md): domain rules
- [`SECURITY.md`](SECURITY.md): how to report vulnerabilities
- [`validation_note.md`](validation_note.md): latest homologation run and fixed bugs
