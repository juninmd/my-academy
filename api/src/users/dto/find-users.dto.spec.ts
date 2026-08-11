import { validate } from 'class-validator';
import { FindUsersDto } from './find-users.dto';

describe('FindUsersDto', () => {
  it('should validate with valid properties', async () => {
    const dto = new FindUsersDto();
    dto.email = 'test@example.com';
    const errors = await validate(dto);
    expect(errors.length).toBe(0);
  });

  it('should validate when empty (optional properties)', async () => {
    const dto = new FindUsersDto();
    const errors = await validate(dto);
    expect(errors.length).toBe(0);
  });
});
