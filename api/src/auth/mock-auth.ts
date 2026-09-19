export type MockClaims = Record<string, unknown> & { uid: string };

const claimId = (claims: Record<string, unknown>): string | undefined =>
  (claims.uid ?? claims.user_id ?? claims.id) as string | undefined;

/**
 * Resolves a mock identity for local homologation. `Bearer <token>` selects the
 * first configured user; `Bearer <token>:<uid>` selects the user with that uid.
 */
export function resolveMockUser(
  authorization: string | undefined,
  token: string | undefined,
  json: string | undefined,
): MockClaims | null {
  const prefix = `Bearer ${token}`;
  if (!token || !json || !authorization?.startsWith(prefix)) return null;

  const suffix = authorization.slice(prefix.length);
  if (suffix !== '' && !suffix.startsWith(':')) return null;

  const parsed: unknown = JSON.parse(json);
  const users = (Array.isArray(parsed) ? parsed : [parsed]) as Record<
    string,
    unknown
  >[];
  const wantedUid = suffix.slice(1);
  const match = wantedUid
    ? users.find((u) => claimId(u) === wantedUid)
    : users[0];
  if (!match) return null;

  return { ...match, uid: claimId(match) as string };
}
