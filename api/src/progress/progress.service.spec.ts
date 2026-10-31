import type { Mock } from 'vitest';
import { Test, TestingModule } from '@nestjs/testing';
import { ProgressService } from './progress.service.js';
import { PrismaService } from '../prisma.service.js';
import { dayKey } from './progress.math.js';

const HOUR = 60 * 60 * 1000;
const DAY = 24 * HOUR;

describe('ProgressService', () => {
  let service: ProgressService;
  let prisma: {
    exerciseLog: { findMany: Mock };
    assessment: { findMany: Mock };
  };

  beforeEach(async () => {
    prisma = {
      exerciseLog: { findMany: vi.fn() },
      assessment: { findMany: vi.fn() },
    };
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProgressService,
        { provide: PrismaService, useValue: prisma },
      ],
    }).compile();
    service = module.get(ProgressService);
  });

  describe('exerciseProgress', () => {
    it('builds history and records ignoring warm-up-only logs', async () => {
      prisma.exerciseLog.findMany.mockResolvedValue([
        {
          date: new Date('2026-10-01T10:00:00Z'),
          sets: [
            { reps: 5, weight: 100, type: 'normal' },
            { reps: 10, weight: 40, type: 'warmup' },
          ],
        },
        {
          date: new Date('2026-10-08T10:00:00Z'),
          sets: [{ reps: 5, weight: 105, type: 'normal' }],
        },
        {
          date: new Date('2026-10-15T10:00:00Z'),
          sets: [{ reps: 8, weight: 60, type: 'normal' }],
        },
        {
          date: new Date('2026-10-20T10:00:00Z'),
          sets: [{ reps: 10, weight: 20, type: 'warmup' }],
        },
      ]);

      const result = await service.exerciseProgress('u1', 7);

      expect(result.history).toHaveLength(3);
      expect(result.history[0]).toEqual({
        date: '2026-10-01',
        sets: 1,
        volume: 500,
        topWeight: 100,
        estimatedOneRepMax: 116.67,
      });
      expect(result.records.maxWeight).toEqual({
        value: 105,
        date: '2026-10-08',
      });
      expect(result.records.maxEstimatedOneRepMax).toEqual({
        value: 122.5,
        date: '2026-10-08',
      });
      expect(result.records.maxVolume).toEqual({
        value: 525,
        date: '2026-10-08',
      });
    });

    it('returns null records without history', async () => {
      prisma.exerciseLog.findMany.mockResolvedValue([]);
      const result = await service.exerciseProgress('u1', 7);
      expect(result.history).toEqual([]);
      expect(result.records).toEqual({
        maxWeight: null,
        maxEstimatedOneRepMax: null,
        maxVolume: null,
      });
    });
  });

  describe('summary', () => {
    it('aggregates activity and weekly volume', async () => {
      prisma.exerciseLog.findMany.mockResolvedValue([
        {
          date: new Date('2026-10-26T08:00:00Z'),
          sets: [{ reps: 10, weight: 50, type: 'normal' }],
        },
        {
          date: new Date('2026-10-26T18:00:00Z'),
          sets: [
            { reps: 5, weight: 100, type: 'normal' },
            { reps: 10, weight: 20, type: 'warmup' },
          ],
        },
        {
          date: new Date('2026-11-02T08:00:00Z'),
          sets: [{ reps: 1, weight: 120, type: 'normal' }],
        },
      ]);

      const result = await service.summary('u1', 30);

      expect(prisma.exerciseLog.findMany.mock.calls[0][0].where.userId).toBe(
        'u1',
      );
      expect(result).toEqual({
        days: 30,
        trainingDays: 2,
        totalSets: 3,
        totalVolume: 1120,
        activity: [
          { date: '2026-10-26', sets: 2, volume: 1000 },
          { date: '2026-11-02', sets: 1, volume: 120 },
        ],
        weeklyVolume: [
          { weekStart: '2026-10-26', volume: 1000 },
          { weekStart: '2026-11-02', volume: 120 },
        ],
      });
    });

    it('defaults to 90 days', async () => {
      prisma.exerciseLog.findMany.mockResolvedValue([]);
      const result = await service.summary('u1');
      expect(result).toMatchObject({
        days: 90,
        trainingDays: 0,
        totalVolume: 0,
      });
    });
  });

  describe('muscles', () => {
    it('weights working sets per muscle, tracks last hit and recovery, and balances', async () => {
      const now = Date.now();
      prisma.exerciseLog.findMany.mockResolvedValue([
        {
          date: new Date(now - 5 * DAY),
          sets: [
            { reps: 5, weight: 100, type: 'normal' },
            { reps: 5, weight: 100, type: 'normal' },
          ],
          exercise: { muscles: ['chest', 'triceps'] },
        },
        {
          date: new Date(now - HOUR),
          sets: [{ reps: 8, weight: 40, type: 'normal' }],
          exercise: { muscles: ['chest'] },
        },
        {
          date: new Date(now - HOUR),
          sets: [
            { reps: 10, weight: 20, type: 'warmup' },
            { reps: 8, weight: 40, type: 'normal' },
          ],
          exercise: { muscles: ['back', 'biceps'] },
        },
        {
          date: new Date(now - HOUR),
          sets: [{ reps: 10, weight: 20, type: 'warmup' }],
          exercise: { muscles: ['quads'] },
        },
      ]);

      const result = await service.muscles('u1', 30);
      const byMuscle = Object.fromEntries(
        result.muscles.map((m) => [m.muscle, m]),
      );

      expect(byMuscle.chest).toEqual({
        muscle: 'chest',
        weightedSets: 3,
        lastTrained: dayKey(new Date(now - HOUR)),
        state: 'recovering',
      });
      expect(byMuscle.triceps).toMatchObject({
        weightedSets: 1,
        state: 'recovered',
      });
      expect(byMuscle.back).toMatchObject({
        weightedSets: 1,
        state: 'recovering',
      });
      expect(byMuscle.biceps).toMatchObject({ weightedSets: 0.5 });
      expect(byMuscle.quads).toEqual({
        muscle: 'quads',
        weightedSets: 0,
        lastTrained: null,
        state: 'untrained',
      });
      expect(result.balance.find((b) => b.key === 'push_pull')).toMatchObject({
        left: 4,
        right: 1.5,
        status: 'left_high',
      });
      expect(prisma.exerciseLog.findMany.mock.calls[0][0].where.userId).toBe(
        'u1',
      );
    });

    it('defaults to 90 days', async () => {
      prisma.exerciseLog.findMany.mockResolvedValue([]);
      const result = await service.muscles('u1');
      expect(result.days).toBe(90);
      expect(result.muscles.every((m) => m.state === 'untrained')).toBe(true);
    });
  });

  describe('bodyWeight', () => {
    it('returns series, latest, change and weekly rate', async () => {
      prisma.assessment.findMany.mockResolvedValue([
        { date: new Date('2026-01-01T00:00:00Z'), weight: 80 },
        { date: new Date('2026-06-01T00:00:00Z'), weight: 76.5 },
      ]);
      expect(await service.bodyWeight('u1')).toEqual({
        points: [
          { date: '2026-01-01', weight: 80 },
          { date: '2026-06-01', weight: 76.5 },
        ],
        latest: 76.5,
        change: -3.5,
        weeklyRate: -0.16,
      });
    });

    it('handles no assessments', async () => {
      prisma.assessment.findMany.mockResolvedValue([]);
      expect(await service.bodyWeight('u1')).toEqual({
        points: [],
        latest: null,
        change: null,
        weeklyRate: null,
      });
    });

    it('has no rate from a single weigh-in', async () => {
      prisma.assessment.findMany.mockResolvedValue([
        { date: new Date('2026-01-01T00:00:00Z'), weight: 80 },
      ]);
      expect(await service.bodyWeight('u1')).toMatchObject({
        change: 0,
        weeklyRate: null,
      });
    });
  });

  describe('relativeStrength', () => {
    it('divides the best e1RM by the latest earlier body weight', async () => {
      prisma.assessment.findMany.mockResolvedValue([
        { date: new Date('2025-06-01T00:00:00Z'), weight: 0 },
        { date: new Date('2026-01-01T00:00:00Z'), weight: 80 },
        { date: new Date('2026-06-01T00:00:00Z'), weight: 75 },
      ]);
      prisma.exerciseLog.findMany.mockResolvedValue([
        {
          date: new Date('2025-01-01T00:00:00Z'),
          sets: [{ reps: 5, weight: 100, type: 'normal' }],
        },
        {
          date: new Date('2025-12-01T00:00:00Z'),
          sets: [{ reps: 5, weight: 100, type: 'normal' }],
        },
        {
          date: new Date('2026-02-01T00:00:00Z'),
          sets: [{ reps: 5, weight: 100, type: 'normal' }],
        },
        {
          date: new Date('2026-07-01T00:00:00Z'),
          sets: [{ reps: 10, weight: 20, type: 'warmup' }],
        },
        {
          date: new Date('2026-07-02T00:00:00Z'),
          sets: [{ reps: 1, weight: 120, type: 'normal' }],
        },
        {
          date: new Date('2026-08-01T00:00:00Z'),
          sets: [{ reps: 1, weight: 50, type: 'normal' }],
        },
      ]);

      const result = await service.relativeStrength('u1', 7);

      expect(result.points).toEqual([
        {
          date: '2026-02-01',
          estimatedOneRepMax: 116.67,
          bodyWeight: 80,
          ratio: 1.46,
        },
        {
          date: '2026-07-02',
          estimatedOneRepMax: 120,
          bodyWeight: 75,
          ratio: 1.6,
        },
        {
          date: '2026-08-01',
          estimatedOneRepMax: 50,
          bodyWeight: 75,
          ratio: 0.67,
        },
      ]);
      expect(result.best).toEqual(result.points[1]);
    });

    it('returns no points or best without history', async () => {
      prisma.assessment.findMany.mockResolvedValue([]);
      prisma.exerciseLog.findMany.mockResolvedValue([]);
      expect(await service.relativeStrength('u1', 7)).toEqual({
        exerciseId: 7,
        points: [],
        best: null,
      });
    });
  });

  describe('suggestion', () => {
    it('suggests from the latest sessions with defaults', async () => {
      prisma.exerciseLog.findMany.mockResolvedValue([
        { sets: [{ reps: 12, weight: 50, type: 'normal' }] },
      ]);
      expect(await service.suggestion('u1', 7)).toEqual({
        exerciseId: 7,
        strategy: 'double',
        suggestion: expect.objectContaining({ weight: 52.5, reps: 8 }),
      });
    });

    it('honours linear options and never lets max fall below min', async () => {
      prisma.exerciseLog.findMany.mockResolvedValue([]);
      const result = await service.suggestion('u1', 7, {
        strategy: 'linear',
        increment: 5,
        maxReps: 2,
      });
      expect(result).toEqual({
        exerciseId: 7,
        strategy: 'linear',
        suggestion: null,
      });
    });

    it('accepts explicit rep range', async () => {
      prisma.exerciseLog.findMany.mockResolvedValue([
        { sets: [{ reps: 6, weight: 80, type: 'normal' }] },
      ]);
      const result = await service.suggestion('u1', 7, {
        minReps: 4,
        maxReps: 6,
      });
      expect(result.suggestion).toMatchObject({ weight: 82.5, reps: 4 });
    });

    it('passes the triple set cap through', async () => {
      prisma.exerciseLog.findMany.mockResolvedValue([
        {
          sets: [
            { reps: 12, weight: 50, type: 'normal' },
            { reps: 12, weight: 50, type: 'normal' },
            { reps: 12, weight: 50, type: 'normal' },
          ],
        },
      ]);
      const result = await service.suggestion('u1', 7, {
        strategy: 'triple',
        maxSets: 3,
      });
      expect(result.suggestion).toMatchObject({ weight: 52.5, sets: 3 });
    });
  });
});
