import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto.js';
import { UpdateUserDto } from './dto/update-user.dto.js';
import { PrismaService } from '../prisma.service.js';
import { User } from './entities/user.entity.js';

@Injectable()
export class UsersService {
  constructor(private readonly prismaService: PrismaService) {}

  async create(createusersDto: CreateUserDto): Promise<User> {
    const existing = await this.prismaService.users.findUnique({
      where: { id: createusersDto.id },
    });

    if (existing) {
      throw new ConflictException('User already exists');
    }

    const { id, name, email, photoUrl, telegramId, role } = createusersDto;

    return this.prismaService.users.create({
      data: {
        id,
        name,
        email,
        photoUrl,
        telegramId,
        ...(role && { role }),
      },
    });
  }

  async findAll(email: string): Promise<User[]> {
    return this.prismaService.users.findMany({ where: { email } });
  }

  async findOne(id: string): Promise<User> {
    const user = await this.prismaService.users.findUnique({ where: { id } });
    if (!user) {
      throw new NotFoundException(`User #${id} not found`);
    }
    return user;
  }

  async update(id: string, updateDto: UpdateUserDto): Promise<User> {
    const { name, email, photoUrl, telegramId, role, onboarded } = updateDto;

    try {
      return await this.prismaService.users.update({
        where: { id },
        data: {
          name,
          email,
          photoUrl,
          telegramId,
          ...(role && { role }),
          ...(onboarded && { onboardedAt: new Date() }),
        },
      });
    } catch (error: any) {
      if (error.code === 'P2025') {
        throw new NotFoundException(`User #${id} not found`);
      }
      throw error;
    }
  }

  async remove(id: string): Promise<User> {
    try {
      return await this.prismaService.users.delete({ where: { id } });
    } catch (error: any) {
      if (error.code === 'P2025') {
        throw new NotFoundException(`User #${id} not found`);
      }
      throw error;
    }
  }
}
