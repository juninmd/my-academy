import {
  BadGatewayException,
  ServiceUnavailableException,
} from '@nestjs/common';
import { CoachService } from './coach.service.js';

const reply = (status: number, body: unknown = {}) =>
  ({
    ok: status >= 200 && status < 300,
    status,
    json: async () => body,
  }) as Response;

describe('CoachService', () => {
  const progress = {
    summary: vi.fn(),
    muscles: vi.fn(),
    bodyWeight: vi.fn(),
  };
  let service: CoachService;
  const original = process.env.ANTHROPIC_API_KEY;
  const originalModel = process.env.COACH_MODEL;

  beforeEach(() => {
    vi.clearAllMocks();
    process.env.ANTHROPIC_API_KEY = 'sk-test';
    delete process.env.COACH_MODEL;
    progress.summary.mockResolvedValue({
      trainingDays: 3,
      totalSets: 12,
      totalVolume: 4000,
      weeklyVolume: [{ weekStart: '2026-10-26', volume: 4000 }],
      activity: [],
    });
    progress.muscles.mockResolvedValue({
      days: 30,
      muscles: [
        {
          muscle: 'chest',
          weightedSets: 6,
          lastTrained: '2026-10-29',
          state: 'recovering',
        },
        {
          muscle: 'quads',
          weightedSets: 0,
          lastTrained: null,
          state: 'untrained',
        },
      ],
      balance: [
        {
          key: 'chest_back',
          label: 'Chest vs back',
          left: 6,
          right: 0,
          ratio: null,
          status: 'right_untrained',
        },
      ],
    });
    progress.bodyWeight.mockResolvedValue({
      points: [],
      latest: 80,
      change: -1,
      weeklyRate: -0.2,
    });
    service = new CoachService(progress as never);
  });

  afterAll(() => {
    if (original === undefined) delete process.env.ANTHROPIC_API_KEY;
    else process.env.ANTHROPIC_API_KEY = original;
    if (originalModel === undefined) delete process.env.COACH_MODEL;
    else process.env.COACH_MODEL = originalModel;
  });

  it('is off without an API key', async () => {
    delete process.env.ANTHROPIC_API_KEY;
    await expect(service.advise('u1')).rejects.toThrow(
      ServiceUnavailableException,
    );
  });

  it('sends only the summary data and returns the advice text', async () => {
    const fetchFn = vi.fn().mockResolvedValue(
      reply(200, {
        content: [{ type: 'text', text: 'Chest is ahead of back.' }],
      }),
    );

    const result = await service.advise('u1', 14, fetchFn as never);

    expect(result).toMatchObject({
      advice: 'Chest is ahead of back.',
      model: 'claude-sonnet-5-5',
      days: 14,
    });
    expect(progress.summary).toHaveBeenCalledWith('u1', 14);
    const [url, init] = fetchFn.mock.calls[0];
    expect(url).toBe('https://api.anthropic.com/v1/messages');
    expect(init.headers).toMatchObject({
      'x-api-key': 'sk-test',
      'anthropic-version': '2023-06-01',
    });
    const sent = JSON.parse(init.body);
    expect(sent.model).toBe('claude-sonnet-5-5');
    expect(sent.messages[0].content).toContain('"muscles":[{"muscle":"chest"');
    expect(sent.messages[0].content).not.toContain('quads');
  });

  it('uses COACH_MODEL and the default days', async () => {
    process.env.COACH_MODEL = 'claude-haiku-5-5';
    const fetchFn = vi
      .fn()
      .mockResolvedValue(
        reply(200, { content: [{ type: 'text', text: 'ok' }] }),
      );
    const result = await service.advise('u1', undefined, fetchFn as never);
    expect(result).toMatchObject({ model: 'claude-haiku-5-5', days: 30 });
    expect(progress.summary).toHaveBeenCalledWith('u1', 30);
  });

  it('reports provider errors and empty answers as bad gateway', async () => {
    await expect(
      service.advise('u1', 30, vi.fn().mockResolvedValue(reply(529)) as never),
    ).rejects.toThrow(BadGatewayException);
    await expect(
      service.advise(
        'u1',
        30,
        vi
          .fn()
          .mockResolvedValue(
            reply(200, { content: [{ type: 'tool_use' }] }),
          ) as never,
      ),
    ).rejects.toThrow(BadGatewayException);
    await expect(
      service.advise(
        'u1',
        30,
        vi.fn().mockResolvedValue(reply(200, {})) as never,
      ),
    ).rejects.toThrow(BadGatewayException);
  });

  it('falls back to the global fetch', async () => {
    const original = globalThis.fetch;
    globalThis.fetch = vi
      .fn()
      .mockResolvedValue(
        reply(200, { content: [{ type: 'text', text: 'hi' }] }),
      ) as never;
    try {
      expect(await service.advise('u1')).toMatchObject({ advice: 'hi' });
    } finally {
      globalThis.fetch = original;
    }
  });
});
