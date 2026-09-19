import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PaymentStatus, SubscriptionStatus } from '@prisma/client';
import { PrismaService } from '../prisma.service.js';
import {
  CreateSubscriptionDto,
  FindPaymentsDto,
  FindSubscriptionsDto,
  UpdatePaymentDto,
  UpdateSubscriptionDto,
} from './dto/gym.dto.js';

const memberSelect = { id: true, name: true, email: true, photoUrl: true };

/** Calendar months, clamped to the target month's last day (Jan 31 + 1 = Feb 28). */
export const addMonths = (date: Date, months: number): Date => {
  const result = new Date(date);
  const day = result.getDate();
  result.setDate(1);
  result.setMonth(result.getMonth() + months);
  const lastDay = new Date(
    result.getFullYear(),
    result.getMonth() + 1,
    0,
  ).getDate();
  result.setDate(Math.min(day, lastDay));
  return result;
};

@Injectable()
export class GymMembersService {
  constructor(private readonly prismaService: PrismaService) {}

  async subscribe(gymId: number, dto: CreateSubscriptionDto, now = new Date()) {
    const [user, plan] = await Promise.all([
      this.prismaService.users.findUnique({ where: { email: dto.email } }),
      this.prismaService.plan.findFirst({ where: { id: dto.planId, gymId } }),
    ]);
    if (!user) throw new NotFoundException('Aluno não encontrado');
    if (!plan) throw new BadRequestException('Plano não pertence à academia');

    const active = await this.prismaService.subscription.findFirst({
      where: { gymId, userId: user.id, status: SubscriptionStatus.ACTIVE },
      select: { id: true },
    });
    if (active) throw new ConflictException('Aluno já possui matrícula ativa');

    return this.prismaService.subscription.create({
      data: {
        gymId,
        userId: user.id,
        planId: plan.id,
        startDate: now,
        endDate: addMonths(now, plan.durationMonths),
        payments: { create: { userId: user.id, amount: plan.price } },
      },
      include: { user: { select: memberSelect }, plan: true, payments: true },
    });
  }

  async findSubscriptions(gymId: number, q: FindSubscriptionsDto) {
    return this.prismaService.subscription.findMany({
      where: { gymId, status: q.status },
      include: { user: { select: memberSelect }, plan: true },
      orderBy: { startDate: 'desc' },
      skip: q.skip,
      take: q.take,
    });
  }

  async updateSubscription(
    gymId: number,
    id: number,
    dto: UpdateSubscriptionDto,
  ) {
    await this.findInGym('subscription', id, { gymId });
    return this.prismaService.subscription.update({
      where: { id },
      data: { status: dto.status },
    });
  }

  async findPayments(gymId: number, q: FindPaymentsDto) {
    return this.prismaService.payment.findMany({
      where: { subscription: { gymId }, status: q.status },
      include: {
        user: { select: memberSelect },
        subscription: { include: { plan: true } },
      },
      orderBy: { date: 'desc' },
      skip: q.skip,
      take: q.take,
    });
  }

  async updatePayment(
    gymId: number,
    id: number,
    dto: UpdatePaymentDto,
    now = new Date(),
  ) {
    await this.findInGym('payment', id, { subscription: { gymId } });
    return this.prismaService.payment.update({
      where: { id },
      data: {
        status: dto.status,
        ...(dto.status === PaymentStatus.PAID && { date: now }),
      },
    });
  }

  async findUserSubscriptions(userId: string | undefined) {
    if (!userId) return [];
    return this.prismaService.subscription.findMany({
      where: { userId },
      include: {
        gym: { select: { id: true, name: true, address: true } },
        plan: true,
        payments: { orderBy: { date: 'desc' }, take: 12 },
      },
      orderBy: { startDate: 'desc' },
    });
  }

  private async findInGym(
    model: 'subscription' | 'payment',
    id: number,
    scope: object,
  ) {
    const delegate = this.prismaService[model] as unknown as {
      findFirst: (args: object) => Promise<unknown>;
    };
    const found = await delegate.findFirst({
      where: { id, ...scope },
      select: { id: true },
    });
    if (!found) throw new NotFoundException(`${model} #${id} not found`);
  }
}
