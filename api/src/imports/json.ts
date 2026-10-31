import type { ImportedSet } from './csv.js';
import { dayKey } from '../progress/progress.math.js';

const MAX_REPS = 1000;
const MAX_KG = 2000;

const isRecord = (value: unknown): value is Record<string, unknown> =>
  typeof value === 'object' && value !== null && !Array.isArray(value);

const numberOf = (value: unknown): number | null =>
  typeof value === 'number' && Number.isFinite(value) ? value : null;

/**
 * Reads the `exerciseLogs` of an export file (GET /export/json) back into sets.
 * Logs are matched to the catalogue by exercise name, as with CSV.
 */
export function fromExportJson(payload: unknown): {
  sets: ImportedSet[];
  skippedRows: number;
} {
  const logs =
    isRecord(payload) && Array.isArray(payload.exerciseLogs)
      ? payload.exerciseLogs
      : [];
  const sets: ImportedSet[] = [];
  let skippedRows = 0;

  for (const log of logs) {
    const exercise =
      isRecord(log) && isRecord(log.exercise) ? log.exercise.name : undefined;
    const date =
      isRecord(log) && typeof log.date === 'string' ? new Date(log.date) : null;
    const logSets = isRecord(log) && Array.isArray(log.sets) ? log.sets : [];
    if (typeof exercise !== 'string' || !date || Number.isNaN(date.getTime())) {
      skippedRows += logSets.length || 1;
      continue;
    }
    for (const set of logSets) {
      if (!isRecord(set)) {
        skippedRows++;
        continue;
      }
      const reps = numberOf(set.reps);
      const weight = numberOf(set.weight);
      if (
        reps === null ||
        weight === null ||
        reps <= 0 ||
        reps > MAX_REPS ||
        weight < 0 ||
        weight > MAX_KG
      ) {
        skippedRows++;
        continue;
      }
      const rpe = numberOf(set.rpe);
      sets.push({
        day: dayKey(date),
        date,
        exercise,
        reps,
        weight,
        rpe: rpe !== null && rpe >= 1 && rpe <= 10 ? Math.round(rpe) : null,
      });
    }
  }
  return { sets, skippedRows };
}
