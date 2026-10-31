import { BadGatewayException, BadRequestException } from '@nestjs/common';
import type { ImportedSet } from './csv.js';
import { dayKey } from '../progress/progress.math.js';

export const HEVY_BASE_URL = 'https://api.hevyapp.com/v1';
export const HEVY_PAGE_SIZE = 10;
export const MAX_HEVY_PAGES = 50;

export interface HevySet {
  type?: string;
  weight_kg?: number | null;
  reps?: number | null;
  rpe?: number | null;
}

export interface HevyWorkout {
  start_time?: string;
  exercises?: { title?: string; sets?: HevySet[] }[];
}

interface HevyPage {
  page: number;
  page_count: number;
  workouts?: HevyWorkout[];
}

type FetchLike = (
  url: string,
  init: { headers: Record<string, string> },
) => Promise<{
  ok: boolean;
  status: number;
  json: () => Promise<unknown>;
}>;

/** Reads every page of the user's workouts. The key is used for this request only. */
export async function fetchHevyWorkouts(
  apiKey: string,
  fetchFn: FetchLike = fetch as unknown as FetchLike,
  maxPages = MAX_HEVY_PAGES,
): Promise<HevyWorkout[]> {
  const workouts: HevyWorkout[] = [];
  for (let page = 1; page <= maxPages; page++) {
    const res = await fetchFn(
      `${HEVY_BASE_URL}/workouts?page=${page}&pageSize=${HEVY_PAGE_SIZE}`,
      { headers: { 'api-key': apiKey, accept: 'application/json' } },
    );
    if (res.status === 401 || res.status === 403) {
      throw new BadRequestException(
        'Hevy rejected the API key (Hevy Pro is needed)',
      );
    }
    if (!res.ok) {
      throw new BadGatewayException(`Hevy answered ${res.status}`);
    }
    const body = (await res.json()) as HevyPage;
    workouts.push(...(body.workouts ?? []));
    if (page >= body.page_count) break;
  }
  return workouts;
}

/** Turns Hevy workouts into sets. Sets without reps or an exercise name are skipped. */
export function hevyToSets(workouts: HevyWorkout[]): {
  sets: ImportedSet[];
  skippedRows: number;
} {
  const sets: ImportedSet[] = [];
  let skippedRows = 0;
  for (const workout of workouts) {
    const date = new Date(workout.start_time ?? '');
    for (const exercise of workout.exercises ?? []) {
      const name = (exercise.title ?? '').trim();
      for (const set of exercise.sets ?? []) {
        const reps = set.reps ?? 0;
        if (
          Number.isNaN(date.getTime()) ||
          name === '' ||
          reps <= 0 ||
          reps > 1000
        ) {
          skippedRows++;
          continue;
        }
        const rpe = set.rpe ?? null;
        sets.push({
          day: dayKey(date),
          date,
          exercise: name,
          reps,
          weight: Math.round((set.weight_kg ?? 0) * 100) / 100,
          rpe: rpe !== null && rpe >= 1 && rpe <= 10 ? Math.round(rpe) : null,
        });
      }
    }
  }
  return { sets, skippedRows };
}
