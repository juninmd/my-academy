import { IsOptional, IsString } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class FindAssessmentDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  studentId?: string;
}
