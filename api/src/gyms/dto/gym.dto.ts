import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateGymDto {
  @ApiProperty({ example: 'Iron Gym' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ example: '123 Main St' })
  @IsString()
  @IsOptional()
  address?: string;

  @ApiProperty({ example: 'owner-id' })
  @IsString()
  @IsOptional()
  ownerId?: string;
}

export class CreatePlanDto {
  @ApiProperty({ example: 'Monthly' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ example: 99.9 })
  @IsNotEmpty()
  price: number;

  @ApiProperty({ example: 1 })
  @IsNotEmpty()
  durationMonths: number;

  @ApiProperty({ example: 1 })
  @IsNotEmpty()
  gymId: number;
}
