import { nextInRotation } from './rotation.js';

describe('nextInRotation', () => {
  it('returns nothing without routines', () => {
    expect(nextInRotation([], null)).toBeNull();
    expect(nextInRotation([], 3)).toBeNull();
  });

  it('starts at the first routine with no history', () => {
    expect(nextInRotation([10, 11, 12], null)).toBe(10);
  });

  it('moves to the following routine and wraps around', () => {
    expect(nextInRotation([10, 11, 12], 10)).toBe(11);
    expect(nextInRotation([10, 11, 12], 11)).toBe(12);
    expect(nextInRotation([10, 11, 12], 12)).toBe(10);
  });

  it('starts over when the last routine was deleted', () => {
    expect(nextInRotation([10, 11], 99)).toBe(10);
  });
});
