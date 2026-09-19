import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import {
  CreateGymDto,
  CreatePlanDto,
  CreateSubscriptionDto,
  FindPaymentsDto,
  UpdatePaymentDto,
} from './gym.dto.js';

const errorsOf = async (cls: any, plain: object) =>
  (await validate(plainToInstance(cls, plain) as object)).map(
    (e) => e.property,
  );

describe('Gym DTOs', () => {
  it('accepts a valid gym and requires a name', async () => {
    expect(
      await errorsOf(CreateGymDto, { name: 'Iron', address: 'Rua 1' }),
    ).toEqual([]);
    expect(await errorsOf(CreateGymDto, { name: '' })).toEqual(['name']);
  });

  it('rejects negative prices and zero-month plans', async () => {
    expect(
      await errorsOf(CreatePlanDto, {
        name: 'M',
        price: 99.9,
        durationMonths: 1,
      }),
    ).toEqual([]);
    expect(
      await errorsOf(CreatePlanDto, {
        name: 'M',
        price: -1,
        durationMonths: 0,
      }),
    ).toEqual(['price', 'durationMonths']);
  });

  it('requires a valid email to enroll', async () => {
    expect(
      await errorsOf(CreateSubscriptionDto, { email: 'x', planId: 1 }),
    ).toEqual(['email']);
  });

  it('only accepts known payment statuses', async () => {
    expect(await errorsOf(UpdatePaymentDto, { status: 'PAID' })).toEqual([]);
    expect(await errorsOf(UpdatePaymentDto, { status: 'FREE' })).toEqual([
      'status',
    ]);
  });

  it('paginates with safe defaults and caps page size', async () => {
    expect(plainToInstance(FindPaymentsDto, { take: '5' })).toMatchObject({
      skip: 0,
      take: 5,
    });
    expect(plainToInstance(FindPaymentsDto, { skip: '40' }).skip).toBe(40);
    expect(await errorsOf(FindPaymentsDto, { take: '1000' })).toEqual(['take']);
  });
});
