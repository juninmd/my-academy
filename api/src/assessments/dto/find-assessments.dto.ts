import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class FindAssessmentsDto {
  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  studentId?: string;
}
