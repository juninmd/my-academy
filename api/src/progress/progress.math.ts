export interface SetLike {
  reps: number;
  weight: number;
  type: string;
}

/** Epley estimated one-rep max; 0 for sets that carry no usable load. */
export function estimateOneRepMax(weight: number, reps: number): number {
  if (weight <= 0 || reps <= 0) return 0;
  if (reps === 1) return weight;
  return round(weight * (1 + reps / 30));
}

export function setVolume(set: SetLike): number {
  return set.weight * set.reps;
}

/** Warm-up sets never count towards records or volume. */
export function workingSets<T extends SetLike>(sets: T[]): T[] {
  return sets.filter((set) => set.type !== 'warmup');
}

export function round(value: number): number {
  return Math.round(value * 100) / 100;
}

export function dayKey(date: Date): string {
  return date.toISOString().slice(0, 10);
}

/** Monday of the (UTC) week containing the date, as YYYY-MM-DD. */
export function weekStart(date: Date): string {
  const copy = new Date(
    Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()),
  );
  const offset = (copy.getUTCDay() + 6) % 7;
  copy.setUTCDate(copy.getUTCDate() - offset);
  return dayKey(copy);
}
