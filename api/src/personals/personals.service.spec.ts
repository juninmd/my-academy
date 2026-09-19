import type { Mock } from 'vitest';
import { ConflictException, NotFoundException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { PersonalsService } from './personals.service.js';
import { PrismaService } from '../prisma.service.js';

describe('PersonalsService', () => {
  let service: PersonalsService;
  let prisma: PrismaService;

  const mockPrisma = {
    personals: {
      create: vi.fn(),
      findMany: vi.fn(),
      findUnique: vi.fn(),
      update: vi.fn(),
      delete: vi.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PersonalsService,
        {
          provide: PrismaService,
          useValue: mockPrisma,
        },
      ],
    }).compile();

    service = module.get<PersonalsService>(PersonalsService);
    prisma = module.get<PrismaService>(PrismaService);
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create personal relation', async () => {
      const dto = { studentUserId: 's1', personalUserId: 'p1' };
      const result = { id: 1, ...dto };
      (prisma.personals.create as Mock).mockResolvedValue(result);

      expect(await service.create(dto)).toBe(result);
      expect(prisma.personals.create).toHaveBeenCalledWith({ data: dto });
    });

    it('should map a duplicate contract to ConflictException', async () => {
      const dto = { studentUserId: 's1', personalUserId: 'p1' };
      const error: any = new Error('Unique constraint failed');
      error.code = 'P2002';
      (prisma.personals.create as Mock).mockRejectedValue(error);

      await expect(service.create(dto)).rejects.toThrow(ConflictException);
    });

    it('should rethrow unexpected errors', async () => {
      const dto = { studentUserId: 's1', personalUserId: 'p1' };
      const error = new Error('db down');
      (prisma.personals.create as Mock).mockRejectedValue(error);

      await expect(service.create(dto)).rejects.toThrow('db down');
    });
  });

  describe('findOne', () => {
    it('should return a contract if found', async () => {
      const result = { id: 1, personalUserId: 'p1', studentUserId: 's1' };
      (prisma.personals.findUnique as Mock).mockResolvedValue(result);

      expect(await service.findOne(1)).toBe(result);
      expect(prisma.personals.findUnique).toHaveBeenCalledWith({
        where: { id: 1 },
      });
    });

    it('should throw NotFoundException if contract not found', async () => {
      (prisma.personals.findUnique as Mock).mockResolvedValue(null);

      await expect(service.findOne(1)).rejects.toThrow(NotFoundException);
    });
  });

  describe('findAll', () => {
    it('should return personals with relations', async () => {
      const result = [{ id: 1 }];
      (prisma.personals.findMany as Mock).mockResolvedValue(result);

      expect(await service.findAll('p1')).toBe(result);
      expect(prisma.personals.findMany).toHaveBeenCalledWith({
        where: { personalUserId: 'p1' },
        include: { PersonalUser: true, StudentUser: true },
      });
    });

    it('should return all personals when personalUserId is not provided', async () => {
      const result = [{ id: 1 }];
      (prisma.personals.findMany as Mock).mockResolvedValue(result);

      expect(await service.findAll()).toBe(result);
      expect(prisma.personals.findMany).toHaveBeenCalledWith({
        where: undefined,
        include: { PersonalUser: true, StudentUser: true },
      });
    });
  });

  describe('findStudents', () => {
    it('should return students and schedule flattened', async () => {
      const dbResult = [
        {
          StudentUser: { id: 's1' },
          PersonalClassSchedule: { id: 'sch1' },
        },
      ];
      const expected = [{ student: { id: 's1' }, schedule: { id: 'sch1' } }];

      (prisma.personals.findMany as Mock).mockResolvedValue(dbResult);

      expect(await service.findStudents('p1')).toEqual(expected);
      expect(prisma.personals.findMany).toHaveBeenCalledWith({
        where: { personalUserId: 'p1' },
        include: { StudentUser: true, PersonalClassSchedule: true },
      });
    });
  });

  describe('update', () => {
    it('should update personal relation', async () => {
      const dto = { id: 1, active: true };
      const result = { id: 1, active: true };

      (prisma.personals.update as Mock).mockResolvedValue(result);

      expect(await service.update(1, dto as any)).toBe(result);
      expect(prisma.personals.update).toHaveBeenCalledWith({
        where: { id: 1 },
        data: { active: true },
      });
    });
  });

  describe('remove', () => {
    it('should delete personal relation', async () => {
      const result = { id: 1 };
      (prisma.personals.delete as Mock).mockResolvedValue(result);

      expect(await service.remove(1)).toBe(result);
      expect(prisma.personals.delete).toHaveBeenCalledWith({
        where: { id: 1 },
      });
    });
  });
});
