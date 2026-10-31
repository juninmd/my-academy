import { z } from 'zod';

const days = z.number().int().min(1).max(365).optional();

/**
 * Each tool gets `{ api, userId }` and the validated params. Reads only, except
 * get_coach_advice, which asks the API's coach (it changes nothing).
 */
export const TOOLS = [
  {
    name: 'get_muscle_overview',
    description:
      'Weighted sets per muscle over the last N days, when each muscle was last trained, recovered or still recovering, and left/right balance (push vs pull, chest vs back, quads vs hamstrings, biceps vs triceps).',
    schema: { days },
    handler: ({ api, userId }, { days }) =>
      api.get('progress/muscles', { userId, days }),
  },
  {
    name: 'get_progress_summary',
    description: 'Training days, total sets and volume, daily activity and weekly volume over the last N days.',
    schema: { days },
    handler: ({ api, userId }, { days }) => api.get('progress/summary', { userId, days }),
  },
  {
    name: 'get_body_weight',
    description: 'Body-weight history from assessments, latest value, change and weekly rate.',
    schema: {},
    handler: ({ api, userId }) => api.get('progress/body-weight', { userId }),
  },
  {
    name: 'get_exercise_progress',
    description: 'History and records (max weight, best estimated 1RM, max volume) for one exercise.',
    schema: { exerciseId: z.number().int().positive() },
    handler: ({ api, userId }, { exerciseId }) =>
      api.get(`progress/exercises/${exerciseId}`, { userId }),
  },
  {
    name: 'get_exercise_suggestion',
    description:
      'Suggested load, reps and sets for the next session of one exercise, from its recent history (linear, double or triple progression, with a 10% deload after three stalls).',
    schema: {
      exerciseId: z.number().int().positive(),
      strategy: z.enum(['linear', 'double', 'triple']).optional(),
      maxSets: z.number().int().min(1).max(10).optional(),
    },
    handler: ({ api, userId }, { exerciseId, strategy, maxSets }) =>
      api.get(`progress/exercises/${exerciseId}/suggestion`, { userId, strategy, maxSets }),
  },
  {
    name: 'calculate_plates',
    description: 'Plates per side needed to reach a target load, using the plates the user owns.',
    schema: {
      target: z.number().positive(),
      bar: z.number().min(0).optional(),
      plates: z.array(z.number().positive()).min(1).optional(),
    },
    handler: ({ api }, { target, bar, plates }) =>
      api.get('plates', {
        target,
        bar,
        plates: plates?.join(','),
      }),
  },
  {
    name: 'list_starter_plans',
    description: 'The built-in starter plans (Push/Pull/Legs, Upper/Lower, Full Body, 5x5) and their days.',
    schema: {},
    handler: ({ api }) => api.get('starter-plans'),
  },
  {
    name: 'get_coach_advice',
    description:
      'Observations and suggestions from the server AI coach about the last N days. Needs the server to have an AI key; it changes no data.',
    schema: { days: z.number().int().min(7).max(90).optional() },
    handler: ({ api, userId }, { days }) => api.post('coach/advice', { userId, days }),
  },
];
