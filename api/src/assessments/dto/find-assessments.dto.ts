import { IsOptional, IsString } from 'class-validator';

export class FindAssessmentsDto {
  @IsOptional()
  @IsString()
  studentId?: string;
}
