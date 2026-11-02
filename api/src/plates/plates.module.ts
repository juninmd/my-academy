import { Module } from '@nestjs/common';
import { PlatesController } from './plates.controller.js';

@Module({ controllers: [PlatesController] })
export class PlatesModule {}
