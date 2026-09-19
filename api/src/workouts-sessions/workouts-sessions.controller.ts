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
  NotFoundException,
} from '@nestjs/common';
import { WorkoutsSessionsService } from './workouts-sessions.service.js';
import { CreateWorkoutsSessionsDto } from './dto/create-workouts-sessions.dto.js';
import { UpdateWorkoutsSessionsDto } from './dto/update-workouts-sessions.dto.js';
import { FindWorkoutsSessionsDto } from './dto/find-workouts-sessions.dto.js';
import { AccessService } from '../access/access.service.js';
import { CurrentUserId } from '../access/current-user.decorator.js';

@Controller('workouts-sessions')
export class WorkoutsSessionsController {
  constructor(
    private readonly workoutsSessionsService: WorkoutsSessionsService,
    private readonly accessService: AccessService,
  ) {}

  @Post()
  async create(
    @Body() createWorkoutsSessionsDto: CreateWorkoutsSessionsDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanAccessGroup(
      actor,
      createWorkoutsSessionsDto.workoutGroupId,
    );
    return this.workoutsSessionsService.create(
      createWorkoutsSessionsDto,
      actor,
    );
  }

  @Get(':idUser')
  async findAll(
    @Param('idUser') idUser: string,
    @Query() query: FindWorkoutsSessionsDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, idUser);
    return this.workoutsSessionsService.findAll(
      idUser,
      +query.year,
      +query.month,
    );
  }

  @Get(':idUser/summary')
  async findSummary(
    @Param('idUser') idUser: string,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, idUser);
    return this.workoutsSessionsService.findSummary(idUser);
  }

  @Get('single/:id')
  async findOne(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUserId() actor: string | undefined,
  ) {
    const groupId = await this.resolveGroupId(id);
    await this.accessService.assertCanAccessGroup(actor, groupId);
    return this.workoutsSessionsService.findOne(id);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateWorkoutsSessionsDto: UpdateWorkoutsSessionsDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    const groupId = await this.resolveGroupId(id);
    await this.accessService.assertCanAccessGroup(actor, groupId);
    return this.workoutsSessionsService.update(id, updateWorkoutsSessionsDto);
  }

  @Delete(':id')
  async remove(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUserId() actor: string | undefined,
  ) {
    const groupId = await this.resolveGroupId(id);
    await this.accessService.assertCanAccessGroup(actor, groupId);
    return this.workoutsSessionsService.remove(id);
  }

  private async resolveGroupId(id: number): Promise<number> {
    const session = await this.workoutsSessionsService.findOne(id);
    if (!session) {
      throw new NotFoundException(`WorkoutSession #${id} not found`);
    }
    return session.workoutGroupId;
  }
}
