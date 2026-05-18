import { Test, TestingModule } from '@nestjs/testing';
import { GymsService } from './gyms.service';
import { PrismaService } from '../prisma.service';

describe('GymsService', () => {
  let service: GymsService;
  let prisma: PrismaService;

  beforeEach(async () => {
    process.env.DATABASE_URL = 'postgresql://dummy:dummy@localhost:5432/dummy';
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        GymsService,
        {
          provide: PrismaService,
          useValue: {
            gym: {
              create: jest.fn(),
              findMany: jest.fn(),
            },
            plan: {
              create: jest.fn(),
              findMany: jest.fn(),
            },
          },
        },
      ],
    }).compile();

    service = module.get<GymsService>(GymsService);
    prisma = module.get<PrismaService>(PrismaService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('createGym', () => {
    it('should call prisma.gym.create', async () => {
      const dto = { name: 'Iron Gym' };
      const expectedResult = {
        id: 1,
        ...dto,
        address: null,
        ownerId: null,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      (prisma.gym.create as jest.Mock).mockResolvedValue(expectedResult);
      expect(await service.createGym(dto)).toEqual(expectedResult);
      expect(prisma.gym.create).toHaveBeenCalledWith({ data: dto });
    });
  });

  describe('findAllGyms', () => {
    it('should call prisma.gym.findMany', async () => {
      const expectedResult = [
        {
          id: 1,
          name: 'Iron Gym',
          address: null,
          ownerId: null,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      ];
      (prisma.gym.findMany as jest.Mock).mockResolvedValue(expectedResult);
      expect(await service.findAllGyms()).toEqual(expectedResult);
      expect(prisma.gym.findMany).toHaveBeenCalledWith({
        include: { plans: true },
      });
    });
  });

  describe('createPlan', () => {
    it('should call prisma.plan.create', async () => {
      const dto = { name: 'Monthly', price: 99.9, durationMonths: 1, gymId: 1 };
      const expectedResult = {
        id: 1,
        ...dto,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      (prisma.plan.create as jest.Mock).mockResolvedValue(expectedResult);
      expect(await service.createPlan(dto)).toEqual(expectedResult);
      expect(prisma.plan.create).toHaveBeenCalledWith({ data: dto });
    });
  });

  describe('findGymPlans', () => {
    it('should call prisma.plan.findMany', async () => {
      const expectedResult = [
        {
          id: 1,
          name: 'Monthly',
          price: 99.9,
          durationMonths: 1,
          gymId: 1,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      ];
      (prisma.plan.findMany as jest.Mock).mockResolvedValue(expectedResult);
      expect(await service.findGymPlans(1)).toEqual(expectedResult);
      expect(prisma.plan.findMany).toHaveBeenCalledWith({
        where: { gymId: 1 },
      });
    });
  });
});
