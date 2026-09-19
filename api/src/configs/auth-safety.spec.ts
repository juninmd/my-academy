import { assertSafeAuthConfig } from './auth-safety.js';

describe('assertSafeAuthConfig', () => {
  it('allows any auth setup outside production (local stack, tests)', () => {
    expect(() =>
      assertSafeAuthConfig({
        NODE_ENV: 'development',
        AUTH_MOC_ENABLED: 'true',
      }),
    ).not.toThrow();
  });

  it('allows production with Firebase and no mock auth', () => {
    expect(() =>
      assertSafeAuthConfig({
        NODE_ENV: 'production',
        FIREBASE_ENABLED: 'true',
      }),
    ).not.toThrow();
  });

  it('refuses production without Firebase, which would skip every access check', () => {
    expect(() => assertSafeAuthConfig({ NODE_ENV: 'production' })).toThrow(
      'FIREBASE_ENABLED',
    );
  });

  it('refuses production with mock identities enabled', () => {
    expect(() =>
      assertSafeAuthConfig({
        NODE_ENV: 'production',
        FIREBASE_ENABLED: 'true',
        AUTH_MOC_ENABLED: 'true',
      }),
    ).toThrow('AUTH_MOC_ENABLED');
  });

  it('reads process.env by default', () => {
    expect(() => assertSafeAuthConfig()).not.toThrow();
  });
});
