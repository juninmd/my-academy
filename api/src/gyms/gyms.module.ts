import { Module } from '@nestjs/common';
import { GymsService } from './gyms.service';
import { PrismaService } from '../prisma.service';

@Module({
  providers: [GymsService, PrismaService],
  exports: [GymsService],
})
export class GymsModule {}
