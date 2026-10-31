import { MiddlewareConsumer, Module, RequestMethod } from '@nestjs/common';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { ExercisesModule } from './exercises/exercises.module.js';
import { WorkoutsSeriesModule } from './workouts-series/workouts-series.module.js';
import { MethodsModule } from './methods/methods.module.js';
import { PersonalsModule } from './personals/personals.module.js';
import { UsersModule } from './users/users.module.js';
import { WorkoutsModule } from './workouts/workouts.module.js';
import { WorkoutsGroupsModule } from './workouts-groups/workouts-groups.module.js';
import { WorkoutsSessionsModule } from './workouts-sessions/workouts-sessions.module.js';
import { PreauthMiddleware } from './auth/firebase.auth.js';
import { HealthModule } from './health/health.module.js';
import { ExerciseLogsModule } from './exercise-logs/exercise-logs.module.js';
import { ProgressModule } from './progress/progress.module.js';
import { PlatesModule } from './plates/plates.module.js';
import { StarterPlansModule } from './starter-plans/starter-plans.module.js';
import { FavoritesModule } from './favorites/favorites.module.js';
import { ImportsModule } from './imports/imports.module.js';
import { ExportModule } from './export/export.module.js';
import { CoachModule } from './coach/coach.module.js';
import { RotationModule } from './rotation/rotation.module.js';
import { BodyWeightModule } from './body-weight/body-weight.module.js';
import { InvitesModule } from './invites/invites.module.js';
import { TelegramModule } from './telegram/telegram.module.js';
import { AssessmentsModule } from './assessments/assessments.module.js';
import { GymsModule } from './gyms/gyms.module.js';
import { PrismaModule } from './prisma.module.js';
import { AppCacheModule } from './cache/app-cache.module.js';
import { AccessModule } from './access/access.module.js';

@Module({
  imports: [
    PrismaModule,
    AppCacheModule,
    AccessModule,
    ExercisesModule,
    WorkoutsSeriesModule,
    MethodsModule,
    PersonalsModule,
    UsersModule,
    WorkoutsModule,
    WorkoutsSessionsModule,
    WorkoutsGroupsModule,
    HealthModule,
    TelegramModule,
    ExerciseLogsModule,
    ProgressModule,
    PlatesModule,
    StarterPlansModule,
    ExportModule,
    FavoritesModule,
    ImportsModule,
    CoachModule,
    RotationModule,
    BodyWeightModule,
    InvitesModule,
    AssessmentsModule,
    GymsModule,
  ],

  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {
  configure(consumer: MiddlewareConsumer) {
    if (process.env.FIREBASE_ENABLED === 'true') {
      consumer
        .apply(PreauthMiddleware)
        .exclude(
          { path: 'health', method: RequestMethod.GET },
          { path: 'api/health', method: RequestMethod.GET },
        )
        .forRoutes({
          path: '{*splat}',
          method: RequestMethod.ALL,
        });
    }
  }
}
