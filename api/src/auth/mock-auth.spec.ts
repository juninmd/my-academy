import { resolveMockUser } from './mock-auth.js';

describe('resolveMockUser', () => {
  const users = JSON.stringify([
    { uid: 'student-1', email: 's@x.io' },
    { user_id: 'personal-1', email: 'p@x.io' },
  ]);

  it('selects the first user for the bare token (backwards compatible)', () => {
    expect(resolveMockUser('Bearer tk', 'tk', users)).toEqual({
      uid: 'student-1',
      email: 's@x.io',
    });
  });

  it('selects a persona by uid and normalizes user_id into uid', () => {
    expect(resolveMockUser('Bearer tk:personal-1', 'tk', users)).toEqual({
      user_id: 'personal-1',
      email: 'p@x.io',
      uid: 'personal-1',
    });
  });

  it('accepts a single object config', () => {
    expect(resolveMockUser('Bearer tk', 'tk', '{"id":"only"}')).toEqual({
      id: 'only',
      uid: 'only',
    });
  });

  it.each([
    ['unknown uid', 'Bearer tk:ghost'],
    ['token with a different suffix', 'Bearer tkX'],
    ['wrong token', 'Bearer other'],
    ['missing header', undefined],
  ])('rejects %s so the request falls through to real auth', (_, header) => {
    expect(resolveMockUser(header, 'tk', users)).toBeNull();
  });

  it('is disabled when token or users are not configured', () => {
    expect(resolveMockUser('Bearer ', '', users)).toBeNull();
    expect(resolveMockUser('Bearer tk', 'tk', undefined)).toBeNull();
  });
});
