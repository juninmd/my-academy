import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { CACHE_MANAGER, Cache } from '@nestjs/cache-manager';
import { PrismaService } from '../prisma.service.js';
import { CreateMethodDto } from './dto/create-method.dto.js';
import { UpdateMethodDto } from './dto/update-method.dto.js';
import { Method } from './entities/method.entity.js';

export const METHODS_CACHE_KEY = '/api/methods';

@Injectable()
export class MethodsService {
  constructor(
    private readonly prismaService: PrismaService,
    @Inject(CACHE_MANAGER) private readonly cache: Cache,
  ) {}

  async create(createMethodsDto: CreateMethodDto): Promise<Method> {
    const { name, description } = createMethodsDto;
    const result = await this.prismaService.methods.create({
      data: {
        name,
        description,
      },
    });
    await this.cache.del(METHODS_CACHE_KEY);
    return result;
  }

  async findAll(): Promise<Method[]> {
    return this.prismaService.methods.findMany();
  }

  async findOne(id: number): Promise<Method> {
    const method = await this.prismaService.methods.findUnique({
      where: { id },
    });
    if (!method) {
      throw new NotFoundException(`Method #${id} not found`);
    }
    return method;
  }

  async update(id: number, updateDto: UpdateMethodDto): Promise<Method> {
    await this.findOne(id);
    const { name, description } = updateDto;
    const result = await this.prismaService.methods.update({
      where: { id },
      data: {
        name,
        description,
      },
    });
    await this.cache.del(METHODS_CACHE_KEY);
    return result;
  }

  async remove(id: number): Promise<Method> {
    await this.findOne(id);
    const result = await this.prismaService.methods.delete({ where: { id } });
    await this.cache.del(METHODS_CACHE_KEY);
    return result;
  }
}
