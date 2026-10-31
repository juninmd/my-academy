# openGym review: what to adopt

Source: README and ROADMAP of DuarteSantos8/openGym (code not reviewed).

## Adopted (API, this branch)

| openGym idea | Here |
|---|---|
| Estimated 1RM, PRs, per-exercise progress | `GET /progress/exercises/:id` |
| Year heatmap, weekly volume | `GET /progress/summary` |
| Body-weight chart | `GET /progress/body-weight` |
| Progression rules (linear, double, stall → deload) | `GET /progress/exercises/:id/suggestion` |
| Plate math | `GET /plates?target=&bar=&plates=` |
| Starter plans (PPL, Upper/Lower, Full Body, 5x5) | `GET /starter-plans`, `POST /starter-plans/:key/apply` |
| Export everything (JSON) and sets (CSV) | `GET /export/json`, `GET /export/csv` |

Starter plans match the catalog by Portuguese name terms; exercises not found are returned in `missingExercises`.

## Next (needs schema or Flutter work)

1. Flutter screens for the endpoints above (no Flutter SDK in this environment, so not built/tested).
2. Favourite exercises, per-set RIR/RPE colour, backup exercise per slot (schema).
3. Muscle map: volume/recovery/untrained (needs muscle fields on `Exercises`).
4. Import from Strong/Hevy/FitNotes CSV.
5. Supersets, drop sets, rest-pause, deload weeks (schema).
6. Offline sync with field-level merge, passkeys, Health Connect/Apple Health (large, app-side).

## Not a fit

Self-hosted single-user model, 20-language catalog of 5,600 exercises, Apple Watch app, AI coach/MCP server: out of scope for a multi-role gym platform for now.
