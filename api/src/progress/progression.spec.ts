import {
  roundTo,
  suggestNext,
  type ProgressionOptions,
} from './progression.js';

const set = (reps: number, weight: number, type = 'normal') => ({
  reps,
  weight,
  type,
});
const double: ProgressionOptions = {
  strategy: 'double',
  increment: 2.5,
  minReps: 8,
  maxReps: 12,
};
const linear: ProgressionOptions = {
  strategy: 'linear',
  increment: 2.5,
  minReps: 5,
  maxReps: 5,
};

describe('progression', () => {
  it('rounds to the increment', () => {
    expect(roundTo(61, 2.5)).toBe(60);
    expect(roundTo(91.4, 2.5)).toBe(92.5);
  });

  it('returns null without usable history', () => {
    expect(suggestNext([], double)).toBeNull();
    expect(suggestNext([[set(10, 20, 'warmup')]], double)).toBeNull();
  });

  it('double: adds load at the top of the range', () => {
    const result = suggestNext(
      [[set(12, 50), set(12, 50), set(10, 40)]],
      double,
    );
    expect(result).toMatchObject({ weight: 52.5, reps: 8, deload: false });
    expect(result?.reason).toMatch(/Top of the rep range/);
  });

  it('double: chases reps inside the range', () => {
    expect(suggestNext([[set(9, 50), set(10, 50)]], double)).toMatchObject({
      weight: 50,
      reps: 10,
    });
    expect(suggestNext([[set(5, 50)]], double)).toMatchObject({
      weight: 50,
      reps: 8,
    });
    expect(suggestNext([[set(11, 50)]], double)).toMatchObject({
      weight: 50,
      reps: 12,
    });
  });

  it('linear: adds load when every set hits the target', () => {
    const result = suggestNext([[set(5, 100), set(5, 100)]], linear);
    expect(result).toMatchObject({ weight: 102.5, reps: 5 });
    expect(result?.reason).toMatch(/target reps/);
  });

  it('linear: a miss keeps the load', () => {
    expect(suggestNext([[set(5, 100), set(4, 100)]], linear)).toMatchObject({
      weight: 100,
      reps: 5,
      deload: false,
    });
  });

  it('deloads after three stalled sessions at the same weight', () => {
    const miss = [set(4, 100)];
    const result = suggestNext([miss, miss, miss], linear);
    expect(result).toMatchObject({ weight: 90, reps: 5, deload: true });
  });

  it('a different weight or earlier success ends the stall streak', () => {
    const miss = [set(4, 100)];
    expect(suggestNext([miss, miss, [set(4, 95)]], linear)?.deload).toBe(false);
    expect(suggestNext([miss, miss, [set(5, 100)], miss], linear)?.deload).toBe(
      false,
    );
  });

  describe('triple', () => {
    const triple: ProgressionOptions = {
      strategy: 'triple',
      increment: 2.5,
      minReps: 8,
      maxReps: 12,
      maxSets: 3,
    };

    it('adds a set when every set reaches the top reps', () => {
      const result = suggestNext([[set(12, 50), set(12, 50), set(12, 50)]], {
        ...triple,
        maxSets: 5,
      });
      expect(result).toMatchObject({
        weight: 50,
        reps: 8,
        sets: 4,
        deload: false,
      });
      expect(result?.reason).toMatch(/add a set/);
    });

    it('adds load once the set cap is reached', () => {
      const result = suggestNext([[set(12, 50), set(12, 50), set(12, 50)]], {
        ...triple,
        maxSets: 3,
      });
      expect(result).toMatchObject({ weight: 52.5, reps: 8, sets: 3 });
      expect(result?.reason).toMatch(/restart at the bottom/);
    });

    it('defaults the set cap to five', () => {
      const four = [set(12, 50), set(12, 50), set(12, 50), set(12, 50)];
      const withoutCap = { ...triple, maxSets: undefined };
      expect(suggestNext([four], withoutCap)).toMatchObject({ sets: 5 });
    });

    it('chases reps while the top is not reached', () => {
      expect(suggestNext([[set(10, 50), set(10, 50)]], triple)).toMatchObject({
        weight: 50,
        reps: 11,
        sets: 2,
      });
    });
  });
});
