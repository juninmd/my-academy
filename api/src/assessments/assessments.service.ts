import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service.js';
import { CreateAssessmentDto } from './dto/create-assessment.dto.js';
import { UpdateAssessmentDto } from './dto/update-assessment.dto.js';

@Injectable()
export class AssessmentsService {
  constructor(private readonly prismaService: PrismaService) {}

  async create(createDto: CreateAssessmentDto) {
    const { weight, height } = createDto;

    // Auto-calculate IMC if not provided
    const imc = createDto.imc ?? weight / (height * height);

    return this.prismaService.assessment.create({
      data: {
        ...createDto,
        imc,
      },
    });
  }

  async findAll(studentId?: string, personalId?: string) {
    return this.prismaService.assessment.findMany({
      where: {
        ...(studentId && { studentId }),
        ...(personalId && { personalId }),
      },
      orderBy: { date: 'desc' },
    });
  }

  async findOne(id: number) {
    const assessment = await this.prismaService.assessment.findUnique({
      where: { id },
    });
    if (!assessment) throw new NotFoundException(`Assessment #${id} not found`);
    return assessment;
  }

  async update(id: number, updateDto: UpdateAssessmentDto) {
    try {
      return await this.prismaService.assessment.update({
        where: { id },
        data: updateDto,
      });
    } catch (_error) {
      throw new NotFoundException(`Assessment #${id} not found`);
    }
  }

  async remove(id: number) {
    try {
      return await this.prismaService.assessment.delete({
        where: { id },
      });
    } catch (_error) {
      throw new NotFoundException(`Assessment #${id} not found`);
    }
  }
}
