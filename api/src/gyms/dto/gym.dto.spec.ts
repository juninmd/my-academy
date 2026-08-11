import { validate } from 'class-validator';
import { CreateGymDto, CreatePlanDto } from './gym.dto';

describe('GymDto', () => {
  it('should validate CreateGymDto with valid properties', async () => {
    const dto = new CreateGymDto();
    dto.name = 'Test Gym';
    dto.address = 'Test Address';
    dto.ownerId = 'owner-id';

    const errors = await validate(dto);
    expect(errors.length).toBe(0);
  });

  it('should validate CreatePlanDto with valid properties', async () => {
    const dto = new CreatePlanDto();
    dto.name = 'Test Plan';
    dto.price = 99.9;
    dto.durationMonths = 1;
    dto.gymId = 1;

    const errors = await validate(dto);
    expect(errors.length).toBe(0);
  });
});
