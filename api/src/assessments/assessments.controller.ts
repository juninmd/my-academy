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
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { AssessmentsService } from './assessments.service.js';
import { CreateAssessmentDto } from './dto/create-assessment.dto.js';
import { UpdateAssessmentDto } from './dto/update-assessment.dto.js';
import { FindAssessmentDto } from './dto/find-assessment.dto.js';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { AccessService } from '../access/access.service.js';
import { CurrentUserId } from '../access/current-user.decorator.js';

@ApiTags('assessments')
@ApiBearerAuth()
@Controller('assessments')
export class AssessmentsController {
  constructor(
    private readonly assessmentsService: AssessmentsService,
    private readonly accessService: AccessService,
  ) {}

  @Post()
  async create(
    @Body() createAssessmentDto: CreateAssessmentDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    this.accessService.assertSelf(actor, createAssessmentDto.personalId);
    await this.accessService.assertCanActFor(
      actor,
      createAssessmentDto.studentId,
    );
    return this.assessmentsService.create(createAssessmentDto);
  }

  @Get()
  async findAll(
    @Query() query: FindAssessmentDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    if (!query.studentId && !query.personalId) {
      throw new BadRequestException('studentId or personalId is required');
    }
    if (query.studentId) {
      await this.accessService.assertCanActFor(actor, query.studentId);
    } else {
      this.accessService.assertSelf(actor, query.personalId);
    }
    return this.assessmentsService.findAll(query.studentId, query.personalId);
  }

  @Get(':id')
  async findOne(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUserId() actor: string | undefined,
  ) {
    const assessment = await this.assessmentsService.findOne(id);
    this.assertParty(actor, assessment);
    return assessment;
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateAssessmentDto: UpdateAssessmentDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    const assessment = await this.assessmentsService.findOne(id);
    this.assertOwnerPersonal(actor, assessment);
    return this.assessmentsService.update(id, updateAssessmentDto);
  }

  @Delete(':id')
  async remove(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUserId() actor: string | undefined,
  ) {
    const assessment = await this.assessmentsService.findOne(id);
    this.assertOwnerPersonal(actor, assessment);
    return this.assessmentsService.remove(id);
  }

  private assertParty(
    actor: string | undefined,
    assessment: { personalId: string; studentId: string },
  ): void {
    if (
      actor !== undefined &&
      actor !== assessment.personalId &&
      actor !== assessment.studentId
    ) {
      throw new ForbiddenException('Access denied');
    }
  }

  private assertOwnerPersonal(
    actor: string | undefined,
    assessment: { personalId: string },
  ): void {
    if (actor !== undefined && actor !== assessment.personalId) {
      throw new ForbiddenException('Access denied');
    }
  }
}
