import { ForbiddenException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { ExercisesController } from './exercises.controller.js';
import { ExercisesService } from './exercises.service.js';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { AccessService } from '../access/access.service.js';
import { Role } from '@prisma/client';

describe('ExercisesController', () => {
  let controller: ExercisesController;
  let service: ExercisesService;
  let accessService: AccessService;

  const mockService = {
    create: vi.fn(),
    findAll: vi.fn(),
    findOne: vi.fn(),
    update: vi.fn(),
    remove: vi.fn(),
  };

  const mockAccessService = {
    assertRole: vi.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ExercisesController],
      providers: [
        {
          provide: ExercisesService,
          useValue: mockService,
        },
        {
          provide: AccessService,
          useValue: mockAccessService,
        },
        {
          provide: CACHE_MANAGER,
          useValue: {
            get: vi.fn(),
            set: vi.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<ExercisesController>(ExercisesController);
    service = module.get<ExercisesService>(ExercisesService);
    accessService = module.get<AccessService>(AccessService);
  });

  afterEach(() => {
    vi.resetAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('create as admin', async () => {
    const dto = { name: 'n', image: 'i', tips: 't', mistakes: 'm' };
    await controller.create(dto, 'admin');
    expect(accessService.assertRole).toHaveBeenCalledWith('admin', Role.ADMIN);
    expect(service.create).toHaveBeenCalledWith(dto);
  });

  it('non-admin cannot create', async () => {
    mockAccessService.assertRole.mockRejectedValue(
      new ForbiddenException('Access denied'),
    );
    const dto = { name: 'n', image: 'i', tips: 't', mistakes: 'm' };

    await expect(controller.create(dto, 'student')).rejects.toThrow(
      ForbiddenException,
    );
    expect(service.create).not.toHaveBeenCalled();
  });

  it('findAll', async () => {
    await controller.findAll();
    expect(service.findAll).toHaveBeenCalled();
  });

  it('findOne', async () => {
    await controller.findOne(1);
    expect(service.findOne).toHaveBeenCalledWith(1);
  });

  it('update as admin', async () => {
    const dto = { name: 'n' };
    await controller.update(1, dto, 'admin');
    expect(accessService.assertRole).toHaveBeenCalledWith('admin', Role.ADMIN);
    expect(service.update).toHaveBeenCalledWith(1, dto);
  });

  it('non-admin cannot update', async () => {
    mockAccessService.assertRole.mockRejectedValue(
      new ForbiddenException('Access denied'),
    );

    await expect(
      controller.update(1, { name: 'n' }, 'student'),
    ).rejects.toThrow(ForbiddenException);
    expect(service.update).not.toHaveBeenCalled();
  });

  it('remove as admin', async () => {
    await controller.remove(1, 'admin');
    expect(accessService.assertRole).toHaveBeenCalledWith('admin', Role.ADMIN);
    expect(service.remove).toHaveBeenCalledWith(1);
  });

  it('non-admin cannot remove', async () => {
    mockAccessService.assertRole.mockRejectedValue(
      new ForbiddenException('Access denied'),
    );

    await expect(controller.remove(1, 'student')).rejects.toThrow(
      ForbiddenException,
    );
    expect(service.remove).not.toHaveBeenCalled();
  });
});
