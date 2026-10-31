import {
  Body,
  Controller,
  ForbiddenException,
  Get,
  Post,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { InvitesService } from './invites.service.js';
import { CreateInviteDto } from './dto/create-invite.dto.js';
import { AccessService } from '../access/access.service.js';
import { CurrentUserId } from '../access/current-user.decorator.js';

@ApiTags('Invites')
@Controller('invites')
export class InvitesController {
  constructor(
    private readonly invitesService: InvitesService,
    private readonly accessService: AccessService,
  ) {}

  @Post()
  async create(
    @Body() body: CreateInviteDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertRole(actor, Role.ADMIN);
    if (!actor) throw new ForbiddenException('Sign in to create invites');
    return this.invitesService.create(actor, body.validityDays);
  }

  @Get()
  async list(@CurrentUserId() actor: string | undefined) {
    await this.accessService.assertRole(actor, Role.ADMIN);
    return this.invitesService.list();
  }
}
