import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateGymDto, CreatePlanDto } from './dto/gym.dto';

@Injectable()
export class GymsService {
  constructor(private readonly prismaService: PrismaService) {}

  async createGym(dto: CreateGymDto) {
    return this.prismaService.gym.create({ data: dto });
  }

  async findAllGyms() {
    return this.prismaService.gym.findMany({ include: { plans: true } });
  }

  async createPlan(dto: CreatePlanDto) {
    return this.prismaService.plan.create({ data: dto });
  }

  async findGymPlans(gymId: number) {
    return this.prismaService.plan.findMany({ where: { gymId } });
  }
}
