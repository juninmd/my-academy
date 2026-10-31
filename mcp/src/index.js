#!/usr/bin/env node
// stdio transport: the MCP client (Claude Desktop, Cursor, ...) starts this process.
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { loadConfig } from './config.js';
import { createServer } from './server.js';

let config;
try {
  config = loadConfig();
} catch (err) {
  console.error(`[my-academy-mcp] ${err.message}`);
  process.exit(1);
}
const server = createServer({ config });
await server.connect(new StdioServerTransport());
