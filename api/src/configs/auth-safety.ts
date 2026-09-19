/**
 * Refuses to boot a production API without real authentication: with
 * FIREBASE_ENABLED off no user is resolved and access checks cannot apply.
 */
export function assertSafeAuthConfig(env: NodeJS.ProcessEnv = process.env) {
  if (env.NODE_ENV !== 'production') return;
  if (env.FIREBASE_ENABLED !== 'true') {
    throw new Error('FIREBASE_ENABLED must be "true" in production');
  }
  if (env.AUTH_MOC_ENABLED === 'true') {
    throw new Error('AUTH_MOC_ENABLED must not be "true" in production');
  }
}
