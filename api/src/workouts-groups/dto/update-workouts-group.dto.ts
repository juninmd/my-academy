import { PartialType } from '@nestjs/swagger';
import { CreateWorkoutsGroupDto } from './create-workouts-group.dto.js';

export class UpdateWorkoutsGroupDto extends PartialType(
  CreateWorkoutsGroupDto,
) {}
