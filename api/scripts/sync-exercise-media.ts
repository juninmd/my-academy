// Builds one animated WebP per catalog exercise (start -> end position) from
// free-exercise-db and uploads it to S3-compatible object storage.
//
//   bun scripts/sync-exercise-media.ts --out ./media            # build only
//   S3_ENDPOINT=... S3_BUCKET=... S3_ACCESS_KEY_ID=... S3_SECRET_ACCESS_KEY=... \
//     bun scripts/sync-exercise-media.ts --out ./media --upload
//
// Requires ffmpeg with libwebp. Re-running overwrites the same keys.
import { S3Client } from 'bun';
import { mkdir } from 'node:fs/promises';
import { join } from 'node:path';
import {
  EXERCISE_MEDIA,
  FREE_EXERCISE_DB_RAW,
} from '../prisma/exercise-media.js';

const KEY_PREFIX = 'my-academy/exercises/v1';
const FILTER =
  'scale=720:480:force_original_aspect_ratio=decrease,' +
  'pad=720:480:(ow-iw)/2:(oh-ih)/2:color=white';

function arg(name: string): string | undefined {
  const i = process.argv.indexOf(name);
  return i === -1 ? undefined : process.argv[i + 1];
}

async function download(url: string, path: string) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`GET ${url} -> ${res.status}`);
  await Bun.write(path, res);
}

function encode(framesDir: string, output: string) {
  const ffmpeg = Bun.spawnSync(
    [
      'ffmpeg',
      '-v',
      'error',
      '-y',
      '-framerate',
      '1.25',
      '-i',
      join(framesDir, '%d.jpg'),
      '-vf',
      FILTER,
      '-c:v',
      'libwebp_anim',
      '-quality',
      '70',
      '-loop',
      '0',
      output,
    ],
    { stderr: 'pipe' },
  );
  if (ffmpeg.exitCode !== 0) {
    throw new Error(`ffmpeg failed for ${output}: ${ffmpeg.stderr.toString()}`);
  }
}

function s3FromEnv(): S3Client {
  const { S3_ENDPOINT, S3_BUCKET, S3_ACCESS_KEY_ID, S3_SECRET_ACCESS_KEY } =
    process.env;
  if (
    !S3_ENDPOINT ||
    !S3_BUCKET ||
    !S3_ACCESS_KEY_ID ||
    !S3_SECRET_ACCESS_KEY
  ) {
    throw new Error('S3_ENDPOINT, S3_BUCKET and S3 credentials are required');
  }
  return new S3Client({
    endpoint: S3_ENDPOINT,
    bucket: S3_BUCKET,
    accessKeyId: S3_ACCESS_KEY_ID,
    secretAccessKey: S3_SECRET_ACCESS_KEY,
  });
}

async function main() {
  const outDir = arg('--out') ?? 'media';
  const s3 = process.argv.includes('--upload') ? s3FromEnv() : undefined;

  for (const { slug, source } of Object.values(EXERCISE_MEDIA)) {
    const framesDir = join(outDir, 'frames', slug);
    await mkdir(framesDir, { recursive: true });
    for (const frame of [0, 1]) {
      await download(
        `${FREE_EXERCISE_DB_RAW}/${source}/${frame}.jpg`,
        join(framesDir, `${frame + 1}.jpg`),
      );
    }
    const output = join(outDir, `${slug}.webp`);
    encode(framesDir, output);

    const file = Bun.file(output);
    if (s3) {
      await s3.write(`${KEY_PREFIX}/${slug}.webp`, file, {
        type: 'image/webp',
      });
    }
    console.log(
      `${slug}.webp ${Math.round(file.size / 1024)} KB${s3 ? ' uploaded' : ''}`,
    );
  }
}

await main();
