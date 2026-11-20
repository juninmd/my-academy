import type { Mock } from 'vitest';
import { Test, TestingModule } from '@nestjs/testing';
import { WorkoutsSessionsService } from './workouts-sessions.service.js';
import { PrismaService } from '../prisma.service.js';
import { TelegramService } from '../telegram/telegram.service.js';
import { Logger } from '@nestjs/common';
import { CreateWorkoutsSessionsDto } from './dto/create-workouts-sessions.dto.js';

describe('WorkoutsSessionsService', () => {
  let service: WorkoutsSessionsService;
  let prisma: PrismaService;
  let telegramService: TelegramService;

  beforeEach(async () => {
    const prismaMock: Record<string, unknown> = {
      users: {
        findFirstOrThrow: vi.fn(),
      },
      workoutsGroups: {
        findFirstOrThrow: vi.fn(),
        findMany: vi.fn(),
      },
      workoutSessions: {
        create: vi.fn(),
        findMany: vi.fn(),
        findFirst: vi.fn(),
        findUnique: vi.fn(),
        update: vi.fn(),
        delete: vi.fn(),
      },
      personals: {
        findMany: vi.fn(),
        findFirst: vi.fn(),
      },
    };
    prismaMock.$transaction = vi.fn((cb) => cb(prismaMock));
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        WorkoutsSessionsService,
        {
          provide: PrismaService,
          useValue: prismaMock,
        },
        {
          provide: TelegramService,
          useValue: {
            postChannelMessage: vi.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<WorkoutsSessionsService>(WorkoutsSessionsService);
    prisma = module.get<PrismaService>(PrismaService);
    telegramService = module.get<TelegramService>(TelegramService);
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    const createDto = { workoutGroupId: 1, date: new Date() };
    const userId = 'user1';

    it('should create session and send telegram if user has telegramId', async () => {
      const user = { id: userId, telegramId: '123' };
      const group = { id: 1, name: 'Legs' };
      const session = { id: 1, ...createDto };

      (prisma.users.findFirstOrThrow as Mock).mockResolvedValue(user);
      (prisma.workoutsGroups.findFirstOrThrow as Mock).mockResolvedValue(group);
      (telegramService.postChannelMessage as Mock).mockResolvedValue(undefined);
      (prisma.workoutSessions.create as Mock).mockResolvedValue(session);

      const result = await service.create(createDto as any, userId);

      expect(result).toBe(session);
      expect(telegramService.postChannelMessage).toHaveBeenCalled();
    });

    it('should not send telegram if user has no telegramId', async () => {
      const user = { id: userId, telegramId: null };
      const session = { id: 1, ...createDto };

      (prisma.users.findFirstOrThrow as Mock).mockResolvedValue(user);
      (prisma.workoutSessions.create as Mock).mockResolvedValue(session);

      await service.create(createDto as any, userId);

      expect(telegramService.postChannelMessage).not.toHaveBeenCalled();
    });

    it('should catch telegram errors', async () => {
      const user = { id: userId, telegramId: '123' };
      const group = { id: 1, name: 'Legs' };
      const session = { id: 1, ...createDto };

      (prisma.users.findFirstOrThrow as Mock).mockResolvedValue(user);
      (prisma.workoutsGroups.findFirstOrThrow as Mock).mockResolvedValue(group);
      (telegramService.postChannelMessage as Mock).mockRejectedValue(
        new Error('Telegram fail'),
      );
      (prisma.workoutSessions.create as Mock).mockResolvedValue(session);

      const loggerSpy = vi
        .spyOn(Logger.prototype, 'error')
        .mockImplementation(() => {});

      await service.create(createDto as any, userId);

      expect(telegramService.postChannelMessage).toHaveBeenCalled();
      expect(prisma.workoutSessions.create).toHaveBeenCalled();
      expect(loggerSpy).toHaveBeenCalled();
    });
  });

  describe('findAll', () => {
    it('should return sessions in a month range', async () => {
      const sessions = [{ id: 1 }];
      (prisma.workoutSessions.findMany as Mock).mockResolvedValue(sessions);

      const result = await service.findAll('user1', 2023, 1);
      expect(result).toBe(sessions);
      expect(prisma.workoutSessions.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            workoutsGroups: { userId: 'user1' },
          }),
        }),
      );
    });
  });

  describe('findSummary & calculateSequence', () => {
    const userId = 'user1';

    beforeEach(() => {
      // Default mocks
      (prisma.personals.findMany as Mock).mockResolvedValue([]);
      (prisma.personals.findFirst as Mock).mockResolvedValue(null);
      (prisma.workoutsGroups.findMany as Mock).mockResolvedValue([]);
      (prisma.workoutSessions.findFirst as Mock).mockResolvedValue(null);
      (prisma.workoutSessions.findMany as Mock).mockResolvedValue([]);
    });

    it('should return 0 streak if empty sessions', async () => {
      const result = await service.findSummary(userId);
      expect(result.counter).toBe(0);
    });

    it('should handle iAmPersonal and iAmStudent', async () => {
      (prisma.personals.findMany as Mock).mockResolvedValue([
        { StudentUser: { id: 's1' } },
      ]);
      (prisma.personals.findFirst as Mock).mockResolvedValue({
        PersonalUser: { id: 'p1' },
      });

      const result = await service.findSummary(userId);
      expect(result.students).toHaveLength(1);
      expect(result.personal).toEqual({ id: 'p1' });
    });

    it('should calculate sequence with consecutive days', async () => {
      // Mon 16, Tue 17, Wed 18 (Today is Thu 19)
      vi.useFakeTimers();
      const thursday = new Date('2023-10-19T12:00:00Z');
      vi.setSystemTime(thursday);

      const d1 = new Date('2023-10-16T12:00:00Z');
      const d2 = new Date('2023-10-17T12:00:00Z');
      const d3 = new Date('2023-10-18T12:00:00Z');

      const sequences = [{ date: d1 }, { date: d2 }, { date: d3 }];
      (prisma.workoutSessions.findMany as Mock).mockResolvedValue(sequences);

      const result = await service.findSummary(userId);
      // d1 (1), d2(2), d3(3). Gap to today is 1 day. So 3.
      expect(result.counter).toBe(3);
    });

    it('should calculate sequence across weekend (Sat -> Mon)', async () => {
      // Sat 14, Mon 16 (Today is Tue 17 to avoid same-day gap issue)
      vi.useFakeTimers();
      const tuesday = new Date('2023-10-17T12:00:00Z');
      vi.setSystemTime(tuesday);

      const d1 = new Date('2023-10-14T12:00:00Z'); // Sat
      const d2 = new Date('2023-10-16T12:00:00Z'); // Mon

      const sequences = [{ date: d1 }, { date: d2 }];
      (prisma.workoutSessions.findMany as Mock).mockResolvedValue(sequences);

      const result = await service.findSummary(userId);
      // d1(1), d2 is Mon and prev is Sat -> increment -> 2.
      // Last date Mon 16. Today Tue 17. diffDays = 1. OK.
      expect(result.counter).toBe(2);
    });

    it('should break sequence if gap is large', async () => {
      vi.useFakeTimers();
      const friday = new Date('2023-10-20T12:00:00Z');
      vi.setSystemTime(friday);

      const d1 = new Date('2023-10-01T12:00:00Z');
      const d2 = new Date('2023-10-05T12:00:00Z');

      const sequences = [{ date: d1 }, { date: d2 }];
      (prisma.workoutSessions.findMany as Mock).mockResolvedValue(sequences);

      const result = await service.findSummary(userId);
      // Gap > 1. Counter resets.
      // Also gap from last date (5th) to today (20th) is large.
      expect(result.counter).toBe(0);
    });

    it('should handle same day sequence (reset to 1)', async () => {
      vi.useFakeTimers();
      // To hit the "else { currentSequence = 1 }" block, we need diffDays != 1 AND diffDays <= 1.
      // Since diffDays = ceil(diffTime), it must be 0. So identical timestamps.
      const today = new Date('2023-10-21T09:00:00Z'); // Saturday. <24h from Friday 10:00
      vi.setSystemTime(today);

      const d1 = new Date('2023-10-20T10:00:00Z');
      const d2 = new Date('2023-10-20T10:00:00Z'); // Same time

      const sequences = [{ date: d1 }, { date: d2 }];
      (prisma.workoutSessions.findMany as Mock).mockResolvedValue(sequences);

      const result = await service.findSummary(userId);
      // i=0 -> seq=1.
      // i=1 -> diffDays=0. canIncrement=false.
      // diffDays > 1 (0>1) false.
      // else -> currentSequence = 1.
      // End loop.
      // LastDate 20th. Today 21st. diffDays=1. OK.
      expect(result.counter).toBe(1);
    });

    it('should determine correct workoutGroupOfDay', async () => {
      vi.useFakeTimers();
      const today = new Date('2023-10-20T12:00:00Z');
      vi.setSystemTime(today);

      const groups = [{ id: 1 }, { id: 2 }];
      (prisma.workoutsGroups.findMany as Mock).mockResolvedValue(groups);

      // Case 1: lastSession is yesterday, group 1. Next should be group 2.
      let lastSession = {
        id: 1,
        workoutGroupId: 1,
        date: new Date('2023-10-19T12:00:00Z'),
        workoutsGroups: groups[0],
      };
      (prisma.workoutSessions.findFirst as Mock).mockResolvedValue(lastSession);

      let result = await service.findSummary(userId);
      expect(result.workoutGroupOfDay).toBe(groups[1]);

      // Case 2: lastSession is yesterday, group 2. Next should be group 1 (loop).
      lastSession = {
        id: 1,
        workoutGroupId: 2,
        date: new Date('2023-10-19T12:00:00Z'),
        workoutsGroups: groups[1],
      };
      (prisma.workoutSessions.findFirst as Mock).mockResolvedValue(lastSession);

      result = await service.findSummary(userId);
      expect(result.workoutGroupOfDay).toBe(groups[0]);

      // Case 3: No last session -> Group 0
      (prisma.workoutSessions.findFirst as Mock).mockResolvedValue(null);
      result = await service.findSummary(userId);
      expect(result.workoutGroupOfDay).toBe(groups[0]);

      // Case 4: Last session is today -> Return that group
      lastSession = {
        id: 1,
        workoutGroupId: 2,
        date: new Date('2023-10-20T10:00:00Z'),
        workoutsGroups: groups[1],
      };
      (prisma.workoutSessions.findFirst as Mock).mockResolvedValue(lastSession);
      result = await service.findSummary(userId);
      expect(result.workoutGroupOfDay).toBe(groups[1]);
    });

    it('should ignore Sunday in calculateSequence loop', async () => {
      vi.useFakeTimers();
      const monday = new Date('2023-10-23T12:00:00Z');
      vi.setSystemTime(monday);

      // Sunday 22nd
      const sunday = new Date('2023-10-22T12:00:00Z');
      const saturday = new Date('2023-10-21T12:00:00Z');

      const sequences = [{ date: saturday }, { date: sunday }];
      (prisma.workoutSessions.findMany as Mock).mockResolvedValue(sequences);

      const result = await service.findSummary(userId);
      // Sunday is skipped in loop. Saturday is processed (i=0 -> seq=1).
      // Then loop finishes.
      // Last date is Sunday. diffTime from Mon to Sun is 1 day.

      expect(result.counter).toBe(1);
    });

    it('should maintain streak if last workout was Saturday and today is Monday (end check)', async () => {
      vi.useFakeTimers();
      const monday = new Date('2023-10-16T12:00:00Z');
      vi.setSystemTime(monday);

      const saturday = new Date('2023-10-14T12:00:00Z');
      const sequences = [{ date: saturday }];
      (prisma.workoutSessions.findMany as Mock).mockResolvedValue(sequences);

      const result = await service.findSummary(userId);

      // i=0. seq=1.
      // End loop.
      // LastDate Sat. Current Mon. diffDays=2.
      // (Sat && Mon) is True.
      // Streak maintained.
      expect(result.counter).toBe(1);
    });

    // Session dates are @db.Date, so they arrive as midnight UTC.
    const streakOn = (now: string, days: string[]) => {
      vi.useFakeTimers();
      vi.setSystemTime(new Date(now));
      (prisma.workoutSessions.findMany as Mock).mockResolvedValue(
        days.map((day) => ({ date: new Date(`${day}T00:00:00Z`) })),
      );
      return service.findSummary(userId).then((r) => r.counter);
    };

    it('keeps yesterday streak alive later in the day', async () => {
      expect(
        await streakOn('2023-10-19T16:00:00Z', ['2023-10-17', '2023-10-18']),
      ).toBe(2);
    });

    it('counts the current streak, not the best one in history', async () => {
      const oldRun = ['2023-10-02', '2023-10-03', '2023-10-04', '2023-10-05'];
      expect(
        await streakOn('2023-10-19T09:00:00Z', [
          ...oldRun,
          '2023-10-17',
          '2023-10-18',
        ]),
      ).toBe(2);
    });

    it('counts the first session after a gap', async () => {
      expect(
        await streakOn('2023-10-21T09:00:00Z', [
          '2023-10-16',
          '2023-10-19',
          '2023-10-20',
        ]),
      ).toBe(2);
    });

    it('does not count two sessions on the same day twice', async () => {
      expect(
        await streakOn('2023-10-20T18:00:00Z', [
          '2023-10-19',
          '2023-10-20',
          '2023-10-20',
        ]),
      ).toBe(2);
    });
  });

  describe('CRUD operations', () => {
    it('findOne should call prisma', async () => {
      (prisma.workoutSessions.findUnique as Mock).mockResolvedValue({
        id: 1,
      });
      await service.findOne(1);
      expect(prisma.workoutSessions.findUnique).toHaveBeenCalledWith({
        where: { id: 1 },
      });
    });

    it('update should call prisma', async () => {
      (prisma.workoutSessions.update as Mock).mockResolvedValue({ id: 1 });
      await service.update(1, { workoutGroupId: 2, date: new Date() } as any);
      expect(prisma.workoutSessions.update).toHaveBeenCalled();
    });

    it('remove should call prisma', async () => {
      (prisma.workoutSessions.delete as Mock).mockResolvedValue({ id: 1 });
      await service.remove(1);
      expect(prisma.workoutSessions.delete).toHaveBeenCalledWith({
        where: { id: 1 },
      });
    });
  });

  describe('getStartDateOfWeek and getEndDateOfWeek', () => {
    it('getStartDateOfWeek', () => {
      const date = service.getStartDateOfWeek(1);
      expect(date).toBeInstanceOf(Date);
    });
    it('getEndDateOfWeek', () => {
      const date = service.getEndDateOfWeek(1);
      expect(date).toBeInstanceOf(Date);
    });
  });

  describe('create with Workouts and sets', () => {
    beforeEach(() => {
      (prisma.exerciseLog as any) = {
        create: vi.fn(),
      };
    });

    it('should not leave a session nor notify telegram when a log fails', async () => {
      const userId = 'user1';
      const createDto: CreateWorkoutsSessionsDto = {
        date: new Date(),
        workoutGroupId: 1,
        workouts: [{ exerciseId: 10 }],
      };
      (prisma.users.findFirstOrThrow as Mock).mockResolvedValue({
        id: userId,
        telegramId: '123',
      });
      (prisma.workoutsGroups.findFirstOrThrow as Mock).mockResolvedValue({
        id: 1,
        name: 'Legs',
      });
      (prisma.workoutSessions.create as Mock).mockResolvedValue({ id: 100 });
      (prisma.exerciseLog.create as Mock).mockRejectedValue(new Error('db'));

      await expect(service.create(createDto, userId)).rejects.toThrow('db');

      expect(prisma.$transaction).toHaveBeenCalledTimes(1);
      expect(telegramService.postChannelMessage).not.toHaveBeenCalled();
    });

    it('should create session and exercise logs with sets', async () => {
      const userId = 'user1';
      const createDto: CreateWorkoutsSessionsDto = {
        date: new Date(),
        workoutGroupId: 1,
        workouts: [
          {
            exerciseId: 10,
            notes: 'Test notes',
            sets: [
              { reps: 10, weight: 50, rpe: 8, type: 'normal' },
              { reps: 8, weight: 60 },
            ],
          },
          {
            exerciseId: 0, // Should be skipped
            sets: [],
          },
        ],
      };

      const user = { id: userId, telegramId: null } as any;
      (prisma.users.findFirstOrThrow as Mock).mockResolvedValue(user);
      const session = { id: 100, date: createDto.date, workoutGroupId: 1 };
      (prisma.workoutSessions.create as Mock).mockResolvedValue(session);

      await service.create(createDto, userId);

      expect(prisma.workoutSessions.create).toHaveBeenCalledWith({
        data: {
          date: createDto.date,
          workoutGroupId: createDto.workoutGroupId,
        },
      });

      expect(prisma.exerciseLog.create).toHaveBeenCalledTimes(1);
      expect(prisma.exerciseLog.create).toHaveBeenCalledWith({
        data: {
          userId: userId,
          exerciseId: 10,
          date: createDto.date,
          notes: 'Test notes',
          sets: {
            create: [
              { reps: 10, weight: 50, rpe: 8, type: 'normal' },
              { reps: 8, weight: 60, rpe: null, type: 'normal' },
            ],
          },
        },
      });
    });

    it('should handle workouts without sets and notes', async () => {
      const userId = 'user1';
      const createDto: CreateWorkoutsSessionsDto = {
        date: new Date(),
        workoutGroupId: 1,
        workouts: [
          {
            exerciseId: 11,
          },
        ],
      };

      const user = { id: userId, telegramId: null } as any;
      (prisma.users.findFirstOrThrow as Mock).mockResolvedValue(user);
      const session = { id: 100, date: createDto.date, workoutGroupId: 1 };
      (prisma.workoutSessions.create as Mock).mockResolvedValue(session);

      await service.create(createDto, userId);

      expect(prisma.exerciseLog.create).toHaveBeenCalledTimes(1);
      expect(prisma.exerciseLog.create).toHaveBeenCalledWith({
        data: {
          userId: userId,
          exerciseId: 11,
          date: createDto.date,
          notes: '',
          sets: {
            create: [],
          },
        },
      });
    });
  });
});
