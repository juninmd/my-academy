import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsArray,
  IsInt,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { WorkoutSessionSetItemDto } from './workout-session-set-item.dto';

export class WorkoutSessionItemDto {
  @ApiProperty()
  @IsInt()
  exerciseId: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({ type: [WorkoutSessionSetItemDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => WorkoutSessionSetItemDto)
  sets?: WorkoutSessionSetItemDto[];
}
