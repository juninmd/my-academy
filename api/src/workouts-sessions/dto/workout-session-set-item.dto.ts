import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsInt, IsNumber, IsOptional, IsString, Min } from 'class-validator';

export class WorkoutSessionSetItemDto {
  @ApiProperty()
  @IsInt()
  reps: number;

  @ApiProperty()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
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
