import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Query,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { BodyWeightService } from './body-weight.service.js';
import {
  BodyWeightUserDto,
  CreateBodyWeightDto,
} from './dto/body-weight.dto.js';
import { AccessService } from '../access/access.service.js';
import { CurrentUserId } from '../access/current-user.decorator.js';

@ApiTags('Body Weight')
@Controller('body-weight')
export class BodyWeightController {
  constructor(
    private readonly bodyWeightService: BodyWeightService,
    private readonly accessService: AccessService,
  ) {}

  @Get()
  async list(
    @Query() query: BodyWeightUserDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, query.userId);
    return this.bodyWeightService.list(query.userId);
  }

  @Post()
  async upsert(
    @Body() body: CreateBodyWeightDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, body.userId);
    return this.bodyWeightService.upsert(
      body.userId,
      new Date(`${body.date.slice(0, 10)}T00:00:00.000Z`),
      body.weight,
    );
  }

  @Delete(':id')
  async remove(
    @Param('id', ParseIntPipe) id: number,
    @Query() query: BodyWeightUserDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, query.userId);
    return this.bodyWeightService.remove(query.userId, id);
  }
}
