import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service.js';
import { CreateExerciseLogDto } from './dto/create-exercise-log.dto.js';

@Injectable()
export class ExerciseLogsService {
  constructor(private prisma: PrismaService) {}

  async create(createExerciseLogDto: CreateExerciseLogDto) {
    const { sets, ...data } = createExerciseLogDto;
    return this.prisma.exerciseLog.create({
      data: {
        ...data,
        sets: {
          create: sets,
        },
      },
      include: {
        sets: true,
      },
    });
  }

  async findAll(userId: string, exerciseId?: number) {
    return this.prisma.exerciseLog.findMany({
      where: {
        userId,
        ...(exerciseId ? { exerciseId } : {}),
      },
      include: {
        sets: true,
      },
      orderBy: {
        date: 'desc',
      },
      take: 200,
    });
  }
}
