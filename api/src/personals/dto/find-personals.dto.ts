import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class FindPersonalsDto {
  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  personalUserId?: string;
}
