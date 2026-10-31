import { ForbiddenException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { ProgressController } from './progress.controller.js';
import { ProgressService } from './progress.service.js';
import { AccessService } from '../access/access.service.js';

describe('ProgressController', () => {
  let controller: ProgressController;
  const service = {
    summary: vi.fn().mockResolvedValue('summary'),
    bodyWeight: vi.fn().mockResolvedValue('weight'),
    exerciseProgress: vi.fn().mockResolvedValue('exercise'),
    suggestion: vi.fn().mockResolvedValue('suggestion'),
  };
  const access = { assertCanActFor: vi.fn() };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ProgressController],
      providers: [
        { provide: ProgressService, useValue: service },
        { provide: AccessService, useValue: access },
      ],
    }).compile();
    controller = module.get(ProgressController);
  });

  afterEach(() => vi.clearAllMocks());

  it('returns the summary after the access check', async () => {
    expect(await controller.summary({ userId: 'u1', days: 30 }, 'actor')).toBe(
      'summary',
    );
    expect(access.assertCanActFor).toHaveBeenCalledWith('actor', 'u1');
    expect(service.summary).toHaveBeenCalledWith('u1', 30);
  });

  it('returns body weight', async () => {
    expect(await controller.bodyWeight({ userId: 'u1' }, 'actor')).toBe(
      'weight',
    );
    expect(service.bodyWeight).toHaveBeenCalledWith('u1');
  });

  it('returns exercise progress', async () => {
    expect(await controller.exercise(7, { userId: 'u1' }, 'actor')).toBe(
      'exercise',
    );
    expect(service.exerciseProgress).toHaveBeenCalledWith('u1', 7);
  });

  it('returns a suggestion forwarding options', async () => {
    expect(
      await controller.suggestion(
        7,
        { userId: 'u1', strategy: 'linear' },
        'actor',
      ),
    ).toBe('suggestion');
    expect(service.suggestion).toHaveBeenCalledWith('u1', 7, {
      strategy: 'linear',
    });
  });

  it('blocks when access is denied', async () => {
    access.assertCanActFor.mockRejectedValueOnce(new ForbiddenException());
    await expect(controller.summary({ userId: 'u2' }, 'actor')).rejects.toThrow(
      ForbiddenException,
    );
    expect(service.summary).not.toHaveBeenCalled();
  });
});
