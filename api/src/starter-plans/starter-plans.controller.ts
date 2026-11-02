import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { ApiProperty, ApiTags } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';
import { StarterPlansService } from './starter-plans.service.js';
import { AccessService } from '../access/access.service.js';
import { CurrentUserId } from '../access/current-user.decorator.js';

export class ApplyStarterPlanDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  userId: string;
}

@ApiTags('Starter Plans')
@Controller('starter-plans')
export class StarterPlansController {
  constructor(
    private readonly starterPlansService: StarterPlansService,
    private readonly accessService: AccessService,
  ) {}

  @Get()
  list() {
    return this.starterPlansService.list();
  }

  @Post(':key/apply')
  async apply(
    @Param('key') key: string,
    @Body() body: ApplyStarterPlanDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, body.userId);
    return this.starterPlansService.apply(key, body.userId);
  }
}
