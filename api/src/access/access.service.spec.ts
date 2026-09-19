import { ForbiddenException, NotFoundException } from '@nestjs/common';
import { Role } from '@prisma/client';
import { AccessService } from './access.service.js';

describe('AccessService', () => {
  const prisma = {
    personals: { findFirst: vi.fn() },
    workoutsGroups: { findUnique: vi.fn() },
    gym: { findUnique: vi.fn() },
    users: { findUnique: vi.fn() },
  };
  const access = new AccessService(prisma as any);

  afterEach(() => vi.clearAllMocks());

  describe('assertCanActFor', () => {
    it('lets users act on their own data without hitting the database', async () => {
      await access.assertCanActFor('u1', 'u1');
      expect(prisma.personals.findFirst).not.toHaveBeenCalled();
    });

    it('skips checks when authentication is disabled', async () => {
      await expect(
        access.assertCanActFor(undefined, 'u1'),
      ).resolves.toBeUndefined();
    });

    it('lets a personal act for a contracted student', async () => {
      prisma.personals.findFirst.mockResolvedValue({ id: 1 });
      await access.assertCanActFor('p1', 's1');
      expect(prisma.personals.findFirst).toHaveBeenCalledWith({
        where: { personalUserId: 'p1', studentUserId: 's1' },
        select: { id: true },
      });
    });

    it('blocks anyone else (IDOR)', async () => {
      prisma.personals.findFirst.mockResolvedValue(null);
      await expect(access.assertCanActFor('intruder', 's1')).rejects.toThrow(
        ForbiddenException,
      );
    });
  });

  describe('assertSelf', () => {
    it('allows self and disabled auth, blocks others', () => {
      expect(() => access.assertSelf('u1', 'u1')).not.toThrow();
      expect(() => access.assertSelf(undefined, 'u1')).not.toThrow();
      expect(() => access.assertSelf('u2', 'u1')).toThrow(ForbiddenException);
    });
  });

  describe('assertCanAccessGroup', () => {
    it('skips lookup when auth is disabled', async () => {
      await access.assertCanAccessGroup(undefined, 1);
      expect(prisma.workoutsGroups.findUnique).not.toHaveBeenCalled();
    });

    it('404s for a missing group', async () => {
      prisma.workoutsGroups.findUnique.mockResolvedValue(null);
      await expect(access.assertCanAccessGroup('u1', 9)).rejects.toThrow(
        NotFoundException,
      );
    });

    it('delegates to the group owner check', async () => {
      prisma.workoutsGroups.findUnique.mockResolvedValue({ userId: 'u2' });
      prisma.personals.findFirst.mockResolvedValue(null);
      await expect(access.assertCanAccessGroup('u1', 1)).rejects.toThrow(
        ForbiddenException,
      );
      await expect(
        access.assertCanAccessGroup('u2', 1),
      ).resolves.toBeUndefined();
    });
  });

  describe('assertGymOwner', () => {
    it('404s for a missing gym', async () => {
      prisma.gym.findUnique.mockResolvedValue(null);
      await expect(access.assertGymOwner('o1', 1)).rejects.toThrow(
        NotFoundException,
      );
    });

    it('only lets the owner manage the gym', async () => {
      prisma.gym.findUnique.mockResolvedValue({ ownerId: 'o1' });
      await expect(access.assertGymOwner('o1', 1)).resolves.toBeUndefined();
      await expect(
        access.assertGymOwner(undefined, 1),
      ).resolves.toBeUndefined();
      await expect(access.assertGymOwner('o2', 1)).rejects.toThrow(
        ForbiddenException,
      );
    });
  });

  describe('assertRole', () => {
    it('checks the stored role of the actor', async () => {
      prisma.users.findUnique.mockResolvedValueOnce({ role: Role.ADMIN });
      await expect(access.assertRole('a', Role.ADMIN)).resolves.toBeUndefined();
      prisma.users.findUnique.mockResolvedValueOnce(null);
      await expect(access.assertRole('ghost', Role.ADMIN)).rejects.toThrow(
        ForbiddenException,
      );
      await expect(
        access.assertRole(undefined, Role.ADMIN),
      ).resolves.toBeUndefined();
    });
  });
});
