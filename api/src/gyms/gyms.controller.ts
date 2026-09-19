import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { AccessService } from '../access/access.service.js';
import { CurrentUserId } from '../access/current-user.decorator.js';
import {
  CreateGymDto,
  CreatePlanDto,
  CreateSubscriptionDto,
  FindPaymentsDto,
  FindSubscriptionsDto,
  PageQueryDto,
  UpdateGymDto,
  UpdatePaymentDto,
  UpdatePlanDto,
  UpdateSubscriptionDto,
} from './dto/gym.dto.js';
import { GymMembersService } from './gym-members.service.js';
import { GymsService } from './gyms.service.js';

type Actor = string | undefined;

@ApiTags('Gyms')
@Controller('gyms')
export class GymsController {
  constructor(
    private readonly gyms: GymsService,
    private readonly members: GymMembersService,
    private readonly access: AccessService,
  ) {}

  @Post()
  @ApiOperation({ summary: 'Create a gym owned by the current user (OWNER)' })
  async create(@CurrentUserId() actor: Actor, @Body() dto: CreateGymDto) {
    await this.access.assertRole(actor, Role.OWNER, Role.ADMIN);
    return this.gyms.createGym(actor, dto);
  }

  @Get()
  @ApiOperation({ summary: 'List gyms with their plans (paginated)' })
  findAll(@Query() query: PageQueryDto) {
    return this.gyms.findAllGyms(query);
  }

  @Get('mine')
  @ApiOperation({ summary: 'Gyms owned by the current user' })
  findMine(@CurrentUserId() actor: Actor) {
    return this.gyms.findOwnedGyms(actor);
  }

  @Get('subscriptions/me')
  @ApiOperation({ summary: 'Current user gym memberships and payments' })
  findMySubscriptions(@CurrentUserId() actor: Actor) {
    return this.members.findUserSubscriptions(actor);
  }

  @Patch(':id')
  async update(
    @CurrentUserId() actor: Actor,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateGymDto,
  ) {
    await this.access.assertGymOwner(actor, id);
    return this.gyms.updateGym(id, dto);
  }

  @Get(':id/dashboard')
  @ApiOperation({ summary: 'Owner KPIs: members, pending/overdue, revenue' })
  async dashboard(
    @CurrentUserId() actor: Actor,
    @Param('id', ParseIntPipe) id: number,
  ) {
    await this.access.assertGymOwner(actor, id);
    return this.gyms.getDashboard(id);
  }

  @Get(':id/plans')
  findPlans(@Param('id', ParseIntPipe) id: number) {
    return this.gyms.findGymPlans(id);
  }

  @Post(':id/plans')
  async createPlan(
    @CurrentUserId() actor: Actor,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: CreatePlanDto,
  ) {
    await this.access.assertGymOwner(actor, id);
    return this.gyms.createPlan(id, dto);
  }

  @Patch(':id/plans/:planId')
  async updatePlan(
    @CurrentUserId() actor: Actor,
    @Param('id', ParseIntPipe) id: number,
    @Param('planId', ParseIntPipe) planId: number,
    @Body() dto: UpdatePlanDto,
  ) {
    await this.access.assertGymOwner(actor, id);
    return this.gyms.updatePlan(id, planId, dto);
  }

  @Get(':id/subscriptions')
  async findSubscriptions(
    @CurrentUserId() actor: Actor,
    @Param('id', ParseIntPipe) id: number,
    @Query() query: FindSubscriptionsDto,
  ) {
    await this.access.assertGymOwner(actor, id);
    return this.members.findSubscriptions(id, query);
  }

  @Post(':id/subscriptions')
  @ApiOperation({ summary: 'Enroll a registered user by email on a plan' })
  async subscribe(
    @CurrentUserId() actor: Actor,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: CreateSubscriptionDto,
  ) {
    await this.access.assertGymOwner(actor, id);
    return this.members.subscribe(id, dto);
  }

  @Patch(':id/subscriptions/:subscriptionId')
  async updateSubscription(
    @CurrentUserId() actor: Actor,
    @Param('id', ParseIntPipe) id: number,
    @Param('subscriptionId', ParseIntPipe) subscriptionId: number,
    @Body() dto: UpdateSubscriptionDto,
  ) {
    await this.access.assertGymOwner(actor, id);
    return this.members.updateSubscription(id, subscriptionId, dto);
  }

  @Get(':id/payments')
  async findPayments(
    @CurrentUserId() actor: Actor,
    @Param('id', ParseIntPipe) id: number,
    @Query() query: FindPaymentsDto,
  ) {
    await this.access.assertGymOwner(actor, id);
    return this.members.findPayments(id, query);
  }

  @Patch(':id/payments/:paymentId')
  async updatePayment(
    @CurrentUserId() actor: Actor,
    @Param('id', ParseIntPipe) id: number,
    @Param('paymentId', ParseIntPipe) paymentId: number,
    @Body() dto: UpdatePaymentDto,
  ) {
    await this.access.assertGymOwner(actor, id);
    return this.members.updatePayment(id, paymentId, dto);
  }
}
