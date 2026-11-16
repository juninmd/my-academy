import { Module } from '@nestjs/common';
import { StarterPlansController } from './starter-plans.controller.js';
import { StarterPlansService } from './starter-plans.service.js';

@Module({
  controllers: [StarterPlansController],
  providers: [StarterPlansService],
})
export class StarterPlansModule {}
