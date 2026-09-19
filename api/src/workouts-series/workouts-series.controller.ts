import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Query,
  Delete,
  ParseIntPipe,
  BadRequestException,
} from '@nestjs/common';
import { WorkoutsSeriesService } from './workouts-series.service.js';
import { CreateWorkoutsSeriesDto } from './dto/create-workouts-series.dto.js';
import { UpdateWorkoutsSeriesDto } from './dto/update-workouts-series.dto.js';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { WorkoutSeries } from './entities/workout-series.entity.js';
import { AccessService } from '../access/access.service.js';
import { CurrentUserId } from '../access/current-user.decorator.js';

@ApiTags('Workouts Series')
@Controller('workouts-series')
export class WorkoutsSeriesController {
  constructor(
    private readonly workoutsSeriesService: WorkoutsSeriesService,
    private readonly accessService: AccessService,
  ) {}

  @Post()
  @ApiOperation({ summary: 'Create a new workout series' })
  @ApiResponse({
    status: 201,
    description: 'The workout series has been successfully created.',
  })
  async create(
    @Body() createWorkoutsSeriesDto: CreateWorkoutsSeriesDto,
    @CurrentUserId() actor: string | undefined,
  ): Promise<WorkoutSeries> {
    if (!createWorkoutsSeriesDto.workoutId) {
      throw new BadRequestException('workoutId is required');
    }
    await this.assertCanAccessWorkout(actor, createWorkoutsSeriesDto.workoutId);
    return this.workoutsSeriesService.create(createWorkoutsSeriesDto);
  }

  @Get()
  @ApiOperation({ summary: 'List workout series of a workout' })
  @ApiResponse({ status: 200, description: 'Return the workout series.' })
  async findAll(
    @Query('workoutId', ParseIntPipe) workoutId: number,
    @CurrentUserId() actor: string | undefined,
  ): Promise<WorkoutSeries[]> {
    await this.assertCanAccessWorkout(actor, workoutId);
    return this.workoutsSeriesService.findAll(workoutId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a workout series by id' })
  @ApiResponse({ status: 200, description: 'Return the workout series.' })
  @ApiResponse({ status: 404, description: 'Workout series not found.' })
  async findOne(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUserId() actor: string | undefined,
  ): Promise<WorkoutSeries> {
    const series = await this.workoutsSeriesService.findOne(id);
    await this.assertCanAccessWorkout(actor, series.workoutId);
    return series;
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a workout series' })
  @ApiResponse({
    status: 200,
    description: 'The workout series has been successfully updated.',
  })
  @ApiResponse({ status: 404, description: 'Workout series not found.' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateWorkoutsSeriesDto: UpdateWorkoutsSeriesDto,
    @CurrentUserId() actor: string | undefined,
  ): Promise<WorkoutSeries> {
    const series = await this.workoutsSeriesService.findOne(id);
    await this.assertCanAccessWorkout(actor, series.workoutId);
    return this.workoutsSeriesService.update(id, updateWorkoutsSeriesDto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a workout series' })
  @ApiResponse({
    status: 200,
    description: 'The workout series has been successfully deleted.',
  })
  @ApiResponse({ status: 404, description: 'Workout series not found.' })
  async remove(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUserId() actor: string | undefined,
  ): Promise<WorkoutSeries> {
    const series = await this.workoutsSeriesService.findOne(id);
    await this.assertCanAccessWorkout(actor, series.workoutId);
    return this.workoutsSeriesService.remove(id);
  }

  private async assertCanAccessWorkout(
    actor: string | undefined,
    workoutId: number,
  ): Promise<void> {
    const groupId = await this.workoutsSeriesService.resolveGroupId(workoutId);
    await this.accessService.assertCanAccessGroup(actor, groupId);
  }
}
