import { validate } from 'class-validator';
import { CreateWorkoutsSessionsDto } from './create-workouts-sessions.dto';
import { WorkoutSessionItemDto } from './workout-session-item.dto';
import { WorkoutSessionSetItemDto } from './workout-session-set-item.dto';

describe('CreateWorkoutsSessionsDto', () => {
  it('should validate with valid properties', async () => {
    const dto = new CreateWorkoutsSessionsDto();
    // Use type assertion since it's defined as readonly
    (dto as any).workoutGroupId = 1;
    (dto as any).date = new Date();

    const item = new WorkoutSessionItemDto();
    item.exerciseId = 1;
    const set = new WorkoutSessionSetItemDto();
    set.reps = 10;
    set.weight = 20;
    item.sets = [set];

    (dto as any).workouts = [item];

    const errors = await validate(dto);
    expect(errors.length).toBe(0);
  });
});
