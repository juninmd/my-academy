import type { Mock } from 'vitest';
import { Test, TestingModule } from '@nestjs/testing';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { MethodsService, METHODS_CACHE_KEY } from './methods.service.js';
import { PrismaService } from '../prisma.service.js';
import { NotFoundException } from '@nestjs/common';

describe('MethodsService', () => {
  let service: MethodsService;
  let prisma: PrismaService;

  const mockCache = { del: vi.fn() };

  const mockPrisma = {
    methods: {
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
        MethodsService,
        {
          provide: PrismaService,
          useValue: mockPrisma,
        },
        { provide: CACHE_MANAGER, useValue: mockCache },
      ],
    }).compile();

    service = module.get<MethodsService>(MethodsService);
    prisma = module.get<PrismaService>(PrismaService);
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create a method', async () => {
      const dto = { name: 'Method 1', description: 'Desc' };
      const result = { id: 1, ...dto };
      (prisma.methods.create as Mock).mockResolvedValue(result);

      expect(await service.create(dto)).toBe(result);
      expect(prisma.methods.create).toHaveBeenCalledWith({ data: dto });
    });
  });

  describe('findAll', () => {
    it('should return array of methods', async () => {
      const result = [{ id: 1 }];
      (prisma.methods.findMany as Mock).mockResolvedValue(result);

      expect(await service.findAll()).toBe(result);
    });
  });

  describe('findOne', () => {
    it('should return a method', async () => {
      const result = { id: 1 };
      (prisma.methods.findUnique as Mock).mockResolvedValue(result);

      expect(await service.findOne(1)).toBe(result);
      expect(prisma.methods.findUnique).toHaveBeenCalledWith({
        where: { id: 1 },
      });
    });

    it('should throw NotFoundException', async () => {
      (prisma.methods.findUnique as Mock).mockResolvedValue(null);
      await expect(service.findOne(1)).rejects.toThrow(NotFoundException);
    });
  });

  describe('update', () => {
    it('should update a method', async () => {
      const dto = { name: 'Updated' };
      const result = { id: 1, ...dto };

      (prisma.methods.findUnique as Mock).mockResolvedValue(result);
      (prisma.methods.update as Mock).mockResolvedValue(result);

      expect(await service.update(1, dto as any)).toBe(result);
      expect(prisma.methods.update).toHaveBeenCalledWith({
        where: { id: 1 },
        data: expect.objectContaining(dto),
      });
    });
  });

  describe('remove', () => {
    it('should remove a method', async () => {
      const result = { id: 1 };
      (prisma.methods.findUnique as Mock).mockResolvedValue(result);
      (prisma.methods.delete as Mock).mockResolvedValue(result);

      expect(await service.remove(1)).toBe(result);
      expect(prisma.methods.delete).toHaveBeenCalledWith({ where: { id: 1 } });
    });
  });

  describe('cache invalidation', () => {
    it('evicts the cached list after every write so clients never read stale catalog data', async () => {
      const entity = { id: 1 };
      (prisma.methods.create as Mock).mockResolvedValue(entity);
      (prisma.methods.findUnique as Mock).mockResolvedValue(entity);
      (prisma.methods.update as Mock).mockResolvedValue(entity);
      (prisma.methods.delete as Mock).mockResolvedValue(entity);

      await service.create({} as any);
      await service.update(1, {} as any);
      await service.remove(1);

      expect(mockCache.del).toHaveBeenCalledTimes(3);
      expect(mockCache.del).toHaveBeenCalledWith(METHODS_CACHE_KEY);
    });

    it('does not evict the cache when the write fails', async () => {
      (prisma.methods.create as Mock).mockRejectedValue(new Error('db down'));
      await expect(service.create({} as any)).rejects.toThrow('db down');
      expect(mockCache.del).not.toHaveBeenCalled();
    });
  });
});
