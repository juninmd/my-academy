import { parseCsv } from './csv.js';

const LB_TO_KG = 0.45359237;
export interface WeighIn {
  day: string;
  weight: number;
}

const ATTR = /(\w+)="([^"]*)"/g;
const DAY = /^\d{4}-\d{2}-\d{2}$/;

const toKg = (value: number, unit: string) =>
  Math.round((unit === 'lb' ? value * LB_TO_KG : value) * 100) / 100;

/**
 * Body-mass records from an Apple Health `export.xml`. The day is the one written in the
 * record (the phone's local day), not a UTC conversion of it.
 */
export function parseAppleHealthWeights(xml: string): {
  weighIns: WeighIn[];
  skipped: number;
} {
  const weighIns: WeighIn[] = [];
  let skipped = 0;
  for (const match of xml.matchAll(/<Record\b[^>]*>/g)) {
    const attrs: Record<string, string> = {};
    for (const [, key, value] of match[0].matchAll(ATTR)) attrs[key] = value;
    if (attrs.type !== 'HKQuantityTypeIdentifierBodyMass') continue;
    const day = (attrs.startDate ?? '').slice(0, 10);
    const value = Number(attrs.value);
    if (!DAY.test(day) || !Number.isFinite(value) || value <= 0) {
      skipped++;
      continue;
    }
    weighIns.push({ day, weight: toKg(value, attrs.unit ?? 'kg') });
  }
  return { weighIns, skipped };
}

const norm = (h: string) =>
  h
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, ' ')
    .trim();
const indexOf = (keys: string[], names: string[]) => {
  for (const name of names) {
    const i = keys.indexOf(name);
    if (i !== -1) return i;
  }
  return -1;
};

/**
 * Weigh-ins from a CSV with a date and a weight column, or Strong's measurements export
 * (Measurement Type + Value; only the weight rows are read).
 */
export function parseWeightCsv(
  text: string,
  unit: 'kg' | 'lb',
): {
  weighIns: WeighIn[];
  skipped: number;
} {
  const [header, ...rows] = parseCsv(text);
  const keys = (header ?? []).map(norm);
  const date = indexOf(keys, ['date', 'start time']);
  const type = indexOf(keys, ['measurement type', 'measurement']);
  const value = indexOf(keys, [
    'value',
    'weight',
    'weight kg',
    'weight lb',
    'weight lbs',
  ]);
  if (date === -1 || value === -1)
    return { weighIns: [], skipped: rows.length };

  const headerUnit = /\blbs?\b/.test(keys[value])
    ? 'lb'
    : /\bkgs?\b/.test(keys[value])
      ? 'kg'
      : unit;
  const weighIns: WeighIn[] = [];
  let skipped = 0;
  for (const row of rows) {
    if (type !== -1 && !/weight|peso/i.test(row[type] ?? '')) continue;
    const day = (row[date] ?? '').trim().slice(0, 10);
    const weight = Number((row[value] ?? '').replace(',', '.'));
    if (!DAY.test(day) || !Number.isFinite(weight) || weight <= 0) {
      skipped++;
      continue;
    }
    weighIns.push({ day, weight: toKg(weight, headerUnit) });
  }
  return { weighIns, skipped };
}
