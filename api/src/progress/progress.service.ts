import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service.js';
import {
  dayKey,
  estimateOneRepMax,
  round,
  setVolume,
  weekStart,
  workingSets,
} from './progress.math.js';
import { suggestNext, type ProgressionOptions } from './progression.js';
import {
  balanceOf,
  MUSCLES,
  muscleWeights,
  recoveryOf,
} from '../muscles/muscles.js';

const DEFAULT_DAYS = 90;
const MAX_LOGS = 5000;
const WEEK_MS = 7 * 24 * 60 * 60 * 1000;
const DAY_MS = 24 * 60 * 60 * 1000;

@Injectable()
export class ProgressService {
  constructor(private prisma: PrismaService) {}

  async exerciseProgress(userId: string, exerciseId: number) {
    const logs = await this.prisma.exerciseLog.findMany({
      where: { userId, exerciseId },
      include: { sets: true },
      orderBy: { date: 'asc' },
      take: MAX_LOGS,
    });

    const history = logs
      .map((log) => {
        const sets = workingSets(log.sets);
        return {
          date: dayKey(log.date),
          sets: sets.length,
          volume: round(sets.reduce((sum, s) => sum + setVolume(s), 0)),
          topWeight: Math.max(0, ...sets.map((s) => s.weight)),
          estimatedOneRepMax: Math.max(
            0,
            ...sets.map((s) => estimateOneRepMax(s.weight, s.reps)),
          ),
        };
      })
      .filter((entry) => entry.sets > 0);

    const best = (key: 'topWeight' | 'estimatedOneRepMax' | 'volume') =>
      history.reduce<{ value: number; date: string } | null>(
        (acc, entry) =>
          !acc || entry[key] > acc.value
            ? { value: entry[key], date: entry.date }
            : acc,
        null,
      );

    return {
      exerciseId,
      history,
      records: {
        maxWeight: best('topWeight'),
        maxEstimatedOneRepMax: best('estimatedOneRepMax'),
        maxVolume: best('volume'),
      },
    };
  }

  async summary(userId: string, days = DEFAULT_DAYS) {
    const since = new Date(Date.now() - days * DAY_MS);
    const logs = await this.prisma.exerciseLog.findMany({
      where: { userId, date: { gte: since } },
      include: { sets: true },
      orderBy: { date: 'asc' },
      take: MAX_LOGS,
    });

    const activity = new Map<string, { sets: number; volume: number }>();
    const weekly = new Map<string, number>();
    let totalSets = 0;
    let totalVolume = 0;

    for (const log of logs) {
      const sets = workingSets(log.sets);
      const volume = sets.reduce((sum, s) => sum + setVolume(s), 0);
      const key = dayKey(log.date);
      const day = activity.get(key) ?? { sets: 0, volume: 0 };
      activity.set(key, {
        sets: day.sets + sets.length,
        volume: day.volume + volume,
      });
      const week = weekStart(log.date);
      weekly.set(week, (weekly.get(week) ?? 0) + volume);
      totalSets += sets.length;
      totalVolume += volume;
    }

    return {
      days,
      trainingDays: activity.size,
      totalSets,
      totalVolume: round(totalVolume),
      activity: [...activity].map(([date, d]) => ({
        date,
        sets: d.sets,
        volume: round(d.volume),
      })),
      weeklyVolume: [...weekly].map(([week, volume]) => ({
        weekStart: week,
        volume: round(volume),
      })),
    };
  }

  /** Weighted working sets per muscle, last hit and recovery, plus left/right balance. */
  async muscles(userId: string, days = DEFAULT_DAYS) {
    const now = Date.now();
    const logs = await this.prisma.exerciseLog.findMany({
      where: { userId, date: { gte: new Date(now - days * DAY_MS) } },
      include: { sets: true, exercise: { select: { muscles: true } } },
      orderBy: { date: 'asc' },
      take: MAX_LOGS,
    });

    const sets = new Map<string, number>();
    const lastHit = new Map<string, number>();
    for (const log of logs) {
      const count = workingSets(log.sets).length;
      if (count === 0) continue;
      for (const [muscle, weight] of muscleWeights(log.exercise.muscles)) {
        sets.set(muscle, (sets.get(muscle) ?? 0) + weight * count);
        lastHit.set(
          muscle,
          Math.max(lastHit.get(muscle) ?? 0, log.date.getTime()),
        );
      }
    }

    return {
      days,
      muscles: MUSCLES.map((muscle) => {
        const last = lastHit.get(muscle) ?? null;
        return {
          muscle,
          weightedSets: round(sets.get(muscle) ?? 0),
          lastTrained: last === null ? null : dayKey(new Date(last)),
          state: recoveryOf(last, now),
        };
      }),
      balance: balanceOf(sets),
    };
  }

