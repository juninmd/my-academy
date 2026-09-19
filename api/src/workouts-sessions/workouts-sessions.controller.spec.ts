import { NotFoundException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { WorkoutsSessionsController } from './workouts-sessions.controller.js';
import { WorkoutsSessionsService } from './workouts-sessions.service.js';
import { AccessService } from '../access/access.service.js';

describe('WorkoutsSessionsController', () => {
  let controller: WorkoutsSessionsController;
  let service: WorkoutsSessionsService;
  let accessService: AccessService;

  const mockService = {
    create: vi.fn(),
    findAll: vi.fn(),
    findSummary: vi.fn(),
    findOne: vi.fn(),
    update: vi.fn(),
    remove: vi.fn(),
  };

  const mockAccessService = {
    assertCanActFor: vi.fn(),
    assertCanAccessGroup: vi.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [WorkoutsSessionsController],
      providers: [
        {
          provide: WorkoutsSessionsService,
          useValue: mockService,
        },
        {
          provide: AccessService,
          useValue: mockAccessService,
        },
      ],
    }).compile();

    controller = module.get<WorkoutsSessionsController>(
      WorkoutsSessionsController,
    );
    service = module.get<WorkoutsSessionsService>(WorkoutsSessionsService);
    accessService = module.get<AccessService>(AccessService);
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('create', async () => {
    const dto = { workoutGroupId: 1, duration: 60 };
    await controller.create(dto as any, 'u1');
    expect(accessService.assertCanAccessGroup).toHaveBeenCalledWith('u1', 1);
    expect(service.create).toHaveBeenCalledWith(dto, 'u1');
  });

  it('findAll', async () => {
    await controller.findAll('u1', { year: '2023', month: '1' }, 'u1');
    expect(accessService.assertCanActFor).toHaveBeenCalledWith('u1', 'u1');
    expect(service.findAll).toHaveBeenCalledWith('u1', 2023, 1);
  });

  it('findSummary', async () => {
    await controller.findSummary('u1', 'u1');
    expect(accessService.assertCanActFor).toHaveBeenCalledWith('u1', 'u1');
    expect(service.findSummary).toHaveBeenCalledWith('u1');
  });

  it('findOne', async () => {
    mockService.findOne.mockResolvedValue({ id: 1, workoutGroupId: 5 });
    await controller.findOne(1, 'u1');
    expect(accessService.assertCanAccessGroup).toHaveBeenCalledWith('u1', 5);
    expect(service.findOne).toHaveBeenCalledWith(1);
  });

  it('findOne throws NotFoundException when session is missing', async () => {
    mockService.findOne.mockResolvedValue(null);
    await expect(controller.findOne(1, 'u1')).rejects.toThrow(
      NotFoundException,
    );
    expect(accessService.assertCanAccessGroup).not.toHaveBeenCalled();
  });

  it('update', async () => {
    mockService.findOne.mockResolvedValue({ id: 1, workoutGroupId: 5 });
    const dto = { duration: 120, workoutGroupId: 1, date: new Date() };
    await controller.update(1, dto, 'u1');
    expect(accessService.assertCanAccessGroup).toHaveBeenCalledWith('u1', 5);
    expect(service.update).toHaveBeenCalledWith(1, dto);
  });

  it('remove', async () => {
    mockService.findOne.mockResolvedValue({ id: 1, workoutGroupId: 5 });
    await controller.remove(1, 'u1');
    expect(accessService.assertCanAccessGroup).toHaveBeenCalledWith('u1', 5);
    expect(service.remove).toHaveBeenCalledWith(1);
  });
});
