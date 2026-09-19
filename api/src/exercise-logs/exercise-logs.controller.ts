import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { CreateExerciseLogDto } from './dto/create-exercise-log.dto.js';
import { FindExerciseLogsDto } from './dto/find-exercise-logs.dto.js';
import { ExerciseLogsService } from './exercise-logs.service.js';
import { AccessService } from '../access/access.service.js';
import { CurrentUserId } from '../access/current-user.decorator.js';

@ApiTags('Exercise Logs')
@Controller('exercise-logs')
export class ExerciseLogsController {
  constructor(
    private readonly exerciseLogsService: ExerciseLogsService,
    private readonly accessService: AccessService,
  ) {}

  @Post()
  async create(
    @Body() createExerciseLogDto: CreateExerciseLogDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(
      actor,
      createExerciseLogDto.userId,
    );
    return this.exerciseLogsService.create(createExerciseLogDto);
  }

  @Get()
  async findAll(
    @Query() query: FindExerciseLogsDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, query.userId);
    return this.exerciseLogsService.findAll(
      query.userId,
      query.exerciseId ? +query.exerciseId : undefined,
    );
  }
}
