export const config = { apiUrl: 'http://api.test', token: 'tok', userId: 'u1' };

export function reply(status, body) {
  const text = body === undefined ? '' : JSON.stringify(body);
  return { ok: status >= 200 && status < 300, status, text: async () => text };
}
