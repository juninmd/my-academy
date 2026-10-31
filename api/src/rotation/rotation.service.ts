import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service.js';
import { nextInRotation } from './rotation.js';

@Injectable()
export class RotationService {
  constructor(private prisma: PrismaService) {}

  /** The routine to do next, following the order the user created them in. */
  async next(userId: string) {
    const [groups, last] = await Promise.all([
      this.prisma.workoutsGroups.findMany({
        where: { userId },
        select: { id: true, name: true },
        orderBy: { id: 'asc' },
      }),
      this.prisma.workoutSessions.findFirst({
        where: { workoutsGroups: { userId } },
        select: { workoutGroupId: true, date: true },
        orderBy: [{ date: 'desc' }, { id: 'desc' }],
      }),
    ]);

    const nextId = nextInRotation(
      groups.map((g) => g.id),
      last?.workoutGroupId ?? null,
    );
    return {
      group: groups.find((g) => g.id === nextId) ?? null,
      lastSession: last
        ? { groupId: last.workoutGroupId, date: last.date }
        : null,
    };
  }
}
