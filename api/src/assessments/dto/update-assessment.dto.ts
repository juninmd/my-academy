import { PartialType } from '@nestjs/swagger';
import { CreateAssessmentDto } from './create-assessment.dto.js';

export class UpdateAssessmentDto extends PartialType(CreateAssessmentDto) {}
