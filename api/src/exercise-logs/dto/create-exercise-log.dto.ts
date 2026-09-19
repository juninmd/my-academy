import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDateString,
  IsInt,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  ValidateNested,
} from 'class-validator';

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

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  type?: string;
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
