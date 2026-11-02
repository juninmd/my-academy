import {
  LB_TO_KG,
  mapColumns,
  normalizeName,
  parseCsv,
  toSets,
} from './csv.js';

const BOM = String.fromCharCode(0xfeff);

describe('parseCsv', () => {
  it('handles quoted fields, escaped quotes and CRLF', () => {
    expect(parseCsv('a,b\r\n"x, y","say ""hi"""\r\n')).toEqual([
      ['a', 'b'],
      ['x, y', 'say "hi"'],
    ]);
  });

  it('handles bare CR, LF without trailing newline, and sniffs ; and tab', () => {
    expect(parseCsv('a;b\r1;2')).toEqual([
      ['a', 'b'],
      ['1', '2'],
    ]);
    expect(parseCsv('a\tb\n1\t2')).toEqual([
      ['a', 'b'],
      ['1', '2'],
    ]);
  });

  it('drops a BOM, blank lines and keeps empty trailing fields', () => {
    expect(parseCsv(`${BOM}a,b\n\n1,\n`)).toEqual([
      ['a', 'b'],
      ['1', ''],
    ]);
  });

  it('returns nothing for empty input', () => {
    expect(parseCsv('')).toEqual([]);
  });
});

describe('mapColumns', () => {
  it('recognises Strong headers without a weight unit', () => {
    expect(
      mapColumns([
        'Date',
        'Workout Name',
        'Exercise Name',
        'Set Order',
        'Weight',
        'Reps',
        'RPE',
      ]),
    ).toEqual({
      date: 0,
      exercise: 2,
      weight: 4,
      reps: 5,
      rpe: 6,
      weightUnit: null,
    });
  });

  it('recognises Hevy headers with kilograms', () => {
    expect(
      mapColumns(['start_time', 'exercise_title', 'weight_kg', 'reps']),
    ).toEqual({
      date: 0,
      exercise: 1,
      weight: 2,
      reps: 3,
      rpe: null,
      weightUnit: 'kg',
    });
  });

  it('reads pounds from the header', () => {
    expect(
      mapColumns(['Date', 'Exercise', 'Weight (lb)', 'Reps'])?.weightUnit,
    ).toBe('lb');
    expect(
      mapColumns(['Date', 'Exercise', 'Weight lbs', 'Reps'])?.weightUnit,
    ).toBe('lb');
  });

  it('falls back to the exercise column name', () => {
    expect(mapColumns(['Date', 'Exercise', 'Weight', 'Reps'])?.exercise).toBe(
      1,
    );
  });

  it('returns null when a required column is missing', () => {
    expect(mapColumns(['Date', 'Exercise', 'Reps'])).toBeNull();
    expect(mapColumns([])).toBeNull();
  });
});

describe('toSets', () => {
  const map = {
    date: 0,
    exercise: 1,
    weight: 2,
    reps: 3,
    rpe: 4,
    weightUnit: null,
  };

  it('reads rows as sets grouped by day', () => {
    const { sets, skippedRows } = toSets(
      [
        ['2026-10-01T10:00:00Z', 'Supino', '100', '5', '8.4'],
        ['2026-10-01T10:00:00Z', 'Supino', '100,5', '5', ''],
      ],
      map,
      'kg',
    );
    expect(skippedRows).toBe(0);
    expect(sets[0]).toEqual({
      day: '2026-10-01',
      date: new Date('2026-10-01T10:00:00Z'),
      exercise: 'Supino',
      reps: 5,
      weight: 100,
      rpe: 8,
    });
    expect(sets[1]).toMatchObject({ weight: 100.5, rpe: null });
  });

  it('converts pounds when the header or the request says so', () => {
    const row = ['2026-10-01T10:00:00Z', 'Supino', '225', '5', ''];
    expect(
      toSets([row], { ...map, weightUnit: 'lb' }, 'kg').sets[0].weight,
    ).toBe(Math.round(225 * LB_TO_KG * 100) / 100);
    expect(toSets([row], map, 'lb').sets[0].weight).toBe(102.06);
    expect(
      toSets([row], { ...map, weightUnit: 'kg' }, 'lb').sets[0].weight,
    ).toBe(225);
  });

  it('keeps only sane RPE values', () => {
    const rows = ['0', '11', ''].map((rpe) => [
      '2026-10-01T10:00:00Z',
      'Supino',
      '50',
      '5',
      rpe,
    ]);
    expect(toSets(rows, map, 'kg').sets.map((s) => s.rpe)).toEqual([
      null,
      null,
      null,
    ]);
  });

  it('skips rows it cannot read', () => {
    const bad = [
      ['not a date', 'Supino', '50', '5'],
      ['2026-10-01T10:00:00Z', '  ', '50', '5'],
      ['2026-10-01T10:00:00Z', 'Supino', '', '5'],
      ['2026-10-01T10:00:00Z', 'Supino', '50', ''],
      ['2026-10-01T10:00:00Z', 'Supino', '50', '0'],
      ['2026-10-01T10:00:00Z', 'Supino', '50', '1001'],
      ['2026-10-01T10:00:00Z', 'Supino', '2001', '5'],
      ['2026-10-01T10:00:00Z', 'Supino', '-5', '5'],
      ['2026-10-01T10:00:00Z', 'Supino', 'NaN', '5'],
      [],
    ];
    const { sets, skippedRows } = toSets(bad, map, 'kg');
    expect(sets).toEqual([]);
    expect(skippedRows).toBe(bad.length);
  });

  it('leaves RPE empty when the file has no RPE column', () => {
    const { sets } = toSets(
      [['2026-10-01T10:00:00Z', 'Supino', '50', '5']],
      { ...map, rpe: null },
      'kg',
    );
    expect(sets[0].rpe).toBeNull();
  });

  it('keeps bodyweight sets with zero load', () => {
    expect(
      toSets([['2026-10-01T10:00:00Z', 'Flexão', '0', '12']], map, 'kg').sets[0]
        .weight,
    ).toBe(0);
  });
});

describe('normalizeName', () => {
  it('ignores case, accents and punctuation', () => {
    expect(normalizeName('Tríceps Corda')).toBe(normalizeName('triceps-corda'));
    expect(normalizeName('Supino (reto)')).toBe('supinoreto');
  });
});
