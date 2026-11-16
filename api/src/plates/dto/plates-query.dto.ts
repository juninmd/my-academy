import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import {
  IsArray,
  IsNumber,
  IsOptional,
  IsPositive,
  Min,
} from 'class-validator';

export class PlatesQueryDto {
  @ApiProperty({ description: 'Total weight to load (kg)' })
  @Type(() => Number)
  @IsNumber()
  @IsPositive()
  target: number;

  @ApiPropertyOptional({ default: 20, description: 'Bar weight (kg)' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  bar?: number;

  @ApiPropertyOptional({
    description: 'Comma-separated plate sizes you own, e.g. 20,10,5,2.5',
  })
  @IsOptional()
  @Transform(({ value }: { value: unknown }) =>
    String(value).split(',').map(Number),
  )
  @IsArray()
  @IsPositive({ each: true })
  plates?: number[];
}
