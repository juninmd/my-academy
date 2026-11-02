import type { Mock } from 'vitest';
import { NotFoundException } from '@nestjs/common';
import { BodyWeightService } from './body-weight.service.js';

describe('BodyWeightService', () => {
  const prisma = {
    bodyWeightEntry: {
      findMany: vi.fn() as Mock,
      upsert: vi.fn() as Mock,
      deleteMany: vi.fn() as Mock,
    },
  };
  const service = new BodyWeightService(prisma as never);

  beforeEach(() => vi.clearAllMocks());

  it('lists entries oldest first', async () => {
    prisma.bodyWeightEntry.findMany.mockResolvedValue(['e']);
    expect(await service.list('u1')).toEqual(['e']);
    expect(prisma.bodyWeightEntry.findMany.mock.calls[0][0]).toMatchObject({
      where: { userId: 'u1' },
      orderBy: { date: 'asc' },
    });
  });

  it('upserts one reading per day', async () => {
    const date = new Date('2026-10-31T00:00:00.000Z');
    prisma.bodyWeightEntry.upsert.mockResolvedValue({ id: 1 });
    expect(await service.upsert('u1', date, 80.4)).toEqual({ id: 1 });
    expect(prisma.bodyWeightEntry.upsert).toHaveBeenCalledWith({
      where: { userId_date: { userId: 'u1', date } },
      update: { weight: 80.4 },
      create: { userId: 'u1', date, weight: 80.4 },
    });
  });

  it('removes only the user’s own entry', async () => {
    prisma.bodyWeightEntry.deleteMany.mockResolvedValue({ count: 1 });
    expect(await service.remove('u1', 4)).toEqual({ id: 4, removed: true });
    expect(prisma.bodyWeightEntry.deleteMany).toHaveBeenCalledWith({
      where: { id: 4, userId: 'u1' },
    });
  });

  it('reports a missing entry', async () => {
    prisma.bodyWeightEntry.deleteMany.mockResolvedValue({ count: 0 });
    await expect(service.remove('u1', 4)).rejects.toThrow(NotFoundException);
  });
});
