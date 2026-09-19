import { BadRequestException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { WorkoutsController } from './workouts.controller.js';
import { WorkoutsService } from './workouts.service.js';
import { AccessService } from '../access/access.service.js';

describe('WorkoutsController', () => {
  let controller: WorkoutsController;
  let service: WorkoutsService;
  let accessService: AccessService;

  const mockService = {
    create: vi.fn(),
    findAll: vi.fn(),
    findOne: vi.fn(),
    update: vi.fn(),
    remove: vi.fn(),
  };

  const mockAccessService = {
    assertCanAccessGroup: vi.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [WorkoutsController],
      providers: [
        {
          provide: WorkoutsService,
          useValue: mockService,
        },
        {
          provide: AccessService,
          useValue: mockAccessService,
        },
      ],
    }).compile();

    controller = module.get<WorkoutsController>(WorkoutsController);
    service = module.get<WorkoutsService>(WorkoutsService);
    accessService = module.get<AccessService>(AccessService);
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('create', async () => {
    const dto = { exerciseId: 1, methodId: 1, workoutsGroupsId: 1 };
    await controller.create(dto, 'u1');
    expect(accessService.assertCanAccessGroup).toHaveBeenCalledWith('u1', 1);
    expect(service.create).toHaveBeenCalledWith(dto);
  });

  it('findAll', async () => {
    await controller.findAll(1, 'u1');
    expect(accessService.assertCanAccessGroup).toHaveBeenCalledWith('u1', 1);
    expect(service.findAll).toHaveBeenCalledWith(1);
  });

  it('findOne', async () => {
    mockService.findOne.mockResolvedValue({ id: 1, workoutsGroupsId: 5 });
    await controller.findOne(1, 'u1');
    expect(accessService.assertCanAccessGroup).toHaveBeenCalledWith('u1', 5);
    expect(service.findOne).toHaveBeenCalledWith(1);
  });

  it('update', async () => {
    mockService.findOne.mockResolvedValue({ id: 1, workoutsGroupsId: 5 });
    const dto = { exerciseId: 2 };
    await controller.update(1, dto, 'u1');
    expect(accessService.assertCanAccessGroup).toHaveBeenCalledWith('u1', 5);
    expect(service.update).toHaveBeenCalledWith(1, dto);
  });

  it('update rejects moving the workout to another group', async () => {
    mockService.findOne.mockResolvedValue({ id: 1, workoutsGroupsId: 5 });
    const dto = { workoutsGroupsId: 9 };
    await expect(controller.update(1, dto, 'u1')).rejects.toThrow(
      BadRequestException,
    );
    expect(service.update).not.toHaveBeenCalled();
  });

  it('remove', async () => {
    mockService.findOne.mockResolvedValue({ id: 1, workoutsGroupsId: 5 });
    await controller.remove(1, 'u1');
    expect(accessService.assertCanAccessGroup).toHaveBeenCalledWith('u1', 5);
    expect(service.remove).toHaveBeenCalledWith(1);
  });
});
