import { Test, TestingModule } from '@nestjs/testing';
import { BodyWeightController } from './body-weight.controller.js';
import { BodyWeightService } from './body-weight.service.js';
import { AccessService } from '../access/access.service.js';

describe('BodyWeightController', () => {
  let controller: BodyWeightController;
  const service = {
    list: vi.fn().mockResolvedValue(['list']),
    upsert: vi.fn().mockResolvedValue('saved'),
    remove: vi.fn().mockResolvedValue('removed'),
  };
  const access = { assertCanActFor: vi.fn() };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [BodyWeightController],
      providers: [
        { provide: BodyWeightService, useValue: service },
        { provide: AccessService, useValue: access },
      ],
    }).compile();
    controller = module.get(BodyWeightController);
  });

  afterEach(() => vi.clearAllMocks());

  it('lists after the access check', async () => {
    expect(await controller.list({ userId: 'u1' }, 'actor')).toEqual(['list']);
    expect(access.assertCanActFor).toHaveBeenCalledWith('actor', 'u1');
  });

  it('stores the day as UTC midnight', async () => {
    expect(
      await controller.upsert(
        { userId: 'u1', date: '2026-10-31T09:30:00Z', weight: 80 },
        'actor',
      ),
    ).toBe('saved');
    expect(service.upsert).toHaveBeenCalledWith(
      'u1',
      new Date('2026-10-31T00:00:00.000Z'),
      80,
    );
  });

  it('removes after the access check', async () => {
    expect(await controller.remove(4, { userId: 'u1' }, 'actor')).toBe(
      'removed',
    );
    expect(service.remove).toHaveBeenCalledWith('u1', 4);
  });
});
