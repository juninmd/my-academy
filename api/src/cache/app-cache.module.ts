import { Module } from '@nestjs/common';
import { CacheModule } from '@nestjs/cache-manager';
import { createKeyv } from '@keyv/redis';

export const CACHE_TTL_MS = 5 * 60 * 1000;

export const cacheOptionsFactory = () => {
  const redisUrl = process.env.REDIS_URL;
  return {
    ttl: CACHE_TTL_MS,
    ...(redisUrl ? { stores: [createKeyv(redisUrl)] } : {}),
  };
};

@Module({
  imports: [
    CacheModule.registerAsync({
      isGlobal: true,
      useFactory: cacheOptionsFactory,
    }),
  ],
})
export class AppCacheModule {}
