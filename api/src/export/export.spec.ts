import { ExportController } from './export.controller.js';
import { csvCell, ExportService } from './export.service.js';

describe('Export', () => {
  const prisma = {
    exerciseLog: { findMany: vi.fn() },
    assessment: { findMany: vi.fn() },
    workoutsGroups: { findMany: vi.fn() },
  };
  const service = new ExportService(prisma as never);

  afterEach(() => vi.resetAllMocks());

  it('escapes csv cells', () => {
    expect(csvCell(null)).toBe('');
    expect(csvCell(5)).toBe('5');
    expect(csvCell('plain')).toBe('plain');
    expect(csvCell('a,"b"')).toBe('"a,""b"""');
  });

  it('exports everything as json', async () => {
    prisma.exerciseLog.findMany.mockResolvedValue([{ id: 1 }]);
    prisma.assessment.findMany.mockResolvedValue([{ id: 2 }]);
    prisma.workoutsGroups.findMany.mockResolvedValue([{ id: 3 }]);
    const result = await service.exportJson('u1');
    expect(result).toMatchObject({
      userId: 'u1',
      exerciseLogs: [{ id: 1 }],
      assessments: [{ id: 2 }],
      workoutGroups: [{ id: 3 }],
    });
    expect(typeof result.exportedAt).toBe('string');
  });

  it('exports sets as csv', async () => {
    prisma.exerciseLog.findMany.mockResolvedValue([
      {
        date: new Date('2026-10-01T10:00:00Z'),
        exercise: { name: 'Supino, reto' },
        sets: [
          { reps: 5, weight: 100, rpe: 8, type: 'normal' },
          { reps: 10, weight: 40, rpe: null, type: 'warmup' },
        ],
      },
    ]);
    expect(await service.exportCsv('u1')).toBe(
      [
        'date,exercise,set,reps,weight,rpe,type',
        '2026-10-01,"Supino, reto",1,5,100,8,normal',
        '2026-10-01,"Supino, reto",2,10,40,,warmup',
        '',
      ].join('\n'),
    );
  });

  it('controller checks access for both formats', async () => {
    const access = { assertCanActFor: vi.fn() };
    vi.spyOn(service, 'exportJson').mockResolvedValue({ a: 1 } as never);
    vi.spyOn(service, 'exportCsv').mockResolvedValue('csv');
    const controller = new ExportController(service, access as never);
    expect(await controller.json({ userId: 'u1' }, 'actor')).toEqual({ a: 1 });
    expect(await controller.csv({ userId: 'u1' }, 'actor')).toBe('csv');
    expect(access.assertCanActFor).toHaveBeenCalledTimes(2);
  });
});
