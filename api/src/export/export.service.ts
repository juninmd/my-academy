import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service.js';
import { dayKey } from '../progress/progress.math.js';

const MAX_ROWS = 20000;

export function csvCell(value: string | number | null): string {
  const text = value === null ? '' : String(value);
  return /[",\n\r]/.test(text) ? `"${text.replace(/"/g, '""')}"` : text;
}

@Injectable()
export class ExportService {
  constructor(private prisma: PrismaService) {}

  async exportJson(userId: string) {
    const [logs, assessments, workoutGroups] = await Promise.all([
      this.prisma.exerciseLog.findMany({
        where: { userId },
        include: { sets: true, exercise: { select: { name: true } } },
        orderBy: { date: 'asc' },
        take: MAX_ROWS,
      }),
      this.prisma.assessment.findMany({
        where: { studentId: userId },
        orderBy: { date: 'asc' },
        take: MAX_ROWS,
      }),
      this.prisma.workoutsGroups.findMany({
        where: { userId },
        include: {
          workouts: {
            include: {
              exercise: { select: { name: true } },
              workoutSeries: true,
            },
          },
        },
      }),
    ]);
    return {
      exportedAt: new Date().toISOString(),
      userId,
      exerciseLogs: logs,
      assessments,
      workoutGroups,
    };
  }

  async exportCsv(userId: string): Promise<string> {
    const logs = await this.prisma.exerciseLog.findMany({
      where: { userId },
      include: { sets: true, exercise: { select: { name: true } } },
      orderBy: { date: 'asc' },
      take: MAX_ROWS,
    });
    const rows = ['date,exercise,set,reps,weight,rpe,type'];
    for (const log of logs) {
      log.sets.forEach((set, index) => {
        rows.push(
          [
            dayKey(log.date),
            log.exercise.name,
            index + 1,
            set.reps,
            set.weight,
            set.rpe,
            set.type,
          ]
            .map(csvCell)
            .join(','),
        );
      });
    }
    return rows.join('\n') + '\n';
  }
}
