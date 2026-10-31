import { Test, TestingModule } from '@nestjs/testing';
import { CoachController } from './coach.controller.js';
import { CoachService } from './coach.service.js';
import { AccessService } from '../access/access.service.js';

describe('CoachController', () => {
  let controller: CoachController;
  const service = { advise: vi.fn().mockResolvedValue('advice') };
  const access = { assertCanActFor: vi.fn() };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [CoachController],
      providers: [
        { provide: CoachService, useValue: service },
        { provide: AccessService, useValue: access },
      ],
    }).compile();
    controller = module.get(CoachController);
  });

  afterEach(() => vi.clearAllMocks());

  it('checks access then asks for advice', async () => {
    expect(await controller.advice({ userId: 'u1', days: 14 }, 'actor')).toBe(
      'advice',
    );
    expect(access.assertCanActFor).toHaveBeenCalledWith('actor', 'u1');
    expect(service.advise).toHaveBeenCalledWith('u1', 14);
  });
});
