import { IsEmail, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class FindUserDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsEmail()
  email: string;
}
