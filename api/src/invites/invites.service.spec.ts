import type { Mock } from 'vitest';
import { ForbiddenException } from '@nestjs/common';
import { InvitesService } from './invites.service.js';

describe('InvitesService', () => {
  const prisma = {
    invite: {
      create: vi.fn() as Mock,
      findMany: vi.fn() as Mock,
      updateMany: vi.fn() as Mock,
    },
  };
  const service = new InvitesService(prisma as never);

  beforeEach(() => vi.clearAllMocks());

  it('creates a random code that expires after the validity', async () => {
    prisma.invite.create.mockImplementation(async ({ data, select }) => ({
      code: data.code,
      expiresAt: data.expiresAt,
      select,
    }));
    const before = Date.now();

    const result = await service.create('admin1', 3);

    expect(result.code).toMatch(/^[0-9a-f]{12}$/);
    expect(prisma.invite.create.mock.calls[0][0].data.createdById).toBe(
      'admin1',
    );
    const days = (result.expiresAt.getTime() - before) / (24 * 60 * 60 * 1000);
    expect(days).toBeGreaterThan(2.99);
    expect(days).toBeLessThanOrEqual(3.01);
  });

  it('defaults to seven days', async () => {
    prisma.invite.create.mockImplementation(async ({ data }) => data);
    const data = await service.create('admin1');
    const days =
      (data.expiresAt.getTime() - Date.now()) / (24 * 60 * 60 * 1000);
    expect(days).toBeGreaterThan(6.99);
    expect(days).toBeLessThanOrEqual(7.01);
  });

  it('lists the latest invites', async () => {
    prisma.invite.findMany.mockResolvedValue([{ code: 'a' }]);
    expect(await service.list()).toEqual([{ code: 'a' }]);
    expect(prisma.invite.findMany.mock.calls[0][0]).toMatchObject({
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
  });

  it('redeems a valid code for one user', async () => {
    prisma.invite.updateMany.mockResolvedValue({ count: 1 });
    await service.redeem('ABC', 'u1');
    const { where, data } = prisma.invite.updateMany.mock.calls[0][0];
    expect(where).toMatchObject({ code: 'ABC', usedAt: null });
    expect(where.expiresAt.gt).toBeInstanceOf(Date);
    expect(data.usedById).toBe('u1');
  });

  it('refuses a code that is unknown, used or expired', async () => {
    prisma.invite.updateMany.mockResolvedValue({ count: 0 });
    await expect(service.redeem('nope', 'u1')).rejects.toThrow(
      ForbiddenException,
    );
  });
});
