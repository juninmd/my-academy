import { round, workingSets, type SetLike } from './progress.math.js';

export type Strategy = 'linear' | 'double';

export interface ProgressionOptions {
  strategy: Strategy;
  increment: number;
  /** Linear: reps every set must reach. Double: bottom of the rep range. */
  minReps: number;
  /** Double progression: top of the rep range. */
  maxReps: number;
}

export interface Suggestion {
  weight: number;
  reps: number;
  deload: boolean;
  reason: string;
}

const STALLS_BEFORE_DELOAD = 3;
const DELOAD_FACTOR = 0.9;

export function roundTo(value: number, step: number): number {
  return round(Math.round(value / step) * step);
}

interface Session {
  weight: number;
  reps: number[];
}

/** Reduces a session to its heaviest working weight and the reps done at it. */
function toSession(sets: SetLike[]): Session | null {
  const working = workingSets(sets);
  if (working.length === 0) return null;
  const weight = Math.max(...working.map((s) => s.weight));
  return {
    weight,
    reps: working.filter((s) => s.weight === weight).map((s) => s.reps),
  };
}

function succeeded(session: Session, options: ProgressionOptions): boolean {
  const target =
    options.strategy === 'linear' ? options.minReps : options.maxReps;
  return Math.min(...session.reps) >= target;
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
  if (succeeded(last, options)) {
    return {
      weight: roundTo(last.weight + increment, increment),
      reps: minReps,
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
    deload: false,
    reason: 'Target missed: keep the load and chase the reps.',
  };
}
