import { ForbiddenException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { Role } from '@prisma/client';
import { InvitesController } from './invites.controller.js';
import { InvitesService } from './invites.service.js';
import { AccessService } from '../access/access.service.js';

describe('InvitesController', () => {
  let controller: InvitesController;
  const service = {
    create: vi.fn().mockResolvedValue({ code: 'x' }),
    list: vi.fn().mockResolvedValue(['list']),
  };
  const access = { assertRole: vi.fn() };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [InvitesController],
      providers: [
        { provide: InvitesService, useValue: service },
        { provide: AccessService, useValue: access },
      ],
    }).compile();
    controller = module.get(InvitesController);
  });

  afterEach(() => vi.clearAllMocks());

  it('lets an admin create an invite', async () => {
    expect(await controller.create({ validityDays: 5 }, 'admin1')).toEqual({
      code: 'x',
    });
    expect(access.assertRole).toHaveBeenCalledWith('admin1', Role.ADMIN);
    expect(service.create).toHaveBeenCalledWith('admin1', 5);
  });

  it('needs a signed-in actor to create an invite', async () => {
    await expect(controller.create({}, undefined)).rejects.toThrow(
      ForbiddenException,
    );
    expect(service.create).not.toHaveBeenCalled();
  });

  it('lists invites for an admin', async () => {
    expect(await controller.list('admin1')).toEqual(['list']);
    expect(access.assertRole).toHaveBeenCalledWith('admin1', Role.ADMIN);
  });
});
