import { PartialType } from '@nestjs/swagger';
import { CreateWorkoutsSeriesDto } from './create-workouts-series.dto.js';

export class UpdateWorkoutsSeriesDto extends PartialType(
  CreateWorkoutsSeriesDto,
) {}
