import { plainToInstance } from 'class-transformer';
import { validateSync } from 'class-validator';
import { CreateMethodDto } from '../../methods/dto/create-method.dto.js';
import { UpdateMethodDto } from '../../methods/dto/update-method.dto.js';
import { CreatePersonalDto } from './create-personal.dto.js';

// Mirrors the global ValidationPipe: undecorated fields are rejected outright.
const errors = (cls: new () => object, body: object) =>
  validateSync(plainToInstance(cls, body), {
    whitelist: true,
    forbidNonWhitelisted: true,
  });

describe('write DTOs under forbidNonWhitelisted', () => {
  it('accepts the contract payload the app sends', () => {
    const body = { personalUserId: 'p1', studentUserId: 's1' };
    expect(errors(CreatePersonalDto, body)).toHaveLength(0);
  });

  it('rejects a contract without the student', () => {
    expect(
      errors(CreatePersonalDto, { personalUserId: 'p1' }),
    ).not.toHaveLength(0);
  });

  it('accepts a training method and partial updates to it', () => {
    const body = { name: 'Drop-set', description: 'Reduce load' };
    expect(errors(CreateMethodDto, body)).toHaveLength(0);
    expect(errors(UpdateMethodDto, { name: 'Rest-pause' })).toHaveLength(0);
  });

  it('rejects a method with an empty name', () => {
    expect(
      errors(CreateMethodDto, { name: '', description: 'x' }),
    ).not.toHaveLength(0);
  });
});
