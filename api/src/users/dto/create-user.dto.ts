import { ApiProperty } from '@nestjs/swagger';
import {
  IsEmail,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUrl,
  IsIn,
  MaxLength,
} from 'class-validator';
import { Role } from '@prisma/client';

/** Roles a user may pick for themselves (onboarding). */
export const SELF_ASSIGNABLE_ROLES: Role[] = [
  Role.STUDENT,
  Role.PERSONAL,
  Role.OWNER,
];

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
    enum: SELF_ASSIGNABLE_ROLES,
    example: 'STUDENT',
    description: 'User role; ADMIN is only granted directly in the database',
  })
  @IsOptional()
  @IsIn(SELF_ASSIGNABLE_ROLES)
  role?: Role;

  @ApiProperty({
    required: false,
    description: 'Invite code; required when REGISTRATION_INVITE_ONLY=true',
  })
  @IsOptional()
  @IsString()
  @MaxLength(64)
  inviteCode?: string;
}
