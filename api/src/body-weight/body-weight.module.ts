import { Module } from '@nestjs/common';
import { BodyWeightController } from './body-weight.controller.js';
import { BodyWeightService } from './body-weight.service.js';

@Module({
  controllers: [BodyWeightController],
  providers: [BodyWeightService],
  exports: [BodyWeightService],
})
export class BodyWeightModule {}
