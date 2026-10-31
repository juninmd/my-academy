import {
  dayKey,
  estimateOneRepMax,
  round,
  setVolume,
  weekStart,
  workingSets,
} from './progress.math.js';

describe('progress.math', () => {
  it('estimates 1RM with Epley', () => {
    expect(estimateOneRepMax(100, 5)).toBe(116.67);
    expect(estimateOneRepMax(100, 1)).toBe(100);
    expect(estimateOneRepMax(0, 5)).toBe(0);
    expect(estimateOneRepMax(100, 0)).toBe(0);
  });

  it('computes set volume and drops warm-ups', () => {
    const sets = [
      { reps: 10, weight: 20, type: 'warmup' },
      { reps: 5, weight: 100, type: 'normal' },
    ];
    expect(setVolume(sets[1])).toBe(500);
    expect(workingSets(sets)).toEqual([sets[1]]);
  });

  it('rounds and formats dates', () => {
    expect(round(1.005 + 1.1)).toBe(2.11);
    expect(dayKey(new Date('2026-10-31T23:00:00Z'))).toBe('2026-10-31');
  });

  it('finds the Monday of a week', () => {
    expect(weekStart(new Date('2026-10-31T10:00:00Z'))).toBe('2026-10-26'); // Sat
    expect(weekStart(new Date('2026-11-01T10:00:00Z'))).toBe('2026-10-26'); // Sun
    expect(weekStart(new Date('2026-10-26T00:00:00Z'))).toBe('2026-10-26'); // Mon
  });
});
