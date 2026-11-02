import { BadGatewayException, BadRequestException } from '@nestjs/common';
import { fetchHevyWorkouts, hevyToSets, HEVY_BASE_URL } from './hevy.js';

const reply = (status: number, body: unknown = {}) => ({
  ok: status >= 200 && status < 300,
  status,
  json: async () => body,
});

describe('fetchHevyWorkouts', () => {
  it('reads every page with the key header', async () => {
    const fetchFn = vi
      .fn()
      .mockResolvedValueOnce(
        reply(200, { page: 1, page_count: 2, workouts: [{ title: 'a' }] }),
      )
      .mockResolvedValueOnce(
        reply(200, { page: 2, page_count: 2, workouts: [{ title: 'b' }] }),
      );

    const workouts = await fetchHevyWorkouts('secret', fetchFn);

    expect(workouts).toEqual([{ title: 'a' }, { title: 'b' }]);
    expect(fetchFn).toHaveBeenNthCalledWith(
      1,
      `${HEVY_BASE_URL}/workouts?page=1&pageSize=10`,
      { headers: { 'api-key': 'secret', accept: 'application/json' } },
    );
    expect(fetchFn.mock.calls[1][0]).toContain('page=2');
  });

  it('stops at the page limit and tolerates a missing workouts array', async () => {
    const fetchFn = vi
      .fn()
      .mockResolvedValue(reply(200, { page: 1, page_count: 9 }));
    expect(await fetchHevyWorkouts('k', fetchFn, 2)).toEqual([]);
    expect(fetchFn).toHaveBeenCalledTimes(2);
  });

  it('rejects a key Hevy does not accept', async () => {
    await expect(
      fetchHevyWorkouts('bad', vi.fn().mockResolvedValue(reply(401))),
    ).rejects.toThrow(BadRequestException);
    await expect(
      fetchHevyWorkouts('bad', vi.fn().mockResolvedValue(reply(403))),
    ).rejects.toThrow(BadRequestException);
  });

  it('reports other Hevy failures as bad gateway', async () => {
    await expect(
      fetchHevyWorkouts('k', vi.fn().mockResolvedValue(reply(500))),
    ).rejects.toThrow(BadGatewayException);
  });

  it('uses the global fetch when none is given', async () => {
    const original = globalThis.fetch;
    globalThis.fetch = vi
      .fn()
      .mockResolvedValue(
        reply(200, { page: 1, page_count: 1, workouts: [{ title: 'x' }] }),
      ) as never;
    try {
      expect(await fetchHevyWorkouts('k')).toEqual([{ title: 'x' }]);
    } finally {
      globalThis.fetch = original;
    }
  });
});

describe('hevyToSets', () => {
  const workout = {
    start_time: '2026-10-01T10:00:00+00:00',
    exercises: [
      {
        title: ' Bench Press (Barbell) ',
        sets: [
          { type: 'normal', weight_kg: 80, reps: 8, rpe: 8.4 },
          { type: 'warmup', weight_kg: null, reps: 10, rpe: null },
        ],
      },
    ],
  };

  it('maps sets with trimmed names, day keys and rounded values', () => {
    const { sets, skippedRows } = hevyToSets([workout]);
    expect(skippedRows).toBe(0);
    expect(sets).toEqual([
      {
        day: '2026-10-01',
        date: new Date('2026-10-01T10:00:00+00:00'),
        exercise: 'Bench Press (Barbell)',
        reps: 8,
        weight: 80,
        rpe: 8,
      },
      {
        day: '2026-10-01',
        date: new Date('2026-10-01T10:00:00+00:00'),
        exercise: 'Bench Press (Barbell)',
        reps: 10,
        weight: 0,
        rpe: null,
      },
    ]);
  });

  it('skips sets it cannot read', () => {
    const bad = {
      start_time: 'not a date',
      exercises: [
        { title: 'Squat', sets: [{ reps: 5, weight_kg: 100 }] },
        { title: '   ', sets: [{ reps: 5 }] },
        { title: 'Row', sets: [{ reps: null }, { reps: 0 }, { reps: 1001 }] },
      ],
    };
    expect(hevyToSets([bad])).toEqual({ sets: [], skippedRows: 5 });
    expect(hevyToSets([{ start_time: '2026-10-01T10:00:00Z' }])).toEqual({
      sets: [],
      skippedRows: 0,
    });
  });

  it('drops out-of-range RPE values', () => {
    const rows = [0, 11, null].map((rpe) => ({
      start_time: '2026-10-01T10:00:00Z',
      exercises: [{ title: 'Row', sets: [{ reps: 5, weight_kg: 50, rpe }] }],
    }));
    expect(hevyToSets(rows).sets.map((s) => s.rpe)).toEqual([null, null, null]);
  });
});

describe('hevyToSets with missing fields', () => {
  it('treats absent fields as empty rather than failing', () => {
    const result = hevyToSets([
      { start_time: '2026-10-01T10:00:00Z', exercises: [{ title: 'Row' }] },
      { exercises: [{ title: 'Row', sets: [{ reps: 5 }] }] },
      {
        start_time: '2026-10-01T10:00:00Z',
        exercises: [{ sets: [{ reps: 5 }] }],
      },
      {
        start_time: '2026-10-01T10:00:00Z',
        exercises: [{ title: 'Curl', sets: [{ reps: 10 }] }],
      },
    ]);
    expect(result.skippedRows).toBe(2);
    expect(result.sets).toEqual([
      {
        day: '2026-10-01',
        date: new Date('2026-10-01T10:00:00Z'),
        exercise: 'Curl',
        reps: 10,
        weight: 0,
        rpe: null,
      },
    ]);
  });
});
