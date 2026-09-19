import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service.js';
import { PrismaService } from '../prisma.service.js';
import { NotFoundException, ConflictException } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto.js';
import { UpdateUserDto } from './dto/update-user.dto.js';
import { User } from './entities/user.entity.js';

describe('UsersService', () => {
  let service: UsersService;

  const mockUser: User = {
    id: '123',
    name: 'Test User',
    email: 'test@example.com',
    photoUrl: 'http://example.com/photo.jpg',
    telegramId: '123456789',
    createdAt: new Date(),
    updatedAt: new Date(),
    role: 'STUDENT',
  } as any; // Using any to bypass unused properties for now

  const prismaMock = {
    users: {
      findUnique: vi.fn(),
      create: vi.fn(),
      findMany: vi.fn(),
      update: vi.fn(),
      delete: vi.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: PrismaService,
          useValue: prismaMock,
        },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    const createUserDto: CreateUserDto = {
      id: '123',
      name: 'Test User',
      email: 'test@example.com',
      photoUrl: 'http://example.com/photo.jpg',
      telegramId: '123456789',
    };

    it('should create a user if not exists', async () => {
      prismaMock.users.findUnique.mockResolvedValue(null);
      prismaMock.users.create.mockResolvedValue(mockUser);

      const result = await service.create(createUserDto);

      expect(prismaMock.users.findUnique).toHaveBeenCalledWith({
        where: { id: createUserDto.id },
      });
      expect(prismaMock.users.create).toHaveBeenCalledWith({
        data: {
          id: createUserDto.id,
          name: createUserDto.name,
          email: createUserDto.email,
          photoUrl: createUserDto.photoUrl,
          telegramId: createUserDto.telegramId,
        },
      });
      expect(result).toEqual(mockUser);
    });

    it('persists the role chosen at sign-up (e.g. a personal trainer)', async () => {
      prismaMock.users.findUnique.mockResolvedValue(null);
      await service.create({ ...createUserDto, role: 'PERSONAL' } as any);
      expect(prismaMock.users.create.mock.calls[0][0].data.role).toBe(
        'PERSONAL',
      );
    });

    it('should throw ConflictException if user already exists', async () => {
      prismaMock.users.findUnique.mockResolvedValue(mockUser);

      await expect(service.create(createUserDto)).rejects.toThrow(
        ConflictException,
      );
      expect(prismaMock.users.findUnique).toHaveBeenCalledWith({
        where: { id: createUserDto.id },
      });
      expect(prismaMock.users.create).not.toHaveBeenCalled();
    });
  });

  describe('findAll', () => {
    it('should return an array of users by email', async () => {
      prismaMock.users.findMany.mockResolvedValue([mockUser]);

      const result = await service.findAll('test@example.com');

      expect(prismaMock.users.findMany).toHaveBeenCalledWith({
        where: { email: 'test@example.com' },
      });
      expect(result).toEqual([mockUser]);
    });
  });

  describe('findOne', () => {
    it('should return a user if found', async () => {
      prismaMock.users.findUnique.mockResolvedValue(mockUser);

      const result = await service.findOne('123');

      expect(prismaMock.users.findUnique).toHaveBeenCalledWith({
        where: { id: '123' },
      });
      expect(result).toEqual(mockUser);
    });

    it('should throw NotFoundException if user not found', async () => {
      prismaMock.users.findUnique.mockResolvedValue(null);

      await expect(service.findOne('999')).rejects.toThrow(NotFoundException);
      expect(prismaMock.users.findUnique).toHaveBeenCalledWith({
        where: { id: '999' },
      });
    });
  });

  describe('update', () => {
    const updateUserDto: UpdateUserDto = {
      name: 'Updated User',
    };

    it('should update a user if found', async () => {
      prismaMock.users.update.mockResolvedValue({
        ...mockUser,
        ...updateUserDto,
      });

      const result = await service.update('123', updateUserDto);

      expect(prismaMock.users.update).toHaveBeenCalledWith({
        where: { id: '123' },
        data: expect.objectContaining(updateUserDto),
      });
      expect(result.name).toEqual(updateUserDto.name);
    });

    it('should persist role when provided', async () => {
      const dtoWithRole: UpdateUserDto = { role: 'ADMIN' } as UpdateUserDto;
      prismaMock.users.update.mockResolvedValue({
        ...mockUser,
        role: 'ADMIN',
      });

      await service.update('123', dtoWithRole);

      expect(prismaMock.users.update).toHaveBeenCalledWith({
        where: { id: '123' },
        data: expect.objectContaining({ role: 'ADMIN' }),
      });
    });

    it('records when onboarding is finished so other devices skip it', async () => {
      await service.update('123', { onboarded: true });

      const data = prismaMock.users.update.mock.calls[0][0].data;
      expect(data.onboardedAt).toBeInstanceOf(Date);
    });

    it('does not touch onboarding when the flag is absent', async () => {
      await service.update('123', { name: 'x' });

      expect(prismaMock.users.update.mock.calls[0][0].data).not.toHaveProperty(
        'onboardedAt',
      );
    });

    it('should throw NotFoundException if user to update not found', async () => {
      const error = new Error('Record to update not found.');
      (error as any).code = 'P2025';
      prismaMock.users.update.mockRejectedValue(error);

      await expect(service.update('999', updateUserDto)).rejects.toThrow(
        NotFoundException,
      );
      expect(prismaMock.users.update).toHaveBeenCalled();
    });

    it('should throw Error if generic error is thrown', async () => {
      const error = new Error('Some error');
      prismaMock.users.update.mockRejectedValue(error);

      await expect(service.update('999', updateUserDto)).rejects.toThrow(Error);
      expect(prismaMock.users.update).toHaveBeenCalled();
    });
  });

  describe('remove', () => {
    it('should remove a user if found', async () => {
      prismaMock.users.delete.mockResolvedValue(mockUser);

      const result = await service.remove('123');

      expect(prismaMock.users.delete).toHaveBeenCalledWith({
        where: { id: '123' },
      });
      expect(result).toEqual(mockUser);
    });

    it('should throw NotFoundException if user to remove not found', async () => {
      const error = new Error('Record to delete not found.');
      (error as any).code = 'P2025';
      prismaMock.users.delete.mockRejectedValue(error);

      await expect(service.remove('999')).rejects.toThrow(NotFoundException);
      expect(prismaMock.users.delete).toHaveBeenCalled();
    });

    it('should throw Error if generic error is thrown', async () => {
      const error = new Error('Some error');
      prismaMock.users.delete.mockRejectedValue(error);

      await expect(service.remove('999')).rejects.toThrow(Error);
      expect(prismaMock.users.delete).toHaveBeenCalled();
    });
  });
});
