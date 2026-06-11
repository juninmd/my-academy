import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsOptional,
  IsString,
  IsNumberString,
} from 'class-validator';

export class FindExerciseLogsDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  userId: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumberString()
  exerciseId?: string;
}