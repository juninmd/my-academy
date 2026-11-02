import {
  balanceOf,
  muscleWeights,
  RECOVERY_HOURS,
  recoveryOf,
} from './muscles.js';

const HOUR = 60 * 60 * 1000;

describe('muscles', () => {
  describe('muscleWeights', () => {
    it('weights the first muscle fully and the rest by half', () => {
      expect(muscleWeights(['chest', 'triceps'])).toEqual(
        new Map([
          ['chest', 1],
          ['triceps', 0.5],
        ]),
      );
    });

    it('drops unknown slugs and keeps the first occurrence of a duplicate', () => {
      expect(muscleWeights(['chest', 'bogus', 'triceps', 'chest'])).toEqual(
        new Map([
          ['chest', 1],
          ['triceps', 0.5],
        ]),
      );
    });

    it('promotes the first known muscle to primary', () => {
      expect(muscleWeights(['bogus', 'quads', 'calves']).get('quads')).toBe(1);
    });

    it('returns nothing for an exercise without muscles', () => {
      expect(muscleWeights([]).size).toBe(0);
    });
  });

  describe('balanceOf', () => {
    const statusOf = (volume: Record<string, number>) =>
      Object.fromEntries(
        balanceOf(new Map(Object.entries(volume))).map((b) => [b.key, b]),
      );

    it('reports no data when neither side is trained', () => {
      const result = statusOf({});
      expect(result.quads_hamstrings).toEqual({
        key: 'quads_hamstrings',
        label: 'Quads vs hamstrings',
        left: 0,
        right: 0,
        ratio: null,
        status: 'no_data',
      });
    });

    it('reports an untrained right side without a ratio', () => {
      const result = statusOf({ chest: 4 });
      expect(result.chest_back).toMatchObject({
        left: 4,
        right: 0,
        ratio: null,
        status: 'right_untrained',
      });
    });

    it('classifies left as low, high or balanced', () => {
      const result = statusOf({
        chest: 4,
        back: 4,
        quads: 2,
        hamstrings: 4,
        biceps: 4,
        triceps: 2,
      });
      expect(result.chest_back).toMatchObject({ ratio: 1, status: 'balanced' });
      expect(result.quads_hamstrings).toMatchObject({
        ratio: 0.5,
        status: 'left_low',
      });
      expect(result.biceps_triceps).toMatchObject({
        ratio: 2,
        status: 'left_high',
      });
      expect(result.push_pull).toMatchObject({
        ratio: 0.75,
        status: 'left_low',
      });
    });
  });

  describe('recoveryOf', () => {
    const now = 1_000_000_000_000;

    it('is untrained without a last hit', () => {
      expect(recoveryOf(null, now)).toBe('untrained');
    });

    it('is recovering inside the recovery window', () => {
      expect(recoveryOf(now - HOUR, now)).toBe('recovering');
    });

    it('is recovered from the window edge on', () => {
      expect(recoveryOf(now - RECOVERY_HOURS * HOUR, now)).toBe('recovered');
      expect(recoveryOf(now - 5 * 24 * HOUR, now)).toBe('recovered');
    });
  });
});
