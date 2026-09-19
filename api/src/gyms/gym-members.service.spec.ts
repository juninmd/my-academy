import {
  BadRequestException,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import { addMonths, GymMembersService } from './gym-members.service.js';

describe('GymMembersService', () => {
  const prisma = {
    users: { findUnique: vi.fn() },
    plan: { findFirst: vi.fn() },
    subscription: {
      findFirst: vi.fn(),
      create: vi.fn(),
      findMany: vi.fn(),
      update: vi.fn(),
    },
    payment: { findFirst: vi.fn(), findMany: vi.fn(), update: vi.fn() },
  };
  const service = new GymMembersService(prisma as any);
  const now = new Date(2026, 0, 31);
  const dto = { email: 'a@x.io', planId: 2 };

  afterEach(() => vi.clearAllMocks());

  describe('subscribe', () => {
    it('404s when the student has never signed in', async () => {
      prisma.users.findUnique.mockResolvedValue(null);
      prisma.plan.findFirst.mockResolvedValue({ id: 2 });
      await expect(service.subscribe(1, dto)).rejects.toThrow(
        NotFoundException,
      );
    });

    it('rejects a plan belonging to another gym', async () => {
      prisma.users.findUnique.mockResolvedValue({ id: 'u' });
      prisma.plan.findFirst.mockResolvedValue(null);
      await expect(service.subscribe(1, dto)).rejects.toThrow(
        BadRequestException,
      );
    });

    it('prevents a second active membership in the same gym', async () => {
      prisma.users.findUnique.mockResolvedValue({ id: 'u' });
      prisma.plan.findFirst.mockResolvedValue({ id: 2 });
      prisma.subscription.findFirst.mockResolvedValue({ id: 9 });
      await expect(service.subscribe(1, dto)).rejects.toThrow(
        ConflictException,
      );
      expect(prisma.subscription.create).not.toHaveBeenCalled();
    });

    it('enrolls with an end date from the plan and a pending first payment', async () => {
      prisma.users.findUnique.mockResolvedValue({ id: 'u' });
      prisma.plan.findFirst.mockResolvedValue({
        id: 2,
        price: 119.9,
        durationMonths: 3,
      });
      prisma.subscription.findFirst.mockResolvedValue(null);

      await service.subscribe(1, dto, now);

      const { data } = prisma.subscription.create.mock.calls[0][0];
      expect(data).toMatchObject({
        gymId: 1,
        userId: 'u',
        planId: 2,
        startDate: now,
        endDate: addMonths(now, 3),
        payments: { create: { userId: 'u', amount: 119.9 } },
      });
    });
  });

  it('adds calendar months', () => {
    expect(addMonths(new Date(2026, 0, 15), 3)).toEqual(new Date(2026, 3, 15));
  });

  it('lists members and payments scoped to the gym with pagination', async () => {
    await service.findSubscriptions(1, { skip: 0, take: 20, status: 'ACTIVE' });
    expect(prisma.subscription.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { gymId: 1, status: 'ACTIVE' },
        skip: 0,
        take: 20,
      }),
    );
    await service.findPayments(1, { skip: 0, take: 20 });
    expect(prisma.payment.findMany).toHaveBeenCalledWith(
      expect.objectContaining({ where: { subscription: { gymId: 1 } } }),
    );
  });

  it('refuses to change a subscription of another gym', async () => {
    prisma.subscription.findFirst.mockResolvedValue(null);
    await expect(
      service.updateSubscription(1, 5, { status: 'CANCELLED' }),
    ).rejects.toThrow(NotFoundException);
    expect(prisma.subscription.update).not.toHaveBeenCalled();
  });

  it('updates a subscription status', async () => {
    prisma.subscription.findFirst.mockResolvedValue({ id: 5 });
    await service.updateSubscription(1, 5, { status: 'CANCELLED' });
    expect(prisma.subscription.update).toHaveBeenCalledWith({
      where: { id: 5 },
      data: { status: 'CANCELLED' },
    });
  });

  it('stamps the paid date so it counts in this month revenue', async () => {
    prisma.payment.findFirst.mockResolvedValue({ id: 7 });
    await service.updatePayment(1, 7, { status: 'PAID' }, now);
    expect(prisma.payment.update).toHaveBeenCalledWith({
      where: { id: 7 },
      data: { status: 'PAID', date: now },
    });
    await service.updatePayment(1, 7, { status: 'OVERDUE' }, now);
    expect(prisma.payment.update).toHaveBeenLastCalledWith({
      where: { id: 7 },
      data: { status: 'OVERDUE' },
    });
    await service.updatePayment(1, 7, { status: 'PAID' });
    expect(prisma.payment.update.mock.lastCall[0].data.date).toBeInstanceOf(
      Date,
    );
  });

  it('never lists memberships without a user (auth disabled)', async () => {
    expect(await service.findUserSubscriptions(undefined)).toEqual([]);
    expect(prisma.subscription.findMany).not.toHaveBeenCalled();
    await service.findUserSubscriptions('u');
    expect(prisma.subscription.findMany).toHaveBeenCalledWith(
      expect.objectContaining({ where: { userId: 'u' } }),
    );
  });
});
