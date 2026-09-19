import { Module } from '@nestjs/common';
import { ExerciseLogsService } from './exercise-logs.service.js';
import { ExerciseLogsController } from './exercise-logs.controller.js';

@Module({
  controllers: [ExerciseLogsController],
  providers: [ExerciseLogsService],
})
export class ExerciseLogsModule {}
