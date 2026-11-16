import { RotationService } from './rotation.service.js';

describe('RotationService', () => {
  const prisma = {
    workoutsGroups: { findMany: vi.fn() },
    workoutSessions: { findFirst: vi.fn() },
  };
  const service = new RotationService(prisma as never);

  beforeEach(() => vi.clearAllMocks());

  it('picks the routine after the last one done', async () => {
    prisma.workoutsGroups.findMany.mockResolvedValue([
      { id: 1, name: 'A' },
      { id: 2, name: 'B' },
    ]);
    const date = new Date('2026-10-29T00:00:00Z');
    prisma.workoutSessions.findFirst.mockResolvedValue({
      workoutGroupId: 1,
      date,
    });

    expect(await service.next('u1')).toEqual({
      group: { id: 2, name: 'B' },
      lastSession: { groupId: 1, date },
    });
    expect(prisma.workoutsGroups.findMany.mock.calls[0][0].where).toEqual({
      userId: 'u1',
    });
  });

  it('starts with the first routine when nothing was done', async () => {
    prisma.workoutsGroups.findMany.mockResolvedValue([{ id: 5, name: 'Push' }]);
    prisma.workoutSessions.findFirst.mockResolvedValue(null);
    expect(await service.next('u1')).toEqual({
      group: { id: 5, name: 'Push' },
      lastSession: null,
    });
  });

  it('returns no group when the user has no routines', async () => {
    prisma.workoutsGroups.findMany.mockResolvedValue([]);
    prisma.workoutSessions.findFirst.mockResolvedValue(null);
    expect(await service.next('u1')).toEqual({
      group: null,
      lastSession: null,
    });
  });
});
