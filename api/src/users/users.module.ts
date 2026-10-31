import { Module } from '@nestjs/common';
import { UsersService } from './users.service.js';
import { UsersController } from './users.controller.js';
import { InvitesModule } from '../invites/invites.module.js';

@Module({
  imports: [InvitesModule],
  controllers: [UsersController],
  providers: [UsersService],
})
export class UsersModule {}
