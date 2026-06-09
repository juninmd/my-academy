import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class FindWorkoutsSessionsDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  year: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  month: string;
}
