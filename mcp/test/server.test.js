import { describe, expect, it } from 'vitest';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { InMemoryTransport } from '@modelcontextprotocol/sdk/inMemory.js';
import { createServer } from '../src/server.js';
import { TOOLS } from '../src/tools.js';
import { config, reply } from './helpers.js';

async function connect(fetchFn) {
  const server = createServer({ config, fetchFn });
  const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
  await server.connect(serverTransport);
  const client = new Client({ name: 'test', version: '1.0.0' });
  await client.connect(clientTransport);
  return client;
}

describe('MCP server', () => {
  it('advertises every tool', async () => {
    const client = await connect(async () => reply(200, {}));
    const { tools } = await client.listTools();
    expect(tools.map((t) => t.name).sort()).toEqual(TOOLS.map((t) => t.name).sort());
  });

  it('answers a tool call with the API data as text', async () => {
    const fetchFn = async () => reply(200, { weeklyRate: -0.2 });
    const client = await connect(fetchFn);
    const result = await client.callTool({ name: 'get_body_weight', arguments: {} });
    expect(result.isError).toBeFalsy();
    expect(JSON.parse(result.content[0].text)).toEqual({ weeklyRate: -0.2 });
  });

  it('reports API failures as tool errors', async () => {
    const client = await connect(async () => reply(404, { message: 'Exercise #9 not found' }));
    const result = await client.callTool({ name: 'get_exercise_progress', arguments: { exerciseId: 9 } });
    expect(result.isError).toBe(true);
    expect(result.content[0].text).toBe('HTTP_404: Exercise #9 not found');
  });

  it('reports unexpected failures without a code', async () => {
    const client = await connect(async () => {
      throw new Error('boom');
    });
    const result = await client.callTool({ name: 'get_body_weight', arguments: {} });
    expect(result.isError).toBe(true);
    expect(result.content[0].text).toBe('ERROR: boom');
  });

  it('defaults missing params to an empty object', async () => {
    const client = await connect(async () => reply(200, []));
    const result = await client.callTool({ name: 'list_starter_plans' });
    expect(result.isError).toBeFalsy();
  });

  it('rejects params the schema does not allow', async () => {
    const client = await connect(async () => reply(200, []));
    const result = await client.callTool({ name: 'get_muscle_overview', arguments: { days: 9999 } });
    expect(result.isError).toBe(true);
    expect(result.content[0].text).toMatch(/Invalid arguments/);
  });
});
