import { round, workingSets, type SetLike } from './progress.math.js';

/**
 * linear: every set hits `minReps`, then add load.
 * double: every set hits `maxReps`, then add load and restart at `minReps`.
 * triple: reps first (to `maxReps`), then extra sets up to `maxSets`, then load.
 */
export type Strategy = 'linear' | 'double' | 'triple';

export interface ProgressionOptions {
  strategy: Strategy;
  increment: number;
  minReps: number;
  maxReps: number;
  /** Triple progression only. */
  maxSets?: number;
}

export interface Suggestion {
  weight: number;
  reps: number;
  sets: number;
  deload: boolean;
  reason: string;
}

const STALLS_BEFORE_DELOAD = 3;
const DELOAD_FACTOR = 0.9;
export const TRIPLE_DEFAULT_MAX_SETS = 5;

export function roundTo(value: number, step: number): number {
  return round(Math.round(value / step) * step);
}

interface Session {
  weight: number;
  reps: number[];
  sets: number;
}

/** Reduces a session to its heaviest working weight and the reps done at it. */
function toSession(sets: SetLike[]): Session | null {
  const working = workingSets(sets);
  if (working.length === 0) return null;
  const weight = Math.max(...working.map((s) => s.weight));
  return {
    weight,
    reps: working.filter((s) => s.weight === weight).map((s) => s.reps),
    sets: working.length,
  };
}

const targetOf = (options: ProgressionOptions) =>
  options.strategy === 'linear' ? options.minReps : options.maxReps;

function succeeded(session: Session, options: ProgressionOptions): boolean {
  return Math.min(...session.reps) >= targetOf(options);
}

/**
 * Next-session target from past sessions, most recent first.
 * Missed reps never add load; three misses at one weight trigger a deload.
 */
export function suggestNext(
  history: SetLike[][],
  options: ProgressionOptions,
): Suggestion | null {
  const sessions = history
    .map(toSession)
    .filter((s): s is Session => s !== null);
  const last = sessions[0];
  if (!last) return null;

  const { increment, minReps, maxReps, strategy } = options;
  const maxSets = options.maxSets ?? TRIPLE_DEFAULT_MAX_SETS;

  if (succeeded(last, options)) {
    if (strategy === 'triple' && last.sets < maxSets) {
      return {
        weight: last.weight,
        reps: minReps,
        sets: last.sets + 1,
        deload: false,
        reason: 'Top reps on every set: add a set at the same load.',
      };
    }
    return {
      weight: roundTo(last.weight + increment, increment),
      reps: minReps,
      sets: last.sets,
      deload: false,
      reason:
        strategy === 'linear'
          ? 'All sets hit the target reps: add load.'
          : 'Top of the rep range reached: add load and restart at the bottom.',
    };
  }

  let stalls = 0;
  for (const session of sessions) {
    if (session.weight !== last.weight || succeeded(session, options)) break;
    stalls++;
  }
  if (stalls >= STALLS_BEFORE_DELOAD) {
    return {
      weight: roundTo(last.weight * DELOAD_FACTOR, increment),
      reps: minReps,
      sets: last.sets,
      deload: true,
      reason: `Stalled ${stalls} sessions at ${last.weight}: deload 10%.`,
    };
  }

  const reps =
    strategy === 'linear'
      ? minReps
      : Math.min(maxReps, Math.max(minReps, Math.min(...last.reps) + 1));
  return {
    weight: last.weight,
    reps,
    sets: last.sets,
    deload: false,
    reason: 'Target missed: keep the load and chase the reps.',
  };
}
