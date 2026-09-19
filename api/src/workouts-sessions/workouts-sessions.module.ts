import { Module } from '@nestjs/common';
import { WorkoutsSessionsService } from './workouts-sessions.service.js';
import { WorkoutsSessionsController } from './workouts-sessions.controller.js';
import { TelegramService } from '../telegram/telegram.service.js';

@Module({
  controllers: [WorkoutsSessionsController],
  providers: [WorkoutsSessionsService, TelegramService],
})
export class WorkoutsSessionsModule {}
