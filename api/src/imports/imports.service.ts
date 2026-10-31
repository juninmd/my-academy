import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service.js';
import { dayKey } from '../progress/progress.math.js';
import {
  ImportedSet,
  mapColumns,
  normalizeName,
  parseCsv,
  toSets,
  WeightUnit,
} from './csv.js';
import { fromExportJson } from './json.js';
import { fetchHevyWorkouts, hevyToSets } from './hevy.js';
import { parseAppleHealthWeights, parseWeightCsv } from './body-weight.js';

export const MAX_IMPORT_ROWS = 20000;
const MAX_REPORTED_NAMES = 50;
const DAY_MS = 24 * 60 * 60 * 1000;

interface Group {
  exerciseId: number;
  date: Date;
  sets: ImportedSet[];
}

@Injectable()
export class ImportsService {
  constructor(private prisma: PrismaService) {}

  /** Imports workout history from a CSV export (Strong, Hevy, FitNotes or your own file). */
  async importCsv(userId: string, csv: string, unit: WeightUnit = 'kg') {
    const [header, ...body] = parseCsv(csv);
    const map = mapColumns(header ?? []);
    if (!map) {
      throw new BadRequestException(
        'CSV needs date, exercise, weight and reps columns',
      );
    }
    if (body.length > MAX_IMPORT_ROWS) {
      throw new BadRequestException(
        `Import at most ${MAX_IMPORT_ROWS} rows at once`,
      );
    }
    const { sets, skippedRows } = toSets(body, map, unit);
    return this.importSets(userId, sets, skippedRows);
  }

  /**
   * Body weight from an Apple Health export.xml (detected by its leading "<") or a CSV.
   * One reading per day: days that already have a weigh-in are left alone.
   */
  async importBodyWeight(
    userId: string,
    text: string,
    unit: WeightUnit = 'kg',
  ) {
    const isXml = text.trimStart().startsWith('<');
    const { weighIns, skipped } = isXml
      ? parseAppleHealthWeights(text)
      : parseWeightCsv(text, unit);

    const byDay = new Map(weighIns.map((w) => [w.day, w.weight]));
    const days = [...byDay.keys()].sort();
    let fresh: { day: string; weight: number }[] = [];
    if (days.length > 0) {
      const existing = await this.prisma.bodyWeightEntry.findMany({
        where: {
          userId,
          date: {
            gte: new Date(`${days[0]}T00:00:00.000Z`),
            lte: new Date(`${days[days.length - 1]}T00:00:00.000Z`),
          },
        },
        select: { date: true },
      });
      const have = new Set(existing.map((e) => dayKey(e.date)));
      fresh = [...byDay]
        .filter(([day]) => !have.has(day))
        .map(([day, weight]) => ({ day, weight }));
    }

    if (fresh.length > 0) {
      await this.prisma.bodyWeightEntry.createMany({
        data: fresh.map((f) => ({
          userId,
          date: new Date(`${f.day}T00:00:00.000Z`),
          weight: f.weight,
        })),
      });
    }
    return {
      format: isXml ? 'apple-health' : 'csv',
      imported: fresh.length,
      skippedExisting: byDay.size - fresh.length,
      skippedRows: skipped,
    };
  }

  /** Re-imports a backup made by GET /export/json. */
  async importJson(userId: string, payload: unknown) {
    const { sets, skippedRows } = fromExportJson(payload);
    if (sets.length + skippedRows > MAX_IMPORT_ROWS) {
      throw new BadRequestException(
        `Import at most ${MAX_IMPORT_ROWS} sets at once`,
      );
    }
    return this.importSets(userId, sets, skippedRows);
  }

  /** Imports the workouts of a Hevy Pro account. The API key is not stored. */
  async importHevy(
    userId: string,
    apiKey: string,
    fetchFn?: Parameters<typeof fetchHevyWorkouts>[1],
  ) {
    const workouts = await fetchHevyWorkouts(apiKey, fetchFn);
    const { sets, skippedRows } = hevyToSets(workouts);
    return this.importSets(userId, sets, skippedRows);
  }

  /**
   * Saves sets as one log per exercise and day. Exercises are matched by name against
   * the catalogue; days that already hold a log for the exercise are left alone, so
   * importing the same file twice never duplicates anything.
   */
  private async importSets(
    userId: string,
    sets: ImportedSet[],
    skippedRows: number,
  ) {
    const catalogue = await this.prisma.exercises.findMany({
      select: { id: true, name: true },
    });
    const idByName = new Map(
      catalogue.map((e) => [normalizeName(e.name), e.id]),
    );

    const groups = new Map<string, Group>();
    const unmatched = new Set<string>();
    for (const set of sets) {
      const exerciseId = idByName.get(normalizeName(set.exercise));
      if (exerciseId === undefined) {
        unmatched.add(set.exercise);
        continue;
      }
      const key = `${set.day}|${exerciseId}`;
      const group = groups.get(key) ?? { exerciseId, date: set.date, sets: [] };
      group.sets.push(set);
      groups.set(key, group);
    }

    const existing = await this.existingKeys(userId, [...groups.values()]);
    let skippedExisting = 0;
    let importedSets = 0;
    let importedLogs = 0;
    for (const [key, group] of groups) {
      if (existing.has(key)) {
        skippedExisting++;
        continue;
      }
      await this.prisma.exerciseLog.create({
        data: {
          userId,
          exerciseId: group.exerciseId,
          date: group.date,
          sets: {
            create: group.sets.map((s) => ({
              reps: s.reps,
              weight: s.weight,
              rpe: s.rpe,
            })),
          },
        },
      });
      importedLogs++;
      importedSets += group.sets.length;
    }

    return {
      imported: { logs: importedLogs, sets: importedSets },
      skippedExisting,
      skippedRows,
      unmatchedExercises: [...unmatched].slice(0, MAX_REPORTED_NAMES),
    };
  }

  /** Keys (`day|exerciseId`) of groups the user already has a log for. */
  private async existingKeys(
    userId: string,
    groups: Group[],
  ): Promise<Set<string>> {
    if (groups.length === 0) return new Set();
    const times = groups.map((g) => g.date.getTime());
    const logs = await this.prisma.exerciseLog.findMany({
      where: {
        userId,
        exerciseId: { in: [...new Set(groups.map((g) => g.exerciseId))] },
        date: {
          gte: new Date(Math.min(...times) - DAY_MS),
          lte: new Date(Math.max(...times) + DAY_MS),
        },
      },
      select: { exerciseId: true, date: true },
    });
    return new Set(logs.map((l) => `${dayKey(l.date)}|${l.exerciseId}`));
  }
}
