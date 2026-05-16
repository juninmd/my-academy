import { Test, TestingModule } from '@nestjs/testing';
import { AssessmentsService } from './assessments.service';
import { PrismaService } from '../prisma.service';
import { NotFoundException } from '@nestjs/common';

describe('AssessmentsService', () => {
  let service: AssessmentsService;

  const mockPrisma = {
    assessment: {
      create: jest.fn(),
      findMany: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AssessmentsService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<AssessmentsService>(AssessmentsService);
  });

  afterEach(() => jest.clearAllMocks());

  it('should calculate IMC automatically', async () => {
    const dto = { studentId: 's1', personalId: 'p1', weight: 80, height: 2 };
    mockPrisma.assessment.create.mockResolvedValue({ id: 1, ...dto, imc: 20 });

    await service.create(dto as any);
    expect(mockPrisma.assessment.create).toHaveBeenCalledWith({
      data: expect.objectContaining({ imc: 20 }),
    });
  });

  it('should find all assessments', async () => {
    mockPrisma.assessment.findMany.mockResolvedValue([]);
    await service.findAll('s1');
    expect(mockPrisma.assessment.findMany).toHaveBeenCalledWith({
      where: { studentId: 's1' },
      orderBy: { date: 'desc' },
    });
  });

  it('should find one assessment', async () => {
    mockPrisma.assessment.findUnique.mockResolvedValue({ id: 1 });
    const result = await service.findOne(1);
    expect(result.id).toBe(1);
  });

  it('should throw if not found', async () => {
    mockPrisma.assessment.findUnique.mockResolvedValue(null);
    await expect(service.findOne(99)).rejects.toThrow(NotFoundException);
  });

  it('should update an assessment', async () => {
    mockPrisma.assessment.update.mockResolvedValue({ id: 1 });
    await service.update(1, { weight: 85 });
    expect(mockPrisma.assessment.update).toHaveBeenCalled();
  });

  it('should throw if update fails', async () => {
    mockPrisma.assessment.update.mockRejectedValue(new Error());
    await expect(service.update(1, {})).rejects.toThrow(NotFoundException);
  });

  it('should remove an assessment', async () => {
    mockPrisma.assessment.delete.mockResolvedValue({ id: 1 });
    await service.remove(1);
    expect(mockPrisma.assessment.delete).toHaveBeenCalled();
  });

  it('should throw if remove fails', async () => {
    mockPrisma.assessment.delete.mockRejectedValue(new Error());
    await expect(service.remove(1)).rejects.toThrow(NotFoundException);
  });
});
