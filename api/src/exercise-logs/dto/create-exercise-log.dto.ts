import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDateString,
  IsIn,
  IsInt,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  ValidateNested,
} from 'class-validator';

/** normal, warmup, dropset, failure and restpause (rest-pause: short rests inside one set). */
export const SET_TYPES = [
  'normal',
  'warmup',
  'dropset',
  'failure',
  'restpause',
] as const;

export class CreateSetLogDto {
  @ApiProperty()
  @IsInt()
  reps: number;

  @ApiProperty()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  weight: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsInt()
  rpe?: number;

  @ApiProperty({ required: false, enum: SET_TYPES })
  @IsOptional()
  @IsIn(SET_TYPES)
  type?: (typeof SET_TYPES)[number];
}

export class CreateExerciseLogDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  userId: string;

  @ApiProperty()
  @IsInt()
  exerciseId: number;

  @ApiProperty()
  @IsDateString()
  date: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiProperty({ type: [CreateSetLogDto] })
  @ValidateNested({ each: true })
  @Type(() => CreateSetLogDto)
  sets: CreateSetLogDto[];
}
