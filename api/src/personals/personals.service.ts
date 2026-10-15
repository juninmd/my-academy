import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma.service.js';
import { CreatePersonalDto } from './dto/create-personal.dto.js';
import { UpdatePersonalDto } from './dto/update-personal.dto.js';

@Injectable()
export class PersonalsService {
  constructor(private readonly prismaService: PrismaService) {}

  async create(createpersonalsDto: CreatePersonalDto) {
    try {
      return await this.prismaService.personals.create({
        data: {
          studentUserId: createpersonalsDto.studentUserId,
          personalUserId: createpersonalsDto.personalUserId,
        },
      });
    } catch (error: any) {
      if (error.code === 'P2002') {
        throw new ConflictException('Student already linked');
      }
      throw error;
    }
  }

  async findOne(id: number) {
    const personal = await this.prismaService.personals.findUnique({
      where: { id },
    });
    if (!personal) {
      throw new NotFoundException(`Personal #${id} not found`);
    }
    return personal;
  }

  findAll(personalUserId?: string) {
    const where = personalUserId ? { personalUserId } : undefined;
    return this.prismaService.personals.findMany({
      where,
      include: { PersonalUser: true, StudentUser: true },
    });
  }

  async findStudents(personalUserId: string) {
    const personal = await this.prismaService.personals.findMany({
      where: { personalUserId },
      include: { StudentUser: true, personalClassSchedule: true },
    });
    return personal
      .map((q) => ({
        student: q.StudentUser,
        schedule: q.personalClassSchedule,
      }))
      .flat(1);
  }

  update(id: number, updateDto: UpdatePersonalDto) {
    const { id: _, ...data } = updateDto;
    return this.prismaService.personals.update({
      where: { id },
      data: {
        ...data,
      },
    });
  }

  remove(id: number) {
    return this.prismaService.personals.delete({ where: { id } });
  }
}
