import {
  Controller,
  Get,
  Post,
  Body,
  Put,
  Param,
  Delete,
  ParseIntPipe,
} from '@nestjs/common';
import { WorkoutsGroupsService } from './workouts-groups.service.js';
import { CreateWorkoutsGroupDto } from './dto/create-workouts-group.dto.js';
import { UpdateWorkoutsGroupDto } from './dto/update-workouts-group.dto.js';
import { AccessService } from '../access/access.service.js';
import { CurrentUserId } from '../access/current-user.decorator.js';

@Controller('workouts-groups')
export class WorkoutsGroupsController {
  constructor(
    private readonly workoutsGroupsService: WorkoutsGroupsService,
    private readonly accessService: AccessService,
  ) {}

  @Post()
  async create(
    @Body() createWorkoutsGroupDto: CreateWorkoutsGroupDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(
      actor,
      createWorkoutsGroupDto.userId,
    );
    return this.workoutsGroupsService.create(createWorkoutsGroupDto);
  }

  @Get('/user/:userId')
  async findAll(
    @Param('userId') userId: string,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, userId);
    return this.workoutsGroupsService.findAll(userId);
  }

  @Get(':id')
  async findOne(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanAccessGroup(actor, id);
    return this.workoutsGroupsService.findOne(id);
  }

  @Get(':id/exercises')
  async findOneExercises(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanAccessGroup(actor, id);
    return this.workoutsGroupsService.findAllExercises(id);
  }

  @Put(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateWorkoutsGroupDto: UpdateWorkoutsGroupDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanAccessGroup(actor, id);
    return this.workoutsGroupsService.update(id, updateWorkoutsGroupDto);
  }

  @Delete(':id')
  async remove(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanAccessGroup(actor, id);
    return this.workoutsGroupsService.remove(id);
  }
}
