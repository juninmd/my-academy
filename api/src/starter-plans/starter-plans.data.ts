export interface PlanSlot {
  /** Catalog names are matched case-insensitively by any of these terms. */
  terms: string[];
  sets: number;
  reps: number;
  rest: number;
}

export interface PlanDay {
  name: string;
  slots: PlanSlot[];
}

export interface StarterPlan {
  key: string;
  name: string;
  description: string;
  days: PlanDay[];
}

const slot = (
  terms: string[],
  sets: number,
  reps: number,
  rest = 90,
): PlanSlot => ({ terms, sets, reps, rest });

const PUSH = [
  slot(['supino'], 4, 8),
  slot(['desenvolvimento'], 3, 10),
  slot(['elevação lateral'], 3, 12, 60),
  slot(['tríceps'], 3, 12, 60),
];
const PULL = [
  slot(['puxada', 'barra fixa'], 4, 8),
  slot(['remada'], 3, 10),
  slot(['crucifixo inverso', 'face pull'], 3, 12, 60),
  slot(['rosca'], 3, 12, 60),
];
const LEGS = [
  slot(['agachamento'], 4, 8, 120),
  slot(['leg press'], 3, 10),
  slot(['stiff', 'mesa flexora', 'flexora'], 3, 10),
  slot(['panturrilha', 'gêmeos'], 4, 15, 60),
];

export const STARTER_PLANS: StarterPlan[] = [
  {
    key: 'ppl',
    name: 'Push/Pull/Legs',
    description: 'Three days: push, pull and legs.',
    days: [
      { name: 'Push', slots: PUSH },
      { name: 'Pull', slots: PULL },
      { name: 'Legs', slots: LEGS },
    ],
  },
  {
    key: 'upper-lower',
    name: 'Upper/Lower',
    description: 'Two days alternating upper and lower body.',
    days: [
      { name: 'Upper', slots: [...PUSH.slice(0, 2), ...PULL.slice(0, 2)] },
      { name: 'Lower', slots: LEGS },
    ],
  },
  {
    key: 'full-body',
    name: 'Full Body',
    description: 'One full-body session to repeat three times a week.',
    days: [
      {
        name: 'Full Body',
        slots: [PUSH[0], PULL[0], LEGS[0], PUSH[1], PULL[1]],
      },
    ],
  },
  {
    key: '5x5',
    name: '5x5',
    description: 'Strength base: five sets of five on the big lifts.',
    days: [
      {
        name: '5x5',
        slots: [
          slot(['agachamento'], 5, 5, 180),
          slot(['supino'], 5, 5, 180),
          slot(['remada'], 5, 5, 180),
        ],
      },
    ],
  },
];
