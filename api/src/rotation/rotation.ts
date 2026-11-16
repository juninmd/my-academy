/**
 * Next routine in an A, B, C, A, ... rotation. `groupIds` are in rotation order.
 * With no history, or when the last routine was deleted, the rotation starts over.
 */
export function nextInRotation(
  groupIds: number[],
  lastGroupId: number | null,
): number | null {
  if (groupIds.length === 0) return null;
  const last = lastGroupId === null ? -1 : groupIds.indexOf(lastGroupId);
  return groupIds[(last + 1) % groupIds.length];
}
