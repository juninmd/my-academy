import { Module } from '@nestjs/common';
import { WorkoutsService } from './workouts.service.js';
import { WorkoutsController } from './workouts.controller.js';
import { CacheModule } from '@nestjs/cache-manager';

@Module({
  imports: [CacheModule.register()],
  controllers: [WorkoutsController],
  providers: [WorkoutsService],
})
export class WorkoutsModule {}
