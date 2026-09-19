import { plainToInstance } from 'class-transformer';
import { validateSync } from 'class-validator';
import { CreateSetLogDto } from '../../exercise-logs/dto/create-exercise-log.dto.js';
import { CreateWorkoutsSeriesDto } from '../../workouts-series/dto/create-workouts-series.dto.js';
import { WorkoutSessionSetItemDto } from './workout-session-set-item.dto.js';

const weightErrors = (cls: new () => object, weight: unknown) =>
  validateSync(
    plainToInstance(cls, { reps: 10, repetitions: 10, workoutId: 1, weight }),
  ).filter((e) => e.property === 'weight');

describe.each([
  ['session set', WorkoutSessionSetItemDto],
  ['exercise log set', CreateSetLogDto],
  ['planned series', CreateWorkoutsSeriesDto],
])('%s weight', (_name, cls) => {
  it.each([0, 20, 22.5, 17.25])('accepts gym plate loads like %s kg', (w) => {
    expect(weightErrors(cls, w)).toHaveLength(0);
  });

  it.each([-1, 22.555, 'heavy'])('rejects %s', (w) => {
    expect(weightErrors(cls, w)).not.toHaveLength(0);
  });
});
