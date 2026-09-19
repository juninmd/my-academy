import { Module } from '@nestjs/common';
import { WorkoutsSeriesService } from './workouts-series.service.js';
import { WorkoutsSeriesController } from './workouts-series.controller.js';

@Module({
  controllers: [WorkoutsSeriesController],
  providers: [WorkoutsSeriesService],
})
export class WorkoutsSeriesModule {}
