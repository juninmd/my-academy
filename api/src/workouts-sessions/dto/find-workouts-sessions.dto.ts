import { IsOptional, IsString } from 'class-validator';

export class FindWorkoutsSessionsDto {
  @IsOptional()
  @IsString()
  year?: string;

  @IsOptional()
  @IsString()
  month?: string;
}
