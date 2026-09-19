import { Module } from '@nestjs/common';
import { PersonalsService } from './personals.service.js';
import { PersonalsController } from './personals.controller.js';

@Module({
  controllers: [PersonalsController],
  providers: [PersonalsService],
})
export class PersonalsModule {}
