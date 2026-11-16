import { Test, TestingModule } from '@nestjs/testing';
import { RotationController } from './rotation.controller.js';
import { RotationService } from './rotation.service.js';
import { AccessService } from '../access/access.service.js';

describe('RotationController', () => {
  it('checks access then returns the next routine', async () => {
    const service = { next: vi.fn().mockResolvedValue('next') };
    const access = { assertCanActFor: vi.fn() };
    const module: TestingModule = await Test.createTestingModule({
      controllers: [RotationController],
      providers: [
        { provide: RotationService, useValue: service },
        { provide: AccessService, useValue: access },
      ],
    }).compile();
    const controller = module.get(RotationController);

    expect(await controller.next({ userId: 'u1' }, 'actor')).toBe('next');
    expect(access.assertCanActFor).toHaveBeenCalledWith('actor', 'u1');
    expect(service.next).toHaveBeenCalledWith('u1');
  });
});
