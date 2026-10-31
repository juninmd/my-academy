import type { Mock } from 'vitest';
import { BadRequestException } from '@nestjs/common';
import { ImportsService, MAX_IMPORT_ROWS } from './imports.service.js';

const HEADER = 'Date,Exercise Name,Weight,Reps,RPE\n';

describe('ImportsService', () => {
  let service: ImportsService;
  const prisma = {
    exercises: { findMany: vi.fn() as Mock },
    exerciseLog: { findMany: vi.fn() as Mock, create: vi.fn() as Mock },
  };

  beforeEach(() => {
    vi.clearAllMocks();
    prisma.exercises.findMany.mockResolvedValue([
      { id: 1, name: 'Supino reto' },
      { id: 2, name: 'Agachamento' },
    ]);
    prisma.exerciseLog.findMany.mockResolvedValue([]);
    service = new ImportsService(prisma as never);
  });

  it('creates one log per exercise and day, skipping unknown exercises', async () => {
    const csv =
      HEADER +
      [
        '2026-10-01T10:00:00Z,Supino Reto,100,5,8',
        '2026-10-01T10:00:00Z,Supino Reto,100,5,',
        '2026-10-01T10:00:00Z,Corrida,0,1,',
        '2026-10-02T10:00:00Z,Agachamento,120,5,',
      ].join('\n');

    const result = await service.importCsv('u1', csv);

    expect(result).toEqual({
      imported: { logs: 2, sets: 3 },
      skippedExisting: 0,
      skippedRows: 0,
      unmatchedExercises: ['Corrida'],
    });
    expect(prisma.exerciseLog.create).toHaveBeenCalledTimes(2);
    const first = prisma.exerciseLog.create.mock.calls[0][0].data;
    expect(first).toMatchObject({
      userId: 'u1',
      exerciseId: 1,
      date: new Date('2026-10-01T10:00:00Z'),
    });
    expect(first.sets.create).toEqual([
      { reps: 5, weight: 100, rpe: 8 },
      { reps: 5, weight: 100, rpe: null },
    ]);
  });

  it('leaves days that already have the exercise alone', async () => {
    prisma.exerciseLog.findMany.mockResolvedValue([
      { exerciseId: 1, date: new Date('2026-10-01T23:00:00Z') },
    ]);
    const csv =
      HEADER +
      '2026-10-01T10:00:00Z,Supino reto,100,5,\n2026-10-02T10:00:00Z,Agachamento,120,5,\n';

    const result = await service.importCsv('u1', csv);

    expect(result.skippedExisting).toBe(1);
    expect(result.imported).toEqual({ logs: 1, sets: 1 });
    expect(prisma.exerciseLog.create).toHaveBeenCalledTimes(1);
  });

  it('does not query existing logs when nothing matched', async () => {
    const result = await service.importCsv(
      'u1',
      HEADER + '2026-10-01T10:00:00Z,Corrida,0,1,\n',
    );
    expect(result).toMatchObject({
      imported: { logs: 0, sets: 0 },
      skippedExisting: 0,
    });
    expect(prisma.exerciseLog.findMany).not.toHaveBeenCalled();
  });

  it('reads pounds when asked to, and kilograms by default', async () => {
    const csv = HEADER + '2026-10-01T10:00:00Z,Supino reto,225,5,\n';

    await service.importCsv('u1', csv, 'lb');
    expect(
      prisma.exerciseLog.create.mock.calls[0][0].data.sets.create[0].weight,
    ).toBe(102.06);

    await service.importCsv('u1', csv);
    expect(
      prisma.exerciseLog.create.mock.calls[1][0].data.sets.create[0].weight,
    ).toBe(225);
  });

  it('reports rows it skipped', async () => {
    const csv = HEADER + '2026-10-01T10:00:00Z,Supino reto,100,,\n';
    expect(await service.importCsv('u1', csv)).toMatchObject({
      skippedRows: 1,
    });
  });

  it('rejects a file without the required columns', async () => {
    await expect(service.importCsv('u1', 'Foo,Bar\n1,2\n')).rejects.toThrow(
      BadRequestException,
    );
    await expect(service.importCsv('u1', '')).rejects.toThrow(
      BadRequestException,
    );
  });

  it('rejects files over the row limit', async () => {
    const csv =
      HEADER +
      '2026-10-01T10:00:00Z,Supino reto,1,1,\n'.repeat(MAX_IMPORT_ROWS + 1);
    await expect(service.importCsv('u1', csv)).rejects.toThrow(
      BadRequestException,
    );
  });
});

