import { Test, TestingModule } from '@nestjs/testing';
import { FavoritesController } from './favorites.controller.js';
import { FavoritesService } from './favorites.service.js';
import { AccessService } from '../access/access.service.js';

describe('FavoritesController', () => {
  let controller: FavoritesController;
  const service = {
    list: vi.fn().mockResolvedValue(['list']),
    add: vi.fn().mockResolvedValue('added'),
    remove: vi.fn().mockResolvedValue('removed'),
  };
  const access = { assertCanActFor: vi.fn() };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [FavoritesController],
      providers: [
        { provide: FavoritesService, useValue: service },
        { provide: AccessService, useValue: access },
      ],
    }).compile();
    controller = module.get(FavoritesController);
  });

  afterEach(() => vi.clearAllMocks());

  it('lists after the access check', async () => {
    expect(await controller.list({ userId: 'u1' }, 'actor')).toEqual(['list']);
    expect(access.assertCanActFor).toHaveBeenCalledWith('actor', 'u1');
  });

  it('adds after the access check', async () => {
    expect(await controller.add({ userId: 'u1', exerciseId: 3 }, 'actor')).toBe(
      'added',
    );
    expect(access.assertCanActFor).toHaveBeenCalledWith('actor', 'u1');
    expect(service.add).toHaveBeenCalledWith('u1', 3);
  });

  it('removes after the access check', async () => {
    expect(await controller.remove(3, { userId: 'u1' }, 'actor')).toBe(
      'removed',
    );
    expect(service.remove).toHaveBeenCalledWith('u1', 3);
  });
});
