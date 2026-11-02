import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { createApi } from './api.js';
import { TOOLS } from './tools.js';

/** Builds the MCP server; `fetchFn` is injectable for tests. */
export function createServer({ config, fetchFn }) {
  const api = createApi(config, fetchFn);
  const server = new McpServer({ name: 'my-academy', version: '0.1.0' });

  for (const tool of TOOLS) {
    server.tool(tool.name, tool.description, tool.schema, async (params) => {
      try {
        const result = await tool.handler({ api, userId: config.userId }, params);
        return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
      } catch (err) {
        return {
          isError: true,
          content: [{ type: 'text', text: `${err.code ?? 'ERROR'}: ${err.message}` }],
        };
      }
    });
  }
  return server;
}
