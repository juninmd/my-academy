import { ApiProperty } from '@nestjs/swagger';
import { CreateWorkoutNestedDto } from '../../workouts/dto/create-workout-nested.dto.js';
import {
  IsNotEmpty,
  IsString,
  IsArray,
  ValidateNested,
  IsOptional,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CreateWorkoutsGroupDto {
  @ApiProperty({ required: true, description: 'Treino' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  image?: string;

  @ApiProperty({ required: true })
  @IsString()
  @IsNotEmpty()
  userId: string;

  @ApiProperty({ required: false, type: [CreateWorkoutNestedDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateWorkoutNestedDto)
  workouts?: CreateWorkoutNestedDto[];
}
