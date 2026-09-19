import type { Mock } from 'vitest';
import { ForbiddenException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { ExerciseLogsController } from './exercise-logs.controller.js';
import { ExerciseLogsService } from './exercise-logs.service.js';
import { CreateExerciseLogDto } from './dto/create-exercise-log.dto.js';
import { AccessService } from '../access/access.service.js';

describe('ExerciseLogsController', () => {
  let controller: ExerciseLogsController;
  let service: ExerciseLogsService;
  let accessService: AccessService;

  const mockExerciseLogsService = {
    create: vi.fn(),
    findAll: vi.fn(),
  };

  const mockAccessService = {
    assertCanActFor: vi.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ExerciseLogsController],
      providers: [
        {
          provide: ExerciseLogsService,
          useValue: mockExerciseLogsService,
        },
        {
          provide: AccessService,
          useValue: mockAccessService,
        },
      ],
    }).compile();

    controller = module.get<ExerciseLogsController>(ExerciseLogsController);
    service = module.get<ExerciseLogsService>(ExerciseLogsService);
    accessService = module.get<AccessService>(AccessService);
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('create', () => {
    it('should create an exercise log', async () => {
      const createDto: CreateExerciseLogDto = {
        userId: '1',
        exerciseId: 1,
        date: new Date().toISOString(),
        notes: 'Test note',
        sets: [],
      };
      const result = { id: 1, ...createDto };
      mockExerciseLogsService.create.mockResolvedValue(result);

      expect(await controller.create(createDto, '1')).toBe(result);
      expect(accessService.assertCanActFor).toHaveBeenCalledWith('1', '1');
      expect(service.create).toHaveBeenCalledWith(createDto);
    });

    it('should reject creating a log for another user', async () => {
      const createDto: CreateExerciseLogDto = {
        userId: 'other',
        exerciseId: 1,
        date: new Date().toISOString(),
        sets: [],
      };
      (accessService.assertCanActFor as Mock).mockRejectedValueOnce(
        new ForbiddenException('Access denied'),
      );
      await expect(controller.create(createDto, 'actor')).rejects.toThrow(
        ForbiddenException,
      );
      expect(service.create).not.toHaveBeenCalled();
    });
  });

  describe('findAll', () => {
    it('should find logs by user ID only', async () => {
      const result = [{ id: 1 }];
      mockExerciseLogsService.findAll.mockResolvedValue(result);

      expect(await controller.findAll({ userId: 'user1' }, 'user1')).toBe(
        result,
      );
      expect(accessService.assertCanActFor).toHaveBeenCalledWith(
        'user1',
        'user1',
      );
      expect(service.findAll).toHaveBeenCalledWith('user1', undefined);
    });

    it('should find logs by user ID and exercise ID', async () => {
      const result = [{ id: 1 }];
      mockExerciseLogsService.findAll.mockResolvedValue(result);

      expect(
        await controller.findAll({ userId: 'user1', exerciseId: '5' }, 'user1'),
      ).toBe(result);
      expect(service.findAll).toHaveBeenCalledWith('user1', 5);
    });

    it('should reject reading logs of another user', async () => {
      (accessService.assertCanActFor as Mock).mockRejectedValueOnce(
        new ForbiddenException('Access denied'),
      );
      await expect(
        controller.findAll({ userId: 'other' }, 'actor'),
      ).rejects.toThrow(ForbiddenException);
      expect(service.findAll).not.toHaveBeenCalled();
    });
  });
});
