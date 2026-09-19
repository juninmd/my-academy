import { AppModule } from './app.module.js';
import { MiddlewareConsumer, RequestMethod } from '@nestjs/common';
import { PreauthMiddleware } from './auth/firebase.auth.js';

describe('AppModule', () => {
  let appModule: AppModule;
  const originalEnv = process.env;

  beforeEach(() => {
    vi.resetModules();
    process.env = { ...originalEnv };
    appModule = new AppModule();
  });

  afterAll(() => {
    process.env = originalEnv;
  });

  it('should be defined', () => {
    expect(appModule).toBeDefined();
  });

  it('should apply middleware if FIREBASE_ENABLED is true', () => {
    process.env.FIREBASE_ENABLED = 'true';

    const consumer = {
      apply: vi.fn().mockReturnThis(),
      exclude: vi.fn().mockReturnThis(),
      forRoutes: vi.fn().mockReturnThis(),
    };

    appModule.configure(consumer as unknown as MiddlewareConsumer);

    expect(consumer.apply).toHaveBeenCalledWith(PreauthMiddleware);
    expect(consumer.exclude).toHaveBeenCalledWith(
      { path: 'health', method: RequestMethod.GET },
      { path: 'api/health', method: RequestMethod.GET },
    );
    expect(consumer.forRoutes).toHaveBeenCalledWith({
      path: '{*splat}',
      method: RequestMethod.ALL,
    });
  });

  it('should NOT apply middleware if FIREBASE_ENABLED is false', () => {
    process.env.FIREBASE_ENABLED = 'false';

    const consumer = {
      apply: vi.fn().mockReturnThis(),
      exclude: vi.fn().mockReturnThis(),
      forRoutes: vi.fn().mockReturnThis(),
    };

    appModule.configure(consumer as unknown as MiddlewareConsumer);

    expect(consumer.apply).not.toHaveBeenCalled();
  });
});
