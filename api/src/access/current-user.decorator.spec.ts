import { ExecutionContext } from '@nestjs/common';
import { ROUTE_ARGS_METADATA } from '@nestjs/common/constants.js';
import { CurrentUserId, extractUserId } from './current-user.decorator.js';

const ctxWith = (user: unknown) =>
  ({
    switchToHttp: () => ({ getRequest: () => ({ user }) }),
  }) as unknown as ExecutionContext;

describe('extractUserId', () => {
  it.each([
    [{ uid: 'a' }, 'a'],
    [{ user_id: 'b' }, 'b'],
    [{ id: 'c' }, 'c'],
    [undefined, undefined],
  ])('reads %j', (user, expected) => {
    expect(extractUserId(ctxWith(user))).toBe(expected);
  });
});

describe('@CurrentUserId', () => {
  it('injects the authenticated uid into the handler argument', () => {
    class Probe {
      handler(@CurrentUserId() _actor: string) {}
    }
    const meta = Reflect.getMetadata(ROUTE_ARGS_METADATA, Probe, 'handler');
    const { factory } = Object.values(meta)[0] as {
      factory: (data: unknown, ctx: ExecutionContext) => unknown;
    };
    expect(factory(undefined, ctxWith({ uid: 'me' }))).toBe('me');
  });
});
