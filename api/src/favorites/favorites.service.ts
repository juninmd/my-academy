import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service.js';

@Injectable()
export class FavoritesService {
  constructor(private prisma: PrismaService) {}

  async list(userId: string) {
    const favorites = await this.prisma.exerciseFavorite.findMany({
      where: { userId },
      include: {
        exercise: {
          select: {
            id: true,
            name: true,
            image: true,
            type: true,
            muscles: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
    return favorites.map((f) => f.exercise);
  }

  /** Idempotent: favouriting twice keeps one row. */
  async add(userId: string, exerciseId: number) {
    const exercise = await this.prisma.exercises.findUnique({
      where: { id: exerciseId },
      select: { id: true },
    });
    if (!exercise)
      throw new NotFoundException(`Exercise #${exerciseId} not found`);
    await this.prisma.exerciseFavorite.upsert({
      where: { userId_exerciseId: { userId, exerciseId } },
      update: {},
      create: { userId, exerciseId },
    });
    return { exerciseId, favorite: true };
  }

  async remove(userId: string, exerciseId: number) {
    const { count } = await this.prisma.exerciseFavorite.deleteMany({
      where: { userId, exerciseId },
    });
    return { exerciseId, favorite: false, removed: count };
  }
}
