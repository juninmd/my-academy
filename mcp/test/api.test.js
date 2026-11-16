import { describe, expect, it, vi } from 'vitest';
import { createApi } from '../src/api.js';
import { config, reply } from './helpers.js';

describe('createApi', () => {
  it('sends the bearer token and query, skipping empty values', async () => {
    const fetchFn = vi.fn().mockResolvedValue(reply(200, { ok: true }));
    const api = createApi(config, fetchFn);

    expect(await api.get('progress/muscles', { userId: 'u1', days: 30, bar: undefined, x: null })).toEqual({ ok: true });

    const [url, init] = fetchFn.mock.calls[0];
    expect(url.toString()).toBe('http://api.test/progress/muscles?userId=u1&days=30');
    expect(init.method).toBe('GET');
    expect(init.headers).toEqual({ accept: 'application/json', authorization: 'Bearer tok' });
    expect(init.body).toBeUndefined();
  });

  it('posts JSON bodies', async () => {
    const fetchFn = vi.fn().mockResolvedValue(reply(201, { advice: 'x' }));
    const api = createApi({ ...config, token: '' }, fetchFn);

    await api.post('coach/advice', { userId: 'u1', days: 14 });

    const [, init] = fetchFn.mock.calls[0];
    expect(init.method).toBe('POST');
    expect(init.headers).toEqual({ accept: 'application/json', 'content-type': 'application/json' });
    expect(JSON.parse(init.body)).toEqual({ userId: 'u1', days: 14 });
  });

  it('returns null for an empty body', async () => {
    const api = createApi(config, vi.fn().mockResolvedValue(reply(200)));
    expect(await api.get('x')).toBeNull();
  });

  it('turns API errors into coded errors with the server message', async () => {
    const withList = createApi(
      config,
      vi.fn().mockResolvedValue(reply(400, { message: ['target too small', 'bar invalid'] })),
    );
    await expect(withList.get('plates')).rejects.toMatchObject({
      code: 'HTTP_400',
      message: 'target too small; bar invalid',
    });

    const withText = createApi(config, vi.fn().mockResolvedValue(reply(404, { message: 'Exercise #9 not found' })));
    await expect(withText.get('x')).rejects.toMatchObject({ code: 'HTTP_404', message: 'Exercise #9 not found' });

    const bare = createApi(config, vi.fn().mockResolvedValue(reply(502)));
    await expect(bare.get('x')).rejects.toMatchObject({ code: 'HTTP_502', message: 'API answered 502' });
  });
});
