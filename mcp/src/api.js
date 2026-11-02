/** Minimal JSON client for the My Academy API. Errors carry `code` = HTTP_<status>. */
export function createApi(config, fetchFn = fetch) {
  const baseHeaders = { accept: 'application/json' };
  if (config.token) baseHeaders.authorization = `Bearer ${config.token}`;

  async function request(method, path, { query, body } = {}) {
    const url = new URL(`${config.apiUrl}/${path}`);
    for (const [key, value] of Object.entries(query ?? {})) {
      if (value !== undefined && value !== null) url.searchParams.set(key, String(value));
    }
    const res = await fetchFn(url, {
      method,
      headers: body === undefined ? baseHeaders : { ...baseHeaders, 'content-type': 'application/json' },
      body: body === undefined ? undefined : JSON.stringify(body),
    });
    const text = await res.text();
    const data = text ? JSON.parse(text) : null;
    if (!res.ok) {
      const message = Array.isArray(data?.message) ? data.message.join('; ') : data?.message;
      const error = new Error(message ?? `API answered ${res.status}`);
      error.code = `HTTP_${res.status}`;
      throw error;
    }
    return data;
  }

  return {
    get: (path, query) => request('GET', path, { query }),
    post: (path, body) => request('POST', path, { body }),
  };
}
