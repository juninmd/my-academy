import { BadRequestException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { WorkoutsSeriesController } from './workouts-series.controller.js';
import { WorkoutsSeriesService } from './workouts-series.service.js';
import { AccessService } from '../access/access.service.js';

describe('WorkoutsSeriesController', () => {
  let controller: WorkoutsSeriesController;
  let service: WorkoutsSeriesService;
  let accessService: AccessService;

  const mockService = {
    create: vi.fn(),
    findAll: vi.fn(),
    findOne: vi.fn(),
    update: vi.fn(),
    remove: vi.fn(),
    resolveGroupId: vi.fn(),
  };

  const mockAccessService = {
    assertCanAccessGroup: vi.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [WorkoutsSeriesController],
      providers: [
        {
          provide: WorkoutsSeriesService,
          useValue: mockService,
        },
        {
          provide: AccessService,
          useValue: mockAccessService,
        },
      ],
    }).compile();

    controller = module.get<WorkoutsSeriesController>(WorkoutsSeriesController);
    service = module.get<WorkoutsSeriesService>(WorkoutsSeriesService);
    accessService = module.get<AccessService>(AccessService);
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('create', async () => {
    const dto = { workoutId: 1, repetitions: 10 };
    mockService.resolveGroupId.mockResolvedValue(5);
    await controller.create(dto as any, 'u1');
    expect(service.resolveGroupId).toHaveBeenCalledWith(1);
    expect(accessService.assertCanAccessGroup).toHaveBeenCalledWith('u1', 5);
    expect(service.create).toHaveBeenCalledWith(dto);
  });

  it('create rejects missing workoutId', async () => {
    const dto = { repetitions: 10 };
    await expect(controller.create(dto as any, 'u1')).rejects.toThrow(
      BadRequestException,
    );
    expect(service.create).not.toHaveBeenCalled();
  });

  it('findAll', async () => {
    mockService.resolveGroupId.mockResolvedValue(5);
    await controller.findAll(1, 'u1');
    expect(accessService.assertCanAccessGroup).toHaveBeenCalledWith('u1', 5);
    expect(service.findAll).toHaveBeenCalledWith(1);
  });

  it('findOne', async () => {
    mockService.findOne.mockResolvedValue({ id: 1, workoutId: 2 });
    mockService.resolveGroupId.mockResolvedValue(5);
    await controller.findOne(1, 'u1');
    expect(service.resolveGroupId).toHaveBeenCalledWith(2);
    expect(accessService.assertCanAccessGroup).toHaveBeenCalledWith('u1', 5);
    expect(service.findOne).toHaveBeenCalledWith(1);
  });

  it('update', async () => {
    mockService.findOne.mockResolvedValue({ id: 1, workoutId: 2 });
    mockService.resolveGroupId.mockResolvedValue(5);
    const dto = { repetitions: 12 };
    await controller.update(1, dto, 'u1');
    expect(accessService.assertCanAccessGroup).toHaveBeenCalledWith('u1', 5);
    expect(service.update).toHaveBeenCalledWith(1, dto);
  });

  it('remove', async () => {
    mockService.findOne.mockResolvedValue({ id: 1, workoutId: 2 });
    mockService.resolveGroupId.mockResolvedValue(5);
    await controller.remove(1, 'u1');
    expect(accessService.assertCanAccessGroup).toHaveBeenCalledWith('u1', 5);
    expect(service.remove).toHaveBeenCalledWith(1);
  });
});
