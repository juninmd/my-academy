import { ApiProperty } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';

export class CreateAssessmentDto {
  @ApiProperty({ example: 'student-id' })
  @IsString()
  @IsNotEmpty()
  studentId: string;

  @ApiProperty({ example: 'personal-id' })
  @IsString()
  @IsNotEmpty()
  personalId: string;

  @ApiProperty({ example: 80.5 })
  @IsNumber()
  @Min(0)
  weight: number;

  @ApiProperty({ example: 1.8 })
  @IsNumber()
  @Min(0)
  height: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsNumber()
  imc?: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsNumber()
  fatPercentage?: number;

  @IsOptional()
  @IsNumber()
  triceps?: number;

  @IsOptional()
  @IsNumber()
  biceps?: number;

  @IsOptional()
  @IsNumber()
  subscapular?: number;

  @IsOptional()
  @IsNumber()
  iliacCrest?: number;

  @IsOptional()
  @IsNumber()
  supraspinale?: number;

  @IsOptional()
  @IsNumber()
  abdominal?: number;

  @IsOptional()
  @IsNumber()
  thigh?: number;

  @IsOptional()
  @IsNumber()
  calf?: number;

  @IsOptional()
  @IsNumber()
  waist?: number;

  @IsOptional()
  @IsNumber()
  hip?: number;

  @IsOptional()
  @IsNumber()
  arm?: number;

  @IsOptional()
  @IsNumber()
  leg?: number;
}
