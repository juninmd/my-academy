import { Body, Controller, Post } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { CoachService } from './coach.service.js';
import { AdviceDto } from './dto/advice.dto.js';
import { AccessService } from '../access/access.service.js';
import { CurrentUserId } from '../access/current-user.decorator.js';

@ApiTags('Coach')
@Controller('coach')
export class CoachController {
  constructor(
    private readonly coachService: CoachService,
    private readonly accessService: AccessService,
  ) {}

  @Post('advice')
  async advice(
    @Body() body: AdviceDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, body.userId);
    return this.coachService.advise(body.userId, body.days);
  }
}
