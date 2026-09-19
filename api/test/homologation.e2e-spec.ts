import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from './../src/app.module.js';
import { PrismaService } from '../src/prisma.service.js';
import { TelegramService } from '../src/telegram/telegram.service.js';

describe('Homologation (e2e)', () => {
  let app: INestApplication;

  const mockPrisma = {
    users: {
      findUnique: vi.fn(),
      findFirstOrThrow: vi.fn(),
      create: vi.fn(),
      findMany: vi.fn(),
      update: vi.fn(),
      delete: vi.fn(),
    },
    exercises: {
      findUnique: vi.fn(),
      create: vi.fn(),
      findMany: vi.fn(),
    },
    workoutsGroups: {
      create: vi.fn(),
      findMany: vi.fn(),
      findUnique: vi.fn(),
      findFirstOrThrow: vi.fn(),
    },
    workoutsSessions: {
      create: vi.fn(),
    },
    workoutSessions: {
      create: vi.fn(),
      findFirst: vi.fn(),
      findMany: vi.fn(),
    },
    exerciseLog: {
      create: vi.fn(),
    },
    personals: {
      create: vi.fn(),
      findMany: vi.fn(),
      findFirst: vi.fn(),
    },
    $transaction: vi.fn().mockImplementation((cb) => cb(mockPrisma)),
  };

  const mockTelegram = {
    postChannelMessage: vi.fn().mockResolvedValue({}),
  };

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(PrismaService)
      .useValue(mockPrisma)
      .overrideProvider(TelegramService)
      .useValue(mockTelegram)
      .compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(
      new ValidationPipe({ whitelist: true, transform: true }),
    );

    // Middleware to inject user for E2E tests
    app.use((req, res, next) => {
      req.user = { uid: 'user-1' };
      next();
    });

    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  describe('1. Users & Auth', () => {
    it('should create a new student', () => {
      const dto = {
        id: 'user-1',
        name: 'Student One',
        email: 'student@test.com',
        photoUrl: 'https://example.com/photo.jpg',
      };
      mockPrisma.users.findUnique.mockResolvedValue(null);
      mockPrisma.users.create.mockResolvedValue({ ...dto, role: 'STUDENT' });

      return request(app.getHttpServer())
        .post('/users')
        .send(dto)
        .expect(201)
        .expect((res) => {
          expect(res.body.role).toBe('STUDENT');
        });
    });
  });

  describe('2. Exercises', () => {
    it('should list exercises', () => {
      mockPrisma.exercises.findMany.mockResolvedValue([
        { id: 1, name: 'Supino' },
      ]);

      return request(app.getHttpServer())
        .get('/exercises')
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveLength(1);
        });
    });
  });

  describe('3. Workouts', () => {
    it('should create a workout group', () => {
      const dto = {
        name: 'Treino A',
        image: 'image.jpg',
        userId: 'user-1',
        workouts: [
          {
            exerciseId: 1,
            description: 'desc',
            workoutSeries: [{ repetitions: 12, weight: 50, rest: 60 }],
          },
        ],
      };
      mockPrisma.workoutsGroups.create.mockResolvedValue({ id: 10, ...dto });

      return request(app.getHttpServer())
        .post('/workouts-groups')
        .send(dto)
        .expect(201)
        .expect((res) => {
          expect(res.body.id).toBe(10);
        });
    });
  });

  describe('4. Sessions', () => {
    it('should register a workout session', () => {
      const dto = {
        workoutGroupId: 10,
        date: new Date().toISOString(),
      };
      mockPrisma.users.findFirstOrThrow.mockResolvedValue({
        id: 'user-1',
        telegramId: '123',
      });
      mockPrisma.workoutsGroups.findFirstOrThrow.mockResolvedValue({
        id: 10,
        name: 'Treino A',
      });
      mockPrisma.workoutsGroups.findUnique.mockResolvedValue({
        userId: 'user-1',
      });
      mockPrisma.workoutSessions.create.mockResolvedValue({ id: 100, ...dto });

      return request(app.getHttpServer())
        .post('/workouts-sessions')
        .send(dto)
        .expect(201);
    });
  });

  describe('5. Personal Trainer', () => {
    it('should let a personal trainer link a student', () => {
      const dto = {
        studentUserId: 'student-1',
        personalUserId: 'user-1',
      };
      mockPrisma.users.findUnique.mockResolvedValue({ role: 'PERSONAL' });
      mockPrisma.personals.create.mockResolvedValue({ id: 50, ...dto });

      return request(app.getHttpServer())
        .post('/personals')
        .send(dto)
        .expect(201);
    });
  });

  describe('6. Workout Summary & Sequences', () => {
    it('should return workout summary with correct sequence', async () => {
      const userId = 'user-1';
      mockPrisma.personals.findMany.mockResolvedValue([]);
      mockPrisma.personals.findFirst.mockResolvedValue(null);
      mockPrisma.workoutsGroups.findMany.mockResolvedValue([
        { id: 10, name: 'Treino A' },
      ]);

      const today = new Date();
      const yesterday = new Date();
      yesterday.setDate(today.getDate() - 1);

      mockPrisma.workoutSessions.findFirst.mockResolvedValue({
        id: 100,
        date: yesterday,
        workoutGroupId: 10,
        workoutsGroups: { id: 10, name: 'Treino A' },
      });

      mockPrisma.workoutSessions.findMany.mockResolvedValue([
        { id: 99, date: yesterday, workoutGroupId: 10 },
      ]);

      const res = await request(app.getHttpServer())
        .get(`/workouts-sessions/${userId}/summary`)
        .expect(200);

      expect(res.body.counter).toBeDefined();
    });
  });
});
