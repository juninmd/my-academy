import { Test, TestingModule } from '@nestjs/testing';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { User } from './entities/user.entity';

describe('UsersController', () => {
  let controller: UsersController;
  let service: UsersService;

  const mockUsersService = {
    create: jest.fn(),
    findAll: jest.fn(),
    findOne: jest.fn(),
    update: jest.fn(),
    remove: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [UsersController],
      providers: [
        {
          provide: UsersService,
          useValue: mockUsersService,
        },
      ],
    }).compile();

    controller = module.get<UsersController>(UsersController);
    service = module.get<UsersService>(UsersService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('create', () => {
    it('should create a user', async () => {
      const createDto: CreateUserDto = {
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        photoUrl: 'https://example.com/photo.jpg',
      };
      const result: User = {
        ...createDto,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      mockUsersService.create.mockResolvedValue(result);

      expect(await controller.create(createDto)).toBe(result);
      expect(service.create).toHaveBeenCalledWith(createDto);
    });
  });

  describe('findAll', () => {
    it('should find all users', async () => {
      const result: User[] = [
        {
          id: '1',
          name: 'User 1',
          email: 'user1@example.com',
          photoUrl: '',
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      ];
      mockUsersService.findAll.mockResolvedValue(result);

      expect(await controller.findAll({})).toBe(result);
      expect(service.findAll).toHaveBeenCalledWith(undefined);
    });

    it('should find users by email', async () => {
      const result: User[] = [
        {
          id: '1',
          name: 'User 1',
          email: 'user1@example.com',
          photoUrl: '',
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      ];
      mockUsersService.findAll.mockResolvedValue(result);

      expect(await controller.findAll({ email: 'user1@example.com' })).toBe(
        result,
      );
      expect(service.findAll).toHaveBeenCalledWith('user1@example.com');
    });
  });

  describe('findOne', () => {
    it('should find a user by id', async () => {
      const result: User = {
        id: '1',
        name: 'User 1',
        email: 'user1@example.com',
        photoUrl: '',
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      mockUsersService.findOne.mockResolvedValue(result);

      expect(await controller.findOne('1')).toBe(result);
      expect(service.findOne).toHaveBeenCalledWith('1');
    });
  });

  describe('update', () => {
    it('should update a user', async () => {
      const updateDto: UpdateUserDto = { name: 'Updated Name' };
      const result: User = {
        id: '1',
        name: 'Updated Name',
        email: 'user1@example.com',
        photoUrl: '',
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      mockUsersService.update.mockResolvedValue(result);

      expect(await controller.update('1', updateDto)).toBe(result);
      expect(service.update).toHaveBeenCalledWith('1', updateDto);
    });
  });

  describe('remove', () => {
    it('should remove a user', async () => {
      const result: User = {
        id: '1',
        name: 'User 1',
        email: 'user1@example.com',
        photoUrl: '',
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      mockUsersService.remove.mockResolvedValue(result);

      expect(await controller.remove('1')).toBe(result);
      expect(service.remove).toHaveBeenCalledWith('1');
    });
  });
});
