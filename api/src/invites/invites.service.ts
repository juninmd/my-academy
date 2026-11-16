import { ForbiddenException, Injectable } from '@nestjs/common';
import { randomBytes } from 'node:crypto';
import { PrismaService } from '../prisma.service.js';

const DAY_MS = 24 * 60 * 60 * 1000;
const DEFAULT_VALIDITY_DAYS = 7;
const LIST_LIMIT = 50;

@Injectable()
export class InvitesService {
  constructor(private prisma: PrismaService) {}

  async create(createdById: string, validityDays = DEFAULT_VALIDITY_DAYS) {
    return this.prisma.invite.create({
      data: {
        code: randomBytes(6).toString('hex'),
        createdById,
        expiresAt: new Date(Date.now() + validityDays * DAY_MS),
      },
      select: { code: true, expiresAt: true },
    });
  }

  async list() {
    return this.prisma.invite.findMany({
      orderBy: { createdAt: 'desc' },
      take: LIST_LIMIT,
      select: {
        id: true,
        code: true,
        createdAt: true,
        expiresAt: true,
        usedAt: true,
        usedById: true,
      },
    });
  }

  /**
   * Marks the code as used by `userId`. The update only matches an unused, unexpired code,
   * so two sign-ups with the same code cannot both succeed.
   */
  async redeem(code: string, userId: string): Promise<void> {
    const { count } = await this.prisma.invite.updateMany({
      where: { code, usedAt: null, expiresAt: { gt: new Date() } },
      data: { usedAt: new Date(), usedById: userId },
    });
    if (count === 0) {
      throw new ForbiddenException('Invite code is invalid, used or expired');
    }
  }
}
