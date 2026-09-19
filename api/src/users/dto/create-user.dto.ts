import { ApiProperty } from '@nestjs/swagger';
import {
  IsEmail,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUrl,
  IsEnum,
} from 'class-validator';
import { Role } from '@prisma/client';

export class CreateUserDto {
  @ApiProperty({
    required: true,
    example: 'auth0|123456',
    description: 'User ID from Auth provider',
  })
  @IsString()
  @IsNotEmpty()
  id: string;

  @ApiProperty({
    required: true,
    example: 'John Doe',
    description: 'User full name',
  })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({
    required: true,
    example: 'john@example.com',
    description: 'User email',
  })
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiProperty({
    required: false,
    example: 'https://example.com/photo.jpg',
    description: 'User profile photo URL',
  })
  @IsOptional()
  @IsUrl()
  photoUrl?: string;

  @ApiProperty({
    required: false,
    example: '123456789',
    description: 'Telegram Chat ID',
  })
  @IsOptional()
  @IsString()
  telegramId?: string;

  @ApiProperty({
    required: false,
    enum: Role,
    example: 'STUDENT',
    description: 'User role',
  })
  @IsOptional()
  @IsEnum(Role)
  role?: Role;
}
