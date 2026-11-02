import { Controller, Get, Header, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { ExportService } from './export.service.js';
import { ProgressQueryDto } from '../progress/dto/progress-query.dto.js';
import { AccessService } from '../access/access.service.js';
import { CurrentUserId } from '../access/current-user.decorator.js';

@ApiTags('Export')
@Controller('export')
export class ExportController {
  constructor(
    private readonly exportService: ExportService,
    private readonly accessService: AccessService,
  ) {}

  @Get('json')
  @Header('Content-Disposition', 'attachment; filename="my-academy.json"')
  async json(
    @Query() query: ProgressQueryDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, query.userId);
    return this.exportService.exportJson(query.userId);
  }

  @Get('csv')
  @Header('Content-Type', 'text/csv; charset=utf-8')
  @Header('Content-Disposition', 'attachment; filename="my-academy.csv"')
  async csv(
    @Query() query: ProgressQueryDto,
    @CurrentUserId() actor: string | undefined,
  ) {
    await this.accessService.assertCanActFor(actor, query.userId);
    return this.exportService.exportCsv(query.userId);
  }
}
