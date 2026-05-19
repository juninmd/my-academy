import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, IsNumberString } from 'class-validator';

export class FindExerciseLogsQueryDto {
  @IsString()
  userId: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumberString()
  exerciseId?: string;
}
