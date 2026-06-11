import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class FindUsersDto {
  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  email?: string;
}
