import { OmitType } from '@nestjs/swagger';
import { CreateWorkoutDto } from './create-workout.dto.js';

export class CreateWorkoutNestedDto extends OmitType(CreateWorkoutDto, [
  'workoutsGroupsId',
] as const) {}
