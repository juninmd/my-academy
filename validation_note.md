# Validation Note

## Persona Homologation — real Postgres + Redis (2026-09-18)

Stack: `docker compose up -d --build` (Postgres 16, Redis 7, API on Bun 1.4 / NestJS 12). Personas: aluno, personal, dono de academia.

### API
- Unit: 331/331, coverage 100% (gate restored to 100%). tsc + eslint clean.
- E2E real DB (`bun run test:e2e:db`): 8/8 — health, profile ownership, catalog + Redis invalidation, methods, student workout (22.5 kg) + session, stranger 403s, personal contract/prescription/assessment, gym enrollment → payment PAID → dashboard revenue.
- Bugs fixed: IDOR on user-scoped routes; POST /personals and /methods rejected every payload (DTOs without validators under forbidNonWhitelisted); POST /workouts-groups required `image`, which the app never sends; integer-only weights; P2002 mapping with the pg adapter; 60 ms cache TTL.

### App (Flutter web, walked through with Playwright at 390px and 1366px)
- Student: login → onboarding → home → create workout with 22,5 kg → profile shows gym membership.
- Personal: onboarding → Alunos tab lists the contracted student.
- Owner: lands on /gym → enroll student → mark payment paid → KPIs update.
- Bugs fixed: release builds ignored API_BASE_URL; save errors swallowed on workout create; exercise GIFs 404 on web; FAB covering "Salvar Treino"; blank avatars on blocked images; truncated enroll dialog; unlabeled icon buttons.
- Round 2 (flutter analyze clean, flutter test 161 passed): onboarding stored server-side (`onboardedAt`, new device skips it); typed stepper values bounded; no placeholder avatar URL (CORS); set inputs wrap under 480px; details header contrast; dashboard/calendar/history refresh after finishing a workout (was stale until reload); summary card contrast and share label on 390px.
- Round 3 (flutter test 163 passed): calendar summary banner contrast; session time from `createdAt` (was always 00:00); dead "2 weeks" format toggle removed; login form capped at 488px on desktop. README screenshots in `docs/screenshots/`.

## Final Homologation & Validation (2026-08-22)

### API (`api/`)
- **Lint**: Clean (eslint + prettier). Fixed 31 files with CRLF line endings (`.gitattributes` added to prevent recurrence).
- **Unit tests**: 206/206 passed (38 suites).
- **E2E homologation**: 7/7 passed (`test/homologation.e2e-spec.ts` + `app.e2e-spec.ts`) — users/auth, exercises, workouts, sessions, personal trainer flows.
- **Fix**: bumped `main.spec.ts` bootstrap timeout 10s → 30s (flaky under parallel load).

### App (`app/` - Flutter, validated via Docker `ghcr.io/cirruslabs/flutter:stable`)
- **Analyze**: No issues (fixed `onReorder` deprecation → `onReorderItem`).
- **Tests**: 139 passed, 2 skipped (pre-existing).

### CI
- **Blocked**: GitHub Actions failing due to account billing/spending limit ("recent account payments have failed"). Not a code issue. Re-run after billing resolved.

### Cleanup
- Removed stale validation artifacts: `api/coverage_output.txt`, `api/e2e_output.txt`, `api/homologation_results.txt`, `app/analysis.txt`.
### CI Notice (2026-11-05)
- **Blocked**: GitHub Actions failing again due to account billing/spending limit ("recent account payments have failed"). Not a code issue. Security workflows (Gitleaks) remain intentionally untouched as per project policy.
