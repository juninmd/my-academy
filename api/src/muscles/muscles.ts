/** Canonical muscle slugs stored in `Exercises.muscles`. Order is not significant here. */
export const MUSCLES = [
  'chest',
  'back',
  'traps',
  'shoulders',
  'biceps',
  'triceps',
  'forearms',
  'abs',
  'lower_back',
  'glutes',
  'quads',
  'hamstrings',
  'adductors',
  'calves',
] as const;

export type Muscle = (typeof MUSCLES)[number];

/** A set on an exercise counts fully for its first (primary) muscle and this much for the rest. */
export const SECONDARY_WEIGHT = 0.5;

/** Hours after the last hit before a muscle counts as recovered. */
export const RECOVERY_HOURS = 48;

const HOUR_MS = 60 * 60 * 1000;

export function muscleWeights(muscles: string[]): Map<string, number> {
  const weights = new Map<string, number>();
  const known = muscles.filter((m): m is Muscle =>
    (MUSCLES as readonly string[]).includes(m),
  );
  known.forEach((muscle, index) => {
    if (!weights.has(muscle)) {
      weights.set(muscle, index === 0 ? 1 : SECONDARY_WEIGHT);
    }
  });
  return weights;
}

export interface BalancePair {
  key: string;
  label: string;
  left: { label: string; muscles: Muscle[] };
  right: { label: string; muscles: Muscle[] };
  /** Healthy range for left / right, a training heuristic and not medical advice. */
  min: number;
  max: number;
}

export const BALANCE_PAIRS: BalancePair[] = [
  {
    key: 'push_pull',
    label: 'Push vs pull',
    left: { label: 'Push', muscles: ['chest', 'shoulders', 'triceps'] },
    right: { label: 'Pull', muscles: ['back', 'traps', 'biceps'] },
    min: 0.8,
    max: 1.2,
  },
  {
    key: 'chest_back',
    label: 'Chest vs back',
    left: { label: 'Chest', muscles: ['chest'] },
    right: { label: 'Back', muscles: ['back'] },
    min: 0.8,
    max: 1.2,
  },
  {
    key: 'quads_hamstrings',
    label: 'Quads vs hamstrings',
    left: { label: 'Quads', muscles: ['quads'] },
    right: { label: 'Hamstrings', muscles: ['hamstrings'] },
    min: 0.67,
    max: 1.5,
  },
  {
    key: 'biceps_triceps',
    label: 'Biceps vs triceps',
    left: { label: 'Biceps', muscles: ['biceps'] },
    right: { label: 'Triceps', muscles: ['triceps'] },
    min: 0.55,
    max: 0.8,
  },
];

export type BalanceStatus =
  'no_data' | 'right_untrained' | 'left_low' | 'left_high' | 'balanced';

export interface BalanceResult {
  key: string;
  label: string;
  left: number;
  right: number;
  ratio: number | null;
  status: BalanceStatus;
}

const sumOf = (volume: Map<string, number>, muscles: Muscle[]) =>
  muscles.reduce((total, m) => total + (volume.get(m) ?? 0), 0);

const round2 = (value: number) => Math.round(value * 100) / 100;

/** Compares weighted set counts per muscle group for each balance pair. */
export function balanceOf(volume: Map<string, number>): BalanceResult[] {
  return BALANCE_PAIRS.map((pair) => {
    const left = sumOf(volume, pair.left.muscles);
    const right = sumOf(volume, pair.right.muscles);
    const base = {
      key: pair.key,
      label: pair.label,
      left: round2(left),
      right: round2(right),
    };
    if (left + right === 0) return { ...base, ratio: null, status: 'no_data' };
    if (right === 0) return { ...base, ratio: null, status: 'right_untrained' };
    const ratio = round2(left / right);
    const status =
      ratio < pair.min
        ? 'left_low'
        : ratio > pair.max
          ? 'left_high'
          : 'balanced';
    return { ...base, ratio, status };
  });
}

export type RecoveryState = 'untrained' | 'recovering' | 'recovered';

/** `lastTrainedMs` is null when the muscle has no working sets in the window. */
export function recoveryOf(
  lastTrainedMs: number | null,
  nowMs: number,
): RecoveryState {
  if (lastTrainedMs === null) return 'untrained';
  return nowMs - lastTrainedMs < RECOVERY_HOURS * HOUR_MS
    ? 'recovering'
    : 'recovered';
}
