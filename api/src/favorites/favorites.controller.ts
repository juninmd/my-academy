import {
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Body,
  Query,
} from '@nestjs/common';
import { ApiProperty, ApiTags } from '@nestjs/swagger';
import { IsNotEmpty, IsInt, IsString } from 'class-validator';
import { FavoritesService } from './favorites.service.js';
import { AccessService } from '../access/access.service.js';
import { CurrentUserId } from '../access/current-user.decorator.js';

export class FavoriteUserDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  userId: string;
}

export class AddFavoriteDto extends FavoriteUserDto {
  @ApiProperty()
  @IsInt()
  exerciseId: number;
}

@ApiTags('Favorites')
@Controller('favorites')
export class FavoritesController {
  constructor(
    private readonly favoritesService: FavoritesService,
    private readonly accessService: AccessService,
  ) {}

  @Get()
  async list(
    @Query() query: FavoriteUserDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, query.userId);
    return this.favoritesService.list(query.userId);
  }

  @Post()
  async add(
    @Body() body: AddFavoriteDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, body.userId);
    return this.favoritesService.add(body.userId, body.exerciseId);
  }

  @Delete(':exerciseId')
  async remove(
    @Param('exerciseId', ParseIntPipe) exerciseId: number,
    @Query() query: FavoriteUserDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, query.userId);
    return this.favoritesService.remove(query.userId, exerciseId);
  }
}
