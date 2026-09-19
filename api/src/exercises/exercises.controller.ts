import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseInterceptors,
  ParseIntPipe,
} from '@nestjs/common';
import { ExercisesService } from './exercises.service.js';
import { CreateExerciseDto } from './dto/create-exercise.dto.js';
import { UpdateExerciseDto } from './dto/update-exercise.dto.js';
import { CacheInterceptor } from '@nestjs/cache-manager';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { Exercise } from './entities/exercise.entity.js';
import { AccessService } from '../access/access.service.js';
import { CurrentUserId } from '../access/current-user.decorator.js';
import { Role } from '@prisma/client';

@ApiTags('Exercises')
@Controller('exercises')
export class ExercisesController {
  constructor(
    private readonly exercisesService: ExercisesService,
    private readonly accessService: AccessService,
  ) {}

  @Post()
  @ApiOperation({ summary: 'Create a new exercise' })
  @ApiResponse({
    status: 201,
    description: 'The exercise has been successfully created.',
    type: Exercise,
  })
  @ApiResponse({ status: 400, description: 'Bad Request.' })
  async create(
    @Body() createExerciseDto: CreateExerciseDto,
    @CurrentUserId() actor: string | undefined,
  ): Promise<Exercise> {
    await this.accessService.assertRole(actor, Role.ADMIN);
    return this.exercisesService.create(createExerciseDto);
  }

  @Get()
  @UseInterceptors(CacheInterceptor)
  @ApiOperation({ summary: 'List all exercises' })
  @ApiResponse({
    status: 200,
    description: 'Return all exercises.',
    type: [Exercise],
  })
  findAll(): Promise<Exercise[]> {
    return this.exercisesService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get an exercise by id' })
  @ApiResponse({
    status: 200,
    description: 'Return the exercise.',
    type: Exercise,
  })
  @ApiResponse({ status: 404, description: 'Exercise not found.' })
  findOne(@Param('id', ParseIntPipe) id: number): Promise<Exercise> {
    return this.exercisesService.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update an exercise' })
  @ApiResponse({
    status: 200,
    description: 'The exercise has been successfully updated.',
    type: Exercise,
  })
  @ApiResponse({ status: 404, description: 'Exercise not found.' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateExerciseDto,
    @CurrentUserId() actor: string | undefined,
  ): Promise<Exercise> {
    await this.accessService.assertRole(actor, Role.ADMIN);
    return this.exercisesService.update(id, updateDto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete an exercise' })
  @ApiResponse({
    status: 200,
    description: 'The exercise has been successfully deleted.',
    type: Exercise,
  })
  @ApiResponse({ status: 404, description: 'Exercise not found.' })
  async remove(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUserId() actor: string | undefined,
  ): Promise<Exercise> {
    await this.accessService.assertRole(actor, Role.ADMIN);
    return this.exercisesService.remove(id);
  }
}
