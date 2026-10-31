import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import { CreateSetLogDto, SET_TYPES } from './create-exercise-log.dto.js';

describe('set types', () => {
  it('accepts the known types, including rest-pause', async () => {
    for (const type of SET_TYPES) {
      const dto = plainToInstance(CreateSetLogDto, {
        reps: 5,
        weight: 50,
        type,
      });
      expect(await validate(dto)).toHaveLength(0);
    }
    expect(SET_TYPES).toContain('restpause');
  });

  it('rejects an unknown type', async () => {
    const dto = plainToInstance(CreateSetLogDto, {
      reps: 5,
      weight: 50,
      type: 'mega',
    });
    expect(await validate(dto)).not.toHaveLength(0);
  });
});