describe('ImportsService.importJson', () => {
  let service: ImportsService;
  const prisma = {
    exercises: { findMany: vi.fn() as Mock },
    exerciseLog: { findMany: vi.fn() as Mock, create: vi.fn() as Mock },
  };

  beforeEach(() => {
    vi.clearAllMocks();
    prisma.exercises.findMany.mockResolvedValue([
      { id: 1, name: 'Supino reto' },
    ]);
    prisma.exerciseLog.findMany.mockResolvedValue([]);
    service = new ImportsService(prisma as never);
  });

  it('restores logs from an export and skips days already present', async () => {
    const payload = {
      exerciseLogs: [
        {
          date: '2026-10-01T10:00:00.000Z',
          exercise: { name: 'Supino reto' },
          sets: [{ reps: 5, weight: 100, rpe: null }],
        },
      ],
    };
    expect(await service.importJson('u1', payload)).toEqual({
      imported: { logs: 1, sets: 1 },
      skippedExisting: 0,
      skippedRows: 0,
      unmatchedExercises: [],
    });

    prisma.exerciseLog.findMany.mockResolvedValue([
      { exerciseId: 1, date: new Date('2026-10-01T12:00:00.000Z') },
    ]);
    expect(await service.importJson('u1', payload)).toMatchObject({
      imported: { logs: 0 },
      skippedExisting: 1,
    });
  });

  it('refuses payloads over the set limit', async () => {
    const sets = Array.from({ length: MAX_IMPORT_ROWS + 1 }, () => ({
      reps: 1,
      weight: 1,
    }));
    await expect(
      service.importJson('u1', {
        exerciseLogs: [
          {
            date: '2026-10-01T10:00:00Z',
            exercise: { name: 'Supino reto' },
            sets,
          },
        ],
      }),
    ).rejects.toThrow(BadRequestException);
  });
});

describe('ImportsService.importHevy', () => {
  it('fetches the workouts, then saves them through the shared path', async () => {
    const prisma = {
      exercises: {
        findMany: vi.fn().mockResolvedValue([{ id: 1, name: 'Bench Press' }]),
      },
      exerciseLog: { findMany: vi.fn().mockResolvedValue([]), create: vi.fn() },
    };
    const service = new ImportsService(prisma as never);
    const fetchFn = vi.fn().mockResolvedValue({
      ok: true,
      status: 200,
      json: async () => ({
        page: 1,
        page_count: 1,
        workouts: [
          {
            start_time: '2026-10-01T10:00:00Z',
            exercises: [
              { title: 'bench press', sets: [{ reps: 5, weight_kg: 100 }] },
            ],
          },
        ],
      }),
    });

    const result = await service.importHevy('u1', 'key', fetchFn);

    expect(result).toMatchObject({ imported: { logs: 1, sets: 1 } });
    expect(prisma.exerciseLog.create).toHaveBeenCalledTimes(1);
    expect(fetchFn.mock.calls[0][1].headers['api-key']).toBe('key');
  });
});

describe('ImportsService.importBodyWeight', () => {
  const prisma = {
    bodyWeightEntry: { findMany: vi.fn() as Mock, createMany: vi.fn() as Mock },
  };
  let service: ImportsService;

  beforeEach(() => {
    vi.clearAllMocks();
    prisma.bodyWeightEntry.findMany.mockResolvedValue([]);
    service = new ImportsService(prisma as never);
  });

  it('imports an Apple Health export and reports the format', async () => {
    const xml =
      '<HealthData><Record type="HKQuantityTypeIdentifierBodyMass" startDate="2026-10-01 07:00:00 +0000" value="80" unit="kg"/></HealthData>';
    const result = await service.importBodyWeight('u1', xml);
    expect(result).toEqual({
      format: 'apple-health',
      imported: 1,
      skippedExisting: 0,
      skippedRows: 0,
    });
    expect(prisma.bodyWeightEntry.createMany.mock.calls[0][0].data).toEqual([
      { userId: 'u1', date: new Date('2026-10-01T00:00:00.000Z'), weight: 80 },
    ]);
  });

  it('keeps the last reading of a day and skips days already logged', async () => {
    prisma.bodyWeightEntry.findMany.mockResolvedValue([
      { date: new Date('2026-10-01T00:00:00Z') },
    ]);
    const csv = 'date,weight\n2026-10-01,80\n2026-10-02,79\n2026-10-02,78.5\n';
    const result = await service.importBodyWeight('u1', csv, 'kg');
    expect(result).toEqual({
      format: 'csv',
      imported: 1,
      skippedExisting: 1,
      skippedRows: 0,
    });
    expect(prisma.bodyWeightEntry.createMany.mock.calls[0][0].data).toEqual([
      {
        userId: 'u1',
        date: new Date('2026-10-02T00:00:00.000Z'),
        weight: 78.5,
      },
    ]);
  });

  it('writes nothing when every day is already there or unreadable', async () => {
    prisma.bodyWeightEntry.findMany.mockResolvedValue([
      { date: new Date('2026-10-01T00:00:00Z') },
    ]);
    const result = await service.importBodyWeight(
      'u1',
      'date,weight\n2026-10-01,80\nbad,row\n',
    );
    expect(result).toEqual({
      format: 'csv',
      imported: 0,
      skippedExisting: 1,
      skippedRows: 1,
    });
    expect(prisma.bodyWeightEntry.createMany).not.toHaveBeenCalled();
  });

  it('does not query when there is nothing to import', async () => {
    const result = await service.importBodyWeight('u1', 'nothing,here\n1,2\n');
    expect(result).toEqual({
      format: 'csv',
      imported: 0,
      skippedExisting: 0,
      skippedRows: 1,
    });
    expect(prisma.bodyWeightEntry.findMany).not.toHaveBeenCalled();
  });
});
