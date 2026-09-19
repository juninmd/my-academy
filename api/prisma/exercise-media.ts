// Exercise images come from yuhonas/free-exercise-db (Unlicense, public
// domain) and are served from object storage, not bundled in the app.
export const EXERCISE_MEDIA_BASE_URL =
  process.env.EXERCISE_MEDIA_BASE_URL ??
  'https://br-se1.magaluobjects.com/fast-dl-cs/my-academy/exercises/v1';

export const FREE_EXERCISE_DB_RAW =
  'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises';

interface ExerciseMedia {
  slug: string;
  /** free-exercise-db exercise id (folder with 0.jpg and 1.jpg). */
  source: string;
}

export const EXERCISE_MEDIA: Record<string, ExerciseMedia> = {
  'Crucifixo Reto': { slug: 'crucifixo-reto', source: 'Dumbbell_Flyes' },
  'Supino com halteres': {
    slug: 'supino-halteres',
    source: 'Dumbbell_Bench_Press',
  },
  'Supino inclinado com barra': {
    slug: 'supino-inclinado-barra',
    source: 'Barbell_Incline_Bench_Press_-_Medium_Grip',
  },
  'Crucifixo Inclinado Com Halteres': {
    slug: 'crucifixo-inclinado-halteres',
    source: 'Incline_Dumbbell_Flyes',
  },
  'Tríceps Testa Barra W': {
    slug: 'triceps-testa-barra-w',
    source: 'EZ-Bar_Skullcrusher',
  },
  'Desenvolvimento com halteres': {
    slug: 'desenvolvimento-halteres',
    source: 'Dumbbell_Shoulder_Press',
  },
  'Elevação Frontal': {
    slug: 'elevacao-frontal',
    source: 'Front_Dumbbell_Raise',
  },
  'Remada Alta': { slug: 'remada-alta', source: 'Upright_Barbell_Row' },
  'Elevação lateral': {
    slug: 'elevacao-lateral',
    source: 'Side_Lateral_Raise',
  },
  'Rosca de bíceps com barra W': {
    slug: 'rosca-biceps-barra-w',
    source: 'EZ-Bar_Curl',
  },
  'Rosca Concentrada': {
    slug: 'rosca-concentrada',
    source: 'Concentration_Curls',
  },
  'Rosca de martelo alternada': {
    slug: 'rosca-martelo-alternada',
    source: 'Alternate_Hammer_Curl',
  },
  'Tríceps Barra (polia alta)': {
    slug: 'triceps-barra-polia-alta',
    source: 'Triceps_Pushdown',
  },
  'Tríceps Corda': {
    slug: 'triceps-corda',
    source: 'Triceps_Pushdown_-_Rope_Attachment',
  },
  'Tríceps Francês Halteres': {
    slug: 'triceps-frances-halteres',
    source: 'Standing_Dumbbell_Triceps_Extension',
  },
  'Cadeira Extensora': { slug: 'cadeira-extensora', source: 'Leg_Extensions' },
  'Leg Pres': { slug: 'leg-press', source: 'Leg_Press' },
  'Adutor de Coxas': { slug: 'adutor-coxas', source: 'Thigh_Adductor' },
  Hack: { slug: 'hack', source: 'Hack_Squat' },
  'Mesa Flexora': { slug: 'mesa-flexora', source: 'Lying_Leg_Curls' },
  'Cadeira Flexora': { slug: 'cadeira-flexora', source: 'Seated_Leg_Curl' },
  'Flexora em pé unilateral (Vertical)': {
    slug: 'flexora-em-pe-unilateral',
    source: 'Standing_Leg_Curl',
  },
  // free-exercise-db has no kettlebell front raise; same movement pattern.
  'Elevação Frontal com Kettlebel': {
    slug: 'elevacao-frontal-kettlebell',
    source: 'Front_Plate_Raise',
  },
  'Abdução de Quadril Máquina': {
    slug: 'abducao-quadril-maquina',
    source: 'Thigh_Abductor',
  },
  'Elevação de Quadril com Step': {
    slug: 'elevacao-quadril-step',
    source: 'Barbell_Hip_Thrust',
  },
};

export function exerciseImage(name: string): string {
  const media = EXERCISE_MEDIA[name];
  if (!media) throw new Error(`No media mapped for exercise "${name}"`);
  return `${EXERCISE_MEDIA_BASE_URL}/${media.slug}.webp`;
}
