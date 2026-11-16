import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service.js';
import { STARTER_PLANS } from './starter-plans.data.js';

@Injectable()
export class StarterPlansService {
  constructor(private prisma: PrismaService) {}

  list() {
    return STARTER_PLANS.map(({ key, name, description, days }) => ({
      key,
      name,
      description,
      days: days.map((day) => day.name),
    }));
  }

  /** Copies a template into ordinary, editable workout groups for the user. */
  async apply(key: string, userId: string) {
    const plan = STARTER_PLANS.find((p) => p.key === key);
    if (!plan) throw new NotFoundException(`Starter plan "${key}" not found`);

    const created: string[] = [];
    const skipped: string[] = [];
    const missing: string[] = [];

    for (const day of plan.days) {
      const name = `${plan.name} - ${day.name}`;
      const existing = await this.prisma.workoutsGroups.findFirst({
        where: { userId, name },
        select: { id: true },
      });
      if (existing) {
        skipped.push(name);
        continue;
      }

      const workouts: {
        exerciseId: number;
        description: string;
        workoutSeries: { create: object[] };
      }[] = [];
      for (const slot of day.slots) {
        const exercise = await this.findExercise(slot.terms);
        if (!exercise) {
          missing.push(slot.terms[0]);
          continue;
        }
        if (workouts.some((w) => w.exerciseId === exercise.id)) continue;
        workouts.push({
          exerciseId: exercise.id,
          description: '',
          workoutSeries: {
            create: Array.from({ length: slot.sets }, () => ({
              repetitions: slot.reps,
              rest: slot.rest,
            })),
          },
        });
      }

      await this.prisma.workoutsGroups.create({
        data: { name, userId, workouts: { create: workouts } },
      });
      created.push(name);
    }

    return { plan: plan.key, created, skipped, missingExercises: missing };
  }

  private async findExercise(terms: string[]) {
    return this.prisma.exercises.findFirst({
      where: {
        OR: terms.map((term) => ({
          name: { contains: term, mode: 'insensitive' as const },
        })),
      },
      select: { id: true },
      orderBy: { id: 'asc' },
    });
  }
}
