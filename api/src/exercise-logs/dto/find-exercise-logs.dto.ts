import {
  IsNotEmpty,
  IsOptional,
  IsString,
  IsNumberString,
} from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class FindExerciseLogsDto {
  @IsNotEmpty()
  @IsString()
  userId: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumberString()
  exerciseId?: string;
}
