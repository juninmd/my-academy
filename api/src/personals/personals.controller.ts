import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  ParseIntPipe,
  ForbiddenException,
} from '@nestjs/common';
import { PersonalsService } from './personals.service.js';
import { CreatePersonalDto } from './dto/create-personal.dto.js';
import { UpdatePersonalDto } from './dto/update-personal.dto.js';
import { FindPersonalsDto } from './dto/find-personals.dto.js';
import { AccessService } from '../access/access.service.js';
import { CurrentUserId } from '../access/current-user.decorator.js';
import { Role } from '@prisma/client';

@Controller('personals')
export class PersonalsController {
  constructor(
    private readonly personalsService: PersonalsService,
    private readonly accessService: AccessService,
  ) {}

  @Post()
  async create(
    @Body() createPersonalDto: CreatePersonalDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    this.accessService.assertSelf(actor, createPersonalDto.personalUserId);
    await this.accessService.assertRole(actor, Role.PERSONAL);
    return this.personalsService.create(createPersonalDto);
  }

  @Get()
  findAll(
    @Query() query: FindPersonalsDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    this.accessService.assertSelf(actor, query.personalUserId);
    return this.personalsService.findAll(query.personalUserId);
  }

  @Get(':id/students')
  findOne(@Param('id') id: string, @CurrentUserId() actor: string | undefined) {
    this.accessService.assertSelf(actor, id);
    return this.personalsService.findStudents(id);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updatePersonalDto: UpdatePersonalDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    const contract = await this.personalsService.findOne(id);
    this.assertParty(actor, contract);
    return this.personalsService.update(id, updatePersonalDto);
  }

  @Delete(':id')
  async remove(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUserId() actor: string | undefined,
  ) {
    const contract = await this.personalsService.findOne(id);
    this.assertParty(actor, contract);
    return this.personalsService.remove(id);
  }

  private assertParty(
    actor: string | undefined,
    contract: { personalUserId: string; studentUserId: string },
  ): void {
    if (
      actor !== undefined &&
      actor !== contract.personalUserId &&
      actor !== contract.studentUserId
    ) {
      throw new ForbiddenException('Access denied');
    }
  }
}
