import { IsOptional, IsString } from 'class-validator';

export class FindExerciseLogsDto {
  @IsString()
  userId: string;

  @IsOptional()
  @IsString()
  exerciseId?: string;
}
