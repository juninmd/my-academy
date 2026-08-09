import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsInt, IsOptional, IsString } from 'class-validator';

export class WorkoutSessionSetItemDto {
  @ApiProperty()
  @IsInt()
  reps: number;

  @ApiProperty()
  @IsInt()
  weight: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  rpe?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  type?: string;
}
