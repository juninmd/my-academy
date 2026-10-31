import type { Mock } from 'vitest';
import { NotFoundException } from '@nestjs/common';
import { FavoritesService } from './favorites.service.js';

describe('FavoritesService', () => {
  let service: FavoritesService;
  const prisma = {
    exerciseFavorite: {
      findMany: vi.fn() as Mock,
      upsert: vi.fn() as Mock,
      deleteMany: vi.fn() as Mock,
    },
    exercises: { findUnique: vi.fn() as Mock },
  };

  beforeEach(() => {
    vi.clearAllMocks();
    service = new FavoritesService(prisma as never);
  });

  it('lists favourite exercises, newest first', async () => {
    const exercise = {
      id: 1,
      name: 'Supino',
      image: 'x',
      type: 'STRENGTH',
      muscles: [],
    };
    prisma.exerciseFavorite.findMany.mockResolvedValue([{ exercise }]);
    expect(await service.list('u1')).toEqual([exercise]);
    expect(prisma.exerciseFavorite.findMany.mock.calls[0][0]).toMatchObject({
      where: { userId: 'u1' },
      orderBy: { createdAt: 'desc' },
    });
  });

  it('adds a favourite with an idempotent upsert', async () => {
    prisma.exercises.findUnique.mockResolvedValue({ id: 3 });
    expect(await service.add('u1', 3)).toEqual({
      exerciseId: 3,
      favorite: true,
    });
    expect(prisma.exerciseFavorite.upsert).toHaveBeenCalledWith({
      where: { userId_exerciseId: { userId: 'u1', exerciseId: 3 } },
      update: {},
      create: { userId: 'u1', exerciseId: 3 },
    });
  });

  it('rejects an unknown exercise', async () => {
    prisma.exercises.findUnique.mockResolvedValue(null);
    await expect(service.add('u1', 99)).rejects.toThrow(NotFoundException);
    expect(prisma.exerciseFavorite.upsert).not.toHaveBeenCalled();
  });

  it('removes a favourite and reports how many rows went', async () => {
    prisma.exerciseFavorite.deleteMany.mockResolvedValue({ count: 1 });
    expect(await service.remove('u1', 3)).toEqual({
      exerciseId: 3,
      favorite: false,
      removed: 1,
    });
    expect(prisma.exerciseFavorite.deleteMany).toHaveBeenCalledWith({
      where: { userId: 'u1', exerciseId: 3 },
    });
  });
});
