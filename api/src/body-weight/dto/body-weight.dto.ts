import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDateString,
  IsNotEmpty,
  IsNumber,
  IsPositive,
  IsString,
  Max,
} from 'class-validator';

export class BodyWeightUserDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  userId: string;
}

export class CreateBodyWeightDto extends BodyWeightUserDto {
  @ApiProperty({
    example: '2026-10-31',
    description: 'Calendar day of the weigh-in',
  })
  @IsDateString()
  date: string;

  @ApiProperty({ example: 80.4, description: 'Body weight in kilograms' })
  @Type(() => Number)
  @IsNumber()
  @IsPositive()
  @Max(650)
  weight: number;
}
