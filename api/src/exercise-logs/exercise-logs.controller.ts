import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { CreateExerciseLogDto } from './dto/create-exercise-log.dto';
import { ExerciseLogsService } from './exercise-logs.service';
import { FindExerciseLogsDto } from './dto/find-exercise-logs.dto';

@ApiTags('Exercise Logs')
@Controller('exercise-logs')
export class ExerciseLogsController {
  constructor(private readonly exerciseLogsService: ExerciseLogsService) {}

  @Post()
  create(@Body() createExerciseLogDto: CreateExerciseLogDto) {
    return this.exerciseLogsService.create(createExerciseLogDto);
  }

  @Get()
  findAll(@Query() query: FindExerciseLogsDto) {
    return this.exerciseLogsService.findAll(
      query.userId,
      query.exerciseId ? +query.exerciseId : undefined,
    );
  }
}
