/**
 * Reads the server settings from the environment.
 *   MY_ACADEMY_USER_ID   required: the student the assistant reads about
 *   MY_ACADEMY_API_URL   optional: API base URL, default http://localhost:9000/api
 *   MY_ACADEMY_TOKEN     optional: bearer token (Firebase ID token, or mock token locally)
 */
export function loadConfig(env = process.env) {
  const userId = env.MY_ACADEMY_USER_ID;
  if (!userId) {
    throw new Error('MY_ACADEMY_USER_ID is required');
  }
  return {
    apiUrl: (env.MY_ACADEMY_API_URL || 'http://localhost:9000/api').replace(/\/+$/, ''),
    token: env.MY_ACADEMY_TOKEN || '',
    userId,
  };
}
