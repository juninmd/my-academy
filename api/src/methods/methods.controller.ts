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
import { MethodsService } from './methods.service.js';
import { CreateMethodDto } from './dto/create-method.dto.js';
import { UpdateMethodDto } from './dto/update-method.dto.js';
import { CacheInterceptor } from '@nestjs/cache-manager';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { Methods, Role } from '@prisma/client';
import { AccessService } from '../access/access.service.js';
import { CurrentUserId } from '../access/current-user.decorator.js';

@ApiTags('Methods')
@Controller('methods')
export class MethodsController {
  constructor(
    private readonly methodsService: MethodsService,
    private readonly accessService: AccessService,
  ) {}

  @Post()
  @ApiOperation({ summary: 'Create a new method' })
  @ApiResponse({
    status: 201,
    description: 'The method has been successfully created.',
  })
  @ApiResponse({ status: 400, description: 'Bad Request.' })
  async create(
    @Body() createMethodDto: CreateMethodDto,
    @CurrentUserId() actor: string | undefined,
  ): Promise<Methods> {
    await this.accessService.assertRole(actor, Role.ADMIN);
    return this.methodsService.create(createMethodDto);
  }

  @Get()
  @UseInterceptors(CacheInterceptor)
  @ApiOperation({ summary: 'List all methods' })
  @ApiResponse({ status: 200, description: 'Return all methods.' })
  findAll(): Promise<Methods[]> {
    return this.methodsService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a method by id' })
  @ApiResponse({ status: 200, description: 'Return the method.' })
  @ApiResponse({ status: 404, description: 'Method not found.' })
  findOne(@Param('id', ParseIntPipe) id: number): Promise<Methods> {
    return this.methodsService.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a method' })
  @ApiResponse({
    status: 200,
    description: 'The method has been successfully updated.',
  })
  @ApiResponse({ status: 404, description: 'Method not found.' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateMethodDto: UpdateMethodDto,
    @CurrentUserId() actor: string | undefined,
  ): Promise<Methods> {
    await this.accessService.assertRole(actor, Role.ADMIN);
    return this.methodsService.update(id, updateMethodDto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a method' })
  @ApiResponse({
    status: 200,
    description: 'The method has been successfully deleted.',
  })
  @ApiResponse({ status: 404, description: 'Method not found.' })
  async remove(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUserId() actor: string | undefined,
  ): Promise<Methods> {
    await this.accessService.assertRole(actor, Role.ADMIN);
    return this.methodsService.remove(id);
  }
}
