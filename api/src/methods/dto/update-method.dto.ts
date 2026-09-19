import { PartialType } from '@nestjs/swagger';
import { CreateMethodDto } from './create-method.dto.js';

export class UpdateMethodDto extends PartialType(CreateMethodDto) {}
