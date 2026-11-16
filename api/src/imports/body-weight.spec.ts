import { parseAppleHealthWeights, parseWeightCsv } from './body-weight.js';

const record = (attrs: string) => `<Record ${attrs}/>`;

describe('parseAppleHealthWeights', () => {
  it('reads body-mass records and converts pounds', () => {
    const xml = [
      '<HealthData>',
      record(
        'type="HKQuantityTypeIdentifierBodyMass" sourceName="Scale" unit="kg" startDate="2026-10-01 07:00:00 -0300" value="80.5"',
      ),
      record(
        'type="HKQuantityTypeIdentifierBodyMass" unit="lb" startDate="2026-10-02 07:00:00 +0000" value="180"',
      ),
      record(
        'type="HKQuantityTypeIdentifierBodyMass" startDate="2026-10-03 07:00:00 +0000" value="79"',
      ),
      record(
        'type="HKQuantityTypeIdentifierStepCount" unit="count" startDate="2026-10-01 07:00:00 +0000" value="9000"',
      ),
      '</HealthData>',
    ].join('\n');

    const { weighIns, skipped } = parseAppleHealthWeights(xml);

    expect(skipped).toBe(0);
    expect(weighIns).toEqual([
      { day: '2026-10-01', weight: 80.5 },
      { day: '2026-10-02', weight: 81.65 },
      { day: '2026-10-03', weight: 79 },
    ]);
  });

  it('skips records without a usable day or value', () => {
    const xml = [
      record(
        'type="HKQuantityTypeIdentifierBodyMass" startDate="nope" value="80"',
      ),
      record(
        'type="HKQuantityTypeIdentifierBodyMass" startDate="2026-10-01 07:00:00 +0000" value="0"',
      ),
      record(
        'type="HKQuantityTypeIdentifierBodyMass" startDate="2026-10-01 07:00:00 +0000" value="abc"',
      ),
    ].join('\n');
    expect(parseAppleHealthWeights(xml)).toEqual({ weighIns: [], skipped: 3 });
  });

  it('defaults to kilograms when the unit is missing', () => {
    const xml = record(
      'type="HKQuantityTypeIdentifierBodyMass" startDate="2026-10-01 07:00:00 +0000" value="70"',
    );
    expect(parseAppleHealthWeights(xml).weighIns).toEqual([
      { day: '2026-10-01', weight: 70 },
    ]);
  });
});

describe('parseWeightCsv', () => {
  it('reads a date and weight columns', () => {
    expect(
      parseWeightCsv('date,weight\n2026-10-01,80.4\n2026-10-02,\n', 'kg'),
    ).toEqual({
      weighIns: [{ day: '2026-10-01', weight: 80.4 }],
      skipped: 1,
    });
  });

  it('honours a unit named in the header and the request otherwise', () => {
    const lb = parseWeightCsv('Date,Weight lb\n2026-10-01,200\n', 'kg');
    expect(lb.weighIns).toEqual([{ day: '2026-10-01', weight: 90.72 }]);
    const requestedLb = parseWeightCsv('date,weight\n2026-10-01,200\n', 'lb');
    expect(requestedLb.weighIns).toEqual([
      { day: '2026-10-01', weight: 90.72 },
    ]);
  });

  it('reads only the weight rows of a Strong measurements export', () => {
    const csv = [
      'Date,Measurement Type,Value',
      '2026-10-01 08:00:00,Body Weight,80,5',
      '2026-10-01 08:00:00,Waist,90',
      '2026-10-02 08:00:00,Peso,79',
    ].join('\n');
    expect(parseWeightCsv(csv, 'kg').weighIns).toEqual([
      { day: '2026-10-01', weight: 80 },
      { day: '2026-10-02', weight: 79 },
    ]);
  });

  it('counts every row as skipped without a date or weight column', () => {
    expect(parseWeightCsv('a,b\n1,2\n3,4\n', 'kg')).toEqual({
      weighIns: [],
      skipped: 2,
    });
  });

  it('skips a row with a decimal comma and no weight', () => {
    expect(
      parseWeightCsv('date,weight\n2026-10-01,80,4\n', 'kg').weighIns,
    ).toEqual([{ day: '2026-10-01', weight: 80 }]);
  });
});

describe('parser edge cases', () => {
  it('skips an Apple record without a start date', () => {
    const xml = record('type="HKQuantityTypeIdentifierBodyMass" value="80"');
    expect(parseAppleHealthWeights(xml)).toEqual({ weighIns: [], skipped: 1 });
  });

  it('reads kilograms named in the header and tolerates short rows', () => {
    expect(
      parseWeightCsv('date,weight kg\n2026-10-01,80\n', 'lb').weighIns,
    ).toEqual([{ day: '2026-10-01', weight: 80 }]);
    expect(
      parseWeightCsv('Date,Measurement Type,Value\n2026-10-01\n', 'kg'),
    ).toEqual({
      weighIns: [],
      skipped: 0,
    });
    expect(parseWeightCsv('date,weight\n2026-10-01\n', 'kg')).toEqual({
      weighIns: [],
      skipped: 1,
    });
  });
});

describe('parser empty input', () => {
  it('reads nothing from empty text and from a weight row without a value', () => {
    expect(parseWeightCsv('', 'kg')).toEqual({ weighIns: [], skipped: 0 });
    expect(
      parseWeightCsv('Date,Measurement Type,Value\n2026-10-01,Weight\n', 'kg'),
    ).toEqual({
      weighIns: [],
      skipped: 1,
    });
  });
});

describe('parser short rows', () => {
  it('counts a row that stops before the date column', () => {
    expect(parseWeightCsv('weight,date\n80\n', 'kg')).toEqual({
      weighIns: [],
      skipped: 1,
    });
  });
});
