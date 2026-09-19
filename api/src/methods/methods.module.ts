import { Module } from '@nestjs/common';
import { MethodsService } from './methods.service.js';
import { MethodsController } from './methods.controller.js';

@Module({
  controllers: [MethodsController],
  providers: [MethodsService],
})
export class MethodsModule {}
