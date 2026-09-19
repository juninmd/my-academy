import type { Mock } from 'vitest';
import { Test, TestingModule } from '@nestjs/testing';
import { ExerciseLogsService } from './exercise-logs.service.js';
import { PrismaService } from '../prisma.service.js';
import { CreateExerciseLogDto } from './dto/create-exercise-log.dto.js';

describe('ExerciseLogsService', () => {
  let service: ExerciseLogsService;
  let prisma: PrismaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ExerciseLogsService,
        {
          provide: PrismaService,
          useValue: {
            exerciseLog: {
              create: vi.fn(),
              findMany: vi.fn(),
            },
          },
        },
      ],
    }).compile();

    service = module.get<ExerciseLogsService>(ExerciseLogsService);
    prisma = module.get<PrismaService>(PrismaService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create an exercise log', async () => {
      const dto: CreateExerciseLogDto = {
        userId: 'user1',
        exerciseId: 1,
        date: new Date().toISOString(),
        sets: [{ reps: 10, weight: 20 }],
      };
      const result = {
        id: 1,
        userId: dto.userId,
        exerciseId: dto.exerciseId,
        date: new Date(dto.date),
        notes: null,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      (prisma.exerciseLog.create as Mock).mockResolvedValue(result);

      expect(await service.create(dto)).toBe(result);
      expect(prisma.exerciseLog.create).toHaveBeenCalledWith({
        data: {
          userId: dto.userId,
          exerciseId: dto.exerciseId,
          date: dto.date,
          sets: {
            create: dto.sets,
          },
        },
        include: {
          sets: true,
        },
      });
    });
  });

  describe('findAll', () => {
    it('should return an array of exercise logs', async () => {
      const result = [{ id: 1, userId: 'user1', exerciseId: 1 }];
      (prisma.exerciseLog.findMany as Mock).mockResolvedValue(result);

      expect(await service.findAll('user1')).toBe(result);
      expect(prisma.exerciseLog.findMany).toHaveBeenCalledWith({
        where: { userId: 'user1' },
        include: { sets: true },
        orderBy: { date: 'desc' },
        take: 200,
      });
    });

    it('should filter by exerciseId', async () => {
      const result = [];
      (prisma.exerciseLog.findMany as Mock).mockResolvedValue(result);

      expect(await service.findAll('user1', 2)).toBe(result);
      expect(prisma.exerciseLog.findMany).toHaveBeenCalledWith({
        where: { userId: 'user1', exerciseId: 2 },
        include: { sets: true },
        orderBy: { date: 'desc' },
        take: 200,
      });
    });
  });
});
