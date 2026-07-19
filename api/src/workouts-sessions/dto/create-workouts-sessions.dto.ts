import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsOptional, IsNumber, IsDate, IsArray } from 'class-validator';

export class CreateWorkoutsSessionsDto {
  @ApiProperty({})
  @IsOptional()
  @IsNumber()
  readonly id?: number;

  @ApiProperty({ required: true, description: 'Treino' })
  @IsNumber()
  readonly workoutGroupId: number;

  @ApiProperty({
    type: Date,
    default: new Date(),
  })
  @IsDate()
  @Type(() => Date)
  readonly date: Date;

  @IsArray()
  @IsOptional()
  readonly Workouts?: any[];
}
