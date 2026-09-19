import type { Mock } from 'vitest';
import { ForbiddenException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { WorkoutsGroupsController } from './workouts-groups.controller.js';
import { WorkoutsGroupsService } from './workouts-groups.service.js';
import { AccessService } from '../access/access.service.js';

describe('WorkoutsGroupsController', () => {
  let controller: WorkoutsGroupsController;
  let service: WorkoutsGroupsService;
  let accessService: AccessService;

  const mockService = {
    create: vi.fn(),
    findAll: vi.fn(),
    findOne: vi.fn(),
    findAllExercises: vi.fn(),
    update: vi.fn(),
    remove: vi.fn(),
  };

  const mockAccessService = {
    assertCanActFor: vi.fn(),
    assertCanAccessGroup: vi.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [WorkoutsGroupsController],
      providers: [
        {
          provide: WorkoutsGroupsService,
          useValue: mockService,
        },
        {
          provide: AccessService,
          useValue: mockAccessService,
        },
      ],
    }).compile();

    controller = module.get<WorkoutsGroupsController>(WorkoutsGroupsController);
    service = module.get<WorkoutsGroupsService>(WorkoutsGroupsService);
    accessService = module.get<AccessService>(AccessService);
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('create', async () => {
    const dto = { name: 'n', image: 'i', userId: 'u' };
    await controller.create(dto, 'u');
    expect(accessService.assertCanActFor).toHaveBeenCalledWith('u', 'u');
    expect(service.create).toHaveBeenCalledWith(dto);
  });

  it('create rejects when actor cannot act for the target user', async () => {
    const dto = { name: 'n', image: 'i', userId: 'other' };
    (accessService.assertCanActFor as Mock).mockRejectedValueOnce(
      new ForbiddenException('Access denied'),
    );
    await expect(controller.create(dto, 'actor')).rejects.toThrow(
      ForbiddenException,
    );
    expect(service.create).not.toHaveBeenCalled();
  });

  it('findAll', async () => {
    await controller.findAll('u1', 'u1');
    expect(accessService.assertCanActFor).toHaveBeenCalledWith('u1', 'u1');
    expect(service.findAll).toHaveBeenCalledWith('u1');
  });

  it('findOne', async () => {
    await controller.findOne(1, 'u1');
    expect(accessService.assertCanAccessGroup).toHaveBeenCalledWith('u1', 1);
    expect(service.findOne).toHaveBeenCalledWith(1);
  });

  it('findOneExercises', async () => {
    await controller.findOneExercises(1, 'u1');
    expect(accessService.assertCanAccessGroup).toHaveBeenCalledWith('u1', 1);
    expect(service.findAllExercises).toHaveBeenCalledWith(1);
  });

  it('update', async () => {
    const dto = { name: 'n' };
    await controller.update(1, dto, 'u1');
    expect(accessService.assertCanAccessGroup).toHaveBeenCalledWith('u1', 1);
    expect(service.update).toHaveBeenCalledWith(1, dto);
  });

  it('remove', async () => {
    await controller.remove(1, 'u1');
    expect(accessService.assertCanAccessGroup).toHaveBeenCalledWith('u1', 1);
    expect(service.remove).toHaveBeenCalledWith(1);
  });
});
