import { Module } from '@nestjs/common';
import { GymsService } from './gyms.service.js';
import { GymMembersService } from './gym-members.service.js';
import { GymsController } from './gyms.controller.js';

@Module({
  controllers: [GymsController],
  providers: [GymsService, GymMembersService],
  exports: [GymsService],
})
export class GymsModule {}
