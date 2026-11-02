import { Controller, Get, Query } from '@nestjs/common';
import { ApiProperty, ApiTags } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';
import { RotationService } from './rotation.service.js';
import { AccessService } from '../access/access.service.js';
import { CurrentUserId } from '../access/current-user.decorator.js';

class RotationQueryDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  userId: string;
}

@ApiTags('Rotation')
@Controller('rotation')
export class RotationController {
  constructor(
    private readonly rotationService: RotationService,
    private readonly accessService: AccessService,
  ) {}

  @Get('next')
  async next(
    @Query() query: RotationQueryDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, query.userId);
    return this.rotationService.next(query.userId);
  }
}