  /** Weigh-ins and assessment weights, one point per day (a weigh-in wins over an assessment). */
  async bodyWeight(userId: string) {
    const [assessments, entries] = await Promise.all([
      this.prisma.assessment.findMany({
        where: { studentId: userId },
        select: { date: true, weight: true },
        orderBy: { date: 'asc' },
        take: MAX_LOGS,
      }),
      this.prisma.bodyWeightEntry.findMany({
        where: { userId },
        select: { date: true, weight: true },
        orderBy: { date: 'asc' },
        take: MAX_LOGS,
      }),
    ]);
    const byDay = new Map<string, number>();
    for (const a of assessments) byDay.set(dayKey(a.date), a.weight);
    for (const e of entries) byDay.set(dayKey(e.date), e.weight);
    const points = [...byDay]
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([date, weight]) => ({ date, weight }));

    const first = points[0];
    const last = points[points.length - 1];
    const change = first && last ? round(last.weight - first.weight) : null;
    const weeks =
      first && last
        ? (Date.parse(last.date) - Date.parse(first.date)) / WEEK_MS
        : 0;
    return {
      points,
      latest: last?.weight ?? null,
      change,
      weeklyRate: change !== null && weeks > 0 ? round(change / weeks) : null,
    };
  }

  /** Best estimated 1RM per session divided by the nearest earlier body weight. */
  async relativeStrength(userId: string, exerciseId: number) {
    const [logs, assessments] = await Promise.all([
      this.prisma.exerciseLog.findMany({
        where: { userId, exerciseId },
        include: { sets: true },
        orderBy: { date: 'asc' },
        take: MAX_LOGS,
      }),
      this.prisma.assessment.findMany({
        where: { studentId: userId },
        select: { date: true, weight: true },
        orderBy: { date: 'asc' },
        take: MAX_LOGS,
      }),
    ]);

    const points: {
      date: string;
      estimatedOneRepMax: number;
      bodyWeight: number;
      ratio: number;
    }[] = [];
    for (const log of logs) {
      const sets = workingSets(log.sets);
      if (sets.length === 0) continue;
      const bodyWeight = [...assessments]
        .reverse()
        .find((a) => a.date.getTime() <= log.date.getTime());
      if (!bodyWeight || bodyWeight.weight <= 0) continue;
      const oneRepMax = Math.max(
        ...sets.map((s) => estimateOneRepMax(s.weight, s.reps)),
      );
      points.push({
        date: dayKey(log.date),
        estimatedOneRepMax: oneRepMax,
        bodyWeight: bodyWeight.weight,
        ratio: round(oneRepMax / bodyWeight.weight),
      });
    }

    return {
      exerciseId,
      points,
      best: points.reduce<(typeof points)[number] | null>(
        (acc, p) => (!acc || p.ratio > acc.ratio ? p : acc),
        null,
      ),
    };
  }

  async suggestion(
    userId: string,
    exerciseId: number,
    options: Partial<ProgressionOptions> = {},
  ) {
    const strategy = options.strategy ?? 'double';
    const minReps = options.minReps ?? (strategy === 'linear' ? 5 : 8);
    const maxReps = Math.max(options.maxReps ?? 12, minReps);
    const logs = await this.prisma.exerciseLog.findMany({
      where: { userId, exerciseId },
      include: { sets: true },
      orderBy: { date: 'desc' },
      take: 10,
    });
    const suggestion = suggestNext(
      logs.map((log) => log.sets),
      {
        strategy,
        increment: options.increment ?? 2.5,
        minReps,
        maxReps,
        maxSets: options.maxSets,
      },
    );
    return { exerciseId, strategy, suggestion };
  }
}
