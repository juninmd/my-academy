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

export class ImportHevyDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  userId: string;

  @ApiProperty({
    description: 'Hevy Pro API key; used for this request only, never stored',
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  apiKey: string;
}

export class ImportBodyWeightDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  userId: string;

  @ApiProperty({
    description:
      'Apple Health export.xml text, or a CSV with a date and a weight column',
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(25_000_000)
  data: string;

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

  @Post('hevy')
  async hevy(
    @Body() body: ImportHevyDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, body.userId);
    return this.importsService.importHevy(body.userId, body.apiKey);
  }

  @Post('body-weight')
  async bodyWeight(
    @Body() body: ImportBodyWeightDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, body.userId);
    return this.importsService.importBodyWeight(
      body.userId,
      body.data,
      body.unit,
    );
  }
}
