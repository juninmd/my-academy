import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Role } from '@prisma/client';
import { PrismaService } from '../prisma.service.js';

type Actor = string | undefined;

@Injectable()
export class AccessService {
  constructor(private readonly prisma: PrismaService) {}

  /** Actor is the user, or a personal trainer with a contract with that user. */
  async assertCanActFor(actor: Actor, userId: string): Promise<void> {
    if (actor === undefined || actor === userId) return;
    const contract = await this.prisma.personals.findFirst({
      where: { personalUserId: actor, studentUserId: userId },
      select: { id: true },
    });
    if (!contract) throw new ForbiddenException('Access denied');
  }

  assertSelf(actor: Actor, userId: string): void {
    if (actor !== undefined && actor !== userId) {
      throw new ForbiddenException('Access denied');
    }
  }

  async assertCanAccessGroup(actor: Actor, groupId: number): Promise<void> {
    if (actor === undefined) return;
    const group = await this.prisma.workoutsGroups.findUnique({
      where: { id: groupId },
      select: { userId: true },
    });
    if (!group)
      throw new NotFoundException(`Workout group #${groupId} not found`);
    await this.assertCanActFor(actor, group.userId);
  }

  async assertGymOwner(actor: Actor, gymId: number): Promise<void> {
    const gym = await this.prisma.gym.findUnique({
      where: { id: gymId },
      select: { ownerId: true },
    });
    if (!gym) throw new NotFoundException(`Gym #${gymId} not found`);
    if (actor !== undefined && gym.ownerId !== actor) {
      throw new ForbiddenException('Only the gym owner can do this');
    }
  }

  async assertRole(actor: Actor, ...roles: Role[]): Promise<void> {
    if (actor === undefined) return;
    const user = await this.prisma.users.findUnique({
      where: { id: actor },
      select: { role: true },
    });
    if (!user || !roles.includes(user.role)) {
      throw new ForbiddenException('Access denied');
    }
  }
}
