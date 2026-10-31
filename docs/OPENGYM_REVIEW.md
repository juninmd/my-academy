# openGym review: what was imported

Source: DuarteSantos8/openGym at `b6cfe2bb` (AGPL-3.0-or-later). Its code is **not copied**: each idea
below is reimplemented in this codebase, so no AGPL obligation comes with it. Exercise catalogue and
muscle-map JSON files from that repository are also not copied; muscles are curated here instead.

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
| Import from Strong, Hevy, FitNotes or own CSV | `imports/csv.ts` | `POST /imports/csv` |
| Restore a JSON backup | `imports/json.ts` | `POST /imports/json` |

Import rules, as in openGym: days that already hold the exercise are skipped (re-importing is safe),
exercises are matched by name against the catalogue, and unmatched names are returned in
`unmatchedExercises` instead of being created. Pounds are converted when the header says `lb`
or `unit: "lb"` is sent. Dates without a timezone are read as UTC.

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
| Flutter screens for the new endpoints | No Flutter SDK in this environment; nothing Dart was built or tested. Next step. |
| Rest timer, supersets, drop sets, pyramid sets, swipe-to-delete, card/list views | Workout UI, belongs to the app. The `type` field on sets already allows drop/warm-up/pyramid kinds. |
| Plan share as file or PDF, print | App-side. |
| Apple Health, Health Connect, Apple Watch, widgets, Live Activity, gym reminder | Native mobile features. |
| Hevy API import | Calls a third-party API with the user's key; not added yet. The CSV export from Hevy already imports. |
| Offline-first sync with field-level merge, passkeys, pairing by QR | Large architecture change; this API is server-first and uses Firebase auth. |
| AI coach and MCP server | Out of scope for now. |
| 20 languages, 5,600-exercise catalogue | Content, licensed under AGPL in that repository; not copied. |
| Admin dashboard with invite-only signup | Overlaps existing roles and admin tooling. |
