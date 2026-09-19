import { Module } from '@nestjs/common';
import { WorkoutsGroupsService } from './workouts-groups.service.js';
import { WorkoutsGroupsController } from './workouts-groups.controller.js';
import { CacheModule } from '@nestjs/cache-manager';

@Module({
  imports: [CacheModule.register()],
  controllers: [WorkoutsGroupsController],
  providers: [WorkoutsGroupsService],
})
export class WorkoutsGroupsModule {}
