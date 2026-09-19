import { createParamDecorator, ExecutionContext } from '@nestjs/common';

/**
 * Authenticated user id, or undefined when the auth middleware is disabled
 * (FIREBASE_ENABLED != 'true'); AccessService treats undefined as "no checks".
 */
export const extractUserId = (ctx: ExecutionContext): string | undefined => {
  const user = ctx.switchToHttp().getRequest().user;
  return user?.uid ?? user?.user_id ?? user?.id;
};

export const CurrentUserId = createParamDecorator(
  (_: unknown, ctx: ExecutionContext) => extractUserId(ctx),
);
