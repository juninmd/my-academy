import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class FindPersonalsDto {
  @ApiProperty({ required: true })
  @IsNotEmpty()
  @IsString()
  personalUserId: string;
}
