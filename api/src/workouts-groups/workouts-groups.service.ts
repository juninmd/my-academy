import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { CreateWorkoutsGroupDto } from './dto/create-workouts-group.dto.js';
import { UpdateWorkoutsGroupDto } from './dto/update-workouts-group.dto.js';
import { PrismaService } from '../prisma.service.js';
import { WorkoutsGroup } from './entities/workouts-group.entity.js';
import { CreateWorkoutNestedDto } from '../workouts/dto/create-workout-nested.dto.js';

@Injectable()
export class WorkoutsGroupsService {
  constructor(private readonly prismaService: PrismaService) {}

  async create(data: CreateWorkoutsGroupDto): Promise<WorkoutsGroup> {
    const { name, image, userId, workouts } = data;
    try {
      return await this.prismaService.workoutsGroups.create({
        data: {
          name,
          image,
          userId,
          workouts: {
            create: this.mapWorkoutsCreate(workouts),
          },
        },
        include: {
          workouts: {
            include: {
              workoutSeries: true,
              exercise: true,
            },
          },
        },
      });
    } catch (error) {
      throw this.mapUniqueConstraintError(error);
    }
  }

  async findAll(userId: string): Promise<WorkoutsGroup[]> {
    return this.prismaService.workoutsGroups.findMany({
      where: { userId },
      include: {
        workouts: {
          include: {
            workoutSeries: true,
            exercise: true,
          },
        },
      },
    });
  }

  async findAllExercises(id: number): Promise<WorkoutsGroup> {
    return this.findOne(id);
  }

  async findOne(id: number): Promise<WorkoutsGroup> {
    const group = await this.prismaService.workoutsGroups.findUnique({
      where: { id },
      include: {
        workouts: {
          include: {
            workoutSeries: true,
            exercise: true,
            method: true,
          },
        },
      },
    });
    if (!group) {
      throw new NotFoundException(`WorkoutsGroup #${id} not found`);
    }
    return group;
  }

  async update(
    id: number,
    data: UpdateWorkoutsGroupDto,
  ): Promise<WorkoutsGroup> {
    const existing = await this.findOne(id);

    const { name, image, userId, workouts } = data;

    if (userId !== undefined && userId !== existing.userId) {
      throw new BadRequestException(
        'Não é possível mover o treino para outro usuário',
      );
    }

    try {
      return await this.prismaService.$transaction(async (tx) => {
        // Delete existing workouts
        await tx.workouts.deleteMany({
          where: { workoutsGroupsId: id },
        });

        return tx.workoutsGroups.update({
          where: { id },
          data: {
            name,
            image,
            userId,
            workouts: {
              create: this.mapWorkoutsCreate(workouts),
            },
          },
          include: {
            workouts: {
              include: {
                workoutSeries: true,
                exercise: true,
              },
            },
          },
        });
      });
    } catch (error) {
      throw this.mapUniqueConstraintError(error);
    }
  }

  async remove(id: number): Promise<WorkoutsGroup> {
    await this.findOne(id);
    return this.prismaService.workoutsGroups.delete({
      where: { id },
      include: { workoutSessions: true },
    });
  }

  private mapWorkoutsCreate(workouts?: CreateWorkoutNestedDto[]) {
    if (!workouts) return [];
    return workouts.map((workout) => ({
      exerciseId: workout.exerciseId,
      description: workout.description || '',
      methodId: workout.methodId,
      workoutSeries: {
        create: workout.workoutSeries?.map((series) => ({
          repetitions: series.repetitions,
          weight: series.weight,
          rest: series.rest,
          time: series.time,
          distance: series.distance,
          speed: series.speed,
        })),
      },
    }));
  }

  private mapUniqueConstraintError(error: unknown): unknown {
    if (
      error instanceof Prisma.PrismaClientKnownRequestError &&
      error.code === 'P2002'
    ) {
      if (uniqueConstraintOf(error).includes('exerciseId')) {
        return new ConflictException('Exercício duplicado no treino');
      }
      return new ConflictException('Já existe um treino com esse nome');
    }
    return error;
  }
}

/** Driver adapters report the violated index instead of `meta.target`. */
export function uniqueConstraintOf(
  error: Prisma.PrismaClientKnownRequestError,
): string {
  const meta = error.meta as
    | {
        target?: string | string[];
        driverAdapterError?: { cause?: { constraint?: { index?: string } } };
      }
    | undefined;
  const target =
    meta?.target ?? meta?.driverAdapterError?.cause?.constraint?.index;
  return Array.isArray(target) ? target.join(',') : (target ?? '');
}
