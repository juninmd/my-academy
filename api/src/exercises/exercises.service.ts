import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { CACHE_MANAGER, Cache } from '@nestjs/cache-manager';
import { CreateExerciseDto } from './dto/create-exercise.dto.js';
import { UpdateExerciseDto } from './dto/update-exercise.dto.js';
import { PrismaService } from '../prisma.service.js';
import { Exercise } from './entities/exercise.entity.js';

export const EXERCISES_CACHE_KEY = '/api/exercises';

@Injectable()
export class ExercisesService {
  constructor(
    private readonly prismaService: PrismaService,
    @Inject(CACHE_MANAGER) private readonly cache: Cache,
  ) {}

  async create(createExerciseDto: CreateExerciseDto): Promise<Exercise> {
    const { name, image, tips, mistakes, type } = createExerciseDto;

    const result = await this.prismaService.exercises.create({
      data: {
        name,
        image,
        tips,
        mistakes,
        type,
      },
    });
    await this.cache.del(EXERCISES_CACHE_KEY);
    return result;
  }

  async findAll(): Promise<Exercise[]> {
    return this.prismaService.exercises.findMany();
  }

  async findOne(id: number): Promise<Exercise> {
    const exercise = await this.prismaService.exercises.findUnique({
      where: { id },
    });

    if (!exercise) {
      throw new NotFoundException(`Exercise #${id} not found`);
    }

    return exercise;
  }

  async update(id: number, updateDto: UpdateExerciseDto): Promise<Exercise> {
    await this.findOne(id);

    const { name, image, tips, mistakes, type } = updateDto;

    const result = await this.prismaService.exercises.update({
      where: { id },
      data: {
        name,
        image,
        tips,
        mistakes,
        type,
      },
    });
    await this.cache.del(EXERCISES_CACHE_KEY);
    return result;
  }

  async remove(id: number): Promise<Exercise> {
    await this.findOne(id);

    const result = await this.prismaService.exercises.delete({ where: { id } });
    await this.cache.del(EXERCISES_CACHE_KEY);
    return result;
  }
}
