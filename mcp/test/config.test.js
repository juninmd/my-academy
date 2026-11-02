import { describe, expect, it } from 'vitest';
import { loadConfig } from '../src/config.js';

describe('loadConfig', () => {
  it('requires a user id', () => {
    expect(() => loadConfig({})).toThrow('MY_ACADEMY_USER_ID is required');
  });

  it('uses defaults and trims trailing slashes', () => {
    expect(loadConfig({ MY_ACADEMY_USER_ID: 'u1' })).toEqual({
      apiUrl: 'http://localhost:9000/api',
      token: '',
      userId: 'u1',
    });
    expect(
      loadConfig({ MY_ACADEMY_USER_ID: 'u1', MY_ACADEMY_API_URL: 'https://x.test/api//', MY_ACADEMY_TOKEN: 't' }),
    ).toEqual({ apiUrl: 'https://x.test/api', token: 't', userId: 'u1' });
  });
});
