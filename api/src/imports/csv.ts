import { dayKey } from '../progress/progress.math.js';

export type WeightUnit = 'kg' | 'lb';

export interface ColumnMap {
  date: number;
  exercise: number;
  weight: number;
  reps: number;
  rpe: number | null;
  /** Unit named in the header (e.g. "Weight (lb)"), or null when unnamed. */
  weightUnit: WeightUnit | null;
}

export interface ImportedSet {
  day: string;
  date: Date;
  exercise: string;
  reps: number;
  weight: number;
  rpe: number | null;
}

export const LB_TO_KG = 0.45359237;
const MAX_REPS = 1000;
const MAX_KG = 2000;

/** RFC 4180-style parser: quoted fields, "" escapes, CRLF or LF, delimiter sniffed from line one. */
export function parseCsv(text: string): string[][] {
  const source = text.replace(/^\uFEFF/, '');
  const delimiter = detectDelimiter(source);
  const rows: string[][] = [];
  let row: string[] = [];
  let field = '';
  let quoted = false;

  for (let i = 0; i < source.length; i++) {
    const ch = source[i];
    if (quoted) {
      if (ch !== '"') {
        field += ch;
      } else if (source[i + 1] === '"') {
        field += '"';
        i++;
      } else {
        quoted = false;
      }
    } else if (ch === '"') {
      quoted = true;
    } else if (ch === delimiter) {
      row.push(field);
      field = '';
    } else if (ch === '\n' || ch === '\r') {
      if (ch === '\r' && source[i + 1] === '\n') i++;
      row.push(field);
      rows.push(row);
      row = [];
      field = '';
    } else {
      field += ch;
    }
  }
  if (field !== '' || row.length > 0) {
    row.push(field);
    rows.push(row);
  }
  return rows.filter((r) => !(r.length === 1 && r[0].trim() === ''));
}

function detectDelimiter(source: string): string {
  const firstLine = source.slice(0, source.search(/\r?\n|$/));
  let best = ',';
  let bestCount = 0;
  for (const candidate of [',', ';', '\t']) {
    const count = firstLine.split(candidate).length - 1;
    if (count > bestCount) {
      best = candidate;
      bestCount = count;
    }
  }
  return best;
}

const normalizeHeader = (header: string) =>
  header
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, ' ')
    .trim();

function findColumn(keys: string[], names: string[]): number {
  for (const name of names) {
    const index = keys.indexOf(name);
    if (index !== -1) return index;
  }
  return -1;
}

/** Recognises the headers of Strong, Hevy, FitNotes and a plain "date, exercise, weight, reps" file. */
export function mapColumns(header: string[]): ColumnMap | null {
  const keys = header.map(normalizeHeader);
  const date = findColumn(keys, ['date', 'start time', 'start date']);
  const exercise = findColumn(keys, [
    'exercise name',
    'exercise title',
    'exercise',
  ]);
  const weight = findColumn(keys, [
    'weight',
    'weight kg',
    'weight lb',
    'weight lbs',
  ]);
  const reps = findColumn(keys, ['reps', 'repetitions']);
  if (date === -1 || exercise === -1 || weight === -1 || reps === -1)
    return null;

  const weightKey = keys[weight];
  const weightUnit: WeightUnit | null = /\blbs?\b/.test(weightKey)
    ? 'lb'
    : /\bkgs?\b/.test(weightKey)
      ? 'kg'
      : null;
  const rpe = findColumn(keys, ['rpe']);
  return {
    date,
    exercise,
    weight,
    reps,
    rpe: rpe === -1 ? null : rpe,
    weightUnit,
  };
}

const numberOf = (value: string | undefined): number | null => {
  if (value === undefined || value.trim() === '') return null;
  const parsed = Number(value.trim().replace(',', '.'));
  return Number.isFinite(parsed) ? parsed : null;
};

/** Turns data rows into sets, counting the rows that cannot be read. */
export function toSets(
  rows: string[][],
  map: ColumnMap,
  unit: WeightUnit,
): { sets: ImportedSet[]; skippedRows: number } {
  const sets: ImportedSet[] = [];
  let skippedRows = 0;
  for (const row of rows) {
    const date = new Date(row[map.date] ?? '');
    const exercise = (row[map.exercise] ?? '').trim();
    const reps = numberOf(row[map.reps]);
    const rawWeight = numberOf(row[map.weight]);
    if (
      Number.isNaN(date.getTime()) ||
      exercise === '' ||
      reps === null ||
      rawWeight === null ||
      reps <= 0 ||
      reps > MAX_REPS
    ) {
      skippedRows++;
      continue;
    }
    const kilos =
      (map.weightUnit ?? unit) === 'lb' ? rawWeight * LB_TO_KG : rawWeight;
    if (kilos < 0 || kilos > MAX_KG) {
      skippedRows++;
      continue;
    }
    const rpe = map.rpe === null ? null : numberOf(row[map.rpe]);
    sets.push({
      day: dayKey(date),
      date,
      exercise,
      reps,
      weight: Math.round(kilos * 100) / 100,
      rpe: rpe !== null && rpe >= 1 && rpe <= 10 ? Math.round(rpe) : null,
    });
  }
  return { sets, skippedRows };
}

/** Matching key: lowercase, accents and punctuation removed. */
export function normalizeName(name: string): string {
  return name
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]/g, '');
}
