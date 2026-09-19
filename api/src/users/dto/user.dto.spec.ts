import { plainToInstance } from 'class-transformer';
import { validateSync } from 'class-validator';
import { CreateUserDto } from './create-user.dto.js';
import { UpdateUserDto } from './update-user.dto.js';

const errors = (cls: new () => object, body: object) =>
  validateSync(plainToInstance(cls, body), {
    whitelist: true,
    forbidNonWhitelisted: true,
  });

describe('user DTOs', () => {
  it('lets an account without a photo sign up (avatar falls back to initials)', () => {
    const body = { id: 'u1', name: 'Ana', email: 'ana@myacademy.dev' };
    expect(errors(CreateUserDto, body)).toHaveLength(0);
  });

  it('still rejects a photo that is not a URL', () => {
    const body = { id: 'u1', name: 'Ana', email: 'a@b.dev', photoUrl: 'x' };
    expect(errors(CreateUserDto, body)).not.toHaveLength(0);
  });

  it('accepts the onboarding flag only as a boolean', () => {
    expect(errors(UpdateUserDto, { onboarded: true })).toHaveLength(0);
    expect(errors(UpdateUserDto, { onboarded: 'yes' })).not.toHaveLength(0);
  });
});
