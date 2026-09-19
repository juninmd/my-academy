import { validate } from 'class-validator';
import { WorkoutSessionItemDto } from './workout-session-item.dto.js';
import { WorkoutSessionSetItemDto } from './workout-session-set-item.dto.js';

describe('WorkoutSessionItemDto', () => {
  it('should validate with valid properties', async () => {
    const dto = new WorkoutSessionItemDto();
    dto.exerciseId = 1;

    const set = new WorkoutSessionSetItemDto();
    set.reps = 10;
    set.weight = 20;

    dto.sets = [set];

    const errors = await validate(dto);
    expect(errors.length).toBe(0);
  });
});
