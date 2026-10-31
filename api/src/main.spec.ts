import type { Mock, MockInstance } from 'vitest';
import { NestFactory } from '@nestjs/core';

const app = {
  useBodyParser: vi.fn(),
  useGlobalPipes: vi.fn(),
  enableCors: vi.fn(),
  use: vi.fn(),
  setGlobalPrefix: vi.fn(),
  listen: vi.fn(),
};
const logger = vi.hoisted(() => ({ log: vi.fn(), error: vi.fn() }));

vi.mock('@nestjs/core', async (importOriginal) => ({
  ...(await importOriginal<object>()),
  NestFactory: { create: vi.fn() },
}));

vi.mock('@nestjs/common', async (importOriginal) => ({
  ...(await importOriginal<object>()),
  Logger: vi.fn(function () {
    return logger;
  }),
}));

vi.mock('@nestjs/swagger', async (importOriginal) => ({
  ...(await importOriginal<object>()),
  SwaggerModule: { createDocument: vi.fn(), setup: vi.fn() },
  DocumentBuilder: vi.fn(function () {
    const builder = {
      setTitle: () => builder,
      setDescription: () => builder,
      setVersion: () => builder,
      addBearerAuth: () => builder,
      build: vi.fn(),
    };
    return builder;
  }),
}));

vi.mock('@scalar/nestjs-api-reference', () => ({ apiReference: vi.fn() }));

const runMain = async () => {
  vi.resetModules();
  await import('./main.js');
};

describe('Main', () => {
  let exit: MockInstance;

  beforeEach(() => {
    (NestFactory.create as Mock).mockResolvedValue(app);
    exit = vi.spyOn(process, 'exit').mockImplementation((() => {}) as any);
  });

  afterEach(() => {
    exit.mockRestore();
    vi.clearAllMocks();
    delete process.env.CORS_ORIGINS;
  });

  it('boots with validation, /api prefix and open CORS by default', async () => {
    await runMain();
    await vi.waitFor(() => expect(app.listen).toHaveBeenCalledWith(9000));
    expect(app.useBodyParser).toHaveBeenCalledWith('json', { limit: '25mb' });
    expect(app.useBodyParser).toHaveBeenCalledWith('urlencoded', {
      limit: '25mb',
      extended: true,
    });
    expect(app.setGlobalPrefix).toHaveBeenCalledWith('api', {
      exclude: ['docs', 'health'],
    });
    expect(app.enableCors).toHaveBeenCalledWith(
      expect.objectContaining({ origin: '*', credentials: false }),
    );
  });

  it('restricts CORS to configured origins', async () => {
    process.env.CORS_ORIGINS = 'http://a.io, http://b.io';
    await runMain();
    await vi.waitFor(() =>
      expect(app.enableCors).toHaveBeenCalledWith(
        expect.objectContaining({
          origin: ['http://a.io', 'http://b.io'],
          credentials: true,
        }),
      ),
    );
  });

  it('exits with code 1 when bootstrap fails', async () => {
    (NestFactory.create as Mock).mockRejectedValueOnce(new Error('boom'));
    await runMain();
    await vi.waitFor(() => expect(exit).toHaveBeenCalledWith(1));
  });

  it('logs unexpected errors raised while handling a failed bootstrap', async () => {
    (NestFactory.create as Mock).mockRejectedValueOnce(new Error('boom'));
    logger.error.mockImplementationOnce(() => {
      throw new Error('logger down');
    });
    await runMain();
    await vi.waitFor(() => expect(logger.error).toHaveBeenCalledTimes(2));
  });
});
