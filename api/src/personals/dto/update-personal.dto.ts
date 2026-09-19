import { ApiProperty, PartialType } from '@nestjs/swagger';
import { CreatePersonalDto } from './create-personal.dto.js';

export class UpdatePersonalDto extends PartialType(CreatePersonalDto) {
  @ApiProperty()
  id?: number;
}
