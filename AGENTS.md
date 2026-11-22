# AGENTS.md

My Academy: gym management platform. NestJS API (`api/`) and Flutter app (`app/`), plus an MCP server (`mcp/`). Details in `CLAUDE.md`; this file is the short contract for agents.

## Stack

- API: NestJS 12, TypeScript, Bun, Prisma on PostgreSQL, Redis cache, Firebase auth
- App: Flutter (Dart >= 3.13), Riverpod, GoRouter, Dio; web deployed to Netlify
- MCP: Node, Vitest, Bun lockfile

## Commands

```bash
# API (run in api/)
bun install --frozen-lockfile
bun run prisma:generate        # after any schema.prisma change
bun run typecheck
bunx eslint "{src,test}/**/*.ts"   # CI form; `bun run lint` adds --fix
bun run test:cov               # Vitest, 100% coverage gate
bun run test:e2e
bun run build

# Local stack (repo root): Postgres :5433, Redis :6380, API :9000
docker compose up -d --build
curl -fsS http://localhost:9000/health

# App (run in app/)
flutter pub get
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs   # after @riverpod / json annotations
flutter build web

# MCP (run in mcp/)
bun run test:cov
```

## Structure

- `api/src/<domain>/` - one NestJS module per domain (exercises, progress, gyms, ...)
- `api/prisma/` - `schema.prisma`, migrations, seeds
- `app/lib/features/<feature>/` - `data/`, `domain/`, `presentation/` (Clean Architecture)
- `app/lib/core/` - network (`ApiClient`), router, exceptions, theme, widgets, utils
- `docs/` - project docs and screenshots; `BUSINESS_RULES.md` for domain rules
- `mcp/` - MCP server package with its own tests

## Conventions

- Max 150 lines per file or widget; refactor when it grows.
- Composition over inheritance for UI components.
- No `dynamic` unless strictly necessary. Use `dartz` `Either` in domain and data layers.
- Every new API code path needs tests; the 100% coverage gate is enforced in CI.
- Workflow: Plan -> Act -> Validate. `flutter test` must pass before any change is done.
- Personas used as review lenses: architect (scalability, clean architecture), UI/UX (accessibility, widget quality), DevOps (CI and E2E reliability).
- `GEMINI.md` files are the instruction set for AI tools; keep them consistent with this file.

<!-- base-actions-main-policy -->
## GitHub Actions — padrão obrigatório (@main)

- Referencie as actions internas sempre pelo branch, nunca por SHA:
  - `uses: juninmd/base-actions/<action>@main`
  - `uses: juninmd/base-actions/.github/workflows/<arquivo>.yml@main`
- Não fixe `@<sha>` em `juninmd/base-actions`: a atualização é centralizada no
  `main` e passa a valer no próximo run.
- PRs cujos checks não iniciam por billing/spending limit são mesclados pelo bot central
  `juninmd/base-actions/.github/workflows/auto-merge-billing-blocked.yml`.
  Para impedir o merge automático de um PR, aplique a label `do-not-merge`.

## Gotchas

- Package manager is Bun (`api/bun.lock`, CI uses `--frozen-lockfile`). `api/GEMINI.md` says pnpm; that is stale. Do not add a pnpm or npm lockfile.
- Env vars (names only, values stay out of git): `FIREBASE_ENABLED`, `AUTH_MOC_ENABLED`, `AUTH_MOC_JSON`, `REDIS_URL`, `TELEGRAM_TOKEN`, `SA_*`. `NODE_ENV=production` refuses to boot with mock auth.
- Local dev uses mock auth: `Authorization: Bearer mock-token:<uid>` with the homologation personas from `api/prisma/seed-homologation.ts`.
- Generated files: `app/**/*.g.dart` is tracked. Regenerate with build_runner; never hand-edit.
