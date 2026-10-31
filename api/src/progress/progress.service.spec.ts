import type { Mock } from 'vitest';
import { Test, TestingModule } from '@nestjs/testing';
import { ProgressService } from './progress.service.js';
import { PrismaService } from '../prisma.service.js';

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

  describe('bodyWeight', () => {
    it('returns series, latest and change', async () => {
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
      });
    });

    it('handles no assessments', async () => {
      prisma.assessment.findMany.mockResolvedValue([]);
      expect(await service.bodyWeight('u1')).toEqual({
        points: [],
        latest: null,
        change: null,
      });
    });
  });
});
