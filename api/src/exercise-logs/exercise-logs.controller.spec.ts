import { Test, TestingModule } from '@nestjs/testing';
import { ExerciseLogsController } from './exercise-logs.controller';
import { ExerciseLogsService } from './exercise-logs.service';
import { CreateExerciseLogDto } from './dto/create-exercise-log.dto';

describe('ExerciseLogsController', () => {
  let controller: ExerciseLogsController;
  let service: ExerciseLogsService;

  const mockExerciseLogsService = {
    create: jest.fn(),
    findAll: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ExerciseLogsController],
      providers: [
        {
          provide: ExerciseLogsService,
          useValue: mockExerciseLogsService,
        },
      ],
    }).compile();

    controller = module.get<ExerciseLogsController>(ExerciseLogsController);
    service = module.get<ExerciseLogsService>(ExerciseLogsService);
  });

  afterEach(() => {
    jest.clearAllMocks();
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

      expect(await controller.create(createDto)).toBe(result);
      expect(service.create).toHaveBeenCalledWith(createDto);
    });
  });

  describe('findAll', () => {
    it('should find logs by user ID only', async () => {
      const result = [{ id: 1 }];
      mockExerciseLogsService.findAll.mockResolvedValue(result);

      expect(await controller.findAll({ userId: 'user1' })).toBe(result);
      expect(service.findAll).toHaveBeenCalledWith('user1', undefined);
    });

    it('should find logs by user ID and exercise ID', async () => {
      const result = [{ id: 1 }];
      mockExerciseLogsService.findAll.mockResolvedValue(result);

      expect(
        await controller.findAll({ userId: 'user1', exerciseId: '5' }),
      ).toBe(result);
      expect(service.findAll).toHaveBeenCalledWith('user1', 5);
    });
  });
});