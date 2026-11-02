import { BadRequestException } from '@nestjs/common';
import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import { PlatesController } from './plates.controller.js';
import { PlatesModule } from './plates.module.js';
import { PlatesQueryDto } from './dto/plates-query.dto.js';
import { calculatePlates, DEFAULT_PLATES } from './plates.js';

describe('calculatePlates', () => {
  it('loads the heaviest plates first', () => {
    expect(calculatePlates(100, 20, DEFAULT_PLATES)).toEqual({
      target: 100,
      bar: 20,
      perSide: [
        { plate: 25, count: 1 },
        { plate: 15, count: 1 },
      ],
      achieved: 100,
      remainder: 0,
    });
  });

  it('reports what cannot be reached', () => {
    const load = calculatePlates(61, 20, [20, 10]);
    expect(load.perSide).toEqual([{ plate: 20, count: 1 }]);
    expect(load.achieved).toBe(60);
    expect(load.remainder).toBe(1);
  });

  it('handles a bare bar', () => {
    expect(calculatePlates(20, 20, DEFAULT_PLATES).perSide).toEqual([]);
    expect(calculatePlates(10, 20, DEFAULT_PLATES).achieved).toBe(20);
  });
});

describe('PlatesController', () => {
  const controller = new PlatesController();

  it('uses defaults', () => {
    const dto = Object.assign(new PlatesQueryDto(), { target: 60 });
    expect(controller.calculate(dto).achieved).toBe(60);
  });

  it('honours bar and plates', () => {
    const dto = Object.assign(new PlatesQueryDto(), {
      target: 35,
      bar: 15,
      plates: [10],
    });
    expect(controller.calculate(dto).perSide).toEqual([
      { plate: 10, count: 1 },
    ]);
  });

  it('rejects a target lighter than the bar', () => {
    const dto = Object.assign(new PlatesQueryDto(), { target: 10 });
    expect(() => controller.calculate(dto)).toThrow(BadRequestException);
  });

  it('parses and validates the query', async () => {
    const ok = plainToInstance(PlatesQueryDto, {
      target: '80',
      bar: '20',
      plates: '20,10,2.5',
    });
    expect(ok.plates).toEqual([20, 10, 2.5]);
    expect(await validate(ok)).toHaveLength(0);
    const bad = plainToInstance(PlatesQueryDto, { target: '80', plates: 'x' });
    expect(await validate(bad)).not.toHaveLength(0);
  });

  it('has a module', () => {
    expect(new PlatesModule()).toBeDefined();
  });
});
