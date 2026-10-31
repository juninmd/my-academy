# openGym review: what was imported

Source: DuarteSantos8/openGym at `b6cfe2bb` (AGPL-3.0-or-later). Its code is **not copied**: each idea
is reimplemented here, so no AGPL obligation comes with it. Its exercise catalogue and muscle-map
data files are not copied either.

## Imported (API)

| openGym feature | Here | Endpoint |
|---|---|---|
| Estimated 1RM, PRs per exercise | `progress` | `GET /progress/exercises/:id` |
| Activity heatmap, weekly volume | `progress` | `GET /progress/summary` |
| Body-weight chart and weekly rate | `progress` | `GET /progress/body-weight` |
| Relative strength (lift ÷ body weight) | `progress` | `GET /progress/exercises/:id/relative` |
| Muscle volume, recovery, untrained muscles | `progress` + `muscles/` | `GET /progress/muscles` |
| Structural balance ratios | `muscles/muscles.ts` | inside `/progress/muscles` (`balance`) |
| Progression: linear, double, triple, stall → deload | `progress/progression.ts` | `GET /progress/exercises/:id/suggestion` |
| Plate calculator | `plates/` | `GET /plates` |
| Starter plans (PPL, Upper/Lower, Full Body, 5×5) | `starter-plans/` | `GET /starter-plans`, `POST /starter-plans/:key/apply` |
| Favourite exercises | `favorites/` | `GET/POST /favorites`, `DELETE /favorites/:id` |
| Export: JSON backup and CSV of sets | `export/` | `GET /export/json`, `GET /export/csv` |
| Import Strong, Hevy, FitNotes or own CSV | `imports/csv.ts` | `POST /imports/csv` |
| Restore a JSON backup | `imports/json.ts` | `POST /imports/json` |
| Hevy Pro account import (key used once, not stored) | `imports/hevy.ts` | `POST /imports/hevy` |
| Next routine in A, B, C rotation | `rotation/` | `GET /rotation/next` |
| AI coach advice, read-only, off without a key | `coach/` | `POST /coach/advice` |

Import rules, as in openGym: days that already hold the exercise are skipped (re-importing is safe),
exercises are matched by name against the catalogue, and unmatched names are returned in
`unmatchedExercises` instead of being created. Pounds are converted when the header says `lb` or
`unit: "lb"` is sent. Dates without a timezone are read as UTC.

The coach sends the last N days of summary numbers to Anthropic. It is off unless
`ANTHROPIC_API_KEY` is set, and it never changes a log or routine (`COACH_MODEL` picks the model).

## Imported (MCP)

- `mcp/`: stdio MCP server so an assistant such as Claude Desktop can read the student's muscle
  overview, progress summary, exercise progress and suggestions, body weight, plates, starter plans,
  and coach advice. See `mcp/README.md`.

## Imported (Flutter)

- `app/lib/features/progress/`: muscle recovery and balance page (`/progress/muscles`), with a coach
  advice dialog.
- "Next time" card on exercise details, from the progression endpoint.
- `app/lib/features/data_transfer/` (`/data`): export backup and sets, import CSV or backup file,
  import from Hevy Pro.
- Favourites are mirrored to the server when signed in: device and server lists merge on load, and
  each toggle is sent best effort.
- Already in the app before this work, not re-imported: plate calculator dialog, starter plans,
  drop sets, rest timer, offline cache of workouts, 1RM calculator.

## Schema

- `exercise_favorites` table (unique per user and exercise).
- `exercises.muscles` text array; the first entry is the primary muscle and counts fully, the others
  count half. Seeded exercises get muscles from `prisma/seed-muscles.ts`; admins set them with the
  exercise endpoints.

Migration `20261031000000_add_favorites_and_muscles` was checked against the previous schema: after
applying it, `prisma migrate diff` reports no difference.

## Not imported, and why

| openGym feature | Reason |
|---|---|
| Supersets | Needs a schema change and a rework of the workout player. Not started. |
| Pyramid sets, rest-pause, card/list view | Workout UI. The set `type` field could carry them; not built. |
| Health Connect, Apple Health (both directions), Apple Watch, widgets, Live Activity, gym reminder | Native plugins and devices. Cannot be built or tested in this environment. |
| Apple Health weight import | Assessments need a personal and a height in this schema. Needs a design decision first. |
| Passkeys, pairing by QR, offline sync with field-level merge | Auth and sync architecture change. This app uses Firebase auth and a server-first model. |
| 5,600-exercise catalogue, 20 languages | Content. The catalogue belongs to that AGPL project and is not copied; the app is in Portuguese only. |
| Admin dashboard with invite-only signup | Overlaps existing roles and admin tooling. |
| openGym's own mobile-only features (sharing a plan as a file or PDF) | Not planned for this app yet. |
