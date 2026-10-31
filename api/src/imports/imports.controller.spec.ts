import { Test, TestingModule } from '@nestjs/testing';
import { ImportsController } from './imports.controller.js';
import { ImportsService } from './imports.service.js';
import { AccessService } from '../access/access.service.js';

describe('ImportsController', () => {
  let controller: ImportsController;
  const service = { importCsv: vi.fn().mockResolvedValue('result') };
  const access = { assertCanActFor: vi.fn() };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ImportsController],
      providers: [
        { provide: ImportsService, useValue: service },
        { provide: AccessService, useValue: access },
      ],
    }).compile();
    controller = module.get(ImportsController);
  });

  afterEach(() => vi.clearAllMocks());

  it('checks access then imports with the requested unit', async () => {
    expect(
      await controller.csv({ userId: 'u1', csv: 'x', unit: 'lb' }, 'actor'),
    ).toBe('result');
    expect(access.assertCanActFor).toHaveBeenCalledWith('actor', 'u1');
    expect(service.importCsv).toHaveBeenCalledWith('u1', 'x', 'lb');
  });

  it('imports with the default unit when none is given', async () => {
    await controller.csv({ userId: 'u1', csv: 'x' }, undefined);
    expect(service.importCsv).toHaveBeenCalledWith('u1', 'x', undefined);
  });
});

describe('ImportsController.json', () => {
  it('checks access then restores the payload', async () => {
    const service = { importJson: vi.fn().mockResolvedValue('restored') };
    const access = { assertCanActFor: vi.fn() };
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ImportsController],
      providers: [
        { provide: ImportsService, useValue: service },
        { provide: AccessService, useValue: access },
      ],
    }).compile();
    const controller = module.get(ImportsController);
    expect(
      await controller.json({ userId: 'u1', data: { x: 1 } }, 'actor'),
    ).toBe('restored');
    expect(access.assertCanActFor).toHaveBeenCalledWith('actor', 'u1');
    expect(service.importJson).toHaveBeenCalledWith('u1', { x: 1 });
  });
});

describe('ImportsController.hevy', () => {
  it('checks access then imports with the key', async () => {
    const service = { importHevy: vi.fn().mockResolvedValue('hevy') };
    const access = { assertCanActFor: vi.fn() };
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ImportsController],
      providers: [
        { provide: ImportsService, useValue: service },
        { provide: AccessService, useValue: access },
      ],
    }).compile();
    const controller = module.get(ImportsController);
    expect(await controller.hevy({ userId: 'u1', apiKey: 'k' }, 'actor')).toBe(
      'hevy',
    );
    expect(access.assertCanActFor).toHaveBeenCalledWith('actor', 'u1');
    expect(service.importHevy).toHaveBeenCalledWith('u1', 'k');
  });
});
