import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service.js';

const MAX_ENTRIES = 5000;

@Injectable()
export class BodyWeightService {
  constructor(private prisma: PrismaService) {}

  async list(userId: string) {
    return this.prisma.bodyWeightEntry.findMany({
      where: { userId },
      orderBy: { date: 'asc' },
      take: MAX_ENTRIES,
    });
  }

  /** One reading per day: a second weigh-in the same day replaces the first. */
  async upsert(userId: string, date: Date, weight: number) {
    return this.prisma.bodyWeightEntry.upsert({
      where: { userId_date: { userId, date } },
      update: { weight },
      create: { userId, date, weight },
    });
  }

  async remove(userId: string, id: number) {
    const { count } = await this.prisma.bodyWeightEntry.deleteMany({
      where: { id, userId },
    });
    if (count === 0) throw new NotFoundException(`Weigh-in #${id} not found`);
    return { id, removed: true };
  }
}
