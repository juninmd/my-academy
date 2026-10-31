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

const DEFAULT_DAYS = 90;
const MAX_LOGS = 5000;

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
    const since = new Date(Date.now() - days * 24 * 60 * 60 * 1000);
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

  async bodyWeight(userId: string) {
    const assessments = await this.prisma.assessment.findMany({
      where: { studentId: userId },
      select: { date: true, weight: true },
      orderBy: { date: 'asc' },
      take: MAX_LOGS,
    });
    const points = assessments.map((a) => ({
      date: dayKey(a.date),
      weight: a.weight,
    }));
    const first = points[0];
    const latest = points[points.length - 1];
    return {
      points,
      latest: latest?.weight ?? null,
      change: first && latest ? round(latest.weight - first.weight) : null,
    };
  }
}
