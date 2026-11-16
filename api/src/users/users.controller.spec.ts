import type { Mock } from 'vitest';
import { ForbiddenException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { UsersController } from './users.controller.js';
import { UsersService } from './users.service.js';
import { CreateUserDto } from './dto/create-user.dto.js';
import { UpdateUserDto } from './dto/update-user.dto.js';
import { User } from './entities/user.entity.js';
import { AccessService } from '../access/access.service.js';
import { InvitesService } from '../invites/invites.service.js';

describe('UsersController', () => {
  let controller: UsersController;
  let module_invites: () => { redeem: Mock };
  let service: UsersService;
  let accessService: AccessService;

  const mockUsersService = {
    create: vi.fn(),
    findAll: vi.fn(),
    findOne: vi.fn(),
    update: vi.fn(),
    remove: vi.fn(),
  };

  const mockAccessService = {
    assertSelf: vi.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [UsersController],
      providers: [
        {
          provide: UsersService,
          useValue: mockUsersService,
        },
        {
          provide: AccessService,
          useValue: mockAccessService,
        },
        {
          provide: InvitesService,
          useValue: { redeem: vi.fn() },
        },
      ],
    }).compile();

    controller = module.get<UsersController>(UsersController);
    service = module.get<UsersService>(UsersService);
    accessService = module.get<AccessService>(AccessService);
    module_invites = () => module.get(InvitesService) as never;
  });

  afterEach(() => {
    vi.resetAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('invite-only registration', () => {
    const body = {
      id: 'u9',
      name: 'New',
      email: 'new@example.com',
      photoUrl: '',
    } as unknown as CreateUserDto;

    afterEach(() => {
      delete process.env.REGISTRATION_INVITE_ONLY;
    });

    it('redeems the code before creating the account', async () => {
      process.env.REGISTRATION_INVITE_ONLY = 'true';
      const invites = module_invites();
      const created = { id: 'u9' } as User;
      mockUsersService.create.mockResolvedValue(created);

      const result = await controller.create(
        { ...body, inviteCode: 'abc' } as CreateUserDto,
        'u9',
      );

      expect(invites.redeem).toHaveBeenCalledWith('abc', 'u9');
      expect(mockUsersService.create).toHaveBeenCalled();
      expect(result).toBe(created);
    });

    it('refuses registration without a code', async () => {
      process.env.REGISTRATION_INVITE_ONLY = 'true';
      await expect(controller.create(body, 'u9')).rejects.toThrow(
        ForbiddenException,
      );
      expect(mockUsersService.create).not.toHaveBeenCalled();
    });

    it('ignores codes when registration is open', async () => {
      mockUsersService.create.mockResolvedValue({ id: 'u9' });
      await controller.create(body, 'u9');
      expect(module_invites().redeem).not.toHaveBeenCalled();
    });
  });

  describe('create', () => {
    it('should create a user when acting as itself', async () => {
      const createDto: CreateUserDto = {
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        photoUrl: 'https://example.com/photo.jpg',
      };
      const result: User = {
        ...createDto,
        photoUrl: createDto.photoUrl!,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      mockUsersService.create.mockResolvedValue(result);

      expect(await controller.create(createDto, '1')).toBe(result);
      expect(accessService.assertSelf).toHaveBeenCalledWith('1', '1');
      expect(service.create).toHaveBeenCalledWith(createDto);
    });

    it('should not allow a user to register another user', async () => {
      const createDto: CreateUserDto = {
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        photoUrl: 'https://example.com/photo.jpg',
      };
      mockAccessService.assertSelf.mockImplementation(() => {
        throw new ForbiddenException('Access denied');
      });

      await expect(controller.create(createDto, '2')).rejects.toThrow(
        ForbiddenException,
      );
      expect(service.create).not.toHaveBeenCalled();
    });
  });

  describe('findAll', () => {
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
    it('a user can update itself', async () => {
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

      expect(await controller.update('1', updateDto, '1')).toBe(result);
      expect(accessService.assertSelf).toHaveBeenCalledWith('1', '1');
      expect(service.update).toHaveBeenCalledWith('1', updateDto);
    });

    it('a student cannot update another user', async () => {
      const updateDto: UpdateUserDto = { name: 'Updated Name' };
      mockAccessService.assertSelf.mockImplementation(() => {
        throw new ForbiddenException('Access denied');
      });

      expect(() => controller.update('1', updateDto, '2')).toThrow(
        ForbiddenException,
      );
      expect(service.update).not.toHaveBeenCalled();
    });
  });

  describe('remove', () => {
    it('a user can remove itself', async () => {
      const result: User = {
        id: '1',
        name: 'User 1',
        email: 'user1@example.com',
        photoUrl: '',
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      mockUsersService.remove.mockResolvedValue(result);

      expect(await controller.remove('1', '1')).toBe(result);
      expect(accessService.assertSelf).toHaveBeenCalledWith('1', '1');
      expect(service.remove).toHaveBeenCalledWith('1');
    });

    it('a student cannot remove another user', async () => {
      mockAccessService.assertSelf.mockImplementation(() => {
        throw new ForbiddenException('Access denied');
      });

      expect(() => controller.remove('1', '2')).toThrow(ForbiddenException);
      expect(service.remove).not.toHaveBeenCalled();
    });
  });
});
