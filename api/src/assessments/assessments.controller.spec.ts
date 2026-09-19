import { BadRequestException, ForbiddenException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { AssessmentsController } from './assessments.controller.js';
import { AssessmentsService } from './assessments.service.js';
import { CreateAssessmentDto } from './dto/create-assessment.dto.js';
import { UpdateAssessmentDto } from './dto/update-assessment.dto.js';
import { AccessService } from '../access/access.service.js';

describe('AssessmentsController', () => {
  let controller: AssessmentsController;
  let service: AssessmentsService;
  let accessService: AccessService;

  const mockAssessmentsService = {
    create: vi.fn(),
    findAll: vi.fn(),
    findOne: vi.fn(),
    update: vi.fn(),
    remove: vi.fn(),
  };

  const mockAccessService = {
    assertSelf: vi.fn(),
    assertCanActFor: vi.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AssessmentsController],
      providers: [
        {
          provide: AssessmentsService,
          useValue: mockAssessmentsService,
        },
        {
          provide: AccessService,
          useValue: mockAccessService,
        },
      ],
    }).compile();

    controller = module.get<AssessmentsController>(AssessmentsController);
    service = module.get<AssessmentsService>(AssessmentsService);
    accessService = module.get<AccessService>(AccessService);
  });

  afterEach(() => {
    vi.resetAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('create', () => {
    it('a personal with a contract can create an assessment for their student', async () => {
      const createDto: CreateAssessmentDto = {
        studentId: '1',
        personalId: '2',
        weight: 70,
        height: 175,
      };
      const result = { id: 1, ...createDto };
      mockAssessmentsService.create.mockResolvedValue(result);

      expect(await controller.create(createDto, '2')).toBe(result);
      expect(accessService.assertSelf).toHaveBeenCalledWith('2', '2');
      expect(accessService.assertCanActFor).toHaveBeenCalledWith('2', '1');
      expect(service.create).toHaveBeenCalledWith(createDto);
    });

    it('cannot create an assessment impersonating another personal', async () => {
      const createDto: CreateAssessmentDto = {
        studentId: '1',
        personalId: '2',
        weight: 70,
        height: 175,
      };
      mockAccessService.assertSelf.mockImplementation(() => {
        throw new ForbiddenException('Access denied');
      });

      await expect(controller.create(createDto, 'other')).rejects.toThrow(
        ForbiddenException,
      );
      expect(service.create).not.toHaveBeenCalled();
    });

    it('cannot create an assessment without a contract with the student', async () => {
      const createDto: CreateAssessmentDto = {
        studentId: '1',
        personalId: '2',
        weight: 70,
        height: 175,
      };
      mockAccessService.assertCanActFor.mockRejectedValue(
        new ForbiddenException('Access denied'),
      );

      await expect(controller.create(createDto, '2')).rejects.toThrow(
        ForbiddenException,
      );
      expect(service.create).not.toHaveBeenCalled();
    });
  });

  describe('findAll', () => {
    it('requires studentId or personalId', async () => {
      await expect(controller.findAll({}, 'actor')).rejects.toThrow(
        BadRequestException,
      );
      expect(service.findAll).not.toHaveBeenCalled();
    });

    it('a personal with a contract can list assessments by studentId', async () => {
      const result = [{ id: 1 }];
      mockAssessmentsService.findAll.mockResolvedValue(result);

      expect(await controller.findAll({ studentId: '1' }, 'personal-1')).toBe(
        result,
      );
      expect(accessService.assertCanActFor).toHaveBeenCalledWith(
        'personal-1',
        '1',
      );
      expect(service.findAll).toHaveBeenCalledWith('1', undefined);
    });

    it('a personal can list their own assessments by personalId', async () => {
      const result = [{ id: 1 }];
      mockAssessmentsService.findAll.mockResolvedValue(result);

      expect(await controller.findAll({ personalId: 'p1' }, 'p1')).toBe(result);
      expect(accessService.assertSelf).toHaveBeenCalledWith('p1', 'p1');
      expect(service.findAll).toHaveBeenCalledWith(undefined, 'p1');
    });
  });

  describe('findOne', () => {
    it('the personal can read the assessment', async () => {
      const result = { id: 1, personalId: 'p1', studentId: 's1' };
      mockAssessmentsService.findOne.mockResolvedValue(result);

      expect(await controller.findOne(1, 'p1')).toBe(result);
      expect(service.findOne).toHaveBeenCalledWith(1);
    });

    it('the student can read the assessment', async () => {
      const result = { id: 1, personalId: 'p1', studentId: 's1' };
      mockAssessmentsService.findOne.mockResolvedValue(result);

      expect(await controller.findOne(1, 's1')).toBe(result);
    });

    it('an unrelated actor cannot read the assessment', async () => {
      const result = { id: 1, personalId: 'p1', studentId: 's1' };
      mockAssessmentsService.findOne.mockResolvedValue(result);

      await expect(controller.findOne(1, 'other')).rejects.toThrow(
        ForbiddenException,
      );
    });
  });

  describe('update', () => {
    it('the personal can update the assessment', async () => {
      const assessment = { id: 1, personalId: 'p1', studentId: 's1' };
      const updateDto: UpdateAssessmentDto = { weight: 75 };
      mockAssessmentsService.findOne.mockResolvedValue(assessment);
      mockAssessmentsService.update.mockResolvedValue({
        ...assessment,
        ...updateDto,
      });

      const result = await controller.update(1, updateDto, 'p1');
      expect(result).toEqual({ ...assessment, ...updateDto });
      expect(service.update).toHaveBeenCalledWith(1, updateDto);
    });

    it('the student cannot update the assessment', async () => {
      const assessment = { id: 1, personalId: 'p1', studentId: 's1' };
      mockAssessmentsService.findOne.mockResolvedValue(assessment);

      await expect(controller.update(1, { weight: 75 }, 's1')).rejects.toThrow(
        ForbiddenException,
      );
      expect(service.update).not.toHaveBeenCalled();
    });
  });

  describe('remove', () => {
    it('the personal can remove the assessment', async () => {
      const assessment = { id: 1, personalId: 'p1', studentId: 's1' };
      mockAssessmentsService.findOne.mockResolvedValue(assessment);
      mockAssessmentsService.remove.mockResolvedValue(assessment);

      expect(await controller.remove(1, 'p1')).toBe(assessment);
      expect(service.remove).toHaveBeenCalledWith(1);
    });

    it('the student cannot remove the assessment', async () => {
      const assessment = { id: 1, personalId: 'p1', studentId: 's1' };
      mockAssessmentsService.findOne.mockResolvedValue(assessment);

      await expect(controller.remove(1, 's1')).rejects.toThrow(
        ForbiddenException,
      );
      expect(service.remove).not.toHaveBeenCalled();
    });
  });
});
