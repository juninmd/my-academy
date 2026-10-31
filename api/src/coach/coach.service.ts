import {
  BadGatewayException,
  Injectable,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ProgressService } from '../progress/progress.service.js';

export const ANTHROPIC_URL = 'https://api.anthropic.com/v1/messages';
export const ANTHROPIC_VERSION = '2023-06-01';
export const DEFAULT_COACH_MODEL = 'claude-sonnet-5-5';

const SYSTEM_PROMPT =
  "You are a strength coach reviewing one athlete's training data. Be concrete and brief. " +
  'Only comment on the numbers you are given. Suggest, never prescribe medical treatment. ' +
  'Reply in the language of the data labels when they are not English, otherwise in English.';

type Fetch = (url: string, init: RequestInit) => Promise<Response>;

@Injectable()
export class CoachService {
  constructor(private readonly progress: ProgressService) {}

  /**
   * Read-only advice from an LLM about the last `days` of training. It never changes a
   * routine or a log. Off unless ANTHROPIC_API_KEY is set; data leaves the server only
   * for this request.
   */
  async advise(userId: string, days = 30, fetchFn: Fetch = fetch) {
    const apiKey = process.env.ANTHROPIC_API_KEY;
    if (!apiKey) {
      throw new ServiceUnavailableException(
        'AI coach is off: set ANTHROPIC_API_KEY',
      );
    }
    const model = process.env.COACH_MODEL || DEFAULT_COACH_MODEL;

    const [summary, muscles, bodyWeight] = await Promise.all([
      this.progress.summary(userId, days),
      this.progress.muscles(userId, days),
      this.progress.bodyWeight(userId),
    ]);
    const context = {
      days,
      trainingDays: summary.trainingDays,
      totalSets: summary.totalSets,
      totalVolume: summary.totalVolume,
      weeklyVolume: summary.weeklyVolume,
      muscles: muscles.muscles.filter((m) => m.weightedSets > 0),
      balance: muscles.balance,
      bodyWeight: {
        latest: bodyWeight.latest,
        change: bodyWeight.change,
        weeklyRate: bodyWeight.weeklyRate,
      },
    };

    const res = await fetchFn(ANTHROPIC_URL, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': ANTHROPIC_VERSION,
      },
      body: JSON.stringify({
        model,
        max_tokens: 700,
        system: SYSTEM_PROMPT,
        messages: [
          {
            role: 'user',
            content: `Training data (JSON):\n${JSON.stringify(context)}\n\nGive 3 to 5 short observations, then 2 or 3 suggestions for next week.`,
          },
        ],
      }),
    });
    if (!res.ok) {
      throw new BadGatewayException(`AI provider answered ${res.status}`);
    }
    const body = (await res.json()) as {
      content?: { type: string; text?: string }[];
    };
    const text = body.content?.find((c) => c.type === 'text')?.text;
    if (!text) {
      throw new BadGatewayException('AI provider sent no text');
    }
    return { advice: text, model, days, generatedAt: new Date().toISOString() };
  }
}
