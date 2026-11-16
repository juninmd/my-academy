import { Module } from '@nestjs/common';
import { CoachController } from './coach.controller.js';
import { CoachService } from './coach.service.js';
import { ProgressModule } from '../progress/progress.module.js';

@Module({
  imports: [ProgressModule],
  controllers: [CoachController],
  providers: [CoachService],
})
export class CoachModule {}
