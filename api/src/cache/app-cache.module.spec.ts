import { cacheOptionsFactory, CACHE_TTL_MS } from './app-cache.module.js';

describe('cacheOptionsFactory', () => {
  const originalUrl = process.env.REDIS_URL;

  afterEach(() => {
    process.env.REDIS_URL = originalUrl;
  });

  it('falls back to the in-memory store when REDIS_URL is unset', () => {
    delete process.env.REDIS_URL;
    expect(cacheOptionsFactory()).toEqual({ ttl: CACHE_TTL_MS });
  });

  it('uses a Redis store when REDIS_URL is set', () => {
    process.env.REDIS_URL = 'redis://localhost:6379';
    const options = cacheOptionsFactory();
    expect(options.ttl).toBe(CACHE_TTL_MS);
    expect(options.stores).toHaveLength(1);
  });
});
