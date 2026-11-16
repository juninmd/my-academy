import { describe, expect, it, vi } from 'vitest';
import { TOOLS } from '../src/tools.js';

const tool = (name) => TOOLS.find((t) => t.name === name);

describe('tools', () => {
  const api = { get: vi.fn().mockResolvedValue('got'), post: vi.fn().mockResolvedValue('posted') };
  const ctx = { api, userId: 'u1' };

  it('lists every tool once with a description', () => {
    const names = TOOLS.map((t) => t.name);
    expect(new Set(names).size).toBe(names.length);
    for (const t of TOOLS) expect(t.description.length).toBeGreaterThan(20);
  });

  it('reads the student progress endpoints', async () => {
    await tool('get_muscle_overview').handler(ctx, { days: 60 });
    expect(api.get).toHaveBeenLastCalledWith('progress/muscles', { userId: 'u1', days: 60 });

    await tool('get_progress_summary').handler(ctx, {});
    expect(api.get).toHaveBeenLastCalledWith('progress/summary', { userId: 'u1', days: undefined });

    await tool('get_body_weight').handler(ctx, {});
    expect(api.get).toHaveBeenLastCalledWith('progress/body-weight', { userId: 'u1' });

    await tool('get_exercise_progress').handler(ctx, { exerciseId: 7 });
    expect(api.get).toHaveBeenLastCalledWith('progress/exercises/7', { userId: 'u1' });

    await tool('get_exercise_suggestion').handler(ctx, { exerciseId: 7, strategy: 'triple', maxSets: 4 });
    expect(api.get).toHaveBeenLastCalledWith('progress/exercises/7/suggestion', {
      userId: 'u1',
      strategy: 'triple',
      maxSets: 4,
    });
  });

  it('joins plates and omits what is not given', async () => {
    await tool('calculate_plates').handler(ctx, { target: 100, plates: [25, 20, 2.5] });
    expect(api.get).toHaveBeenLastCalledWith('plates', { target: 100, bar: undefined, plates: '25,20,2.5' });

    await tool('calculate_plates').handler(ctx, { target: 60, bar: 20 });
    expect(api.get).toHaveBeenLastCalledWith('plates', { target: 60, bar: 20, plates: undefined });
  });

  it('lists starter plans', async () => {
    await tool('list_starter_plans').handler(ctx, {});
    expect(api.get).toHaveBeenLastCalledWith('starter-plans');
  });

  it('asks the coach with the user id', async () => {
    expect(await tool('get_coach_advice').handler(ctx, { days: 14 })).toBe('posted');
    expect(api.post).toHaveBeenLastCalledWith('coach/advice', { userId: 'u1', days: 14 });
  });
});
