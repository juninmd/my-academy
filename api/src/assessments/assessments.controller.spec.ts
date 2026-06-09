import { Test, TestingModule } from '@nestjs/testing';
import { AssessmentsController } from './assessments.controller';
import { AssessmentsService } from './assessments.service';
import { CreateAssessmentDto } from './dto/create-assessment.dto';
import { UpdateAssessmentDto } from './dto/update-assessment.dto';

describe('AssessmentsController', () => {
  let controller: AssessmentsController;
  let service: AssessmentsService;

  const mockAssessmentsService = {
    create: jest.fn(),
    findAll: jest.fn(),
    findOne: jest.fn(),
    update: jest.fn(),
    remove: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AssessmentsController],
      providers: [
        {
          provide: AssessmentsService,
          useValue: mockAssessmentsService,
        },
      ],
    }).compile();

    controller = module.get<AssessmentsController>(AssessmentsController);
    service = module.get<AssessmentsService>(AssessmentsService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('create', () => {
    it('should create an assessment', async () => {
      const createDto: CreateAssessmentDto = {
        studentId: '1',
        personalId: '2',
        weight: 70,
        height: 175,
      };
      const result = { id: 1, ...createDto };
      mockAssessmentsService.create.mockResolvedValue(result);

      expect(await controller.create(createDto)).toBe(result);
      expect(service.create).toHaveBeenCalledWith(createDto);
    });
  });

  describe('findAll', () => {
    it('should find all assessments', async () => {
      const result = [{ id: 1 }];
      mockAssessmentsService.findAll.mockResolvedValue(result);

      expect(await controller.findAll({})).toBe(result);
      expect(service.findAll).toHaveBeenCalledWith(undefined);
    });

    it('should find assessments by studentId', async () => {
      const result = [{ id: 1 }];
      mockAssessmentsService.findAll.mockResolvedValue(result);

      expect(await controller.findAll({ studentId: '1' })).toBe(result);
      expect(service.findAll).toHaveBeenCalledWith('1');
    });
  });

  describe('findOne', () => {
    it('should find an assessment by id', async () => {
      const result = { id: 1 };
      mockAssessmentsService.findOne.mockResolvedValue(result);

      expect(await controller.findOne('1')).toBe(result);
      expect(service.findOne).toHaveBeenCalledWith(1);
    });
  });

  describe('update', () => {
    it('should update an assessment', async () => {
      const updateDto: UpdateAssessmentDto = { weight: 75 };
      const result = { id: 1, ...updateDto };
      mockAssessmentsService.update.mockResolvedValue(result);

      expect(await controller.update('1', updateDto)).toBe(result);
      expect(service.update).toHaveBeenCalledWith(1, updateDto);
    });
  });

  describe('remove', () => {
    it('should remove an assessment', async () => {
      const result = { id: 1 };
      mockAssessmentsService.remove.mockResolvedValue(result);

      expect(await controller.remove('1')).toBe(result);
      expect(service.remove).toHaveBeenCalledWith(1);
    });
  });
});
