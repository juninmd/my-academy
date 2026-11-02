export const DEFAULT_PLATES = [25, 20, 15, 10, 5, 2.5, 1.25];

export interface PlateCount {
  plate: number;
  count: number;
}

export interface PlateLoad {
  target: number;
  bar: number;
  perSide: PlateCount[];
  achieved: number;
  remainder: number;
}

const EPSILON = 1e-9;

/** Greedy plate loading per side, heaviest plate first. */
export function calculatePlates(
  target: number,
  bar: number,
  available: number[],
): PlateLoad {
  let remaining = Math.max(0, (target - bar) / 2);
  const perSide: PlateCount[] = [];
  for (const plate of [...available].sort((a, b) => b - a)) {
    const count = Math.floor(remaining / plate + EPSILON);
    if (count > 0) {
      perSide.push({ plate, count });
      remaining -= count * plate;
    }
  }
  const loaded = perSide.reduce((sum, p) => sum + p.plate * p.count, 0);
  const achieved = Math.round((bar + loaded * 2) * 100) / 100;
  return {
    target,
    bar,
    perSide,
    achieved,
    remainder: Math.round((target - achieved) * 100) / 100,
  };
}
