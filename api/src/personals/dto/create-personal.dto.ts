import { ApiProperty } from '@nestjs/swagger';
import { IsInt, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreatePersonalDto {
  @ApiProperty({ required: false })
  @IsOptional()
  @IsInt()
  id?: number;

  @ApiProperty({ required: true })
  @IsString()
  @IsNotEmpty()
  personalUserId: string;

  @ApiProperty({ required: true })
  @IsString()
  @IsNotEmpty()
  studentUserId: string;
}
