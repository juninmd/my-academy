# Exercise media

Catalog exercise images are served from object storage, not bundled in the app.

- **Source:** [yuhonas/free-exercise-db](https://github.com/yuhonas/free-exercise-db), released under the [Unlicense](https://github.com/yuhonas/free-exercise-db/blob/main/LICENSE) (public domain). No attribution is required; this file keeps the provenance anyway.
- **Mapping:** `api/prisma/exercise-media.ts` maps each seeded exercise to a free-exercise-db id and a slug. The seed stores `EXERCISE_MEDIA_BASE_URL/<slug>.webp` in `exercises.image`.
- **Format:** one animated WebP per exercise, 720×480 on a white background, with two frames (start position, then end position) at 0.8 s each. That is about 50 KB per exercise.
- **Location (PoC):** bucket `fast-dl-cs` on Magalu Object Storage, under the prefix `my-academy/exercises/v1/`. Objects are public-read, and the bucket answers CORS for GET, which Flutter web needs. Moving to a dedicated bucket only needs a new `EXERCISE_MEDIA_BASE_URL` and a re-seed.

## Regenerate or upload

Requires `ffmpeg` built with libwebp. Keys are always read from the environment; never commit them.

```bash
cd api
bun scripts/sync-exercise-media.ts --out ./media          # build only
S3_ENDPOINT=https://br-se1.magaluobjects.com S3_BUCKET=fast-dl-cs \
S3_ACCESS_KEY_ID=... S3_SECRET_ACCESS_KEY=... \
  bun scripts/sync-exercise-media.ts --out ./media --upload
```

Changing an existing image means a new prefix (`v2`), because clients cache each URL indefinitely.

Rows seeded before this change still point at `assets/images/*.gif`. The seed rewrites those rows. Any other leftover shows the app's fallback icon.
