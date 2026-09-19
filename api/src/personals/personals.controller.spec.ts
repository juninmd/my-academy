import { ForbiddenException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { PersonalsController } from './personals.controller.js';
import { PersonalsService } from './personals.service.js';
import { AccessService } from '../access/access.service.js';
import { Role } from '@prisma/client';

describe('PersonalsController', () => {
  let controller: PersonalsController;
  let service: PersonalsService;
  let accessService: AccessService;

  const mockService = {
    create: vi.fn(),
    findAll: vi.fn(),
    findOne: vi.fn(),
    findStudents: vi.fn(),
    update: vi.fn(),
    remove: vi.fn(),
  };

  const mockAccessService = {
    assertSelf: vi.fn(),
    assertRole: vi.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [PersonalsController],
      providers: [
        {
          provide: PersonalsService,
          useValue: mockService,
        },
        {
          provide: AccessService,
          useValue: mockAccessService,
        },
      ],
    }).compile();

    controller = module.get<PersonalsController>(PersonalsController);
    service = module.get<PersonalsService>(PersonalsService);
    accessService = module.get<AccessService>(AccessService);
  });

  afterEach(() => {
    vi.resetAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('create', () => {
    it('a personal can register themselves as the personal', async () => {
      const dto = { studentUserId: 's', personalUserId: 'p' };
      await controller.create(dto, 'p');

      expect(accessService.assertSelf).toHaveBeenCalledWith('p', 'p');
      expect(accessService.assertRole).toHaveBeenCalledWith('p', Role.PERSONAL);
      expect(service.create).toHaveBeenCalledWith(dto);
    });

    it('a student cannot register a personal for someone else', async () => {
      const dto = { studentUserId: 's', personalUserId: 'p' };
      mockAccessService.assertSelf.mockImplementation(() => {
        throw new ForbiddenException('Access denied');
      });

      await expect(controller.create(dto, 'other')).rejects.toThrow(
        ForbiddenException,
      );
      expect(service.create).not.toHaveBeenCalled();
    });
  });

  describe('findAll', () => {
    it('a personal can list their own contracts', async () => {
      await controller.findAll({ personalUserId: 'p1' }, 'p1');
      expect(accessService.assertSelf).toHaveBeenCalledWith('p1', 'p1');
      expect(service.findAll).toHaveBeenCalledWith('p1');
    });

    it('cannot list another personal contracts', () => {
      mockAccessService.assertSelf.mockImplementation(() => {
        throw new ForbiddenException('Access denied');
      });

      expect(() =>
        controller.findAll({ personalUserId: 'p1' }, 'other'),
      ).toThrow(ForbiddenException);
      expect(service.findAll).not.toHaveBeenCalled();
    });
  });

  describe('findOne (findStudents)', () => {
    it('a personal can see their own students', async () => {
      await controller.findOne('p1', 'p1');
      expect(accessService.assertSelf).toHaveBeenCalledWith('p1', 'p1');
      expect(service.findStudents).toHaveBeenCalledWith('p1');
    });

    it('cannot see another personal students', () => {
      mockAccessService.assertSelf.mockImplementation(() => {
        throw new ForbiddenException('Access denied');
      });

      expect(() => controller.findOne('p1', 'other')).toThrow(
        ForbiddenException,
      );
      expect(service.findStudents).not.toHaveBeenCalled();
    });
  });

  describe('update', () => {
    it('the personal party can update the contract', async () => {
      mockService.findOne.mockResolvedValue({
        personalUserId: 'p',
        studentUserId: 's',
      });
      const dto = { id: 1 };
      await controller.update(1, dto, 'p');

      expect(service.findOne).toHaveBeenCalledWith(1);
      expect(service.update).toHaveBeenCalledWith(1, dto);
    });

    it('the student party can update the contract', async () => {
      mockService.findOne.mockResolvedValue({
        personalUserId: 'p',
        studentUserId: 's',
      });
      const dto = { id: 1 };
      await controller.update(1, dto, 's');

      expect(service.update).toHaveBeenCalledWith(1, dto);
    });

    it('an unrelated actor cannot update the contract', async () => {
      mockService.findOne.mockResolvedValue({
        personalUserId: 'p',
        studentUserId: 's',
      });

      await expect(controller.update(1, { id: 1 }, 'other')).rejects.toThrow(
        ForbiddenException,
      );
      expect(service.update).not.toHaveBeenCalled();
    });
  });

  describe('remove', () => {
    it('the personal party can remove the contract', async () => {
      mockService.findOne.mockResolvedValue({
        personalUserId: 'p',
        studentUserId: 's',
      });
      await controller.remove(1, 'p');

      expect(service.remove).toHaveBeenCalledWith(1);
    });

    it('an unrelated actor cannot remove the contract', async () => {
      mockService.findOne.mockResolvedValue({
        personalUserId: 'p',
        studentUserId: 's',
      });

      await expect(controller.remove(1, 'other')).rejects.toThrow(
        ForbiddenException,
      );
      expect(service.remove).not.toHaveBeenCalled();
    });
  });
});
