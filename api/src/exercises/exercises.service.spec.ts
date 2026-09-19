import type { Mock } from 'vitest';
import { Test, TestingModule } from '@nestjs/testing';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { ExercisesService, EXERCISES_CACHE_KEY } from './exercises.service.js';
import { PrismaService } from '../prisma.service.js';
import { NotFoundException } from '@nestjs/common';
import { ExerciseType } from '@prisma/client';

describe('ExercisesService', () => {
  let service: ExercisesService;
  let prisma: PrismaService;

  const mockCache = { del: vi.fn() };

  const mockPrisma = {
    exercises: {
      findUnique: vi.fn(),
      create: vi.fn(),
      findMany: vi.fn(),
      update: vi.fn(),
      delete: vi.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ExercisesService,
        {
          provide: PrismaService,
          useValue: mockPrisma,
        },
        { provide: CACHE_MANAGER, useValue: mockCache },
      ],
    }).compile();

    service = module.get<ExercisesService>(ExercisesService);
    prisma = module.get<PrismaService>(PrismaService);
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create an exercise', async () => {
      const dto = {
        name: 'Push up',
        image: 'img',
        tips: 'tip',
        mistakes: 'mistake',
        type: ExerciseType.STRENGTH,
      };
      const result = {
        id: 1,
        ...dto,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      (prisma.exercises.create as Mock).mockResolvedValue(result);
      expect(await service.create(dto)).toBe(result);
      expect(prisma.exercises.create).toHaveBeenCalledWith({ data: dto });
    });
  });

  describe('findAll', () => {
    it('should return array of exercises', async () => {
      const result = [{ id: 1 }];
      (prisma.exercises.findMany as Mock).mockResolvedValue(result);
      expect(await service.findAll()).toBe(result);
    });
  });

  describe('findOne', () => {
    it('should return an exercise', async () => {
      const result = { id: 1 };
      (prisma.exercises.findUnique as Mock).mockResolvedValue(result);
      expect(await service.findOne(1)).toBe(result);
      expect(prisma.exercises.findUnique).toHaveBeenCalledWith({
        where: { id: 1 },
      });
    });

    it('should throw NotFoundException', async () => {
      (prisma.exercises.findUnique as Mock).mockResolvedValue(null);
      await expect(service.findOne(1)).rejects.toThrow(NotFoundException);
    });
  });

  describe('update', () => {
    it('should update an exercise', async () => {
      const dto = { name: 'Updated' };
      const result = { id: 1, name: 'Updated' };

      (prisma.exercises.findUnique as Mock).mockResolvedValue(result); // for findOne check
      (prisma.exercises.update as Mock).mockResolvedValue(result);

      expect(await service.update(1, dto as any)).toBe(result);
      expect(prisma.exercises.update).toHaveBeenCalledWith({
        where: { id: 1 },
        data: expect.objectContaining(dto),
      });
    });
  });

  describe('remove', () => {
    it('should delete an exercise', async () => {
      const result = { id: 1 };
      (prisma.exercises.findUnique as Mock).mockResolvedValue(result); // for findOne check
      (prisma.exercises.delete as Mock).mockResolvedValue(result);

      expect(await service.remove(1)).toBe(result);
      expect(prisma.exercises.delete).toHaveBeenCalledWith({
        where: { id: 1 },
      });
    });
  });

  describe('cache invalidation', () => {
    it('evicts the cached list after every write so clients never read stale catalog data', async () => {
      const entity = { id: 1 };
      (prisma.exercises.create as Mock).mockResolvedValue(entity);
      (prisma.exercises.findUnique as Mock).mockResolvedValue(entity);
      (prisma.exercises.update as Mock).mockResolvedValue(entity);
      (prisma.exercises.delete as Mock).mockResolvedValue(entity);

      await service.create({} as any);
      await service.update(1, {} as any);
      await service.remove(1);

      expect(mockCache.del).toHaveBeenCalledTimes(3);
      expect(mockCache.del).toHaveBeenCalledWith(EXERCISES_CACHE_KEY);
    });

    it('does not evict the cache when the write fails', async () => {
      (prisma.exercises.create as Mock).mockRejectedValue(new Error('db down'));
      await expect(service.create({} as any)).rejects.toThrow('db down');
      expect(mockCache.del).not.toHaveBeenCalled();
    });
  });
});
