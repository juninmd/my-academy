import { fromExportJson } from './json.js';

const log = (overrides: Record<string, unknown> = {}) => ({
  date: '2026-10-01T10:00:00.000Z',
  exercise: { name: 'Supino inclinado com barra' },
  sets: [{ reps: 8, weight: 80, rpe: 8 }],
  ...overrides,
});

describe('fromExportJson', () => {
  it('reads export logs into sets', () => {
    expect(
      fromExportJson({
        exerciseLogs: [
          log({
            sets: [
              { reps: 8, weight: 80, rpe: 8.4 },
              { reps: 6, weight: 82.5, rpe: null },
            ],
          }),
        ],
      }),
    ).toEqual({
      sets: [
        {
          day: '2026-10-01',
          date: new Date('2026-10-01T10:00:00.000Z'),
          exercise: 'Supino inclinado com barra',
          reps: 8,
          weight: 80,
          rpe: 8,
        },
        {
          day: '2026-10-01',
          date: new Date('2026-10-01T10:00:00.000Z'),
          exercise: 'Supino inclinado com barra',
          reps: 6,
          weight: 82.5,
          rpe: null,
        },
      ],
      skippedRows: 0,
    });
  });

  it('returns nothing for a payload without logs', () => {
    expect(fromExportJson(null)).toEqual({ sets: [], skippedRows: 0 });
    expect(fromExportJson([])).toEqual({ sets: [], skippedRows: 0 });
    expect(fromExportJson({ exerciseLogs: 'nope' })).toEqual({
      sets: [],
      skippedRows: 0,
    });
  });

  it('skips logs it cannot place and counts their sets', () => {
    const result = fromExportJson({
      exerciseLogs: [
        'not an object',
        log({ date: 'not a date' }),
        log({ date: 7 }),
        log({ exercise: { name: 3 } }),
        log({ exercise: 'x' }),
        log({ sets: 'nope' }),
        log({ sets: [] }),
      ],
    });
    expect(result.sets).toEqual([]);
    // Logs without a readable name or date count once; empty sets are simply nothing to import.
    expect(result.skippedRows).toBe(5);
  });

  it('skips sets that are not usable', () => {
    const bad = [
      'nope',
      { reps: 0, weight: 50 },
      { reps: 1001, weight: 50 },
      { reps: 5, weight: -1 },
      { reps: 5, weight: 2001 },
      { reps: '5', weight: 50 },
      { reps: 5 },
      { reps: 5, weight: 50, rpe: 11 },
    ];
    const result = fromExportJson({ exerciseLogs: [log({ sets: bad })] });
    expect(result.skippedRows).toBe(bad.length - 1);
    expect(result.sets.map((s) => s.rpe)).toEqual([null]);
  });
});
