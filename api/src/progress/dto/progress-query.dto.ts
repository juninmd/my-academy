import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsIn,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsPositive,
  IsString,
  Max,
  Min,
} from 'class-validator';

export class ProgressQueryDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  userId: string;
}

export class SummaryQueryDto extends ProgressQueryDto {
  @ApiPropertyOptional({ default: 90, minimum: 1, maximum: 365 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(365)
  days?: number;
}

export class SuggestionQueryDto extends ProgressQueryDto {
  @ApiPropertyOptional({
    enum: ['linear', 'double', 'triple'],
    default: 'double',
  })
  @IsOptional()
  @IsIn(['linear', 'double', 'triple'])
  strategy?: 'linear' | 'double' | 'triple';

  @ApiPropertyOptional({ default: 2.5 })
  @IsOptional()
  @Type(() => Number)
  @IsPositive()
  increment?: number;

  @ApiPropertyOptional({ default: 8 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  minReps?: number;

  @ApiPropertyOptional({ default: 12 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  maxReps?: number;

  @ApiPropertyOptional({
    default: 5,
    description: 'Triple progression: sets cap',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(10)
  maxSets?: number;
}
