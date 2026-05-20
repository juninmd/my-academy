import { IsOptional, IsString } from 'class-validator';

export class FindPersonalsDto {
  @IsOptional()
  @IsString()
  personalUserId?: string;
}
