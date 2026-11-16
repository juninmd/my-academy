import { BadRequestException, Controller, Get, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { PlatesQueryDto } from './dto/plates-query.dto.js';
import { calculatePlates, DEFAULT_PLATES } from './plates.js';

@ApiTags('Plates')
@Controller('plates')
export class PlatesController {
  @Get()
  calculate(@Query() query: PlatesQueryDto) {
    const bar = query.bar ?? 20;
    if (query.target < bar) {
      throw new BadRequestException('Target is lighter than the bar');
    }
    return calculatePlates(query.target, bar, query.plates ?? DEFAULT_PLATES);
  }
}
