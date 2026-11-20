import { NotFoundException } from '@nestjs/common';
import { GymsService } from './gyms.service.js';

describe('GymsService', () => {
  const prisma = {
    gym: { create: vi.fn(), findMany: vi.fn(), update: vi.fn() },
    plan: {
      create: vi.fn(),
      findMany: vi.fn(),
      findFirst: vi.fn(),
      update: vi.fn(),
    },
    subscription: { count: vi.fn() },
    payment: { count: vi.fn(), aggregate: vi.fn() },
    $transaction: vi.fn((ops: Promise<unknown>[]) => Promise.all(ops)),
  };
  const service = new GymsService(prisma as any);

  afterEach(() => vi.clearAllMocks());

  it('assigns the gym to the authenticated owner', async () => {
    await service.createGym('owner', { name: 'Iron' });
    expect(prisma.gym.create).toHaveBeenCalledWith({
      data: { name: 'Iron', ownerId: 'owner' },
    });
  });

  it('lists gyms paginated and owned gyms scoped by owner', async () => {
    await service.findAllGyms({ skip: 20, take: 10 });
    expect(prisma.gym.findMany).toHaveBeenCalledWith(
      expect.objectContaining({ skip: 20, take: 10 }),
    );
    await service.findOwnedGyms('owner');
    expect(prisma.gym.findMany).toHaveBeenLastCalledWith(
      expect.objectContaining({ where: { ownerId: 'owner' } }),
    );
  });

  it('updates a gym', async () => {
    await service.updateGym(1, { name: 'New' });
    expect(prisma.gym.update).toHaveBeenCalledWith({
      where: { id: 1 },
      data: { name: 'New' },
    });
  });

  it('creates and lists plans of a gym', async () => {
    const dto = { name: 'M', price: 10, durationMonths: 1 };
    await service.createPlan(3, dto);
    expect(prisma.plan.create).toHaveBeenCalledWith({
      data: { ...dto, gymId: 3 },
    });
    await service.findGymPlans(3);
    expect(prisma.plan.findMany).toHaveBeenCalledWith({
      where: { gymId: 3 },
      orderBy: { price: 'asc' },
    });
  });

  it('refuses to update a plan from another gym', async () => {
    prisma.plan.findFirst.mockResolvedValue(null);
    await expect(service.updatePlan(1, 99, { price: 1 })).rejects.toThrow(
      NotFoundException,
    );
    expect(prisma.plan.update).not.toHaveBeenCalled();
  });

  it('updates a plan of the gym', async () => {
    prisma.plan.findFirst.mockResolvedValue({ id: 5 });
    await service.updatePlan(1, 5, { price: 1 });
    expect(prisma.plan.update).toHaveBeenCalledWith({
      where: { id: 5 },
      data: { price: 1 },
    });
  });

  it('computes KPIs counting only paid revenue from the current month', async () => {
    prisma.subscription.count.mockResolvedValue(4);
    prisma.payment.count.mockResolvedValueOnce(2).mockResolvedValueOnce(1);
    prisma.payment.aggregate.mockResolvedValue({ _sum: { amount: 239.8 } });

    const kpis = await service.getDashboard(1, new Date(2026, 8, 18));

    expect(kpis).toEqual({
      activeMembers: 4,
      pendingPayments: 2,
      overduePayments: 1,
      revenueThisMonth: 239.8,
    });
    expect(prisma.payment.aggregate.mock.calls[0][0].where.date).toEqual({
      gte: new Date(2026, 8, 1),
    });
    // A membership past its end date is no longer an active member.
    expect(prisma.subscription.count.mock.calls[0][0].where).toEqual({
      gymId: 1,
      status: 'ACTIVE',
      OR: [{ endDate: null }, { endDate: { gt: new Date(2026, 8, 18) } }],
    });
  });

  it('reports zero revenue when nothing was paid', async () => {
    prisma.payment.aggregate.mockResolvedValue({ _sum: { amount: null } });
    expect((await service.getDashboard(1)).revenueThisMonth).toBe(0);
  });
});
