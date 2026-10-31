import { Controller, Get, Param, ParseIntPipe, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import {
  ProgressQueryDto,
  SuggestionQueryDto,
  SummaryQueryDto,
} from './dto/progress-query.dto.js';
import { ProgressService } from './progress.service.js';
import { AccessService } from '../access/access.service.js';
import { CurrentUserId } from '../access/current-user.decorator.js';

@ApiTags('Progress')
@Controller('progress')
export class ProgressController {
  constructor(
    private readonly progressService: ProgressService,
    private readonly accessService: AccessService,
  ) {}

  @Get('summary')
  async summary(
    @Query() query: SummaryQueryDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, query.userId);
    return this.progressService.summary(query.userId, query.days);
  }

  @Get('body-weight')
  async bodyWeight(
    @Query() query: ProgressQueryDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, query.userId);
    return this.progressService.bodyWeight(query.userId);
  }

  @Get('exercises/:exerciseId')
  async exercise(
    @Param('exerciseId', ParseIntPipe) exerciseId: number,
    @Query() query: ProgressQueryDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, query.userId);
    return this.progressService.exerciseProgress(query.userId, exerciseId);
  }

  @Get('exercises/:exerciseId/suggestion')
  async suggestion(
    @Param('exerciseId', ParseIntPipe) exerciseId: number,
    @Query() query: SuggestionQueryDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, query.userId);
    const { userId, ...options } = query;
    return this.progressService.suggestion(userId, exerciseId, options);
  }
}
