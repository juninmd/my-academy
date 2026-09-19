import type { Mock } from 'vitest';
import { Test, TestingModule } from '@nestjs/testing';
import { Prisma } from '@prisma/client';
import {
  uniqueConstraintOf,
  WorkoutsGroupsService,
} from './workouts-groups.service.js';
import { PrismaService } from '../prisma.service.js';
import { CreateWorkoutsGroupDto } from './dto/create-workouts-group.dto.js';
import {
  BadRequestException,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';

describe('WorkoutsGroupsService', () => {
  let service: WorkoutsGroupsService;
  let prisma: PrismaService;

  const mockPrisma = {
    $transaction: vi.fn().mockImplementation((cb) => cb(mockPrisma)),
    workoutsGroups: {
      create: vi.fn(),
      findMany: vi.fn(),
      findUnique: vi.fn(),
      update: vi.fn(),
      delete: vi.fn(),
    },
    workouts: {
      deleteMany: vi.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        WorkoutsGroupsService,
        {
          provide: PrismaService,
          useValue: mockPrisma,
        },
      ],
    }).compile();

    service = module.get<WorkoutsGroupsService>(WorkoutsGroupsService);
    prisma = module.get<PrismaService>(PrismaService);
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create a workout group with nested workouts', async () => {
      const dto: CreateWorkoutsGroupDto = {
        name: 'Group A',
        image: 'img.jpg',
        userId: 'user1',
        workouts: [
          {
            exerciseId: 1,
            description: 'desc',
            methodId: 2,
            workoutSeries: [{ repetitions: 10, weight: 20, rest: 60 }],
          },
        ],
      };

      const result = {
        id: 1,
        ...dto,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      (prisma.workoutsGroups.create as Mock).mockResolvedValue(result);

      expect(await service.create(dto)).toBe(result);

      expect(prisma.workoutsGroups.create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          name: dto.name,
          workouts: {
            create: expect.any(Array),
          },
        }),
        include: {
          workouts: {
            include: {
              workoutSeries: true,
              exercise: true,
            },
          },
        },
      });
    });

    it('should create a workout group without workouts (undefined)', async () => {
      const dto: CreateWorkoutsGroupDto = {
        name: 'Group B',
        image: 'img.jpg',
        userId: 'user1',
        workouts: undefined,
      };

      const result = {
        id: 2,
        ...dto,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      (prisma.workoutsGroups.create as Mock).mockResolvedValue(result);

      await service.create(dto);

      expect(prisma.workoutsGroups.create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          name: dto.name,
          workouts: {
            create: [],
          },
        }),
        include: {
          workouts: {
            include: {
              workoutSeries: true,
              exercise: true,
            },
          },
        },
      });
    });

    it('should create workouts with defaults (no description)', async () => {
      const dto: CreateWorkoutsGroupDto = {
        name: 'Group C',
        image: 'img.jpg',
        userId: 'user1',
        workouts: [
          {
            exerciseId: 1,
            // description missing
            methodId: 2,
            workoutSeries: [],
          },
        ],
      };

      const result = {
        id: 3,
        ...dto,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      (prisma.workoutsGroups.create as Mock).mockResolvedValue(result);

      await service.create(dto);

      // Verify description became ''
      // accessing the call arguments
      const createCall = (prisma.workoutsGroups.create as Mock).mock
        .calls[0][0];
      const mappedWorkouts = createCall.data.workouts.create;
      expect(mappedWorkouts[0].description).toBe('');
    });

    it('should create workouts with empty string description', async () => {
      const dto: CreateWorkoutsGroupDto = {
        name: 'Group D',
        image: 'img.jpg',
        userId: 'user1',
        workouts: [
          {
            exerciseId: 1,
            description: '',
            methodId: 2,
            workoutSeries: [],
          },
        ],
      };

      const result = {
        id: 4,
        ...dto,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      (prisma.workoutsGroups.create as Mock).mockResolvedValue(result);

      await service.create(dto);

      const createCall = (prisma.workoutsGroups.create as Mock).mock
        .calls[0][0];
      const mappedWorkouts = createCall.data.workouts.create;
      expect(mappedWorkouts[0].description).toBe('');
    });

    it('should create workouts with undefined workoutSeries', async () => {
      const dto: CreateWorkoutsGroupDto = {
        name: 'Group E',
        image: 'img.jpg',
        userId: 'user1',
        workouts: [
          {
            exerciseId: 1,
            description: 'desc',
            methodId: 2,
            workoutSeries: undefined,
          },
        ],
      };

      const result = {
        id: 5,
        ...dto,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      (prisma.workoutsGroups.create as Mock).mockResolvedValue(result);

      await service.create(dto);

      const createCall = (prisma.workoutsGroups.create as Mock).mock
        .calls[0][0];
      const mappedWorkouts = createCall.data.workouts.create;
      expect(mappedWorkouts[0].workoutSeries.create).toBeUndefined();
    });

    it('should map P2002 on exercise duplication to a ConflictException', async () => {
      const dto: CreateWorkoutsGroupDto = {
        name: 'Group F',
        image: 'img.jpg',
        userId: 'user1',
        workouts: [
          {
            exerciseId: 1,
            description: 'desc',
            methodId: 2,
            workoutSeries: [],
          },
        ],
      };
      (prisma.workoutsGroups.create as Mock).mockRejectedValue(
        new Prisma.PrismaClientKnownRequestError('duplicate', {
          code: 'P2002',
          clientVersion: '7.3.0',
          meta: { target: ['workoutsGroupsId', 'exerciseId'] },
        }),
      );
      await expect(service.create(dto)).rejects.toThrow(ConflictException);
    });

    it('should rethrow non-P2002 errors from create', async () => {
      const dto: CreateWorkoutsGroupDto = {
        name: 'Group G',
        image: 'img.jpg',
        userId: 'user1',
        workouts: undefined,
      };
      (prisma.workoutsGroups.create as Mock).mockRejectedValue(
        new Error('boom'),
      );
      await expect(service.create(dto)).rejects.toThrow('boom');
    });
  });

  describe('update', () => {
    it('should delete existing workouts and update group', async () => {
      const dto = {
        name: 'Group A Updated',
        image: 'img.jpg',
        userId: 'user1',
        workouts: [],
      };
      const result = {
        id: 1,
        ...dto,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      // Mock findUnique for findOne check
      (prisma.workoutsGroups.findUnique as Mock).mockResolvedValue({
        id: 1,
        userId: 'user1',
      });

      (prisma.workouts.deleteMany as Mock).mockResolvedValue({ count: 5 });
      (prisma.workoutsGroups.update as Mock).mockResolvedValue(result);

      expect(await service.update(1, dto)).toBe(result);

      expect(prisma.workoutsGroups.findUnique).toHaveBeenCalledWith(
        expect.objectContaining({ where: { id: 1 } }),
      );
      expect(prisma.workouts.deleteMany).toHaveBeenCalledWith({
        where: { workoutsGroupsId: 1 },
      });
      expect(prisma.workoutsGroups.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: 1 },
          data: expect.objectContaining({ name: dto.name }),
        }),
      );
    });

    it('should throw NotFoundException if group not found', async () => {
      (prisma.workoutsGroups.findUnique as Mock).mockResolvedValue(null);
      await expect(service.update(1, {} as any)).rejects.toThrow(
        NotFoundException,
      );
    });

    it('should reject moving the group to another user', async () => {
      (prisma.workoutsGroups.findUnique as Mock).mockResolvedValue({
        id: 1,
        userId: 'user1',
      });
      await expect(
        service.update(1, { userId: 'other-user' } as any),
      ).rejects.toThrow(BadRequestException);
      expect(prisma.workoutsGroups.update).not.toHaveBeenCalled();
    });

    it('should map P2002 to a ConflictException on update', async () => {
      (prisma.workoutsGroups.findUnique as Mock).mockResolvedValue({
        id: 1,
        userId: 'user1',
      });
      (prisma.workouts.deleteMany as Mock).mockResolvedValue({
        count: 0,
      });
      (prisma.workoutsGroups.update as Mock).mockRejectedValue(
        new Prisma.PrismaClientKnownRequestError('duplicate', {
          code: 'P2002',
          clientVersion: '7.3.0',
          meta: { target: ['userId', 'name'] },
        }),
      );
      await expect(
        service.update(1, { name: 'dup', userId: 'user1' } as any),
      ).rejects.toThrow(ConflictException);
    });
  });

  describe('findAll', () => {
    it('should return all groups for a user', async () => {
      const result = [{ id: 1 }];
      (prisma.workoutsGroups.findMany as Mock).mockResolvedValue(result);
      expect(await service.findAll('user1')).toBe(result);
      expect(prisma.workoutsGroups.findMany).toHaveBeenCalledWith({
        where: { userId: 'user1' },
        include: {
          workouts: {
            include: {
              workoutSeries: true,
              exercise: true,
            },
          },
        },
      });
    });
  });

  describe('findOne & findAllExercises', () => {
    it('should return one group with relations', async () => {
      const result = { id: 1 };
      (prisma.workoutsGroups.findUnique as Mock).mockResolvedValue(result);

      await service.findOne(1);
      expect(prisma.workoutsGroups.findUnique).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: 1 },
          include: expect.anything(),
        }),
      );
    });

    it('findAllExercises should act like findOne', async () => {
      const result = { id: 1 };
      (prisma.workoutsGroups.findUnique as Mock).mockResolvedValue(result);

      await service.findAllExercises(1);
      expect(prisma.workoutsGroups.findUnique).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: 1 },
          include: expect.anything(),
        }),
      );
    });

    it('should throw NotFoundException if not found', async () => {
      (prisma.workoutsGroups.findUnique as Mock).mockResolvedValue(null);
      await expect(service.findOne(1)).rejects.toThrow(NotFoundException);
    });
  });

  describe('remove', () => {
    it('should delete group', async () => {
      const result = { id: 1 };
      // Mock findUnique for findOne check
      (prisma.workoutsGroups.findUnique as Mock).mockResolvedValue(result);
      (prisma.workoutsGroups.delete as Mock).mockResolvedValue(result);
      await service.remove(1);
      expect(prisma.workoutsGroups.delete).toHaveBeenCalledWith({
        where: { id: 1 },
        include: { WorkoutSessions: true },
      });
    });
  });

  describe('uniqueConstraintOf', () => {
    const p2002 = (meta: Record<string, unknown>) =>
      new Prisma.PrismaClientKnownRequestError('dup', {
        code: 'P2002',
        clientVersion: 'x',
        meta,
      });

    it('reads the index reported by the pg driver adapter (real Postgres shape)', () => {
      const error = p2002({
        modelName: 'Workouts',
        driverAdapterError: {
          cause: {
            kind: 'UniqueConstraintViolation',
            constraint: { index: 'workouts_workoutsGroupsId_exerciseId_key' },
          },
        },
      });
      expect(uniqueConstraintOf(error)).toContain('exerciseId');
    });

    it('supports the classic meta.target shape and missing metadata', () => {
      expect(uniqueConstraintOf(p2002({ target: ['userId', 'name'] }))).toBe(
        'userId,name',
      );
      expect(uniqueConstraintOf(p2002({ target: 'name' }))).toBe('name');
      expect(uniqueConstraintOf(p2002({}))).toBe('');
    });
  });
});
