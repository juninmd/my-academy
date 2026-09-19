import type { Mock } from 'vitest';
import { ForbiddenException } from '@nestjs/common';
import { Role } from '@prisma/client';
import { GymsController } from './gyms.controller.js';

describe('GymsController', () => {
  const gyms = {
    createGym: vi.fn(),
    findAllGyms: vi.fn(),
    findOwnedGyms: vi.fn(),
    updateGym: vi.fn(),
    getDashboard: vi.fn(),
    findGymPlans: vi.fn(),
    createPlan: vi.fn(),
    updatePlan: vi.fn(),
  };
  const members = {
    findUserSubscriptions: vi.fn(),
    findSubscriptions: vi.fn(),
    subscribe: vi.fn(),
    updateSubscription: vi.fn(),
    findPayments: vi.fn(),
    updatePayment: vi.fn(),
  };
  const access = { assertRole: vi.fn(), assertGymOwner: vi.fn() };
  const controller = new GymsController(
    gyms as any,
    members as any,
    access as any,
  );
  const page = { skip: 0, take: 20 };

  afterEach(() => vi.clearAllMocks());

  it('only gym owners (ADMIN) can create gyms', async () => {
    await controller.create('o', { name: 'G' });
    expect(access.assertRole).toHaveBeenCalledWith('o', Role.OWNER, Role.ADMIN);
    expect(gyms.createGym).toHaveBeenCalledWith('o', { name: 'G' });

    access.assertRole.mockRejectedValueOnce(new ForbiddenException());
    await expect(controller.create('s', { name: 'G' })).rejects.toThrow(
      ForbiddenException,
    );
    expect(gyms.createGym).toHaveBeenCalledTimes(1);
  });

  it('exposes public listings without ownership checks', () => {
    controller.findAll(page);
    controller.findPlans(1);
    controller.findMine('o');
    controller.findMySubscriptions('s');
    expect(gyms.findAllGyms).toHaveBeenCalledWith(page);
    expect(gyms.findGymPlans).toHaveBeenCalledWith(1);
    expect(gyms.findOwnedGyms).toHaveBeenCalledWith('o');
    expect(members.findUserSubscriptions).toHaveBeenCalledWith('s');
    expect(access.assertGymOwner).not.toHaveBeenCalled();
  });

  const ownerOnly: [string, () => Promise<unknown>, Mock][] = [
    ['update', () => controller.update('x', 1, {}), gyms.updateGym],
    ['dashboard', () => controller.dashboard('x', 1), gyms.getDashboard],
    [
      'createPlan',
      () => controller.createPlan('x', 1, {} as any),
      gyms.createPlan,
    ],
    ['updatePlan', () => controller.updatePlan('x', 1, 2, {}), gyms.updatePlan],
    [
      'findSubscriptions',
      () => controller.findSubscriptions('x', 1, page),
      members.findSubscriptions,
    ],
    [
      'subscribe',
      () => controller.subscribe('x', 1, {} as any),
      members.subscribe,
    ],
    [
      'updateSubscription',
      () => controller.updateSubscription('x', 1, 2, {} as any),
      members.updateSubscription,
    ],
    [
      'findPayments',
      () => controller.findPayments('x', 1, page),
      members.findPayments,
    ],
    [
      'updatePayment',
      () => controller.updatePayment('x', 1, 2, {} as any),
      members.updatePayment,
    ],
  ];

  it.each(ownerOnly)('%s is owner-only', async (_, call, target) => {
    await call();
    expect(access.assertGymOwner).toHaveBeenCalledWith('x', 1);
    expect(target).toHaveBeenCalled();

    target.mockClear();
    access.assertGymOwner.mockRejectedValueOnce(new ForbiddenException());
    await expect(call()).rejects.toThrow(ForbiddenException);
    expect(target).not.toHaveBeenCalled();
  });
});
