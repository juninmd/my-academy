import { Injectable, NotFoundException } from '@nestjs/common';
import { PaymentStatus } from '@prisma/client';
import { PrismaService } from '../prisma.service.js';
import {
  CreateGymDto,
  CreatePlanDto,
  PageQueryDto,
  UpdateGymDto,
  UpdatePlanDto,
} from './dto/gym.dto.js';
import { activeOn } from './gym-members.service.js';

@Injectable()
export class GymsService {
  constructor(private readonly prismaService: PrismaService) {}

  async createGym(ownerId: string | undefined, dto: CreateGymDto) {
    return this.prismaService.gym.create({ data: { ...dto, ownerId } });
  }

  async findAllGyms({ skip, take }: PageQueryDto) {
    return this.prismaService.gym.findMany({
      select: { id: true, name: true, address: true, plans: true },
      orderBy: { name: 'asc' },
      skip,
      take,
    });
  }

  async findOwnedGyms(ownerId: string | undefined) {
    return this.prismaService.gym.findMany({
      where: { ownerId },
      include: { plans: { orderBy: { price: 'asc' } } },
      orderBy: { createdAt: 'asc' },
    });
  }

  async updateGym(id: number, dto: UpdateGymDto) {
    return this.prismaService.gym.update({ where: { id }, data: dto });
  }

  async createPlan(gymId: number, dto: CreatePlanDto) {
    return this.prismaService.plan.create({ data: { ...dto, gymId } });
  }

  async findGymPlans(gymId: number) {
    return this.prismaService.plan.findMany({
      where: { gymId },
      orderBy: { price: 'asc' },
    });
  }

  async updatePlan(gymId: number, planId: number, dto: UpdatePlanDto) {
    const plan = await this.prismaService.plan.findFirst({
      where: { id: planId, gymId },
      select: { id: true },
    });
    if (!plan) throw new NotFoundException(`Plan #${planId} not found`);
    return this.prismaService.plan.update({ where: { id: planId }, data: dto });
  }

  async getDashboard(gymId: number, now = new Date()) {
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
    const bySubscriptionGym = { subscription: { gymId } };
    const [activeMembers, pendingPayments, overduePayments, revenue] =
      await this.prismaService.$transaction([
        this.prismaService.subscription.count({
          where: { gymId, ...activeOn(now) },
        }),
        this.prismaService.payment.count({
          where: { ...bySubscriptionGym, status: PaymentStatus.PENDING },
        }),
        this.prismaService.payment.count({
          where: { ...bySubscriptionGym, status: PaymentStatus.OVERDUE },
        }),
        this.prismaService.payment.aggregate({
          _sum: { amount: true },
          where: {
            ...bySubscriptionGym,
            status: PaymentStatus.PAID,
            date: { gte: monthStart },
          },
        }),
      ]);
    return {
      activeMembers,
      pendingPayments,
      overduePayments,
      revenueThisMonth: revenue._sum.amount ?? 0,
    };
  }
}
