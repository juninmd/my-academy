import { NotFoundException } from '@nestjs/common';
import { StarterPlansController } from './starter-plans.controller.js';
import { StarterPlansService } from './starter-plans.service.js';

describe('StarterPlans', () => {
  const prisma = {
    workoutsGroups: { findFirst: vi.fn(), create: vi.fn() },
    exercises: { findFirst: vi.fn() },
  };
  const service = new StarterPlansService(prisma as never);

  afterEach(() => vi.resetAllMocks());

  it('lists templates', () => {
    const plans = service.list();
    expect(plans.map((p) => p.key)).toEqual([
      'ppl',
      'upper-lower',
      'full-body',
      '5x5',
    ]);
    expect(plans[0].days).toEqual(['Push', 'Pull', 'Legs']);
  });

  it('rejects an unknown plan', async () => {
    await expect(service.apply('nope', 'u1')).rejects.toThrow(
      NotFoundException,
    );
  });

  it('creates groups, skipping existing ones and missing exercises', async () => {
    prisma.workoutsGroups.findFirst
      .mockResolvedValueOnce(null) // 5x5 not there yet
      .mockResolvedValue(null);
    // squat found, bench found, row missing
    prisma.exercises.findFirst
      .mockResolvedValueOnce({ id: 1 })
      .mockResolvedValueOnce({ id: 2 })
      .mockResolvedValueOnce(null);

    const result = await service.apply('5x5', 'u1');

    expect(result).toEqual({
      plan: '5x5',
      created: ['5x5 - 5x5'],
      skipped: [],
      missingExercises: ['remada'],
    });
    const data = prisma.workoutsGroups.create.mock.calls[0][0].data;
    expect(data.name).toBe('5x5 - 5x5');
    expect(data.workouts.create).toHaveLength(2);
    expect(data.workouts.create[0].workoutSeries.create).toHaveLength(5);
  });

  it('skips existing groups and duplicate exercises', async () => {
    prisma.workoutsGroups.findFirst
      .mockResolvedValueOnce({ id: 9 }) // Upper exists
      .mockResolvedValueOnce(null); // Lower is new
    prisma.exercises.findFirst.mockResolvedValue({ id: 5 }); // same for all slots

    const result = await service.apply('upper-lower', 'u1');

    expect(result.skipped).toEqual(['Upper/Lower - Upper']);
    expect(result.created).toEqual(['Upper/Lower - Lower']);
    expect(
      prisma.workoutsGroups.create.mock.calls[0][0].data.workouts.create,
    ).toHaveLength(1);
  });

  it('controller checks access then applies', async () => {
    const access = { assertCanActFor: vi.fn() };
    const apply = vi.spyOn(service, 'apply').mockResolvedValue('ok' as never);
    const controller = new StarterPlansController(service, access as never);
    expect(controller.list()).toHaveLength(4);
    expect(await controller.apply('ppl', { userId: 'u1' }, 'actor')).toBe('ok');
    expect(access.assertCanActFor).toHaveBeenCalledWith('actor', 'u1');
    expect(apply).toHaveBeenCalledWith('ppl', 'u1');
  });
});
