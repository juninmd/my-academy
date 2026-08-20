import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  Req,
} from '@nestjs/common';
import { WorkoutsSessionsService } from './workouts-sessions.service';
import { CreateWorkoutsSessionsDto } from './dto/create-workouts-sessions.dto';
import { UpdateWorkoutsSessionsDto } from './dto/update-workouts-sessions.dto';
import { FindWorkoutsSessionsDto } from './dto/find-workouts-sessions.dto';

@Controller('workouts-sessions')
export class WorkoutsSessionsController {
  constructor(
    private readonly workoutsSessionsService: WorkoutsSessionsService,
  ) {}

  @Post()
  create(
    @Body() createWorkoutsSessionsDto: CreateWorkoutsSessionsDto,
    @Req() req,
  ) {
    let userId = req.user?.uid || req.user?.user_id || req.user?.id;
    if (!userId && Array.isArray(req.user) && req.user.length > 0) {
      userId = req.user[0].id;
    }
    return this.workoutsSessionsService.create(
      createWorkoutsSessionsDto,
      userId,
    );
  }

  @Get(':idUser')
  findAll(
    @Param('idUser') idUser: string,
    @Query() query: FindWorkoutsSessionsDto,
  ) {
    return this.workoutsSessionsService.findAll(
      idUser,
      +query.year,
      +query.month,
    );
  }

  @Get(':idUser/summary')
  findSummary(@Param('idUser') idUser: string) {
    return this.workoutsSessionsService.findSummary(idUser);
  }

  @Get('single/:id')
  findOne(@Param('id') id: string) {
    return this.workoutsSessionsService.findOne(+id);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateWorkoutsSessionsDto: UpdateWorkoutsSessionsDto,
  ) {
    return this.workoutsSessionsService.update(+id, updateWorkoutsSessionsDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.workoutsSessionsService.remove(+id);
  }
}
