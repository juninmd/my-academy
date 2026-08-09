import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsOptional,
  IsNumber,
  IsDate,
  IsArray,
  ValidateNested,
} from 'class-validator';
import { WorkoutSessionItemDto } from './workout-session-item.dto';

export class CreateWorkoutsSessionsDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  readonly id?: number;

  @ApiProperty({ required: true, description: 'Treino' })
  @IsNumber()
  readonly workoutGroupId: number;

  @ApiProperty({
    type: Date,
    default: new Date(),
  })
  @IsDate()
  @Type(() => Date)
  readonly date: Date;

  @ApiPropertyOptional({ type: [WorkoutSessionItemDto] })
  @IsArray()
  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => WorkoutSessionItemDto)
  readonly workouts?: WorkoutSessionItemDto[];
}
