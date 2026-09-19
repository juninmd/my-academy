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
} from '@nestjs/common';
import { WorkoutsService } from './workouts.service.js';
import { CreateWorkoutDto } from './dto/create-workout.dto.js';
import { UpdateWorkoutDto } from './dto/update-workout.dto.js';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { Workout } from './entities/workout.entity.js';
import { AccessService } from '../access/access.service.js';
import { CurrentUserId } from '../access/current-user.decorator.js';

@ApiTags('Workouts')
@Controller('workouts')
export class WorkoutsController {
  constructor(
    private readonly workoutsService: WorkoutsService,
    private readonly accessService: AccessService,
  ) {}

  @Post()
  @ApiOperation({ summary: 'Create a new workout' })
  @ApiResponse({
    status: 201,
    description: 'The workout has been successfully created.',
    type: Workout,
  })
  @ApiResponse({ status: 400, description: 'Bad Request.' })
  async create(
    @Body() createWorkoutDto: CreateWorkoutDto,
    @CurrentUserId() actor: string | undefined,
  ): Promise<Workout> {
    await this.accessService.assertCanAccessGroup(
      actor,
      createWorkoutDto.workoutsGroupsId,
    );
    return this.workoutsService.create(createWorkoutDto);
  }

  @Get()
  @ApiOperation({ summary: 'List all workouts of a workout group' })
  @ApiResponse({
    status: 200,
    description: 'Return the workouts of the given group.',
    type: [Workout],
  })
  async findAll(
    @Query('workoutsGroupsId', ParseIntPipe) workoutsGroupsId: number,
    @CurrentUserId() actor: string | undefined,
  ): Promise<Workout[]> {
    await this.accessService.assertCanAccessGroup(actor, workoutsGroupsId);
    return this.workoutsService.findAll(workoutsGroupsId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a workout by id' })
  @ApiResponse({
    status: 200,
    description: 'Return the workout.',
    type: Workout,
  })
  @ApiResponse({ status: 404, description: 'Workout not found.' })
  async findOne(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUserId() actor: string | undefined,
  ): Promise<Workout> {
    const workout = await this.workoutsService.findOne(id);
    await this.accessService.assertCanAccessGroup(
      actor,
      workout.workoutsGroupsId,
    );
    return workout;
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a workout' })
  @ApiResponse({
    status: 200,
    description: 'The workout has been successfully updated.',
    type: Workout,
  })
  @ApiResponse({ status: 404, description: 'Workout not found.' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateWorkoutDto: UpdateWorkoutDto,
    @CurrentUserId() actor: string | undefined,
  ): Promise<Workout> {
    const workout = await this.workoutsService.findOne(id);
    await this.accessService.assertCanAccessGroup(
      actor,
      workout.workoutsGroupsId,
    );
    if (
      updateWorkoutDto.workoutsGroupsId !== undefined &&
      updateWorkoutDto.workoutsGroupsId !== workout.workoutsGroupsId
    ) {
      throw new BadRequestException(
        'Não é possível mover o exercício para outro treino',
      );
    }
    return this.workoutsService.update(id, updateWorkoutDto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a workout' })
  @ApiResponse({
    status: 200,
    description: 'The workout has been successfully deleted.',
    type: Workout,
  })
  @ApiResponse({ status: 404, description: 'Workout not found.' })
  async remove(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUserId() actor: string | undefined,
  ): Promise<Workout> {
    const workout = await this.workoutsService.findOne(id);
    await this.accessService.assertCanAccessGroup(
      actor,
      workout.workoutsGroupsId,
    );
    return this.workoutsService.remove(id);
  }
}
