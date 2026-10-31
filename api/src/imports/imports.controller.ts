import { Body, Controller, Post } from '@nestjs/common';
import { ApiProperty, ApiPropertyOptional, ApiTags } from '@nestjs/swagger';
import {
  IsIn,
  IsNotEmpty,
  IsObject,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';
import { ImportsService } from './imports.service.js';
import { AccessService } from '../access/access.service.js';
import { CurrentUserId } from '../access/current-user.decorator.js';

export class ImportCsvDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  userId: string;

  @ApiProperty({ description: 'CSV text, first line is the header' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(5_000_000)
  csv: string;

  @ApiPropertyOptional({ enum: ['kg', 'lb'], default: 'kg' })
  @IsOptional()
  @IsIn(['kg', 'lb'])
  unit?: 'kg' | 'lb';
}

export class ImportJsonDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  userId: string;

  @ApiProperty({ description: 'The file GET /export/json returned' })
  @IsObject()
  data: Record<string, unknown>;
}

@ApiTags('Imports')
@Controller('imports')
export class ImportsController {
  constructor(
    private readonly importsService: ImportsService,
    private readonly accessService: AccessService,
  ) {}

  @Post('csv')
  async csv(
    @Body() body: ImportCsvDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, body.userId);
    return this.importsService.importCsv(body.userId, body.csv, body.unit);
  }

  @Post('json')
  async json(
    @Body() body: ImportJsonDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, body.userId);
    return this.importsService.importJson(body.userId, body.data);
  }
}
