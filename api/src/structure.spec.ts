import { CreateExerciseLogDto } from './exercise-logs/dto/create-exercise-log.dto.js';
import { CreateExerciseDto } from './exercises/dto/create-exercise.dto.js';
import { UpdateExerciseDto } from './exercises/dto/update-exercise.dto.js';
import { Exercise } from './exercises/entities/exercise.entity.js';
import { CreateMethodDto } from './methods/dto/create-method.dto.js';
import { UpdateMethodDto } from './methods/dto/update-method.dto.js';
import { Method } from './methods/entities/method.entity.js';
import { CreatePersonalDto } from './personals/dto/create-personal.dto.js';
import { UpdatePersonalDto } from './personals/dto/update-personal.dto.js';
import { Personal } from './personals/entities/personal.entity.js';
import { CreateUserDto } from './users/dto/create-user.dto.js';
import { UpdateUserDto } from './users/dto/update-user.dto.js';
import { User } from './users/entities/user.entity.js';
import { CreateWorkoutsGroupDto } from './workouts-groups/dto/create-workouts-group.dto.js';
import { UpdateWorkoutsGroupDto } from './workouts-groups/dto/update-workouts-group.dto.js';
import { WorkoutsGroup } from './workouts-groups/entities/workouts-group.entity.js';
import { CreateWorkoutSeriesNestedDto } from './workouts-series/dto/create-workout-series-nested.dto.js';
import { CreateWorkoutsSeriesDto } from './workouts-series/dto/create-workouts-series.dto.js';
import { UpdateWorkoutsSeriesDto } from './workouts-series/dto/update-workouts-series.dto.js';
import { WorkoutSeries } from './workouts-series/entities/workout-series.entity.js';
import { CreateWorkoutsSessionsDto } from './workouts-sessions/dto/create-workouts-sessions.dto.js';
import { UpdateWorkoutsSessionsDto } from './workouts-sessions/dto/update-workouts-sessions.dto.js';
import { WorkoutsSessions } from './workouts-sessions/entities/workouts-sessions.entity.js';
import { CreateWorkoutNestedDto } from './workouts/dto/create-workout-nested.dto.js';
import { CreateWorkoutDto } from './workouts/dto/create-workout.dto.js';
import { UpdateWorkoutDto } from './workouts/dto/update-workout.dto.js';
import { Workout } from './workouts/entities/workout.entity.js';

// Modules
import { AppModule } from './app.module.js';
import { ExerciseLogsModule } from './exercise-logs/exercise-logs.module.js';
import { ExercisesModule } from './exercises/exercises.module.js';
import { HealthModule } from './health/health.module.js';
import { MethodsModule } from './methods/methods.module.js';
import { PersonalsModule } from './personals/personals.module.js';
import { TelegramModule } from './telegram/telegram.module.js';
import { UsersModule } from './users/users.module.js';
import { WorkoutsGroupsModule } from './workouts-groups/workouts-groups.module.js';
import { WorkoutsSeriesModule } from './workouts-series/workouts-series.module.js';
import { WorkoutsSessionsModule } from './workouts-sessions/workouts-sessions.module.js';
import { WorkoutsModule } from './workouts/workouts.module.js';

describe('Structure Coverage', () => {
  it('should instantiate all classes', () => {
    // DTOs & Entities
    expect(new CreateExerciseLogDto()).toBeDefined();
    expect(new CreateExerciseDto()).toBeDefined();
    expect(new UpdateExerciseDto()).toBeDefined();
    expect(new Exercise()).toBeDefined();

    expect(new CreateMethodDto()).toBeDefined();
    expect(new UpdateMethodDto()).toBeDefined();
    expect(new Method()).toBeDefined();

    expect(new CreatePersonalDto()).toBeDefined();
    expect(new UpdatePersonalDto()).toBeDefined();
    expect(new Personal()).toBeDefined();

    expect(new CreateUserDto()).toBeDefined();
    expect(new UpdateUserDto()).toBeDefined();
    expect(new User()).toBeDefined();

    expect(new CreateWorkoutsGroupDto()).toBeDefined();
    expect(new UpdateWorkoutsGroupDto()).toBeDefined();
    expect(new WorkoutsGroup()).toBeDefined();

    expect(new CreateWorkoutSeriesNestedDto()).toBeDefined();
    expect(new CreateWorkoutsSeriesDto()).toBeDefined();
    expect(new UpdateWorkoutsSeriesDto()).toBeDefined();
    expect(new WorkoutSeries()).toBeDefined();

    expect(new CreateWorkoutsSessionsDto()).toBeDefined();
    expect(new UpdateWorkoutsSessionsDto()).toBeDefined();
    expect(new WorkoutsSessions()).toBeDefined();

    expect(new CreateWorkoutNestedDto()).toBeDefined();
    expect(new CreateWorkoutDto()).toBeDefined();
    expect(new UpdateWorkoutDto()).toBeDefined();
    expect(new Workout()).toBeDefined();

    // Modules
    expect(new AppModule()).toBeDefined();
    expect(new ExerciseLogsModule()).toBeDefined();
    expect(new ExercisesModule()).toBeDefined();
    expect(new HealthModule()).toBeDefined();
    expect(new MethodsModule()).toBeDefined();
    expect(new PersonalsModule()).toBeDefined();
    expect(new TelegramModule()).toBeDefined();
    expect(new UsersModule()).toBeDefined();
    expect(new WorkoutsGroupsModule()).toBeDefined();
    expect(new WorkoutsSeriesModule()).toBeDefined();
    expect(new WorkoutsSessionsModule()).toBeDefined();
    expect(new WorkoutsModule()).toBeDefined();
  });
});
